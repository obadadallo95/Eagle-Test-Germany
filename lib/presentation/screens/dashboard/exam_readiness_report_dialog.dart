import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../domain/entities/exam_readiness_report.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';

/// Dialog to display detailed Exam Readiness Report
class ExamReadinessReportDialog extends StatelessWidget {
  final ExamReadinessReport report;

  const ExamReadinessReportDialog({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          primaryGold.withValues(alpha: 0.3),
                          primaryGold.withValues(alpha: 0.1),
                        ]
                      : [
                          primaryGold.withValues(alpha: 0.2),
                          primaryGold.withValues(alpha: 0.05),
                        ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(report.status),
                    color: primaryGold,
                    size: 32.sp,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          l10n?.examReadinessReport ?? 'Exam Readiness Report',
                          style: AppTypography.h2.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                        ),
                        SizedBox(height: 4.h),
                        AutoSizeText(
                          _getStatusText(report.status, l10n),
                          style: AppTypography.bodyM.copyWith(
                            color: primaryGold,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overall Score
                    _buildScoreCard(
                      context: context,
                      title: l10n?.overallScore ?? 'Overall Score',
                      score: report.overallScore,
                      isDark: isDark,
                      primaryGold: primaryGold,
                      surfaceColor: surfaceColor,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Component Scores
                    _buildComponentScores(
                      context: context,
                      report: report,
                      isDark: isDark,
                      primaryGold: primaryGold,
                      surfaceColor: surfaceColor,
                      l10n: l10n,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Statistics
                    _buildStatistics(
                      context: context,
                      statistics: report.statistics,
                      isDark: isDark,
                      primaryGold: primaryGold,
                      surfaceColor: surfaceColor,
                      l10n: l10n,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Strengths
                    if (report.strengths.isNotEmpty) ...[
                      _buildSectionHeader(
                        context: context,
                        title: l10n?.strengths ?? 'Strengths',
                        icon: Icons.check_circle,
                        color: AppColors.successDark,
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...report.strengths.map((strength) => _buildReportItem(
                            context: context,
                            item: strength,
                            isDark: isDark,
                            primaryGold: primaryGold,
                            surfaceColor: surfaceColor,
                            isPositive: true,
                          )),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Weaknesses
                    if (report.weaknesses.isNotEmpty) ...[
                      _buildSectionHeader(
                        context: context,
                        title: l10n?.weaknesses ?? 'Weaknesses',
                        icon: Icons.warning,
                        color: AppColors.warningDark,
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...report.weaknesses.map((weakness) => _buildReportItem(
                            context: context,
                            item: weakness,
                            isDark: isDark,
                            primaryGold: primaryGold,
                            surfaceColor: surfaceColor,
                            isPositive: false,
                          )),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Recommendations
                    if (report.recommendations.isNotEmpty) ...[
                      _buildSectionHeader(
                        context: context,
                        title: l10n?.recommendations ?? 'Recommendations',
                        icon: Icons.lightbulb,
                        color: primaryGold,
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...report.recommendations.map((recommendation) => _buildRecommendation(
                            context: context,
                            text: recommendation,
                            isDark: isDark,
                            primaryGold: primaryGold,
                            surfaceColor: surfaceColor,
                          )),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard({
    required BuildContext context,
    required String title,
    required double score,
    required bool isDark,
    required Color primaryGold,
    required Color surfaceColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  primaryGold.withValues(alpha: 0.2),
                  primaryGold.withValues(alpha: 0.1),
                ]
              : [
                  primaryGold.withValues(alpha: 0.15),
                  primaryGold.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: primaryGold.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          AutoSizeText(
            title,
            style: AppTypography.bodyM.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: AppSpacing.sm),
          AutoSizeText(
            '${score.toStringAsFixed(1)}%',
            style: AppTypography.h1.copyWith(
              color: primaryGold,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildComponentScores({
    required BuildContext context,
    required ExamReadinessReport report,
    required bool isDark,
    required Color primaryGold,
    required Color surfaceColor,
    required AppLocalizations? l10n,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          l10n?.componentScores ?? 'Component Scores',
          style: AppTypography.h3.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildScoreBar(
          context: context,
          label: l10n?.questionMastery ?? 'Question Mastery',
          score: report.masteryScore,
          isDark: isDark,
          primaryGold: primaryGold,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildScoreBar(
          context: context,
          label: l10n?.examPerformance ?? 'Exam Performance',
          score: report.examScore,
          isDark: isDark,
          primaryGold: primaryGold,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildScoreBar(
          context: context,
          label: l10n?.studyConsistency ?? 'Study Consistency',
          score: report.consistencyScore,
          isDark: isDark,
          primaryGold: primaryGold,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildScoreBar(
          context: context,
          label: l10n?.stateQuestions ?? 'State Questions',
          score: report.stateScore,
          isDark: isDark,
          primaryGold: primaryGold,
        ),
      ],
    );
  }

  Widget _buildScoreBar({
    required BuildContext context,
    required String label,
    required double score,
    required bool isDark,
    required Color primaryGold,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: AutoSizeText(
            label,
            style: AppTypography.bodyS.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            maxLines: 1,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: score / 100.0,
              backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(primaryGold),
              minHeight: 8.h,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 50.w,
          child: AutoSizeText(
            '${score.toStringAsFixed(0)}%',
            style: AppTypography.bodyS.copyWith(
              color: primaryGold,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics({
    required BuildContext context,
    required ReportStatistics statistics,
    required bool isDark,
    required Color primaryGold,
    required Color surfaceColor,
    required AppLocalizations? l10n,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            l10n?.statistics ?? 'Statistics',
            style: AppTypography.h3.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildStatRow(
            context: context,
            label: l10n?.questionsAnswered ?? 'Questions Answered',
            value: statistics.totalQuestionsAnswered.toString(),
            isDark: isDark,
          ),
          _buildStatRow(
            context: context,
            label: l10n?.questionsMastered ?? 'Questions Mastered',
            value: statistics.questionsMastered.toString(),
            isDark: isDark,
          ),
          _buildStatRow(
            context: context,
            label: l10n?.correctAnswers ?? 'Correct Answers',
            value: statistics.correctAnswers.toString(),
            isDark: isDark,
          ),
          _buildStatRow(
            context: context,
            label: l10n?.examsCompleted ?? 'Exams Completed',
            value: '${statistics.examsPassed}/${statistics.totalExams}',
            isDark: isDark,
          ),
          _buildStatRow(
            context: context,
            label: l10n?.currentStreak ?? 'Current Streak',
            value: '${statistics.currentStreak} ${l10n?.days ?? 'days'}',
            isDark: isDark,
          ),
          _buildStatRow(
            context: context,
            label: l10n?.studySessionsLast7Days ?? 'Study Sessions (Last 7 Days)',
            value: statistics.studySessionsLast7Days.toString(),
            isDark: isDark,
          ),
          _buildStatRow(
            context: context,
            label: l10n?.totalStudyTime ?? 'Total Study Time',
            value: '${statistics.totalStudyHours.toStringAsFixed(1)} ${l10n?.hours ?? 'hours'}',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required BuildContext context,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: AutoSizeText(
              label,
              style: AppTypography.bodyS.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              maxLines: 1,
            ),
          ),
          AutoSizeText(
            value,
            style: AppTypography.bodyM.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24.sp),
        const SizedBox(width: AppSpacing.sm),
        AutoSizeText(
          title,
          style: AppTypography.h3.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildReportItem({
    required BuildContext context,
    required ReportItem item,
    required bool isDark,
    required Color primaryGold,
    required Color surfaceColor,
    required bool isPositive,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isPositive
            ? (isDark ? AppColors.successDark.withValues(alpha: 0.1) : AppColors.successDark.withValues(alpha: 0.05))
            : (isDark ? AppColors.warningDark.withValues(alpha: 0.1) : AppColors.warningDark.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isPositive
              ? AppColors.successDark.withValues(alpha: 0.3)
              : AppColors.warningDark.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getIconData(item.icon),
            color: isPositive ? AppColors.successDark : AppColors.warningDark,
            size: 24.sp,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  item.title,
                  style: AppTypography.bodyL.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 4.h),
                AutoSizeText(
                  item.description,
                  style: AppTypography.bodyM.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  maxLines: 3,
                ),
                if (item.score != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  AutoSizeText(
                    'Score: ${item.score!.toStringAsFixed(0)}%',
                    style: AppTypography.bodyS.copyWith(
                      color: primaryGold,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation({
    required BuildContext context,
    required String text,
    required bool isDark,
    required Color primaryGold,
    required Color surfaceColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: primaryGold.withValues(alpha: isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: primaryGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: primaryGold,
            size: 20.sp,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AutoSizeText(
              text,
              style: AppTypography.bodyM.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle;
      case 'trending_up':
        return Icons.trending_up;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'quiz':
        return Icons.quiz;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'school':
        return Icons.school;
      case 'target':
        return Icons.center_focus_strong;
      case 'error_outline':
        return Icons.error_outline;
      case 'library_books':
        return Icons.library_books;
      case 'assignment_late':
        return Icons.assignment_late;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'schedule':
        return Icons.schedule;
      case 'location_on':
        return Icons.location_on;
      case 'cancel':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  IconData _getStatusIcon(ReadinessStatus status) {
    switch (status) {
      case ReadinessStatus.excellent:
        return Icons.stars;
      case ReadinessStatus.ready:
        return Icons.check_circle;
      case ReadinessStatus.almostReady:
        return Icons.trending_up;
      case ReadinessStatus.needsWork:
        return Icons.school;
    }
  }

  String _getStatusText(ReadinessStatus status, AppLocalizations? l10n) {
    switch (status) {
      case ReadinessStatus.excellent:
        return l10n?.excellentFullyReady ?? 'Excellent - Fully Ready';
      case ReadinessStatus.ready:
        return l10n?.readyForExam ?? 'Ready for Exam';
      case ReadinessStatus.almostReady:
        return l10n?.almostReady ?? 'Almost Ready';
      case ReadinessStatus.needsWork:
        return l10n?.needsMoreWork ?? 'Needs More Work';
    }
  }
}

