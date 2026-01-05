import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../domain/entities/question.dart';
import '../../core/theme/app_colors.dart';
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
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question Section
        Card(
          elevation: 4,
          color: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(
              color: AppColors.eagleGold.withValues(alpha: 0.3),
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
                        IconButton(
                          icon: Icon(Icons.volume_up, color: AppColors.eagleGold, size: 24.sp),
                          onPressed: widget.onPlayAudio,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                AutoSizeText(
                  widget.question.getText('de'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    color: Colors.white,
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: widget.translationLangCode == 'ar' ? TextAlign.right : TextAlign.left,
                      minFontSize: 10,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                SizedBox(height: 16.h),
                // Translation and AI Tutor buttons row
                Row(
                  children: [
                    // Translation Button
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        icon: Icons.translate,
                        label: widget.translationLangCode != null 
                            ? l10n.hideArabic
                            : l10n.showArabic,
                        onPressed: widget.onToggleTranslation,
                        color: Colors.blue,
                        isActive: widget.translationLangCode != null,
                      ),
                    ),
                    // AI Tutor Button (if callback provided)
                    if (widget.onShowAiExplanation != null) ...[
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildActionButton(
                          context: context,
                          icon: Icons.auto_awesome,
                          label: l10n.explainWithAi,
                          onPressed: widget.onShowAiExplanation!,
                          color: AppColors.eagleGold,
                          isActive: false,
                        ),
                      ),
                    ],
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
          Color cardColor = AppColors.darkSurface;
          Color textColor = Colors.white;
          
          if (isSelected) {
            cardColor = AppColors.eagleGold.withValues(alpha: 0.2);
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
                    color: isSelected ? AppColors.eagleGold : Colors.grey.shade700,
                    width: isSelected ? 2.w : 1.w,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: isSelected ? AppColors.eagleGold : Colors.grey.shade700,
                      child: Text(
                        answer.id,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
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
                            style: TextStyle(
                              fontSize: 16.sp,
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
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14.sp,
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

  /// بناء زر إجراء جميل مع أيقونة ووصف واضح
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    required bool isActive,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isActive
                  ? [color.withValues(alpha: 0.2), color.withValues(alpha: 0.15)]
                  : [color.withValues(alpha: 0.15), color.withValues(alpha: 0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isActive ? color : color.withValues(alpha: 0.4),
              width: 1.5.w,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 18.sp,
                  color: color,
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
