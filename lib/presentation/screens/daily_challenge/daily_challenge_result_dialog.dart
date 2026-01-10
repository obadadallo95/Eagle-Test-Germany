import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// -----------------------------------------------------------------
/// 🏆 DAILY CHALLENGE RESULT DIALOG / ERGEBNIS DIALOG / حوار نتيجة التحدي
/// -----------------------------------------------------------------
/// Gamified result dialog with encouraging messages
/// حوار النتيجة مع رسائل تشجيعية
/// -----------------------------------------------------------------
class DailyChallengeResultDialog extends ConsumerStatefulWidget {
  final int score;
  final int correctCount;
  final int totalQuestions;
  final int timeSeconds;

  const DailyChallengeResultDialog({
    super.key,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.timeSeconds,
  });

  @override
  ConsumerState<DailyChallengeResultDialog> createState() => _DailyChallengeResultDialogState();
}

class _DailyChallengeResultDialogState extends ConsumerState<DailyChallengeResultDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _trophyController;
  late Animation<double> _trophyScaleAnimation;
  late Animation<double> _trophyRotationAnimation;

  @override
  void initState() {
    super.initState();
    _trophyController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _trophyScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0).chain(
          CurveTween(curve: Curves.easeInBack),
        ),
        weight: 50,
      ),
    ]).animate(_trophyController);

    _trophyRotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(
      CurvedAnimation(
        parent: _trophyController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation
    _trophyController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _trophyController.dispose();
    super.dispose();
  }

  String _getEncouragingMessage(int percentage, AppLocalizations? l10n) {
    if (percentage >= 90) {
      return '🌟 ${l10n?.challengeExcellent ?? 'Excellent! You\'re a master!'}';
    } else if (percentage >= 70) {
      return '🎉 ${l10n?.challengeGreat ?? 'Great job! Keep it up!'}';
    } else if (percentage >= 50) {
      return '👍 ${l10n?.challengeGood ?? 'Good effort! Practice makes perfect!'}';
    } else {
      return '💪 ${l10n?.challengeKeepGoing ?? 'Keep going! Every mistake is a lesson!'}';
    }
  }

  String _getEmoji(int percentage) {
    if (percentage >= 90) {
      return '🏆';
    } else if (percentage >= 70) {
      return '⭐';
    } else if (percentage >= 50) {
      return '👍';
    } else {
      return '💪';
    }
  }

  Color _getScoreColor(int percentage, bool isDark) {
    if (percentage >= 90) {
      return isDark ? AppColors.gold : AppColors.goldDark;
    } else if (percentage >= 70) {
      return isDark ? AppColors.successDark : AppColors.successLight;
    } else if (percentage >= 50) {
      return isDark ? AppColors.infoDark : AppColors.infoLight;
    } else {
      return isDark ? AppColors.warningDark : AppColors.warningLight;
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    }
    return '${remainingSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    
    final l10n = AppLocalizations.of(context);
    final percentage = (widget.correctCount / widget.totalQuestions * 100).round();
    final encouragingMessage = _getEncouragingMessage(percentage, l10n);
    final emoji = _getEmoji(percentage);
    final scoreColor = _getScoreColor(percentage, isDark);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.xl),
      child: FadeInUp(
        duration: const Duration(milliseconds: 500),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      surfaceColor,
                      bgColor,
                      surfaceColor,
                    ]
                  : [
                      surfaceColor,
                      surfaceColor.withValues(alpha: 0.95),
                      surfaceColor,
                    ],
            ),
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(
              color: scoreColor.withValues(alpha: 0.6),
              width: 2.5.w,
            ),
            boxShadow: [
              BoxShadow(
                color: scoreColor.withValues(alpha: isDark ? 0.4 : 0.25),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 8),
              ),
              if (isDark)
                BoxShadow(
                  color: AppColors.darkBg.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trophy Icon with Animation
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: AnimatedBuilder(
                    animation: _trophyController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _trophyScaleAnimation.value,
                        child: Transform.rotate(
                          angle: _trophyRotationAnimation.value,
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  scoreColor.withValues(alpha: 0.3),
                                  scoreColor.withValues(alpha: 0.2),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: scoreColor.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Text(
                              emoji,
                              style: TextStyle(fontSize: 72.sp),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FadeInDown(
                  duration: const Duration(milliseconds: 700),
                  child: Text(
                    l10n?.challengeCompleted ?? 'Challenge Completed!',
                    style: AppTypography.h1.copyWith(
                      fontSize: 26.sp,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    encouragingMessage,
                    style: AppTypography.bodyL.copyWith(
                      fontSize: 17.sp,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Score Card
                FadeInUp(
                  duration: const Duration(milliseconds: 900),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scoreColor.withValues(alpha: 0.25),
                          scoreColor.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: scoreColor.withValues(alpha: 0.6),
                        width: 2.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: scoreColor.withValues(alpha: isDark ? 0.3 : 0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Score
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    scoreColor.withValues(alpha: 0.4),
                                    scoreColor.withValues(alpha: 0.3),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.stars,
                                color: scoreColor,
                                size: 36.sp,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              '${widget.score}',
                              style: AppTypography.h1.copyWith(
                                fontSize: 42.sp,
                                color: scoreColor,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              ' ${l10n?.points ?? 'points'}',
                              style: AppTypography.bodyL.copyWith(
                                fontSize: 20.sp,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Container(
                          height: 1.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                isDark 
                                    ? AppColors.darkTextPrimary.withValues(alpha: 0.24)
                                    : AppColors.lightTextTertiary,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        // Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              icon: Icons.check_circle,
                              value: '${widget.correctCount}/${widget.totalQuestions}',
                              label: l10n?.correct ?? 'Correct',
                              color: AppColors.successDark,
                              isDark: isDark,
                            ),
                            _buildStatItem(
                              icon: Icons.percent,
                              value: '$percentage%',
                              label: l10n?.accuracy ?? 'Accuracy',
                              color: scoreColor,
                              isDark: isDark,
                            ),
                            _buildStatItem(
                              icon: Icons.timer,
                              value: _formatTime(widget.timeSeconds),
                              label: l10n?.time ?? 'Time',
                              color: AppColors.infoDark,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Action Button
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryGold,
                          primaryGold.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: primaryGold.withValues(alpha: isDark ? 0.4 : 0.25),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(); // Exit challenge screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n?.done ?? 'Done',
                        style: AppTypography.h2.copyWith(
                          fontSize: 20.sp,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.2),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28.sp),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppTypography.h2.copyWith(
            fontSize: 20.sp,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.bodyS.copyWith(
            fontSize: 13.sp,
            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
          ),
        ),
      ],
    );
  }
}

