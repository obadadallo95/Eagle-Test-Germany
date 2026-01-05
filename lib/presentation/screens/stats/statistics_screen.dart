import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../core/storage/user_preferences_service.dart';
import '../../../core/storage/hive_service.dart';
import '../../../core/storage/srs_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/locale_provider.dart';
import '../../providers/question_provider.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';
import '../../widgets/gamification/celebration_overlay.dart';

/// -----------------------------------------------------------------
/// 📊 PREMIUM STATISTICS SCREEN / STATISTIKBILDSCHIRM / شاشة الإحصائيات
/// -----------------------------------------------------------------
/// Comprehensive, beautiful, and intelligent statistics dashboard
/// -----------------------------------------------------------------
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  // Overview Data
  int _currentStreak = 0;
  int _totalLearned = 0;
  double _overallProgress = 0.0;
  int _studyTimeToday = 0;
  int _dueQuestionsCount = 0;
  
  // Points Data
  int _totalPoints = 0;
  int _pointsFromDailyChallenge = 0;
  int _pointsFromExams = 0;
  int _pointsFromReview = 0;
  
  // Daily Challenge Stats
  int _dailyChallengeCompleted = 0;
  int _dailyChallengeBestScore = 0;
  double _dailyChallengeAverageScore = 0.0;
  int _dailyChallengeStreak = 0;
  
  // Category Stats
  Map<String, CategoryStats> _categoryStats = {};
  
  // Exam Stats
  List<Map<String, dynamic>> _recentExams = [];
  double _averageScore = 0.0;
  int _passRate = 0;
  
  // Weekly Stats
  List<DailyStudyData> _weeklyStudyData = [];
  List<ExamScoreData> _examScoresOverTime = [];
  
  // SRS Stats
  Map<int, int> _srsDistribution = {}; // difficultyLevel -> count
  
  // Study Habits
  Map<String, int> _dailyActivity = {}; // day name -> study minutes
  int _averageSessionTime = 0;
  
  // Gamification
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  int _previousStreak = 0;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // تحديث البيانات عند العودة للصفحة (بعد اكتمال بناء الواجهة)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadStatistics();
      }
    });
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    
    try {
      // Load basic stats
      final streak = await UserPreferencesService.getCurrentStreak();
      final progress = HiveService.getUserProgress();
      final studyTimeToday = HiveService.getStudyTimeToday();
      
      // Calculate total learned
      int totalLearned = 0;
      if (progress != null) {
        final answers = progress['answers'] as Map<String, dynamic>?;
        if (answers != null) {
          answers.forEach((key, value) {
            if (value is Map && value['isCorrect'] == true) {
              totalLearned++;
            }
          });
        }
      }
      
      final overallProgress = (310 > 0) ? (totalLearned / 310).clamp(0.0, 1.0) : 0.0;
      
      // Load questions for SRS and category stats
      final allQuestions = await ref.read(questionsProvider.future);
      final allQuestionIds = allQuestions.map((q) => q.id).toList();
      final dueQuestionIds = SrsService.getDueQuestions(allQuestionIds);
      
      // Calculate category stats
      final categoryStats = <String, CategoryStats>{};
      final srsDistribution = <int, int>{0: 0, 1: 0, 2: 0, 3: 0};
      
      if (progress != null) {
        final answers = progress['answers'] as Map<String, dynamic>?;
        if (answers != null) {
          answers.forEach((questionIdStr, answerData) {
            if (answerData is Map) {
              final questionId = int.tryParse(questionIdStr);
              if (questionId != null) {
                final question = allQuestions.firstWhere(
                  (q) => q.id == questionId,
                  orElse: () => allQuestions.first,
                );
                
                final category = question.categoryId;
                final isCorrect = answerData['isCorrect'] == true;
                
                categoryStats.putIfAbsent(category, () => CategoryStats(
                  category: category,
                  total: 0,
                  correct: 0,
                ));
                
                categoryStats[category]!.total++;
                if (isCorrect) {
                  categoryStats[category]!.correct++;
                }
                
                // SRS distribution
                final difficulty = SrsService.getDifficultyLevel(questionId);
                srsDistribution[difficulty] = (srsDistribution[difficulty] ?? 0) + 1;
              }
            }
          });
        }
      }
      
      // Load exam history
      final examHistory = HiveService.getExamHistory();
      final recentExams = examHistory.take(10).map((exam) {
        return {
          'date': exam['date'] as String? ?? 'Unknown',
          'score': exam['correctCount'] as int? ?? 0,
          'total': exam['totalQuestions'] as int? ?? 0,
          'percentage': exam['scorePercentage'] as int? ?? 0,
          'passed': exam['isPassed'] as bool? ?? false,
          'mode': exam['mode'] as String? ?? 'full',
        };
      }).toList();
      
      // Calculate average score and pass rate
      double avgScore = 0.0;
      int passCount = 0;
      if (recentExams.isNotEmpty) {
        final scores = recentExams.map((e) => e['percentage'] as int).toList();
        avgScore = scores.reduce((a, b) => a + b) / scores.length;
        passCount = recentExams.where((e) => e['passed'] == true).length;
      }
      final passRate = recentExams.isNotEmpty ? ((passCount / recentExams.length) * 100).round() : 0;
      
      // Calculate weekly study data (last 7 days)
      final weeklyStudyData = <DailyStudyData>[];
      final now = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        // Get study time for this date
        final dailyStudySeconds = progress?['daily_study_seconds'] as Map<String, dynamic>?;
        final minutes = dailyStudySeconds != null && dailyStudySeconds[dateStr] != null
            ? ((dailyStudySeconds[dateStr] as int) / 60).round()
            : 0;
        
        weeklyStudyData.add(DailyStudyData(
          day: _getDayName(date.weekday),
          date: date,
          minutes: minutes,
        ));
      }
      
      // Calculate exam scores over time (last 10 exams)
      final examScoresOverTime = recentExams.reversed.take(10).map((exam) {
        final dateStr = exam['date'] as String?;
        final date = dateStr != null ? DateTime.tryParse(dateStr) : DateTime.now();
        return ExamScoreData(
          date: date ?? DateTime.now(),
          score: exam['percentage'] as int,
        );
      }).toList();
      
      // Calculate daily activity (most active days)
      final dailyActivity = <String, int>{};
      if (progress != null) {
        final dailyStudySeconds = progress['daily_study_seconds'] as Map<String, dynamic>?;
        if (dailyStudySeconds != null) {
          dailyStudySeconds.forEach((dateStr, seconds) {
            try {
              final date = DateTime.parse(dateStr);
              final dayName = _getDayName(date.weekday);
              dailyActivity[dayName] = (dailyActivity[dayName] ?? 0) + ((seconds as int) / 60).round();
            } catch (e) {
              // Ignore invalid dates
            }
          });
        }
      }
      
      // Calculate average session time
      int avgSessionTime = 0;
      if (weeklyStudyData.isNotEmpty) {
        final totalMinutes = weeklyStudyData.map((d) => d.minutes).reduce((a, b) => a + b);
        final activeDays = weeklyStudyData.where((d) => d.minutes > 0).length;
        avgSessionTime = activeDays > 0 ? (totalMinutes / activeDays).round() : 0;
      }
      
      // Load Points Data
      final totalPoints = HiveService.getTotalPoints();
      final pointsFromDailyChallenge = HiveService.getPointsBySource('daily_challenge');
      final pointsFromExams = HiveService.getPointsBySource('exam');
      final pointsFromReview = HiveService.getPointsBySource('srs_review');
      
      // Load Daily Challenge Stats
      final dailyChallengeStats = _calculateDailyChallengeStats(progress);
      
      // Check for achievements (streak milestones)
      final shouldCelebrate = _checkAchievements(streak, totalLearned);
      
      setState(() {
        _previousStreak = _currentStreak;
        _currentStreak = streak;
        _totalLearned = totalLearned;
        _overallProgress = overallProgress;
        _studyTimeToday = studyTimeToday;
        _dueQuestionsCount = dueQuestionIds.length;
        _categoryStats = categoryStats;
        _recentExams = recentExams;
        _averageScore = avgScore;
        _passRate = passRate;
        _weeklyStudyData = weeklyStudyData;
        _examScoresOverTime = examScoresOverTime;
        _srsDistribution = srsDistribution;
        _dailyActivity = dailyActivity;
        _averageSessionTime = avgSessionTime;
        _totalPoints = totalPoints;
        _pointsFromDailyChallenge = pointsFromDailyChallenge;
        _pointsFromExams = pointsFromExams;
        _pointsFromReview = pointsFromReview;
        _dailyChallengeCompleted = dailyChallengeStats['completed'] as int;
        _dailyChallengeBestScore = dailyChallengeStats['bestScore'] as int;
        _dailyChallengeAverageScore = dailyChallengeStats['averageScore'] as double;
        _dailyChallengeStreak = dailyChallengeStats['streak'] as int;
        _isLoading = false;
      });
      
      // Trigger celebration if needed
      if (shouldCelebrate && mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _confettiController.play();
          }
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  /// حساب إحصائيات التحدي اليومي
  Map<String, dynamic> _calculateDailyChallengeStats(Map<String, dynamic>? progress) {
    if (progress == null) {
      return {'completed': 0, 'bestScore': 0, 'averageScore': 0.0, 'streak': 0};
    }
    
    final dailyChallengesRaw = progress['daily_challenges'];
    if (dailyChallengesRaw == null || dailyChallengesRaw is! List) {
      return {'completed': 0, 'bestScore': 0, 'averageScore': 0.0, 'streak': 0};
    }
    
    final challenges = List<dynamic>.from(dailyChallengesRaw);
    if (challenges.isEmpty) {
      return {'completed': 0, 'bestScore': 0, 'averageScore': 0.0, 'streak': 0};
    }
    
    int completed = challenges.length;
    int bestScore = 0;
    int totalScore = 0;
    int streak = 0;
    
    DateTime? lastDate;
    for (var challenge in challenges) {
      if (challenge is Map) {
        final score = challenge['score'] as int? ?? 0;
        if (score > bestScore) bestScore = score;
        totalScore += score;
        
        // Calculate streak
        final dateStr = challenge['date'] as String?;
        if (dateStr != null) {
          final date = DateTime.tryParse(dateStr);
          if (date != null) {
            if (lastDate == null) {
              lastDate = date;
              streak = 1;
            } else {
              final daysDiff = date.difference(lastDate).inDays;
              if (daysDiff == 1) {
                streak++;
                lastDate = date;
              } else if (daysDiff > 1) {
                streak = 1;
                lastDate = date;
              }
            }
          }
        }
      }
    }
    
    final averageScore = completed > 0 ? (totalScore / completed) : 0.0;
    
    return {
      'completed': completed,
      'bestScore': bestScore,
      'averageScore': averageScore,
      'streak': streak,
    };
  }

  /// التحقق من الإنجازات وإرجاع true إذا كان يجب الاحتفال
  bool _checkAchievements(int newStreak, int totalLearned) {
    // احتفال عند مضاعفات 5 في Streak (5, 10, 15, 20, 30, 50, 100...)
    if (newStreak > 0 && newStreak % 5 == 0 && newStreak > _previousStreak) {
      return true;
    }
    
    // احتفال عند إنجازات في عدد الأسئلة المتعلمة (50, 100, 150, 200, 250, 300)
    final learnedMilestones = [50, 100, 150, 200, 250, 300];
    if (learnedMilestones.contains(totalLearned)) {
      return true;
    }
    
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
          title: Text(
            l10n?.stats ?? 'Statistics',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                size: 24.sp,
              ),
              onPressed: _loadStatistics,
              tooltip: l10n?.statsRefresh ?? 'Refresh',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.eagleGold),
              )
            : RefreshIndicator(
                onRefresh: _loadStatistics,
                color: AppColors.eagleGold,
                child: AdaptivePageWrapper(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Points Section (New)
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: _buildPointsSection(l10n, isArabic, theme),
                      ),
                      SizedBox(height: 8.h),

                      // Daily Challenge Stats Section (New)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _buildDailyChallengeStatsSection(l10n, isArabic, theme),
                      ),
                      SizedBox(height: 24.h),

                      // Overview Cards (4 cards in 2x2 grid)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _buildOverviewSection(l10n, isArabic),
                      ),
                      SizedBox(height: 24.h),

                      // Progress Charts Section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _buildProgressChartsSection(l10n, isArabic),
                      ),
                      SizedBox(height: 24.h),

                      // Category Mastery Section
                      if (_categoryStats.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: _buildCategoryMasterySection(l10n, isArabic),
                        ),
                        SizedBox(height: 24.h),
                      ],

                      // SRS Insights Section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _buildSrsInsightsSection(l10n, isArabic),
                      ),
                      SizedBox(height: 24.h),

                      // Exam Performance Section
                      if (_recentExams.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: _buildExamPerformanceSection(l10n, isArabic),
                        ),
                        SizedBox(height: 24.h),
                      ],

                      // Study Habits Section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _buildStudyHabitsSection(l10n, isArabic),
                      ),
                      SizedBox(height: 24.h),

                      // Smart Insights Section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _buildSmartInsightsSection(l10n, isArabic),
                      ),
                      SizedBox(height: 24.h),

                      // Recent Exams List
                      if (_recentExams.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: _buildRecentExamsSection(l10n, isArabic),
                        ),
                      ],
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// بناء قسم النقاط
  Widget _buildPointsSection(AppLocalizations? l10n, bool isArabic, ThemeData theme) {
    return ZoomIn(
      duration: const Duration(milliseconds: 600),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.eagleGold.withValues(alpha: 0.2),
              AppColors.eagleGold.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: AppColors.eagleGold.withValues(alpha: 0.4),
            width: 2.w,
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
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.eagleGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      Icons.stars_rounded,
                      color: AppColors.eagleGold,
                      size: 32.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AutoSizeText(
                          l10n?.points ?? 'Total Points',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4.h),
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
                            key: ValueKey(_totalPoints),
                            _formatPoints(_totalPoints),
                            style: GoogleFonts.poppins(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.eagleGold,
                              letterSpacing: 1,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: _buildPointsSourceCard(
                      icon: Icons.local_fire_department,
                      iconColor: Colors.orange,
                      title: l10n?.dailyChallenge ?? 'Daily Challenge',
                      points: _pointsFromDailyChallenge,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildPointsSourceCard(
                      icon: Icons.quiz,
                      iconColor: Colors.blue,
                      title: l10n?.fullExam ?? 'Exams',
                      points: _pointsFromExams,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildPointsSourceCard(
                      icon: Icons.refresh,
                      iconColor: Colors.green,
                      title: l10n?.reviewDue ?? 'Review',
                      points: _pointsFromReview,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointsSourceCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int points,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20.sp, color: iconColor),
          SizedBox(height: 6.h),
          AutoSizeText(
            title,
            style: GoogleFonts.poppins(
              fontSize: 9.sp,
              color: Colors.white70,
            ),
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          AutoSizeText(
            _formatPoints(points),
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  String _formatPoints(int points) {
    if (points < 1000) {
      return points.toString();
    } else if (points < 1000000) {
      return '${(points / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(points / 1000000).toStringAsFixed(1)}M';
    }
  }

  /// بناء قسم إحصائيات التحدي اليومي
  Widget _buildDailyChallengeStatsSection(AppLocalizations? l10n, bool isArabic, ThemeData theme) {
    return SlideInRight(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 100),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.withValues(alpha: 0.15),
              Colors.orange.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.3),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AutoSizeText(
                      l10n?.dailyChallenge ?? 'Daily Challenge',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: _buildChallengeStatCard(
                      icon: Icons.check_circle,
                      iconColor: Colors.green,
                      title: l10n?.statsCompleted ?? 'Completed',
                      value: '$_dailyChallengeCompleted',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildChallengeStatCard(
                      icon: Icons.emoji_events,
                      iconColor: AppColors.eagleGold,
                      title: l10n?.statsBestScore ?? 'Best Score',
                      value: '$_dailyChallengeBestScore',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildChallengeStatCard(
                      icon: Icons.trending_up,
                      iconColor: Colors.blue,
                      title: l10n?.statsAverageScore ?? 'Average',
                      value: '${_dailyChallengeAverageScore.toStringAsFixed(0)}',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildChallengeStatCard(
                      icon: Icons.local_fire_department,
                      iconColor: Colors.orange,
                      title: l10n?.streak ?? 'Streak',
                      value: '$_dailyChallengeStreak',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20.sp, color: iconColor),
          SizedBox(height: 6.h),
          AutoSizeText(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              color: Colors.white70,
            ),
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          AutoSizeText(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(AppLocalizations? l10n, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Text(
            l10n?.statsOverview ?? 'Overview',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 1.7,
          children: [
            SlideInRight(
              delay: const Duration(milliseconds: 100),
              duration: const Duration(milliseconds: 500),
              child: _buildOverviewCard(
                icon: Icons.local_fire_department,
                iconColor: Colors.orange,
                title: l10n?.streak ?? 'Streak',
                value: '$_currentStreak',
                subtitle: _currentStreak == 1 
                    ? (l10n?.statsDay ?? 'day')
                    : (l10n?.statsDays ?? 'days'),
                gradient: [Colors.orange.withValues(alpha: 0.2), Colors.orange.withValues(alpha: 0.05)],
              ),
            ),
            SlideInRight(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 500),
              child: _buildOverviewCard(
                icon: Icons.check_circle,
                iconColor: AppColors.eagleGold,
                title: l10n?.statsProgress ?? 'Progress',
                value: '${(_overallProgress * 100).toStringAsFixed(0)}%',
                subtitle: '$_totalLearned / 310',
                gradient: [AppColors.eagleGold.withValues(alpha: 0.2), AppColors.eagleGold.withValues(alpha: 0.05)],
              ),
            ),
            SlideInRight(
              delay: const Duration(milliseconds: 300),
              duration: const Duration(milliseconds: 500),
              child: _buildOverviewCard(
                icon: Icons.timer,
                iconColor: Colors.blue,
                title: l10n?.statsToday ?? 'Today',
                value: '$_studyTimeToday',
                subtitle: l10n?.statsMinutes ?? 'minutes',
                gradient: [Colors.blue.withValues(alpha: 0.2), Colors.blue.withValues(alpha: 0.05)],
              ),
            ),
            SlideInRight(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 500),
              child: _buildOverviewCard(
                icon: Icons.school,
                iconColor: Colors.green,
                title: l10n?.statsMastered ?? 'Mastered',
                value: '$_totalLearned',
                subtitle: l10n?.statsQuestions ?? 'questions',
                gradient: [Colors.green.withValues(alpha: 0.2), Colors.green.withValues(alpha: 0.05)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.2),
            blurRadius: 12.r,
            spreadRadius: 1,
            offset: Offset(0, 4.h),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(icon, size: 16.sp, color: iconColor),
            ),
            SizedBox(height: 3.h),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: AutoSizeText(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      minFontSize: 7.0,
                      stepGranularity: 1.0,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Flexible(
                    child: AnimatedSwitcher(
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
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        minFontSize: 10.0,
                        stepGranularity: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Flexible(
                    child: AutoSizeText(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 7.sp,
                        color: Colors.white54,
                      ),
                      maxLines: 1,
                      minFontSize: 5.0,
                      stepGranularity: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChartsSection(AppLocalizations? l10n, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Text(
            l10n?.statsProgressCharts ?? 'Progress Charts',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        // Weekly Study Time Chart
        SlideInRight(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 600),
          child: _buildWeeklyStudyChart(l10n, isArabic),
        ),
        SizedBox(height: 16.h),
        // Exam Scores Over Time Chart
        if (_examScoresOverTime.isNotEmpty)
          SlideInRight(
            delay: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 600),
            child: _buildExamScoresChart(l10n, isArabic),
          ),
      ],
    );
  }

  Widget _buildWeeklyStudyChart(AppLocalizations? l10n, bool isArabic) {
    final maxMinutes = _weeklyStudyData.isNotEmpty
        ? _weeklyStudyData.map((d) => d.minutes).reduce((a, b) => a > b ? a : b)
        : 60;

    return Card(
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AutoSizeText(
              l10n?.statsWeeklyStudyTime ?? 'Weekly Study Time',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 200.h,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxMinutes > 0 ? maxMinutes * 1.2 : 60,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _weeklyStudyData.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                _weeklyStudyData[index].day,
                                style: TextStyle(fontSize: 10.sp, color: Colors.white70),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 10.sp, color: Colors.white70),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade700,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _weeklyStudyData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data.minutes.toDouble(),
                          color: AppColors.eagleGold,
                          width: 20.w,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamScoresChart(AppLocalizations? l10n, bool isArabic) {
    if (_examScoresOverTime.isEmpty) return const SizedBox.shrink();

    return Card(
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AutoSizeText(
              l10n?.statsExamScoresOverTime ?? 'Exam Scores Over Time',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 200.h,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade700,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}%',
                          style: TextStyle(fontSize: 10.sp, color: Colors.white70),
                        ),
                      ),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _examScoresOverTime.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.score.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryMasterySection(AppLocalizations? l10n, bool isArabic) {
    final sortedCategories = _categoryStats.values.toList()
      ..sort((a, b) => (b.correct / b.total).compareTo(a.correct / a.total));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Text(
            l10n?.statsCategoryMastery ?? 'Category Mastery',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Card(
          color: AppColors.darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: sortedCategories.take(5).map((cat) {
                final mastery = (cat.correct / cat.total).clamp(0.0, 1.0);
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              cat.category.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          AutoSizeText(
                            '${cat.correct}/${cat.total} (${(mastery * 100).toStringAsFixed(0)}%)',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: LinearProgressIndicator(
                          value: mastery,
                          backgroundColor: Colors.grey.shade800,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            mastery >= 0.7 ? Colors.green : mastery >= 0.5 ? Colors.orange : Colors.red,
                          ),
                          minHeight: 8.h,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSrsInsightsSection(AppLocalizations? l10n, bool isArabic) {
    final total = _srsDistribution.values.fold(0, (a, b) => a + b);
    final newCount = _srsDistribution[0] ?? 0;
    final hardCount = _srsDistribution[1] ?? 0;
    final goodCount = _srsDistribution[2] ?? 0;
    final easyCount = _srsDistribution[3] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Text(
            l10n?.statsSrsInsights ?? 'SRS Insights',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildSrsCard(
                icon: Icons.schedule,
                iconColor: Colors.orange,
                title: l10n?.statsDue ?? 'Due',
                value: '$_dueQuestionsCount',
                subtitle: l10n?.statsQuestions ?? 'questions',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildSrsCard(
                icon: Icons.trending_up,
                iconColor: Colors.green,
                title: l10n?.statsEasy ?? 'Easy',
                value: '$easyCount',
                subtitle: total > 0 ? '${((easyCount / total) * 100).toStringAsFixed(0)}%' : '0%',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Card(
          color: AppColors.darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSrsDistributionRow(
                  l10n?.statsNew ?? 'New',
                  newCount,
                  total,
                  Colors.blue,
                ),
                SizedBox(height: 12.h),
                _buildSrsDistributionRow(
                  l10n?.statsHard ?? 'Hard',
                  hardCount,
                  total,
                  Colors.orange,
                ),
                SizedBox(height: 12.h),
                _buildSrsDistributionRow(
                  l10n?.statsGood ?? 'Good',
                  goodCount,
                  total,
                  Colors.yellow,
                ),
                SizedBox(height: 12.h),
                _buildSrsDistributionRow(
                  l10n?.statsEasy ?? 'Easy',
                  easyCount,
                  total,
                  Colors.green,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSrsCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Card(
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32.sp, color: iconColor),
            SizedBox(height: 8.h),
            AutoSizeText(
              title,
              style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white70),
            ),
            SizedBox(height: 4.h),
            AutoSizeText(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            AutoSizeText(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSrsDistributionRow(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) : 0.0;
    return Row(
      children: [
        SizedBox(width: 80.w, child: Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12.sp))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8.h,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '$count (${(percentage * 100).toStringAsFixed(0)}%)',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12.sp),
        ),
      ],
    );
  }

  Widget _buildExamPerformanceSection(AppLocalizations? l10n, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Text(
            l10n?.statsExamPerformance ?? 'Exam Performance',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildPerformanceCard(
                icon: Icons.assessment,
                iconColor: AppColors.eagleGold,
                title: l10n?.statsAverageScore ?? 'Average Score',
                value: '${_averageScore.toStringAsFixed(0)}%',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildPerformanceCard(
                icon: Icons.check_circle,
                iconColor: Colors.green,
                title: l10n?.statsPassRate ?? 'Pass Rate',
                value: '$_passRate%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Card(
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40.sp, color: iconColor),
            SizedBox(height: 12.h),
            AutoSizeText(
              title,
              style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            AutoSizeText(
              value,
              style: GoogleFonts.poppins(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyHabitsSection(AppLocalizations? l10n, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Text(
            l10n?.statsStudyHabits ?? 'Study Habits',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Card(
          color: AppColors.darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHabitStat(
                      icon: Icons.access_time,
                      label: l10n?.statsAvgSession ?? 'Avg Session',
                      value: '$_averageSessionTime',
                      unit: l10n?.statsMin ?? 'min',
                    ),
                    _buildHabitStat(
                      icon: Icons.calendar_today,
                      label: l10n?.statsActiveDays ?? 'Active Days',
                      value: '${_dailyActivity.length}',
                      unit: l10n?.statsDays ?? 'days',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitStat({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32.sp, color: AppColors.eagleGold),
        SizedBox(height: 8.h),
        AutoSizeText(
          label,
          style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white70),
        ),
        SizedBox(height: 4.h),
        AutoSizeText(
          '$value $unit',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSmartInsightsSection(AppLocalizations? l10n, bool isArabic) {
    final insights = <String>[];
    
    if (_dueQuestionsCount > 0) {
      insights.add(l10n?.statsInsightDueQuestions(_dueQuestionsCount) ?? 'You have $_dueQuestionsCount questions due for review');
    }
    
    if (_overallProgress < 0.5) {
      insights.add(l10n?.statsInsightFocusNew ?? 'Focus on new questions to boost your progress');
    }
    
    if (_averageScore < 50 && _recentExams.isNotEmpty) {
      final scoreStr = _averageScore.toStringAsFixed(0);
      insights.add(l10n?.statsInsightKeepPracticing(scoreStr) ?? 'Keep practicing! Average score: $scoreStr%');
    }
    
    if (_currentStreak >= 7) {
      insights.add(l10n?.statsInsightExcellentStreak(_currentStreak) ?? 'Excellent! You\'re maintaining a study habit ($_currentStreak days)');
    }

    if (insights.isEmpty) {
      insights.add(l10n?.statsInsightKeepStudying ?? 'Keep studying to get smart insights');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Text(
            l10n?.statsSmartInsights ?? 'Smart Insights',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Card(
          color: AppColors.darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: AppColors.eagleGold, size: 24.sp),
                    SizedBox(width: 8.w),
                    AutoSizeText(
                      l10n?.statsRecommendations ?? 'Recommendations',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                ...insights.map((insight) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.arrow_forward, size: 16.sp, color: AppColors.eagleGold),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: AutoSizeText(
                              insight,
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentExamsSection(AppLocalizations? l10n, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Text(
            l10n?.statsRecentExams ?? 'Recent Exams',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Card(
          color: AppColors.darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _recentExams.take(5).map((exam) => _buildExamResultTile(exam, l10n, isArabic)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildExamResultTile(Map<String, dynamic> exam, AppLocalizations? l10n, bool isArabic) {
    final dateStr = exam['date'] as String?;
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
    final formattedDate = date != null
        ? '${date.day}/${date.month}/${date.year}'
        : 'Unknown';
    final passed = exam['passed'] as bool? ?? false;
    final mode = exam['mode'] as String? ?? 'full';

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: AppColors.darkCharcoal,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: passed ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: passed ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
          child: Icon(
            passed ? Icons.check : Icons.close,
            color: passed ? Colors.green : Colors.red,
          ),
        ),
        title: AutoSizeText(
          '${l10n?.fullExam ?? "Exam"} - $formattedDate',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: AutoSizeText(
          '${l10n?.statsScore ?? "Score"}: ${exam['score'] ?? 0}/${exam['total'] ?? 0} • ${mode == 'full' ? (l10n?.fullExam ?? "Full") : (l10n?.quickPractice ?? "Quick")}',
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 12.sp,
          ),
        ),
        trailing: AutoSizeText(
          '${exam['percentage'] ?? 0}%',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: passed ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}

// Helper Classes
class CategoryStats {
  final String category;
  int total;
  int correct;

  CategoryStats({
    required this.category,
    required this.total,
    required this.correct,
  });
}

class DailyStudyData {
  final String day;
  final DateTime date;
  final int minutes;

  DailyStudyData({
    required this.day,
    required this.date,
    required this.minutes,
  });
}

class ExamScoreData {
  final DateTime date;
  final int score;

  ExamScoreData({
    required this.date,
    required this.score,
  });
}
