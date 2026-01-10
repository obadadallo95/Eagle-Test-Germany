import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../../core/storage/hive_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/storage/user_preferences_service.dart';

/// Modal Bottom Sheet لاختيار اللغة
class LanguageSelectionSheet extends ConsumerWidget {
  const LanguageSelectionSheet({super.key});

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

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    l10n.language,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 24.sp),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1.h),
          
          // Language List - Scrollable
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
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
                      ? Icon(Icons.check, color: Theme.of(context).primaryColor, size: 24.sp)
                      : null,
                  selected: isSelected,
                  onTap: () async {
                    final newLanguageCode = language['code']!;
                    // Update locale provider
                    ref.read(localeProvider.notifier).changeLocale(newLanguageCode);
                    // Save to Hive (for notifications)
                    await HiveService.saveLanguage(newLanguageCode);
                    
                    // Re-schedule notifications if enabled (to update language)
                    final isReminderEnabled = await UserPreferencesService.getReminderEnabled();
                    if (isReminderEnabled) {
                      final reminderTime = await UserPreferencesService.getReminderTime();
                      if (reminderTime != null) {
                        await NotificationService.scheduleDailyNotification(reminderTime);
                      }
                    }
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

