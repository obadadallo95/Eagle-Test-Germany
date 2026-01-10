import '../entities/progress_story.dart';
import '../../core/storage/hive_service.dart';
import '../../core/storage/srs_service.dart';
import '../../core/storage/user_preferences_service.dart';
import 'exam_readiness_calculator.dart';

/// Use case for building a weekly progress story
/// 
/// This is a pure Dart class with no UI dependencies.
/// It generates a human-readable narrative comparing the last 7 days
/// to the previous 7 days, highlighting achievements and progress.
class WeeklyProgressStoryBuilder {
  /// Build a weekly progress story
  /// 
  /// Returns a [ProgressStory] with title, bullet points, and confidence message.
  /// This method is deterministic: same inputs → same outputs.
  static Future<ProgressStory> build() async {
    final now = DateTime.now();
    final weekEnd = DateTime(now.year, now.month, now.day);
    final weekStart = weekEnd.subtract(const Duration(days: 6));
    final previousWeekEnd = weekStart.subtract(const Duration(days: 1));
    final previousWeekStart = previousWeekEnd.subtract(const Duration(days: 6));

    // Fetch data
    final progress = HiveService.getUserProgress();
    final examHistory = HiveService.getExamHistory();
    final currentStreak = await UserPreferencesService.getCurrentStreak();

    // Calculate metrics for current week
    final currentWeekMetrics = _calculateWeekMetrics(
      progress: progress,
      examHistory: examHistory,
      weekStart: weekStart,
      weekEnd: weekEnd,
    );

    // Calculate metrics for previous week
    final previousWeekMetrics = _calculateWeekMetrics(
      progress: progress,
      examHistory: examHistory,
      weekStart: previousWeekStart,
      weekEnd: previousWeekEnd,
    );

    // Calculate Exam Readiness (current vs previous)
    final currentReadiness = await ExamReadinessCalculator.calculate();
    
    // For previous week, we'd need to calculate it based on historical data
    // For now, we'll estimate based on progress changes
    final previousReadinessScore = _estimatePreviousReadiness(
      currentReadiness.overallScore,
      currentWeekMetrics,
      previousWeekMetrics,
    );

    // Build story
    final story = _buildStory(
      currentWeekMetrics: currentWeekMetrics,
      previousWeekMetrics: previousWeekMetrics,
      currentReadiness: currentReadiness.overallScore,
      previousReadiness: previousReadinessScore,
      currentStreak: currentStreak,
      weekStart: weekStart,
      weekEnd: weekEnd,
    );

    return story;
  }

  /// Calculate metrics for a specific week
  static _WeekMetrics _calculateWeekMetrics({
    required Map<String, dynamic>? progress,
    required List<Map<String, dynamic>> examHistory,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) {
    int newQuestionsMastered = 0;
    int studySessions = 0;
    int studyMinutes = 0;
    int examsTaken = 0;
    double averageExamScore = 0.0;

    if (progress == null) {
    return const _WeekMetrics(
      newQuestionsMastered: 0,
      studySessions: 0,
      studyMinutes: 0,
      examsTaken: 0,
      averageExamScore: 0.0,
    );
    }

    // Count new questions mastered (SRS difficulty increased to >= 2)
    final answers = progress['answers'] as Map<String, dynamic>?;
    if (answers != null) {
      for (final entry in answers.entries) {
        final questionId = int.tryParse(entry.key);
        if (questionId != null) {
          final answerData = entry.value;
          if (answerData is Map) {
            final timestampStr = answerData['timestamp'] as String?;
            if (timestampStr != null) {
              try {
                final timestamp = DateTime.parse(timestampStr);
                if (timestamp.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                    timestamp.isBefore(weekEnd.add(const Duration(days: 1)))) {
                  final isCorrect = answerData['isCorrect'] as bool? ?? false;
                  final difficulty = SrsService.getDifficultyLevel(questionId);
                  if (isCorrect && difficulty >= 2) {
                    newQuestionsMastered++;
                  }
                }
              } catch (e) {
                // Skip invalid timestamps
              }
            }
          }
        }
      }
    }

    // Count study sessions and minutes
    final dailyStudyRaw = progress['daily_study_seconds'];
    Map<String, dynamic>? dailyStudy;
    if (dailyStudyRaw is Map) {
      dailyStudy = Map<String, dynamic>.from(
        dailyStudyRaw.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    if (dailyStudy != null) {
      for (int i = 0; i < 7; i++) {
        final date = weekEnd.subtract(Duration(days: i));
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final seconds = dailyStudy[dateKey] as int? ?? 0;
        if (seconds > 0) {
          studySessions++;
          studyMinutes += (seconds / 60).round();
        }
      }
    }

    // Count exams and calculate average score
    final weekExams = examHistory.where((exam) {
      final dateStr = exam['date'] as String?;
      if (dateStr == null) return false;
      try {
        final examDate = DateTime.parse(dateStr);
        return examDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            examDate.isBefore(weekEnd.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();

    examsTaken = weekExams.length;
    if (examsTaken > 0) {
      final totalScore = weekExams
          .map((e) => e['scorePercentage'] as int? ?? 0)
          .fold(0, (sum, score) => sum + score);
      averageExamScore = totalScore / examsTaken;
    }

    return _WeekMetrics(
      newQuestionsMastered: newQuestionsMastered,
      studySessions: studySessions,
      studyMinutes: studyMinutes,
      examsTaken: examsTaken,
      averageExamScore: averageExamScore,
    );
  }

  /// Estimate previous week's readiness score
  static double _estimatePreviousReadiness(
    double currentReadiness,
    _WeekMetrics currentWeek,
    _WeekMetrics previousWeek,
  ) {
    // Simple heuristic: if current week has more activity, readiness likely increased
    final activityDiff = (currentWeek.studySessions + currentWeek.examsTaken) -
        (previousWeek.studySessions + previousWeek.examsTaken);
    
    // Estimate: each additional activity session = ~2% readiness increase
    final estimatedIncrease = activityDiff * 2.0;
    
    return (currentReadiness - estimatedIncrease).clamp(0.0, 100.0);
  }

  /// Build the story narrative
  static ProgressStory _buildStory({
    required _WeekMetrics currentWeekMetrics,
    required _WeekMetrics previousWeekMetrics,
    required double currentReadiness,
    required double previousReadiness,
    required int currentStreak,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) {
    final bulletPoints = <String>[];
    const title = "This Week's Progress";

    // Calculate improvements
    final questionsDiff = currentWeekMetrics.newQuestionsMastered - 
        previousWeekMetrics.newQuestionsMastered;
    final readinessDiff = currentReadiness - previousReadiness;
    final sessionsDiff = currentWeekMetrics.studySessions - 
        previousWeekMetrics.studySessions;

    // Build bullet points (always positive framing)
    if (currentWeekMetrics.newQuestionsMastered > 0) {
      if (questionsDiff > 0) {
        bulletPoints.add(
          'You mastered ${currentWeekMetrics.newQuestionsMastered} new question${currentWeekMetrics.newQuestionsMastered > 1 ? 's' : ''} '
          '(${questionsDiff > 0 ? '+' : ''}$questionsDiff from last week)',
        );
      } else {
        bulletPoints.add(
          'You mastered ${currentWeekMetrics.newQuestionsMastered} new question${currentWeekMetrics.newQuestionsMastered > 1 ? 's' : ''}',
        );
      }
    }

    if (currentWeekMetrics.studySessions > 0) {
      if (sessionsDiff > 0) {
        bulletPoints.add(
          'You studied ${currentWeekMetrics.studySessions} day${currentWeekMetrics.studySessions > 1 ? 's' : ''} '
          '(${sessionsDiff > 0 ? '+' : ''}$sessionsDiff from last week)',
        );
      } else {
        bulletPoints.add(
          'You studied ${currentWeekMetrics.studySessions} day${currentWeekMetrics.studySessions > 1 ? 's' : ''}',
        );
      }
    }

    if (currentStreak > 0) {
      bulletPoints.add('You maintained a $currentStreak-day study streak');
    }

    if (currentWeekMetrics.examsTaken > 0) {
      final avgScore = currentWeekMetrics.averageExamScore.round();
      bulletPoints.add(
        'You completed ${currentWeekMetrics.examsTaken} practice exam${currentWeekMetrics.examsTaken > 1 ? 's' : ''} '
        '(average score: $avgScore%)',
      );
    }

    // If no activity, provide encouragement
    if (bulletPoints.isEmpty) {
      bulletPoints.add('Every journey begins with a single step.');
      bulletPoints.add('Start by exploring questions in Study Mode.');
    }

    // Build confidence message
    String confidenceMessage;
    if (readinessDiff > 5) {
      confidenceMessage = 'You are now ${readinessDiff.toStringAsFixed(0)}% more ready than last week. Keep it up!';
    } else if (readinessDiff > 0) {
      confidenceMessage = 'You are making steady progress. Every question counts.';
    } else if (currentReadiness > 70) {
      confidenceMessage = 'You are well-prepared. Trust your preparation.';
    } else if (currentReadiness > 50) {
      confidenceMessage = 'You are on the right track. Consistency is key.';
    } else {
      confidenceMessage = 'You are building your foundation. Keep studying regularly.';
    }

    return ProgressStory(
      title: title,
      bulletPoints: bulletPoints,
      confidenceMessage: confidenceMessage,
      weekStart: weekStart,
      weekEnd: weekEnd,
    );
  }
}

/// Internal helper class for week metrics
class _WeekMetrics {
  final int newQuestionsMastered;
  final int studySessions;
  final int studyMinutes;
  final int examsTaken;
  final double averageExamScore;

  const _WeekMetrics({
    required this.newQuestionsMastered,
    required this.studySessions,
    required this.studyMinutes,
    required this.examsTaken,
    required this.averageExamScore,
  });
}

