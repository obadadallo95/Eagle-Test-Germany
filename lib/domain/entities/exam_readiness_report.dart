/// Entity representing a detailed Exam Readiness Report
/// 
/// Contains overall readiness score, strengths, weaknesses, and recommendations
class ExamReadinessReport {
  /// Overall readiness score (0.0 - 100.0)
  final double overallScore;
  
  /// Question mastery score (0.0 - 100.0)
  final double masteryScore;
  
  /// Recent exam performance score (0.0 - 100.0)
  final double examScore;
  
  /// Study consistency score (0.0 - 100.0)
  final double consistencyScore;
  
  /// State-specific questions score (0.0 - 100.0)
  final double stateScore;

  /// List of user strengths (positive aspects)
  final List<ReportItem> strengths;
  
  /// List of user weaknesses (areas needing improvement)
  final List<ReportItem> weaknesses;
  
  /// Overall readiness status
  final ReadinessStatus status;
  
  /// Recommendations for improvement
  final List<String> recommendations;
  
  /// Statistics
  final ReportStatistics statistics;

  const ExamReadinessReport({
    required this.overallScore,
    required this.masteryScore,
    required this.examScore,
    required this.consistencyScore,
    required this.stateScore,
    required this.strengths,
    required this.weaknesses,
    required this.status,
    required this.recommendations,
    required this.statistics,
  });
}

/// Individual item in the report (strength or weakness)
class ReportItem {
  /// Title of the item
  final String title;
  
  /// Description/explanation
  final String description;
  
  /// Score/value associated with this item
  final double? score;
  
  /// Icon identifier for UI
  final String icon;

  const ReportItem({
    required this.title,
    required this.description,
    this.score,
    required this.icon,
  });
}

/// Readiness status enum
enum ReadinessStatus {
  excellent,  // >= 85%
  ready,      // >= 70%
  almostReady, // >= 50%
  needsWork,  // < 50%
}

/// Statistics for the report
class ReportStatistics {
  /// Total questions answered
  final int totalQuestionsAnswered;
  
  /// Questions mastered (difficulty >= 2)
  final int questionsMastered;
  
  /// Correct answers count
  final int correctAnswers;
  
  /// Total exams taken
  final int totalExams;
  
  /// Exams passed
  final int examsPassed;
  
  /// Current streak
  final int currentStreak;
  
  /// Study sessions in last 7 days
  final int studySessionsLast7Days;
  
  /// Total study time (in hours)
  final double totalStudyHours;

  const ReportStatistics({
    required this.totalQuestionsAnswered,
    required this.questionsMastered,
    required this.correctAnswers,
    required this.totalExams,
    required this.examsPassed,
    required this.currentStreak,
    required this.studySessionsLast7Days,
    required this.totalStudyHours,
  });
}

