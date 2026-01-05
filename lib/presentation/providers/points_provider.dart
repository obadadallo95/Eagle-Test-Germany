import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/hive_service.dart';
import '../../core/debug/app_logger.dart';

/// Provider لإجمالي النقاط
final totalPointsProvider = StateNotifierProvider<TotalPointsNotifier, int>((ref) {
  return TotalPointsNotifier();
});

class TotalPointsNotifier extends StateNotifier<int> {
  TotalPointsNotifier() : super(HiveService.getTotalPoints()) {
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    final points = HiveService.getTotalPoints();
    state = points;
    AppLogger.log('Total points loaded: $points', source: 'TotalPointsNotifier');
  }

  /// إضافة نقاط
  Future<int> addPoints({
    required int points,
    required String source,
    Map<String, dynamic>? details,
  }) async {
    final newTotal = await HiveService.addPoints(
      points: points,
      source: source,
      details: details,
    );
    state = newTotal;
    AppLogger.event('Points added via provider', source: 'TotalPointsNotifier', data: {
      'points': points,
      'total': newTotal,
      'source': source,
    });
    return newTotal;
  }

  /// تحديث النقاط من Hive
  Future<void> refresh() async {
    await _loadPoints();
  }
}

/// Provider لسجل النقاط
final pointsHistoryProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return HiveService.getPointsHistory();
});

/// Provider للنقاط حسب المصدر
final pointsBySourceProvider = Provider.family<int, String>((ref, source) {
  return HiveService.getPointsBySource(source);
});

