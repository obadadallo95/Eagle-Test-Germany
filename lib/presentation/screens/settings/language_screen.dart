import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';
import 'package:politik_test/l10n/app_localizations.dart';

/// شاشة اختيار اللغة
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  /// قائمة اللغات المدعومة مع الأعلام
  static const List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸', 'nativeName': 'English'},
    {'code': 'de', 'name': 'German', 'flag': '🇩🇪', 'nativeName': 'Deutsch'},
    {'code': 'ar', 'name': 'Arabic', 'flag': '🇸🇾', 'nativeName': 'العربية'},
    {'code': 'tr', 'name': 'Turkish', 'flag': '🇹🇷', 'nativeName': 'Türkçe'},
    {'code': 'uk', 'name': 'Ukrainian', 'flag': '🇺🇦', 'nativeName': 'Українська'},
    {'code': 'ru', 'name': 'Russian', 'flag': '🇷🇺', 'nativeName': 'Русский'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language),
      ),
      body: AdaptivePageWrapper(
        padding: EdgeInsets.zero,
        enableScroll: false, // ListView يمرر نفسه
        child: ListView.builder(
          itemCount: _languages.length,
          itemBuilder: (context, index) {
          final language = _languages[index];
          final isSelected = currentLocale.languageCode == language['code'];

          return ListTile(
            leading: Text(
              language['flag']!,
              style: TextStyle(fontSize: 32.sp),
            ),
            title: Text(language['name']!, style: TextStyle(fontSize: 16.sp)),
            subtitle: Text(language['nativeName']!, style: TextStyle(fontSize: 14.sp)),
            trailing: isSelected
                ? Icon(Icons.check, color: Colors.green, size: 24.sp)
                : null,
            onTap: () {
              ref.read(localeProvider.notifier).changeLocale(language['code']!);
              Navigator.pop(context);
            },
            selected: isSelected,
          );
        },
        ),
      ),
    );
  }
}

