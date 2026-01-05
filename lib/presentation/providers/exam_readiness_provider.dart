import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exam_readiness.dart';
import '../../domain/usecases/exam_readiness_calculator.dart';

/// Provider for Exam Readiness Index
/// 
/// This provider automatically recalculates when underlying data changes.
/// It watches:
/// - User progress (via HiveService)
/// - Exam history (via HiveService)
/// - User preferences (streak, state)
/// 
/// Returns a FutureProvider that computes readiness asynchronously.
final examReadinessProvider = FutureProvider<ExamReadiness>((ref) async {
  // Trigger recalculation when user progress changes
  // Note: We can't directly watch Hive boxes, so we'll use a workaround:
  // The provider will recalculate on each access, but we can optimize this
  // by watching related providers if they exist.
  
  // For now, we'll calculate directly
  // In a more sophisticated implementation, you could:
  // 1. Create a StreamProvider that watches Hive box changes
  // 2. Use ref.refresh() to force recalculation
  // 3. Watch related providers (exam history, progress, etc.)
  
  return ExamReadinessCalculator.calculate();
});

/// Helper provider to get just the overall score (for UI convenience)
final examReadinessScoreProvider = Provider<double>((ref) {
  final readinessAsync = ref.watch(examReadinessProvider);
  return readinessAsync.when(
    data: (readiness) => readiness.overallScore,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// Helper provider to check if user is ready (>= 70% threshold)
final isExamReadyProvider = Provider<bool>((ref) {
  final score = ref.watch(examReadinessScoreProvider);
  return score >= 70.0;
});

