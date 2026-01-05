import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/user_preferences_service.dart';

/// Provider لإدارة اللغة (Locale) مع دعم 5 لغات
class LocaleNotifier extends StateNotifier<Locale> {
  static const String _keySavedLocale = 'saved_locale';
  
  LocaleNotifier() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  /// تحميل اللغة المحفوظة
  Future<void> _loadSavedLocale() async {
    final prefs = await UserPreferencesService.getSharedPreferences();
    final savedLocaleCode = prefs.getString(_keySavedLocale);
    
    if (savedLocaleCode != null) {
      state = Locale(savedLocaleCode);
    } else {
      // محاولة استخدام لغة الجهاز
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      if (_isSupported(deviceLocale.languageCode)) {
        state = Locale(deviceLocale.languageCode);
      } else {
        state = const Locale('en'); // افتراضي: الإنجليزية
      }
    }
  }

  /// التحقق من دعم اللغة
  bool _isSupported(String languageCode) {
    const supported = ['en', 'de', 'ar', 'tr', 'uk', 'ru'];
    return supported.contains(languageCode);
  }

  /// تغيير اللغة
  Future<void> changeLocale(String languageCode) async {
    if (!_isSupported(languageCode)) {
      return; // اللغة غير مدعومة
    }

    state = Locale(languageCode);
    
    // حفظ اللغة المختارة
    final prefs = await UserPreferencesService.getSharedPreferences();
    await prefs.setString(_keySavedLocale, languageCode);
  }

  /// جلب اللغة الحالية
  String get currentLanguageCode => state.languageCode;
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

