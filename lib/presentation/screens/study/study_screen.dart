import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:animate_do/animate_do.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../widgets/time_tracker.dart';
import '../glossary/glossary_screen.dart';
import '../review/review_screen.dart';
import '../stats/statistics_screen.dart';
import '../favorites/favorites_screen.dart';
import '../learn/topic_selection_screen.dart';
import 'state_questions_screen.dart';
import '../daily_challenge/daily_challenge_screen.dart';
import '../../providers/locale_provider.dart';
import '../../providers/daily_challenge_provider.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';

/// -----------------------------------------------------------------
/// 📚 STUDY SCREEN / LERNEN / شاشة التعلم
/// -----------------------------------------------------------------
/// Grid layout for study options: All Questions, State Questions, Glossary, Favorites.
/// -----------------------------------------------------------------
class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    
    return TimeTracker(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            isArabic ? 'التعلم' : 'Learn',
            style: AppTypography.h2.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
        ),
        body: AdaptivePageWrapper(
          padding: const EdgeInsets.all(AppSpacing.lg),
          enableScroll: false, // GridView يمرر نفسه
          child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.lg,
          mainAxisSpacing: AppSpacing.lg,
          children: [
            // Daily Challenge Card - Special Design
            FadeInUp(
              delay: const Duration(milliseconds: 50),
              child: _buildDailyChallengeCard(context, isArabic, l10n, isDark, primaryGold),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: _buildStudyCard(
                context,
                title: isArabic ? 'المواضيع' : 'Topics',
                icon: Icons.category,
                color: primaryGold,
                isDark: isDark,
                onTap: () {
                  // Navigate to topic selection
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TopicSelectionScreen(),
                    ),
                  );
                },
              ),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: _buildStudyCard(
                context,
                title: l10n?.fullExam ?? 'All Questions',
                icon: Icons.quiz,
                color: AppColors.infoDark,
                isDark: isDark,
                onTap: () {
                  // Navigate to all questions view
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReviewScreen(),
                    ),
                  );
                },
              ),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 250),
              child: _buildStudyCard(
                context,
                title: isArabic ? 'أسئلة الولاية' : 'State Questions',
                icon: Icons.flag,
                color: AppColors.errorDark,
                isDark: isDark,
                onTap: () {
                  // Navigate to state questions
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StateQuestionsScreen(),
                    ),
                  );
                },
              ),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 350),
              child: _buildStudyCard(
                context,
                title: l10n?.glossary ?? 'Glossary',
                icon: Icons.book,
                color: AppColors.infoDark,
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GlossaryScreen(),
                    ),
                  );
                },
              ),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 450),
              child: _buildStudyCard(
                context,
                title: isArabic ? 'المفضلة' : 'Favorites',
                icon: Icons.favorite,
                color: Colors.pink,
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FavoritesScreen(),
                    ),
                  );
                },
              ),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 550),
              child: _buildStudyCard(
                context,
                title: l10n?.reviewDue ?? 'Review Due',
                icon: Icons.refresh,
                color: AppColors.warningDark,
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReviewScreen(),
                    ),
                  );
                },
              ),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 650),
              child: _buildStudyCard(
                context,
                title: l10n?.stats ?? 'Statistics',
                icon: Icons.bar_chart,
                color: AppColors.successDark,
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StatisticsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildDailyChallengeCard(
    BuildContext context,
    bool isArabic,
    AppLocalizations? l10n,
    bool isDark,
    Color primaryGold,
  ) {
    final result = ref.watch(dailyChallengeResultProvider);
    final hasCompletedToday = result != null &&
        DateTime.now().year == result.date.year &&
        DateTime.now().month == result.date.month &&
        DateTime.now().day == result.date.day;
    
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Card(
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: primaryGold.withValues(alpha: isDark ? 0.5 : 0.3),
          width: 2.w,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DailyChallengeScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryGold.withValues(alpha: isDark ? 0.1 : 0.08),
                primaryGold.withValues(alpha: isDark ? 0.05 : 0.03),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: primaryGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: primaryGold.withValues(alpha: isDark ? 0.3 : 0.15),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.local_fire_department,
                        size: 32.sp,
                        color: primaryGold,
                      ),
                    ),
                    if (hasCompletedToday)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: AppColors.successDark,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: surfaceColor,
                              width: 2.w,
                            ),
                          ),
                          child: Icon(
                            Icons.check,
                            size: 12.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Flexible(
                  child: AutoSizeText(
                    l10n?.dailyChallenge ?? '🔥 Daily Challenge',
                    style: AppTypography.h4.copyWith(
                      color: primaryGold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    minFontSize: 10.0,
                    stepGranularity: 1.0,
                  ),
                ),
                if (hasCompletedToday) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n?.completedToday ?? 'Completed!',
                    style: AppTypography.badge.copyWith(
                      color: AppColors.successDark,
                    ),
                  ),
                ],
              ],
            ),
        ),
      ),
      ),
    );
  }

  Widget _buildStudyCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    
    return Card(
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: color.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1.w,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(icon, size: 32.sp, color: color),
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(
                child: AutoSizeText(
                  title,
                  style: AppTypography.h4.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  minFontSize: 10.0,
                  stepGranularity: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
