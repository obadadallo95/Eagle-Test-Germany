import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../domain/entities/question.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/storage/hive_service.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final String? selectedAnswerId;
  final String? translationLangCode; // Language code for translation (e.g., 'ar', 'tr', 'uk', 'ru', 'en')
  final bool isAnswerChecked; // To show correct/wrong colors
  final Function(String) onAnswerSelected;
  final VoidCallback onToggleTranslation;
  final VoidCallback onPlayAudio;
  final VoidCallback? onShowAiExplanation; // Callback to show AI explanation

  const QuestionCard({
    super.key,
    required this.question,
    this.selectedAnswerId,
    this.translationLangCode, // null = hide translation, non-null = show translation in this language
    required this.isAnswerChecked,
    required this.onAnswerSelected,
    required this.onToggleTranslation,
    required this.onPlayAudio,
    this.onShowAiExplanation, // Optional callback for AI explanation
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = HiveService.isFavorite(widget.question.id);
  }

  Future<void> _toggleFavorite() async {
    final newValue = !_isFavorite;
    setState(() {
      _isFavorite = newValue;
    });

    if (newValue) {
      await HiveService.addFavorite(widget.question.id);
    } else {
      await HiveService.removeFavorite(widget.question.id);
    }
    
    // Notify parent if callback is provided (for favorites screen refresh)
    // This will be handled by the screen's refresh mechanism
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question Section
        Card(
          elevation: 4,
          color: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(
              color: primaryGold.withValues(alpha: 0.3),
              width: 1.w,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Support
                if (widget.question.image != null && widget.question.image!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.asset(
                      widget.question.image!,
                      fit: BoxFit.contain,
                      height: 200.h,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200.h,
                          color: Colors.grey.shade800,
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey.shade600,
                            size: 48.sp,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
                // German Question Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "Question (DE)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade400,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: _isFavorite ? Colors.pink : Colors.grey,
                            size: 24.sp,
                          ),
                          onPressed: _toggleFavorite,
                          tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                AutoSizeText(
                  widget.question.getText('de'),
                  style: AppTypography.h3.copyWith(
                    height: 1.3,
                    color: textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  minFontSize: 10,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.translationLangCode != null && widget.translationLangCode != 'de') ...[
                  Divider(height: 32.h),
                  Directionality(
                    textDirection: widget.translationLangCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                    child: AutoSizeText(
                      widget.question.getText(widget.translationLangCode!),
                      style: AppTypography.bodyM.copyWith(
                        color: textSecondary,
                      ),
                      textAlign: widget.translationLangCode == 'ar' ? TextAlign.right : TextAlign.left,
                      minFontSize: 10,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                SizedBox(height: 16.h),
                // Action buttons row: Play Audio, Translation, AI Tutor
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Play Audio Button
                    IconButton(
                      icon: Icon(
                        Icons.volume_up,
                        color: primaryGold,
                        size: 24.sp,
                      ),
                      onPressed: widget.onPlayAudio,
                      tooltip: l10n.playAudio,
                    ),
                    // Translation Toggle Button
                    IconButton(
                      icon: Icon(
                        widget.translationLangCode != null
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: primaryGold,
                        size: 24.sp,
                      ),
                      onPressed: widget.onToggleTranslation,
                      tooltip: widget.translationLangCode != null
                          ? l10n.hideArabic
                          : l10n.showArabic,
                    ),
                    // AI Tutor Button (if callback provided)
                    if (widget.onShowAiExplanation != null)
                      IconButton(
                        icon: Icon(
                          Icons.auto_awesome,
                          color: primaryGold,
                          size: 24.sp,
                        ),
                        onPressed: widget.onShowAiExplanation!,
                        tooltip: l10n.explainWithAi,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24.h),
        
        // Answers Section
        ...widget.question.answers.map((answer) {
          final isSelected = widget.selectedAnswerId == answer.id;
          Color cardColor = surfaceColor;
          Color textColor = textPrimary;
          Color borderColorSelected = primaryGold;
          Color borderColorUnselected = isDark ? Colors.grey.shade700 : AppColors.lightBorder;
          Color avatarBgSelected = primaryGold;
          Color avatarBgUnselected = isDark ? Colors.grey.shade700 : AppColors.lightTextTertiary;
          Color avatarTextSelected = isDark ? AppColors.darkBg : AppColors.lightTextPrimary;
          Color avatarTextUnselected = isDark ? Colors.white : AppColors.lightTextPrimary;
          
          if (isSelected) {
            cardColor = primaryGold.withValues(alpha: isDark ? 0.2 : 0.15);
            // Correct/Wrong logic would go here if we were showing immediate feedback
          }

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: InkWell(
              onTap: () => widget.onAnswerSelected(answer.id),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: cardColor,
                  border: Border.all(
                    color: isSelected ? borderColorSelected : borderColorUnselected,
                    width: isSelected ? 2.w : 1.w,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: isSelected ? avatarBgSelected : avatarBgUnselected,
                      child: Text(
                        answer.id,
                        style: AppTypography.bodyM.copyWith(
                          color: isSelected ? avatarTextSelected : avatarTextUnselected,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            answer.getText('de'),
                            style: AppTypography.bodyL.copyWith(
                              color: textColor,
                            ),
                            minFontSize: 10,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.translationLangCode != null && widget.translationLangCode != 'de')
                            Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Directionality(
                                textDirection: widget.translationLangCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                child: AutoSizeText(
                                  answer.getText(widget.translationLangCode!),
                                  style: AppTypography.bodyM.copyWith(
                                    color: textSecondary,
                                  ),
                                  textAlign: widget.translationLangCode == 'ar' ? TextAlign.right : TextAlign.left,
                                  minFontSize: 10,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

}
