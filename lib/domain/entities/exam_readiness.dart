/// Entity representing the Exam Readiness Index breakdown
/// 
/// Contains the overall readiness score (0-100) and individual component scores
/// for explainability and transparency.
class ExamReadiness {
  /// Overall readiness score (0.0 - 100.0)
  final double overallScore;
  
  /// Question mastery score (0.0 - 100.0)
  /// Based on percentage of questions answered correctly and SRS difficulty levels
  final double masteryScore;
  
  /// Recent exam performance score (0.0 - 100.0)
  /// Based on last 3 exam simulations
  final double examScore;
  
  /// Study consistency score (0.0 - 100.0)
  /// Based on streak and study sessions in last 7 days
  final double consistencyScore;
  
  /// State-specific questions score (0.0 - 100.0)
  /// Based on mastery of selected Bundesland questions
  final double stateScore;

  const ExamReadiness({
    required this.overallScore,
    required this.masteryScore,
    required this.examScore,
    required this.consistencyScore,
    required this.stateScore,
  });

  /// Creates a zero readiness (new user)
  factory ExamReadiness.zero() {
    return const ExamReadiness(
      overallScore: 0.0,
      masteryScore: 0.0,
      examScore: 0.0,
      consistencyScore: 0.0,
      stateScore: 0.0,
    );
  }

  @override
  String toString() {
    return 'ExamReadiness('
        'overall: ${overallScore.toStringAsFixed(1)}%, '
        'mastery: ${masteryScore.toStringAsFixed(1)}%, '
        'exam: ${examScore.toStringAsFixed(1)}%, '
        'consistency: ${consistencyScore.toStringAsFixed(1)}%, '
        'state: ${stateScore.toStringAsFixed(1)}%'
        ')';
  }
}

