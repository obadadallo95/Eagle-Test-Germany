import '../entities/exam_readiness.dart';
import '../entities/exam_readiness_report.dart';
import '../../core/storage/hive_service.dart';
import '../../core/storage/srs_service.dart';
import '../../core/storage/user_preferences_service.dart';
import 'exam_readiness_calculator.dart';
import 'exam_readiness_translations.dart';

/// Use case for generating a detailed Exam Readiness Report
/// 
/// This generates a comprehensive report with strengths, weaknesses, and recommendations
class ExamReadinessReportGenerator {
  /// Generate a detailed readiness report
  /// 
  /// [languageCode] - Language code for translations (e.g., 'ar', 'en', 'de')
  static Future<ExamReadinessReport> generate({String languageCode = 'en'}) async {
    // Calculate readiness scores
    final readiness = await ExamReadinessCalculator.calculate();
    
    // Gather statistics
    final statistics = await _gatherStatistics();
    
    // Determine status
    final status = _determineStatus(readiness.overallScore);
    
    // Generate strengths
    final strengths = _generateStrengths(readiness, statistics, languageCode);
    
    // Generate weaknesses
    final weaknesses = _generateWeaknesses(readiness, statistics, languageCode);
    
    // Generate recommendations
    final recommendations = _generateRecommendations(readiness, statistics, weaknesses, languageCode);
    
    return ExamReadinessReport(
      overallScore: readiness.overallScore,
      masteryScore: readiness.masteryScore,
      examScore: readiness.examScore,
      consistencyScore: readiness.consistencyScore,
      stateScore: readiness.stateScore,
      strengths: strengths,
      weaknesses: weaknesses,
      status: status,
      recommendations: recommendations,
      statistics: statistics,
    );
  }

  /// Gather statistics from user data
  static Future<ReportStatistics> _gatherStatistics() async {
    final progress = HiveService.getUserProgress();
    final examHistory = HiveService.getExamHistory();
    final streak = await UserPreferencesService.getCurrentStreak();
    
    // Calculate questions statistics
    int totalQuestionsAnswered = 0;
    int questionsMastered = 0;
    int correctAnswers = 0;
    
    if (progress != null) {
      final answersRaw = progress['answers'];
      Map<String, dynamic>? answers;
      if (answersRaw == null) {
        answers = null;
      } else if (answersRaw is Map) {
        answers = Map<String, dynamic>.from(
          answersRaw.map((key, value) => MapEntry(key.toString(), value)),
        );
      } else {
        answers = null;
      }
      
      if (answers != null) {
        answers.forEach((questionIdStr, answerData) {
          if (answerData is! Map) return;
          
          totalQuestionsAnswered++;
          
          final isCorrect = answerData['isCorrect'] as bool? ?? false;
          if (isCorrect) {
            correctAnswers++;
          }
          
          final questionId = int.tryParse(questionIdStr);
          if (questionId != null) {
            final difficultyLevel = SrsService.getDifficultyLevel(questionId);
            if (difficultyLevel >= 2) {
              questionsMastered++;
            }
          }
        });
      }
    }
    
    // Calculate exam statistics
    final totalExams = examHistory.length;
    final examsPassed = examHistory.where((exam) {
      final isPassed = exam['isPassed'] as bool? ?? false;
      final scorePercentage = exam['scorePercentage'] as int? ?? 0;
      return isPassed && scorePercentage >= 50;
    }).length;
    
    // Calculate study sessions in last 7 days
    final studySessionsLast7Days = _countStudySessionsLast7Days(progress);
    
    // Calculate total study time
    final totalStudySeconds = progress?['total_study_seconds'] as int? ?? 0;
    final totalStudyHours = totalStudySeconds / 3600.0;
    
    return ReportStatistics(
      totalQuestionsAnswered: totalQuestionsAnswered,
      questionsMastered: questionsMastered,
      correctAnswers: correctAnswers,
      totalExams: totalExams,
      examsPassed: examsPassed,
      currentStreak: streak,
      studySessionsLast7Days: studySessionsLast7Days,
      totalStudyHours: totalStudyHours,
    );
  }

  /// Count study sessions in the last 7 days
  static int _countStudySessionsLast7Days(Map<String, dynamic>? progress) {
    if (progress == null) return 0;

    final dailyStudyRaw = progress['daily_study_seconds'];
    if (dailyStudyRaw == null) return 0;
    
    Map<String, dynamic> dailyStudy;
    if (dailyStudyRaw is Map) {
      dailyStudy = Map<String, dynamic>.from(
        dailyStudyRaw.map((key, value) => MapEntry(key.toString(), value)),
      );
    } else {
      return 0;
    }

    final now = DateTime.now();
    int sessionCount = 0;

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final seconds = dailyStudy[dateKey] as int? ?? 0;
      if (seconds > 0) {
        sessionCount++;
      }
    }

    return sessionCount;
  }

  /// Determine readiness status based on overall score
  static ReadinessStatus _determineStatus(double overallScore) {
    if (overallScore >= 85) {
      return ReadinessStatus.excellent;
    } else if (overallScore >= 70) {
      return ReadinessStatus.ready;
    } else if (overallScore >= 50) {
      return ReadinessStatus.almostReady;
    } else {
      return ReadinessStatus.needsWork;
    }
  }

  /// Generate strengths based on readiness scores and statistics
  static List<ReportItem> _generateStrengths(
    ExamReadiness readiness,
    ReportStatistics statistics,
    String languageCode,
  ) {
    final strengths = <ReportItem>[];
    
    // Mastery strengths
    if (readiness.masteryScore >= 70) {
      strengths.add(ReportItem(
        title: ExamReadinessTranslations.get('strongQuestionMastery', languageCode),
        description: ExamReadinessTranslations.format(
          'strongQuestionMasteryDesc',
          languageCode,
          [statistics.questionsMastered, readiness.masteryScore.toStringAsFixed(0)],
        ),
        score: readiness.masteryScore,
        icon: 'check_circle',
      ));
    } else if (readiness.masteryScore >= 50) {
      strengths.add(ReportItem(
        title: ExamReadinessTranslations.get('goodProgressOnQuestions', languageCode),
        description: ExamReadinessTranslations.format(
          'goodProgressOnQuestionsDesc',
          languageCode,
          [statistics.questionsMastered],
        ),
        score: readiness.masteryScore,
        icon: 'trending_up',
      ));
    }
    
    // Exam performance strengths
    if (readiness.examScore >= 70 && statistics.totalExams > 0) {
      strengths.add(ReportItem(
        title: ExamReadinessTranslations.get('excellentExamPerformance', languageCode),
        description: ExamReadinessTranslations.format(
          'excellentExamPerformanceDesc',
          languageCode,
          [statistics.examsPassed, statistics.totalExams, readiness.examScore.toStringAsFixed(0)],
        ),
        score: readiness.examScore,
        icon: 'emoji_events',
      ));
    } else if (statistics.examsPassed > 0) {
      final examPlural = ExamReadinessTranslations.getExamPlural(languageCode, statistics.totalExams);
      strengths.add(ReportItem(
        title: ExamReadinessTranslations.get('examExperience', languageCode),
        description: ExamReadinessTranslations.format(
          'examExperienceDesc',
          languageCode,
          [statistics.totalExams, examPlural, statistics.examsPassed],
        ),
        score: readiness.examScore,
        icon: 'quiz',
      ));
    }
    
    // Consistency strengths
    if (readiness.consistencyScore >= 70) {
      strengths.add(ReportItem(
        title: ExamReadinessTranslations.get('consistentStudyHabits', languageCode),
        description: ExamReadinessTranslations.format(
          'consistentStudyHabitsDesc',
          languageCode,
          [statistics.currentStreak, statistics.studySessionsLast7Days],
        ),
        score: readiness.consistencyScore,
        icon: 'local_fire_department',
      ));
    } else if (statistics.currentStreak >= 7) {
      strengths.add(ReportItem(
        title: ExamReadinessTranslations.get('goodStudyStreak', languageCode),
        description: ExamReadinessTranslations.format(
          'goodStudyStreakDesc',
          languageCode,
          [statistics.currentStreak],
        ),
        score: readiness.consistencyScore,
        icon: 'whatshot',
      ));
    }
    
    // Overall activity
    if (statistics.totalQuestionsAnswered >= 100) {
      strengths.add(ReportItem(
        title: ExamReadinessTranslations.get('highActivityLevel', languageCode),
        description: ExamReadinessTranslations.format(
          'highActivityLevelDesc',
          languageCode,
          [statistics.totalQuestionsAnswered, statistics.totalStudyHours.toStringAsFixed(1)],
        ),
        score: null,
        icon: 'school',
      ));
    }
    
    // Accuracy
    if (statistics.totalQuestionsAnswered > 0) {
      final accuracy = (statistics.correctAnswers / statistics.totalQuestionsAnswered) * 100;
      if (accuracy >= 70) {
        strengths.add(ReportItem(
          title: ExamReadinessTranslations.get('highAccuracy', languageCode),
          description: ExamReadinessTranslations.format(
            'highAccuracyDesc',
            languageCode,
            [statistics.correctAnswers, statistics.totalQuestionsAnswered, accuracy.toStringAsFixed(0)],
          ),
          score: accuracy,
          icon: 'target',
        ));
      }
    }
    
    return strengths;
  }

  /// Generate weaknesses based on readiness scores and statistics
  static List<ReportItem> _generateWeaknesses(
    ExamReadiness readiness,
    ReportStatistics statistics,
    String languageCode,
  ) {
    final weaknesses = <ReportItem>[];
    
    // Mastery weaknesses
    if (readiness.masteryScore < 50) {
      weaknesses.add(ReportItem(
        title: ExamReadinessTranslations.get('lowQuestionMastery', languageCode),
        description: ExamReadinessTranslations.format(
          'lowQuestionMasteryDesc',
          languageCode,
          [readiness.masteryScore.toStringAsFixed(0)],
        ),
        score: readiness.masteryScore,
        icon: 'error_outline',
      ));
    } else if (readiness.masteryScore < 70 && statistics.totalQuestionsAnswered < 50) {
      weaknesses.add(ReportItem(
        title: ExamReadinessTranslations.get('limitedQuestionCoverage', languageCode),
        description: ExamReadinessTranslations.format(
          'limitedQuestionCoverageDesc',
          languageCode,
          [statistics.totalQuestionsAnswered],
        ),
        score: readiness.masteryScore,
        icon: 'library_books',
      ));
    }
    
    // Exam performance weaknesses
    if (readiness.examScore < 50 && statistics.totalExams > 0) {
      weaknesses.add(ReportItem(
        title: ExamReadinessTranslations.get('lowExamPerformance', languageCode),
        description: ExamReadinessTranslations.format(
          'lowExamPerformanceDesc',
          languageCode,
          [readiness.examScore.toStringAsFixed(0)],
        ),
        score: readiness.examScore,
        icon: 'assignment_late',
      ));
    } else if (statistics.totalExams == 0) {
      weaknesses.add(ReportItem(
        title: ExamReadinessTranslations.get('noExamPractice', languageCode),
        description: ExamReadinessTranslations.get('noExamPracticeDesc', languageCode),
        score: 0.0,
        icon: 'quiz',
      ));
    }
    
    // Consistency weaknesses
    if (readiness.consistencyScore < 50) {
      if (statistics.currentStreak < 3) {
        weaknesses.add(ReportItem(
          title: ExamReadinessTranslations.get('inconsistentStudyHabits', languageCode),
          description: ExamReadinessTranslations.format(
            'inconsistentStudyHabitsDesc',
            languageCode,
            [statistics.currentStreak],
          ),
          score: readiness.consistencyScore,
          icon: 'calendar_today',
        ));
      } else if (statistics.studySessionsLast7Days < 3) {
        weaknesses.add(ReportItem(
          title: ExamReadinessTranslations.get('lowRecentActivity', languageCode),
          description: ExamReadinessTranslations.format(
            'lowRecentActivityDesc',
            languageCode,
            [statistics.studySessionsLast7Days],
          ),
          score: readiness.consistencyScore,
          icon: 'schedule',
        ));
      }
    }
    
    // State-specific weaknesses
    if (readiness.stateScore < 50) {
      weaknesses.add(ReportItem(
        title: ExamReadinessTranslations.get('weakStateSpecificKnowledge', languageCode),
        description: ExamReadinessTranslations.format(
          'weakStateSpecificKnowledgeDesc',
          languageCode,
          [readiness.stateScore.toStringAsFixed(0)],
        ),
        score: readiness.stateScore,
        icon: 'location_on',
      ));
    }
    
    // Accuracy weaknesses
    if (statistics.totalQuestionsAnswered > 0) {
      final accuracy = (statistics.correctAnswers / statistics.totalQuestionsAnswered) * 100;
      if (accuracy < 50) {
        weaknesses.add(ReportItem(
          title: ExamReadinessTranslations.get('lowAnswerAccuracy', languageCode),
          description: ExamReadinessTranslations.format(
            'lowAnswerAccuracyDesc',
            languageCode,
            [accuracy.toStringAsFixed(0)],
          ),
          score: accuracy,
          icon: 'cancel',
        ));
      }
    }
    
    return weaknesses;
  }

  /// Generate recommendations based on weaknesses and readiness
  static List<String> _generateRecommendations(
    ExamReadiness readiness,
    ReportStatistics statistics,
    List<ReportItem> weaknesses,
    String languageCode,
  ) {
    final recommendations = <String>[];
    
    // Mastery recommendations
    if (readiness.masteryScore < 70) {
      if (statistics.totalQuestionsAnswered < 100) {
        recommendations.add(ExamReadinessTranslations.get('answerMoreQuestions', languageCode));
      } else {
        recommendations.add(ExamReadinessTranslations.get('reviewDifficultQuestions', languageCode));
      }
    }
    
    // Exam recommendations
    if (statistics.totalExams == 0) {
      recommendations.add(ExamReadinessTranslations.get('takePracticeExams', languageCode));
    } else if (readiness.examScore < 70) {
      recommendations.add(ExamReadinessTranslations.get('takeMorePracticeExams', languageCode));
    }
    
    // Consistency recommendations
    if (readiness.consistencyScore < 70) {
      if (statistics.currentStreak < 7) {
        recommendations.add(ExamReadinessTranslations.get('buildDailyStudyHabit', languageCode));
      } else if (statistics.studySessionsLast7Days < 5) {
        recommendations.add(ExamReadinessTranslations.get('increaseStudyFrequency', languageCode));
      }
    }
    
    // State-specific recommendations
    if (readiness.stateScore < 50) {
      recommendations.add(ExamReadinessTranslations.get('focusOnStateQuestions', languageCode));
    }
    
    // Overall recommendations
    if (readiness.overallScore < 70) {
      if (readiness.overallScore >= 50) {
        recommendations.add(ExamReadinessTranslations.get('closeToReady', languageCode));
      } else {
        recommendations.add(ExamReadinessTranslations.get('continueStudyingRegularly', languageCode));
      }
    } else if (readiness.overallScore >= 70 && readiness.overallScore < 85) {
      recommendations.add(ExamReadinessTranslations.get('greatProgressKeepItUp', languageCode));
    }
    
    // If no specific weaknesses, provide general encouragement
    if (weaknesses.isEmpty && recommendations.isEmpty) {
      recommendations.add(ExamReadinessTranslations.get('keepUpExcellentWork', languageCode));
    }
    
    return recommendations;
  }
}

