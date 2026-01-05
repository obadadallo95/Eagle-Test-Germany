import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/user_preferences_service.dart';

/// Provider لإدارة الوضع الفاتح/الداكن
class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _keyThemeMode = 'theme_mode';
  bool _isInitialized = false;
  
  /// للتحقق من حالة التهيئة
  bool get isInitialized => _isInitialized;

  ThemeNotifier() : super(ThemeMode.system) {
    // لا نحمل الثيم هنا لأننا نحملها في main() قبل runApp()
    // هذا يمنع race condition ويضمن أن الثيم محملة بشكل صحيح من البداية
  }

  /// تحميل الوضع المحفوظ بشكل متزامن (يتم استدعاؤه من main)
  static Future<ThemeMode> loadThemeMode() async {
    try {
      final prefs = await UserPreferencesService.getSharedPreferences();
      final savedTheme = prefs.getString(_keyThemeMode);
      
      if (savedTheme != null && savedTheme.isNotEmpty) {
        switch (savedTheme.toLowerCase()) {
          case 'light':
            return ThemeMode.light;
          case 'dark':
            return ThemeMode.dark;
          case 'system':
          default:
            return ThemeMode.system;
        }
      }
      return ThemeMode.system;
    } catch (e) {
      // في حالة الخطأ، استخدم الوضع الافتراضي
      return ThemeMode.system;
    }
  }

  /// تهيئة الثيم بقيمة محملة مسبقاً
  /// يتم استدعاؤها من MyApp.build() بعد تحميل الثيم في main()
  void initializeWith(ThemeMode mode) {
    if (!_isInitialized) {
      state = mode;
      _isInitialized = true;
    }
  }

  /// تغيير الوضع وحفظه على الجهاز بشكل دائم
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      // تحديث الحالة أولاً
      state = mode;
      
      // حفظ الوضع المختار على الجهاز بشكل دائم
      final prefs = await UserPreferencesService.getSharedPreferences();
      
      // تحويل ThemeMode إلى String بشكل صريح
      String themeModeString;
      switch (mode) {
        case ThemeMode.light:
          themeModeString = 'light';
          break;
        case ThemeMode.dark:
          themeModeString = 'dark';
          break;
        case ThemeMode.system:
          themeModeString = 'system';
          break;
      }
      
      // حفظ القيمة
      final success = await prefs.setString(_keyThemeMode, themeModeString);
      
      // التأكد من الحفظ
      if (success) {
        final saved = prefs.getString(_keyThemeMode);
        if (saved != themeModeString) {
          // إعادة المحاولة إذا فشل الحفظ
          await prefs.setString(_keyThemeMode, themeModeString);
        }
      }
    } catch (e) {
      // في حالة الخطأ، على الأقل قم بتحديث الحالة
      state = mode;
    }
  }

  /// التبديل بين الفاتح والداكن
  Future<void> toggleTheme() async {
    if (state == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// Provider لتهيئة الثيم بشكل متزامن
final initialThemeProvider = FutureProvider<ThemeMode>((ref) async {
  return await ThemeNotifier.loadThemeMode();
});

