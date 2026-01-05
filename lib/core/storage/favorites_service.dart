import 'package:hive_flutter/hive_flutter.dart';
import '../debug/app_logger.dart';

/// خدمة إدارة المفضلة باستخدام Hive Box منفصل
class FavoritesService {
  static const String _favoritesBoxName = 'user_favorites';
  static const String _favoritesListKey = 'favorite_ids';
  
  static Box? _favoritesBox;

  /// تهيئة صندوق المفضلة
  static Future<void> init() async {
    AppLogger.functionStart('FavoritesService.init', source: 'FavoritesService');
    try {
      _favoritesBox = await Hive.openBox(_favoritesBoxName);
      AppLogger.event('Favorites box opened', source: 'FavoritesService');
      AppLogger.functionEnd('FavoritesService.init', source: 'FavoritesService');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize favorites box', source: 'FavoritesService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// تبديل حالة المفضلة لسؤال معين
  /// Returns: true if added, false if removed
  static Future<bool> toggleFavorite(int questionId) async {
    AppLogger.functionStart('toggleFavorite', source: 'FavoritesService');
    AppLogger.info('Toggling favorite for question $questionId', source: 'FavoritesService');
    
    try {
      if (_favoritesBox == null) {
        AppLogger.warn('Favorites box is null! Initializing...', source: 'FavoritesService');
        await init();
      }

      final currentFavorites = getFavoriteIds();
      final isCurrentlyFavorite = currentFavorites.contains(questionId);
      
      if (isCurrentlyFavorite) {
        // إزالة من المفضلة
        currentFavorites.remove(questionId);
        AppLogger.event('Question removed from favorites', source: 'FavoritesService', data: {'questionId': questionId});
      } else {
        // إضافة إلى المفضلة
        currentFavorites.add(questionId);
        AppLogger.event('Question added to favorites', source: 'FavoritesService', data: {'questionId': questionId});
      }

      await _favoritesBox?.put(_favoritesListKey, currentFavorites);
      
      // التحقق من الحفظ
      final saved = getFavoriteIds();
      AppLogger.info('Favorites updated: ${saved.length} total favorites', source: 'FavoritesService');
      
      AppLogger.functionEnd('toggleFavorite', source: 'FavoritesService', result: !isCurrentlyFavorite);
      return !isCurrentlyFavorite; // true if added, false if removed
    } catch (e, stackTrace) {
      AppLogger.error('Failed to toggle favorite', source: 'FavoritesService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// التحقق من كون السؤال في المفضلة
  static bool isFavorite(int questionId) {
    final favorites = getFavoriteIds();
    return favorites.contains(questionId);
  }

  /// جلب قائمة معرفات الأسئلة المفضلة
  static List<int> getFavoriteIds() {
    AppLogger.functionStart('getFavoriteIds', source: 'FavoritesService');
    
    try {
      if (_favoritesBox == null) {
        AppLogger.warn('Favorites box is null', source: 'FavoritesService');
        return [];
      }

      final favoritesRaw = _favoritesBox?.get(_favoritesListKey);
      
      if (favoritesRaw == null) {
        AppLogger.info('No favorites found', source: 'FavoritesService');
        return [];
      }

      if (favoritesRaw is List) {
        // تحويل القائمة إلى List<int> بشكل آمن
        final favorites = favoritesRaw
            .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
            .where((e) => e > 0)
            .toList();
        
        AppLogger.functionEnd('getFavoriteIds', source: 'FavoritesService', result: favorites.length);
        return favorites;
      }

      AppLogger.warn('Favorites is not a List, type: ${favoritesRaw.runtimeType}', source: 'FavoritesService');
      return [];
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get favorite IDs', source: 'FavoritesService', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// إضافة سؤال إلى المفضلة
  static Future<void> addFavorite(int questionId) async {
    if (!isFavorite(questionId)) {
      await toggleFavorite(questionId);
    }
  }

  /// إزالة سؤال من المفضلة
  static Future<void> removeFavorite(int questionId) async {
    if (isFavorite(questionId)) {
      await toggleFavorite(questionId);
    }
  }

  /// مسح جميع المفضلة
  static Future<void> clearAll() async {
    AppLogger.functionStart('clearAll', source: 'FavoritesService');
    try {
      await _favoritesBox?.put(_favoritesListKey, <int>[]);
      AppLogger.event('All favorites cleared', source: 'FavoritesService');
      AppLogger.functionEnd('clearAll', source: 'FavoritesService');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear favorites', source: 'FavoritesService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// حذف صندوق المفضلة من القرص (Factory Reset)
  static Future<void> deleteFromDisk() async {
    AppLogger.functionStart('deleteFromDisk', source: 'FavoritesService');
    try {
      await _favoritesBox?.close();
      await Hive.deleteBoxFromDisk(_favoritesBoxName);
      // إعادة تهيئة الصندوق
      _favoritesBox = await Hive.openBox(_favoritesBoxName);
      AppLogger.event('Favorites box deleted from disk', source: 'FavoritesService');
      AppLogger.functionEnd('deleteFromDisk', source: 'FavoritesService');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete favorites box from disk', source: 'FavoritesService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

