import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../core/storage/hive_service.dart';
import '../../../core/storage/user_preferences_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/debug/app_logger.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/locale_provider.dart';
import '../../providers/exam_readiness_provider.dart';
import '../../providers/daily_plan_provider.dart';
import '../../providers/progress_story_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/gamification/celebration_overlay.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';
import '../../widgets/ai_coaching_card.dart';

/// -----------------------------------------------------------------
/// 📊 DASHBOARD SCREEN / DASHBOARD / لوحة التحكم
/// -----------------------------------------------------------------
/// Main dashboard showing overall stats, streak, and last exam score.
/// -----------------------------------------------------------------
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentStreak = 0;
  int _totalLearned = 0;
  double _overallProgress = 0.0;
  int? _lastExamScore;
  List<Map<String, dynamic>> examHistory = [];
  int _studyTimeToday = 0;
  int _totalStudyTime = 0;
  int _remainingQuestions = 0;
  DateTime? _examDate;
  int? _daysUntilExam;
  int _previousStreak = 0; // لتتبع التغييرات في Streak
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when returning to this screen to update study time
    _loadDashboardData();
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // تحديث البيانات عند إعادة بناء الـ Widget
    _loadDashboardData();
  }

  // Method to manually refresh dashboard data (can be called from outside)
  void refreshDashboard() {
    _loadDashboardData();
    // تحديث Exam Readiness Provider عند تحديث Dashboard
    ref.invalidate(examReadinessProvider);
  }

  Future<void> _loadDashboardData() async {
    AppLogger.functionStart('_loadDashboardData', source: 'DashboardScreen');
    final streak = await UserPreferencesService.updateStreak();
    AppLogger.log('Streak updated: $streak', source: 'DashboardScreen');

    // حساب إجمالي الأسئلة المتعلمة
    final progress = HiveService.getUserProgress();
    int totalLearned = 0;
    if (progress != null) {
      final answers = progress['answers'];
      if (answers != null && answers is Map) {
        final answersMap = Map<String, dynamic>.from(
            (answers).map((key, value) => MapEntry(key.toString(), value)));
        answersMap.forEach((key, value) {
          if (value is Map) {
            final valueMap = Map<String, dynamic>.from(
                (value).map((k, v) => MapEntry(k.toString(), v)));
            if (valueMap['isCorrect'] == true) {
              totalLearned++;
            }
          }
        });
      }
    }

    final overallProgress =
        (310 > 0) ? (totalLearned / 310).clamp(0.0, 1.0) : 0.0;
    final remainingQuestions = 310 - totalLearned;

    // جلب آخر نتيجة امتحان
    final lastExamResult = HiveService.getLastExamResult();
    final history = HiveService.getExamHistory();
    final studyTimeToday = HiveService.getStudyTimeToday();
    final totalStudyTime = HiveService.getTotalStudyTime();

    // جلب تاريخ الامتحان وحساب الأيام المتبقية
    final examDate = await UserPreferencesService.getExamDate();
    int? daysUntilExam;
    if (examDate != null) {
      final now = DateTime.now();
      final difference = examDate.difference(now);
      daysUntilExam = difference.inDays;
    }

    // التحقق من الإنجازات وإطلاق الاحتفال
    final shouldCelebrate = _checkAchievements(streak, totalLearned, lastExamResult?['scorePercentage'] as int?);
    
    setState(() {
      _previousStreak = _currentStreak;
      _currentStreak = streak;
      _totalLearned = totalLearned;
      _overallProgress = overallProgress;
      _remainingQuestions = remainingQuestions;
      _lastExamScore = lastExamResult?['scorePercentage'] as int?;
      examHistory = history;
      _studyTimeToday = studyTimeToday;
      _totalStudyTime = totalStudyTime;
      _examDate = examDate;
      _daysUntilExam = daysUntilExam;
    });

    // إطلاق الاحتفال بعد setState
    if (shouldCelebrate) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _confettiController.play();
        }
      });
    }

    // جدولة إشعارات السلسلة إذا لزم الأمر
    final isReminderEnabled = await UserPreferencesService.getReminderEnabled();
    if (isReminderEnabled) {
      await NotificationService.scheduleStreakReminder();
    }

    AppLogger.event('Dashboard data loaded', source: 'DashboardScreen', data: {
      'streak': streak,
      'totalLearned': totalLearned,
      'progress': overallProgress,
      'studyTimeToday': studyTimeToday,
      'examHistoryCount': history.length,
    });
    
    // تحديث Exam Readiness Provider بعد تحميل البيانات
    // هذا يضمن أن جاهزية الامتحان تُحسب بناءً على أحدث البيانات
    ref.invalidate(examReadinessProvider);
    
    AppLogger.functionEnd('_loadDashboardData', source: 'DashboardScreen');
  }

  /// التحقق من الإنجازات وإرجاع true إذا كان يجب الاحتفال
  bool _checkAchievements(int newStreak, int totalLearned, int? examScore) {
    // احتفال عند مضاعفات 5 في Streak (5, 10, 15, 20, 30, 50, 100...)
    if (newStreak > 0 && newStreak % 5 == 0 && newStreak > _previousStreak) {
      AppLogger.event('Streak milestone reached', source: 'DashboardScreen', data: {'streak': newStreak});
      return true;
    }
    
    // احتفال عند إنجازات في عدد الأسئلة المتعلمة (50, 100, 150, 200, 250, 300)
    final learnedMilestones = [50, 100, 150, 200, 250, 300];
    if (learnedMilestones.contains(totalLearned)) {
      AppLogger.event('Learning milestone reached', source: 'DashboardScreen', data: {'totalLearned': totalLearned});
      return true;
    }
    
    // احتفال عند الوصول إلى 70%+ في Exam Readiness (يتم التحقق من Provider)
    // هذا سيتم التحقق منه في build method
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar';

    final theme = Theme.of(context);

    return CelebrationOverlay(
      confettiController: _confettiController,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Row(
            children: [
              AppLogo(
                width: 32.w,
                height: 32.h,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  l10n?.appTitle ?? 'Eagle Test: Germany',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
        ),
        body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: AppColors.eagleGold,
        child: AdaptivePageWrapper(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Big Circular Progress
              ZoomIn(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.eagleGold.withValues(alpha: 0.15),
                        AppColors.darkSurface.withValues(alpha: 0.9),
                        AppColors.darkSurface,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.eagleGold.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Card(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                      side: BorderSide(
                        color: AppColors.eagleGold.withValues(alpha: 0.4),
                        width: 2.w,
                      ),
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: CircularPercentIndicator(
                              key: ValueKey(_totalLearned),
                              radius: 100.r,
                              lineWidth: 16.w,
                              percent: _overallProgress,
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: AutoSizeText(
                                      key: ValueKey(_totalLearned),
                                      '$_totalLearned',
                                      style: GoogleFonts.poppins(
                                        fontSize: 36.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.eagleGold,
                                      ),
                                      maxLines: 1,
                                      minFontSize: 20.0,
                                      stepGranularity: 1.0,
                                    ),
                                  ),
                                  AutoSizeText(
                                    '/ 310',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18.sp,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                    maxLines: 1,
                                    minFontSize: 10.0,
                                    stepGranularity: 1.0,
                                  ),
                                ],
                              ),
                              progressColor: AppColors.eagleGold,
                              backgroundColor: theme.brightness == Brightness.dark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade300,
                              circularStrokeCap: CircularStrokeCap.round,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          AutoSizeText(
                            l10n?.totalLearned ??
                                (isArabic ? 'إجمالي المتعلم' : 'Total Learned'),
                            style: GoogleFonts.poppins(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                          ),
                          SizedBox(height: 8.h),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: AutoSizeText(
                              key: ValueKey(_overallProgress),
                              '${(_overallProgress * 100).toStringAsFixed(1)}% ${isArabic ? 'مكتمل' : 'Complete'}',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // AI Coaching Card (Pro Feature)
              const AiCoachingCard(),

              SizedBox(height: 24.h),

              // Exam Countdown Card
              SlideInRight(
                delay: const Duration(milliseconds: 150),
                duration: const Duration(milliseconds: 500),
                child: _buildCountdownCard(context, l10n, isArabic),
              ),

              SizedBox(height: 24.h),

              // Streak Card
              if (_currentStreak > 0)
                SlideInRight(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 500),
                  child: _buildStatCard(
                    context,
                    icon: Icons.local_fire_department,
                    iconColor: Colors.orange,
                    title: l10n?.streak ?? 'Streak',
                    value: '$_currentStreak',
                    subtitle: isArabic ? 'أيام متتالية' : 'Days in a row',
                    index: 0,
                  ),
                ),

              SizedBox(height: 16.h),

              // Study Time Today Card
              SlideInRight(
                delay: const Duration(milliseconds: 250),
                duration: const Duration(milliseconds: 500),
                child: _buildStatCard(
                  context,
                  icon: Icons.timer,
                  iconColor: Colors.blue,
                  title: isArabic ? 'وقت الدراسة اليوم' : 'Study Time Today',
                  value: '$_studyTimeToday',
                  subtitle: isArabic ? 'دقيقة' : 'minutes',
                  index: 1,
                ),
              ),

              SizedBox(height: 16.h),

              // Last Exam Score Card
              if (_lastExamScore != null)
                SlideInRight(
                  delay: const Duration(milliseconds: 300),
                  duration: const Duration(milliseconds: 500),
                  child: _buildStatCard(
                    context,
                    icon: Icons.assignment,
                    iconColor: AppColors.eagleGold,
                    title: isArabic ? 'آخر نتيجة' : 'Last Exam',
                    value: '$_lastExamScore%',
                    subtitle: isArabic ? 'آخر امتحان' : 'Last attempt',
                    index: 2,
                  ),
                ),

              SizedBox(height: 16.h),

              // Remaining Questions Card
              SlideInRight(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 500),
                child: _buildStatCard(
                  context,
                  icon: Icons.quiz_outlined,
                  iconColor: Colors.purple,
                  title: isArabic ? 'الأسئلة المتبقية' : 'Remaining Questions',
                  value: '$_remainingQuestions',
                  subtitle: isArabic ? 'من 310 سؤال' : 'of 310 questions',
                  index: 3,
                ),
              ),

              SizedBox(height: 16.h),

              // Total Study Time Card
              SlideInRight(
                delay: const Duration(milliseconds: 450),
                duration: const Duration(milliseconds: 500),
                child: _buildStatCard(
                  context,
                  icon: Icons.access_time,
                  iconColor: Colors.teal,
                  title: isArabic ? 'إجمالي وقت الدراسة' : 'Total Study Time',
                  value: '$_totalStudyTime',
                  subtitle: isArabic ? 'دقيقة' : 'minutes',
                  index: 4,
                ),
              ),

              SizedBox(height: 16.h),

              // Passed Exams Count Card
              if (examHistory.isNotEmpty)
                SlideInRight(
                  delay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 500),
                  child: _buildStatCard(
                    context,
                    icon: Icons.check_circle,
                    iconColor: Colors.green,
                    title: isArabic ? 'امتحانات ناجحة' : 'Passed Exams',
                    value:
                        '${examHistory.where((e) => e['isPassed'] == true).length}',
                    subtitle: isArabic
                        ? 'من ${examHistory.length} امتحان'
                        : 'of ${examHistory.length} exams',
                    index: 5,
                  ),
                ),

              SizedBox(height: 16.h),

              // Exam Readiness Card
              ref.watch(examReadinessProvider).when(
                    data: (readiness) {
                      // التحقق من إنجاز 70%+ وإطلاق الاحتفال
                      if (readiness.overallScore >= 70 && _lastExamScore != null && _lastExamScore! < 70) {
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (mounted) {
                            _confettiController.play();
                          }
                        });
                      }
                      
                      return ZoomIn(
                        delay: const Duration(milliseconds: 550),
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: readiness.overallScore >= 70
                                  ? [
                                      Colors.green.withValues(alpha: 0.2),
                                      AppColors.darkSurface.withValues(alpha: 0.9),
                                      AppColors.darkSurface,
                                    ]
                                  : [
                                      AppColors.eagleGold.withValues(alpha: 0.15),
                                      AppColors.darkSurface.withValues(alpha: 0.9),
                                      AppColors.darkSurface,
                                    ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (readiness.overallScore >= 70 ? Colors.green : AppColors.eagleGold)
                                    .withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Card(
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              side: BorderSide(
                                color: readiness.overallScore >= 70
                                    ? Colors.green.withValues(alpha: 0.6)
                                    : AppColors.eagleGold.withValues(alpha: 0.4),
                                width: 2,
                              ),
                            ),
                            elevation: 0,
                            child: Padding(
                              padding: EdgeInsets.all(20.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        readiness.overallScore >= 70
                                            ? Icons.check_circle
                                            : Icons.school,
                                        color: readiness.overallScore >= 70
                                            ? Colors.green
                                            : AppColors.eagleGold,
                                        size: 28.sp,
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: AutoSizeText(
                                          isArabic
                                              ? 'جاهزية الامتحان'
                                              : 'Exam Readiness',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 500),
                                        transitionBuilder: (child, animation) {
                                          return ScaleTransition(
                                            scale: animation,
                                            child: child,
                                          );
                                        },
                                        child: AutoSizeText(
                                          key: ValueKey(readiness.overallScore),
                                          '${readiness.overallScore.toStringAsFixed(0)}%',
                                          style: GoogleFonts.poppins(
                                            fontSize: 24.sp,
                                            fontWeight: FontWeight.bold,
                                            color: readiness.overallScore >= 70
                                                ? Colors.green
                                                : AppColors.eagleGold,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  AutoSizeText(
                                    readiness.overallScore >= 70
                                        ? (isArabic
                                            ? 'أنت جاهز للامتحان!'
                                            : 'You are ready for the exam!')
                                        : (isArabic
                                            ? 'استمر في الدراسة للوصول إلى 70%'
                                            : 'Keep studying to reach 70%'),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

              SizedBox(height: 16.h),

              // Smart Daily Plan Card
              ref.watch(smartDailyPlanProvider).when(
                    data: (plan) => plan.questionIds.isNotEmpty
                        ? SlideInRight(
                            delay: const Duration(milliseconds: 600),
                            duration: const Duration(milliseconds: 500),
                            child: Card(
                              color: theme.cardTheme.color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                side: BorderSide(
                                  color: AppColors.eagleGold.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.today,
                                          color: AppColors.eagleGold,
                                          size: 28.sp,
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: AutoSizeText(
                                            isArabic
                                                ? 'خطة اليوم'
                                                : 'Today\'s Plan',
                                            style: GoogleFonts.poppins(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                        AutoSizeText(
                                          '${plan.questionIds.length}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 24.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.eagleGold,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    AutoSizeText(
                                      plan.explanation,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.7),
                                      ),
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

              SizedBox(height: 16.h),

              // Progress Story Card
              ref.watch(weeklyProgressStoryProvider).when(
                    data: (story) => story.bulletPoints.isNotEmpty
                        ? SlideInRight(
                            delay: const Duration(milliseconds: 650),
                            duration: const Duration(milliseconds: 500),
                            child: Card(
                              color: theme.cardTheme.color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                side: BorderSide(
                                  color: Colors.blue.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.auto_stories,
                                          color: Colors.blue,
                                          size: 28.sp,
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: AutoSizeText(
                                            story.title,
                                            style: GoogleFonts.poppins(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.h),
                                    ...story.bulletPoints.take(3).map((point) =>
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 8.h),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.check_circle_outline,
                                                size: 16.sp,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(width: 8.w),
                                              Expanded(
                                                child: AutoSizeText(
                                                  point,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12.sp,
                                                    color: theme
                                                        .colorScheme.onSurface
                                                        .withValues(alpha: 0.7),
                                                  ),
                                                  maxLines: 2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildCountdownCard(
    BuildContext context,
    AppLocalizations? l10n,
    bool isArabic,
  ) {
    final theme = Theme.of(context);
    final currentLocale = ref.read(localeProvider);

    // حساب الأيام المتبقية والرسالة المناسبة
    String countdownText;
    String subtitleText;
    Color textColor;

    if (_examDate == null) {
      countdownText = isArabic ? 'حدد التاريخ' : 'Set Date';
      subtitleText =
          isArabic ? 'اضغط لتحديد تاريخ الامتحان' : 'Tap to set exam date';
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    } else if (_daysUntilExam == null || _daysUntilExam! < 0) {
      countdownText = isArabic ? 'انتهى' : 'Passed';
      subtitleText =
          isArabic ? 'تاريخ الامتحان قد مضى' : 'Exam date has passed';
      textColor = Colors.red;
    } else if (_daysUntilExam == 0) {
      countdownText = isArabic ? 'اليوم!' : 'Today!';
      subtitleText = isArabic
          ? '🍀 اليوم هو اليوم! حظاً موفقاً!'
          : '🍀 Today is the Day! Good Luck!';
      textColor = AppColors.eagleGold;
    } else {
      countdownText = '$_daysUntilExam';
      subtitleText = isArabic
          ? '${_daysUntilExam == 1 ? 'يوم' : 'أيام'} متبقية'
          : '${_daysUntilExam == 1 ? 'Day' : 'Days'} Left';
      textColor = AppColors.eagleGold;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.eagleGold.withValues(alpha: 0.15),
            AppColors.germanRed.withValues(alpha: 0.1),
            AppColors.darkSurface.withValues(alpha: 0.9),
            AppColors.darkSurface,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.eagleGold.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(
            color: AppColors.eagleGold.withValues(alpha: 0.5),
            width: 2.w,
          ),
        ),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
          ),
        child: InkWell(
          onTap: () async {
            // فتح DatePicker لتغيير التاريخ
            final DateTime now = DateTime.now();
            final DateTime firstDate = now;
            final DateTime lastDate = now.add(const Duration(days: 365 * 2));

            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _examDate ?? now.add(const Duration(days: 30)),
              firstDate: firstDate,
              lastDate: lastDate,
              locale: currentLocale,
            );

            if (picked != null && picked != _examDate) {
              await UserPreferencesService.saveExamDate(picked);
              // إعادة تحميل البيانات
              _loadDashboardData();
            }
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.eagleGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    _daysUntilExam == 0
                        ? Icons.celebration
                        : Icons.calendar_today,
                    size: 36.sp,
                    color: AppColors.eagleGold,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: AutoSizeText(
                          key: ValueKey(countdownText),
                          countdownText,
                          style: GoogleFonts.poppins(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 1,
                          minFontSize: 24.0,
                          stepGranularity: 1.0,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      AutoSizeText(
                        subtitleText,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit_outlined,
                  size: 20.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    int index = 0,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            iconColor.withValues(alpha: 0.1),
            AppColors.darkSurface.withValues(alpha: 0.8),
            AppColors.darkSurface,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(
            color: iconColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      iconColor.withValues(alpha: 0.3),
                      iconColor.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 32.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AutoSizeText(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                    ),
                    SizedBox(height: 4.h),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: AutoSizeText(
                        key: ValueKey(value),
                        value,
                        style: GoogleFonts.poppins(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    AutoSizeText(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
