import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:animate_do/animate_do.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
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
    
    return TimeTracker(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            isArabic ? 'التعلم' : 'Learn',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
        ),
        body: AdaptivePageWrapper(
          padding: EdgeInsets.all(16.w),
          enableScroll: false, // GridView يمرر نفسه
          child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          children: [
            // Daily Challenge Card - Special Design
            FadeInUp(
              delay: const Duration(milliseconds: 50),
              child: _buildDailyChallengeCard(context, isArabic, l10n),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: _buildStudyCard(
                context,
                title: isArabic ? 'المواضيع' : 'Topics',
                icon: Icons.category,
                color: AppColors.eagleGold,
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
                color: Colors.blue,
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
                color: AppColors.germanRed,
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
                color: Colors.blue,
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
                color: Colors.orange,
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
                color: Colors.green,
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
  ) {
    final result = ref.watch(dailyChallengeResultProvider);
    final hasCompletedToday = result != null &&
        DateTime.now().year == result.date.year &&
        DateTime.now().month == result.date.month &&
        DateTime.now().day == result.date.day;

    return Card(
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: AppColors.eagleGold.withValues(alpha: 0.5),
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
                AppColors.eagleGold.withValues(alpha: 0.1),
                AppColors.eagleGold.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.eagleGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.eagleGold.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.local_fire_department,
                        size: 32.sp,
                        color: AppColors.eagleGold,
                      ),
                    ),
                    if (hasCompletedToday)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.darkSurface,
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
                SizedBox(height: 12.h),
                Flexible(
                  child: AutoSizeText(
                    l10n?.dailyChallenge ?? '🔥 Daily Challenge',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.eagleGold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    minFontSize: 10.0,
                    stepGranularity: 1.0,
                  ),
                ),
                if (hasCompletedToday) ...[
                  SizedBox(height: 4.h),
                  Text(
                    l10n?.completedToday ?? 'Completed!',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
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
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: color.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(icon, size: 32.sp, color: color),
              ),
              SizedBox(height: 12.h),
              Flexible(
                child: Builder(
                  builder: (context) {
                    final theme = Theme.of(context);
                    return AutoSizeText(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      minFontSize: 10.0,
                      stepGranularity: 1.0,
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
}

