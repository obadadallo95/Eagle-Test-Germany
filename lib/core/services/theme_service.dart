import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../debug/app_logger.dart';

/// Theme mode options
enum AppThemeMode { light, dark, system }

/// Service to persist and retrieve theme preference
class ThemeService {
  ThemeService._();
  
  static const String _boxName = 'settings';
  static const String _themeKey = 'theme_mode';
  
  /// Save theme mode preference
  static Future<void> setThemeMode(AppThemeMode mode) async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_themeKey, mode.name);
      AppLogger.info(
        'Theme mode saved: ${mode.name}',
        source: 'ThemeService',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to save theme mode',
        source: 'ThemeService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Get saved theme mode preference
  static Future<AppThemeMode> getThemeMode() async {
    try {
      final box = await Hive.openBox(_boxName);
      final value = box.get(_themeKey, defaultValue: 'system') as String;
      
      final mode = AppThemeMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => AppThemeMode.system,
      );
      
      AppLogger.info(
        'Theme mode loaded: ${mode.name}',
        source: 'ThemeService',
      );
      
      return mode;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to load theme mode, defaulting to system',
        source: 'ThemeService',
        error: e,
        stackTrace: stackTrace,
      );
      return AppThemeMode.system;
    }
  }
  
  /// Convert AppThemeMode to Flutter's ThemeMode
  static ThemeMode toFlutterThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
  
  /// Get display name for theme mode
  static String getDisplayName(AppThemeMode mode, {String locale = 'en'}) {
    switch (mode) {
      case AppThemeMode.light:
        return _localizedNames['light']?[locale] ?? 'Light';
      case AppThemeMode.dark:
        return _localizedNames['dark']?[locale] ?? 'Dark';
      case AppThemeMode.system:
        return _localizedNames['system']?[locale] ?? 'System';
    }
  }
  
  /// Get icon for theme mode
  static IconData getIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.phone_android;
    }
  }
  
  // Localized names (basic fallback, actual translations in .arb files)
  static const Map<String, Map<String, String>> _localizedNames = {
    'light': {
      'en': 'Light',
      'de': 'Hell',
      'ar': 'فاتح',
      'tr': 'Açık',
      'ru': 'Светлая',
      'uk': 'Світла',
    },
    'dark': {
      'en': 'Dark',
      'de': 'Dunkel',
      'ar': 'داكن',
      'tr': 'Koyu',
      'ru': 'Темная',
      'uk': 'Темна',
    },
    'system': {
      'en': 'System',
      'de': 'System',
      'ar': 'النظام',
      'tr': 'Sistem',
      'ru': 'Система',
      'uk': 'Система',
    },
  };
}

