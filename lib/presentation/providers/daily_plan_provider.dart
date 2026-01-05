import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/daily_plan.dart';
import '../../domain/usecases/smart_daily_plan_generator.dart';

/// Provider for Smart Daily Plan
/// 
/// This provider automatically regenerates the plan when underlying data changes.
/// The plan is recalculated on each access to ensure it's always current.
final smartDailyPlanProvider = FutureProvider<DailyPlan>((ref) async {
  return SmartDailyPlanGenerator.generate();
});

/// Helper provider to get just the question IDs (for UI convenience)
final dailyPlanQuestionIdsProvider = Provider<List<int>>((ref) {
  final planAsync = ref.watch(smartDailyPlanProvider);
  return planAsync.when(
    data: (plan) => plan.questionIds,
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Helper provider to check if plan is empty
final hasDailyPlanProvider = Provider<bool>((ref) {
  final planAsync = ref.watch(smartDailyPlanProvider);
  return planAsync.when(
    data: (plan) => plan.questionIds.isNotEmpty,
    loading: () => false,
    error: (_, __) => false,
  );
});

