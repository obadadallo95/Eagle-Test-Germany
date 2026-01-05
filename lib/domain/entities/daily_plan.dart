/// Entity representing a daily study plan
/// 
/// Contains the list of question IDs to study today and a human-readable
/// explanation of why this plan was generated.
class DailyPlan {
  /// List of question IDs to study today (5-7 questions max)
  final List<int> questionIds;
  
  /// Human-readable explanation of the plan
  /// Example: "Today's Focus: 3 weak questions (Topic: Constitution), 2 SRS reviews, 1 state-specific question"
  final String explanation;
  
  /// Estimated time to complete (in minutes)
  final int estimatedMinutes;
  
  /// Plan type: 'balanced', 'weakness_focus', 'srs_review', 'exam_prep'
  final String planType;

  const DailyPlan({
    required this.questionIds,
    required this.explanation,
    required this.estimatedMinutes,
    required this.planType,
  });

  /// Creates an empty plan (for new users)
  factory DailyPlan.empty() {
    return const DailyPlan(
      questionIds: [],
      explanation: 'Start by exploring questions in Study Mode.',
      estimatedMinutes: 0,
      planType: 'empty',
    );
  }

  @override
  String toString() {
    return 'DailyPlan(questions: ${questionIds.length}, type: $planType, time: ${estimatedMinutes}min)';
  }
}

