/// Entity representing a weekly progress story
/// 
/// A human-readable narrative that turns statistics into a motivating story.
class ProgressStory {
  /// Title of the story (e.g., "This Week's Progress")
  final String title;
  
  /// List of bullet points describing achievements
  /// Example: ["You mastered 12 new questions", "Improved your weakest topic by 14%"]
  final List<String> bulletPoints;
  
  /// Final confidence message
  /// Example: "You are now 18% more ready than last week."
  final String confidenceMessage;
  
  /// Week start date (for reference)
  final DateTime weekStart;
  
  /// Week end date (for reference)
  final DateTime weekEnd;

  const ProgressStory({
    required this.title,
    required this.bulletPoints,
    required this.confidenceMessage,
    required this.weekStart,
    required this.weekEnd,
  });

  /// Creates an empty story (for new users)
  factory ProgressStory.empty() {
    final now = DateTime.now();
    return ProgressStory(
      title: 'Getting Started',
      bulletPoints: ['Welcome to your citizenship journey!'],
      confidenceMessage: 'Every question you study brings you closer to success.',
      weekStart: now,
      weekEnd: now,
    );
  }

  @override
  String toString() {
    return 'ProgressStory(title: $title, points: ${bulletPoints.length})';
  }
}

