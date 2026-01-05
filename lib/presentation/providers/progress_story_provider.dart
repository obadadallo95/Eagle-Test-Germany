import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/progress_story.dart';
import '../../domain/usecases/weekly_progress_story_builder.dart';

/// Provider for Weekly Progress Story
/// 
/// This provider generates a weekly narrative comparing the last 7 days
/// to the previous 7 days, highlighting achievements and progress.
/// 
/// The story is regenerated when underlying data changes.
final weeklyProgressStoryProvider = FutureProvider<ProgressStory>((ref) async {
  return WeeklyProgressStoryBuilder.build();
});

/// Helper provider to get just the title (for UI convenience)
final progressStoryTitleProvider = Provider<String>((ref) {
  final storyAsync = ref.watch(weeklyProgressStoryProvider);
  return storyAsync.when(
    data: (story) => story.title,
    loading: () => 'Loading...',
    error: (_, __) => 'Progress Summary',
  );
});

/// Helper provider to check if story has content
final hasProgressStoryProvider = Provider<bool>((ref) {
  final storyAsync = ref.watch(weeklyProgressStoryProvider);
  return storyAsync.when(
    data: (story) => story.bulletPoints.isNotEmpty,
    loading: () => false,
    error: (_, __) => false,
  );
});

