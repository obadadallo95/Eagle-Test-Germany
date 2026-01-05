import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/favorites_service.dart';
import '../../core/debug/app_logger.dart';

/// Provider لخدمة المفضلة
final favoritesStorageProvider = Provider<FavoritesService>((ref) {
  return FavoritesService();
});

/// StateNotifier لإدارة قائمة المفضلة
class FavoritesNotifier extends StateNotifier<List<int>> {
  FavoritesNotifier() : super([]) {
    _loadFavorites();
  }

  /// تحميل المفضلة من التخزين
  Future<void> _loadFavorites() async {
    AppLogger.functionStart('_loadFavorites', source: 'FavoritesNotifier');
    try {
      final favorites = FavoritesService.getFavoriteIds();
      state = favorites;
      AppLogger.event('Favorites loaded', source: 'FavoritesNotifier', data: {'count': favorites.length});
      AppLogger.functionEnd('_loadFavorites', source: 'FavoritesNotifier');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load favorites', source: 'FavoritesNotifier', error: e, stackTrace: stackTrace);
      state = [];
    }
  }

  /// تبديل حالة المفضلة لسؤال معين
  Future<void> toggleFavorite(int questionId) async {
    AppLogger.functionStart('toggleFavorite', source: 'FavoritesNotifier');
    AppLogger.info('Toggling favorite for question $questionId', source: 'FavoritesNotifier');
    
    try {
      final wasAdded = await FavoritesService.toggleFavorite(questionId);
      
      // تحديث الحالة بناءً على النتيجة
      if (wasAdded) {
        // تمت الإضافة
        if (!state.contains(questionId)) {
          state = [...state, questionId];
        }
        AppLogger.event('Question added to favorites', source: 'FavoritesNotifier', data: {'questionId': questionId});
      } else {
        // تمت الإزالة
        state = state.where((id) => id != questionId).toList();
        AppLogger.event('Question removed from favorites', source: 'FavoritesNotifier', data: {'questionId': questionId});
      }
      
      AppLogger.functionEnd('toggleFavorite', source: 'FavoritesNotifier', result: wasAdded);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to toggle favorite', source: 'FavoritesNotifier', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// التحقق من كون السؤال في المفضلة
  bool isFavorite(int questionId) {
    return state.contains(questionId);
  }

  /// إعادة تحميل المفضلة من التخزين
  Future<void> refresh() async {
    await _loadFavorites();
  }
}

/// Provider لإدارة حالة المفضلة
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<int>>((ref) {
  return FavoritesNotifier();
});

