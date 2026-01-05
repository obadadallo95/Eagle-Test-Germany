import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/hive_service.dart';

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('de')) {
    // جلب اللغة المحفوظة عند التهيئة
    final savedLanguage = HiveService.getSavedLanguage();
    if (savedLanguage != null) {
      state = Locale(savedLanguage);
    }
  }

  void toggleLanguage() {
    final newLocale = state.languageCode == 'de' ? const Locale('ar') : const Locale('de');
    state = newLocale;
    // حفظ اللغة المختارة
    HiveService.saveLanguage(newLocale.languageCode);
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});
