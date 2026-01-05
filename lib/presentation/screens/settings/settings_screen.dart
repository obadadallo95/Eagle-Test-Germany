import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../../core/storage/hive_service.dart';
import '../../../core/storage/user_preferences_service.dart';
import '../../../core/storage/favorites_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/ai_tutor_service.dart';
import '../../../core/debug/app_logger.dart';
import '../../../core/theme/app_colors.dart';
import '../main_screen.dart';
import '../subscription/paywall_screen.dart';
import 'language_selection_sheet.dart';
import 'legal_screen.dart';
import 'about_screen.dart';
import '../../../domain/entities/question.dart';
import 'widgets/settings_section_card.dart';
import 'widgets/settings_tile.dart';
import 'widgets/danger_zone_card.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';

/// -----------------------------------------------------------------
/// ⚙️ SETTINGS SCREEN / EINSTELLUNGEN / شاشة الإعدادات
/// -----------------------------------------------------------------
/// Comprehensive settings screen with grouped options.
/// Includes language selection, theme toggle, TTS speed control, and data management.
/// Organized into three main sections: General, Audio, and Data.
/// -----------------------------------------------------------------
/// **Deutsch:** Umfassende Einstellungsseite mit gruppierten Optionen.
/// Enthält Sprachauswahl, Design-Umschaltung, TTS-Geschwindigkeitssteuerung und Datenverwaltung.
/// -----------------------------------------------------------------
/// **العربية:** شاشة إعدادات شاملة مع خيارات مجمعة.
/// تتضمن اختيار اللغة، تبديل الثيم، التحكم بسرعة TTS، وإدارة البيانات.
/// -----------------------------------------------------------------
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  double _ttsSpeed = 1.0; // سرعة TTS الافتراضية
  bool _isReminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await UserPreferencesService.getSharedPreferences();
    final reminderTime = await UserPreferencesService.getReminderTime();
    final isReminderOn = await UserPreferencesService.getReminderEnabled();
    setState(() {
      _ttsSpeed = prefs.getDouble('tts_speed') ?? 1.0;
      _isReminderEnabled = isReminderOn;
      _reminderTime = reminderTime ?? const TimeOfDay(hour: 20, minute: 0);
    });
    
    // إذا كان الإشعار مفعلاً، جدوله
    if (_isReminderEnabled) {
      await NotificationService.scheduleDailyNotification(_reminderTime);
      // جدولة إشعارات إضافية
      await NotificationService.scheduleSrsReminder();
      await NotificationService.scheduleStreakReminder();
    }
  }

  Future<void> _saveTtsSpeed(double speed) async {
    final prefs = await UserPreferencesService.getSharedPreferences();
    await prefs.setDouble('tts_speed', speed);
    setState(() {
      _ttsSpeed = speed;
    });
  }

  Future<void> _showResetConfirmation() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.resetProgress ?? 'Reset Progress'),
        content: Text(
          l10n?.resetProgressMessage ?? 
          'Are you sure you want to reset all your progress? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n?.confirm ?? 'Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HiveService.clearAll();
      await UserPreferencesService.clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.progressReset ?? 'Progress reset successfully')),
        );
      }
    }
  }

  String _getCurrentLanguageFlag(String languageCode) {
    const flags = {
      'en': '🇺🇸',
      'de': '🇩🇪',
      'ar': '🇸🇾',
      'tr': '🇹🇷',
      'uk': '🇺🇦',
      'ru': '🇷🇺',
    };
    return flags[languageCode] ?? '🌍';
  }

  /// فحص اتصال AI
  Future<void> _checkAiConnectivity() async {
    AppLogger.functionStart('_checkAiConnectivity', source: 'SettingsScreen');
    final currentLocale = ref.read(localeProvider);
    final userLanguage = currentLocale.languageCode;
    final isArabic = userLanguage == 'ar';
    
    AppLogger.info('Checking AI connectivity...', source: 'SettingsScreen');

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.eagleGold),
            SizedBox(height: 16.h),
            Text(
              isArabic ? 'جاري التحقق...' : 'Checking connection...',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    try {
      // Create a test question for the ping
      const testQuestion = Question(
        id: 999,
        categoryId: 'test',
        questionText: {
          'de': 'Test question',
          'ar': 'سؤال تجريبي',
          'en': 'Test question',
          'tr': 'Test sorusu',
          'uk': 'Тестове питання',
          'ru': 'Тестовый вопрос',
        },
        answers: [
          Answer(
            id: 'a',
            text: {
              'de': 'Test',
              'ar': 'اختبار',
              'en': 'Test',
              'tr': 'Test',
              'uk': 'Тест',
              'ru': 'Тест',
            },
          ),
        ],
        correctAnswerId: 'a',
        stateCode: null,
      );

      // Try to get explanation (this will test the API)
      final explanation = await AiTutorService.explainQuestion(
        question: testQuestion,
        userLanguage: userLanguage,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Check if we got a real response or error message
      final isConnected = !explanation.contains('error') && 
                          !explanation.contains('خطأ') &&
                          !explanation.contains('Fehler') &&
                          !explanation.contains('عذراً') &&
                          !explanation.contains('Sorry') &&
                          !explanation.contains('Entschuldigung') &&
                          explanation.isNotEmpty;
      
      AppLogger.event('AI connectivity check completed', source: 'SettingsScreen', data: {
        'isConnected': isConnected,
        'responseLength': explanation.length,
      });

      // Show result
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.darkSurface,
            title: Row(
              children: [
                Icon(
                  isConnected ? Icons.check_circle : Icons.error_outline,
                  color: isConnected ? Colors.green : Colors.red,
                  size: 32.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    isConnected
                        ? (isArabic ? 'AI متصل' : 'AI Connected')
                        : (isArabic ? 'AI غير متصل' : 'AI Offline'),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              isConnected
                  ? (isArabic 
                      ? 'خدمة AI تعمل بشكل صحيح.' 
                      : 'AI service is working correctly.')
                  : (isArabic
                      ? 'لا يمكن الاتصال بخدمة AI. يرجى التحقق من اتصال الإنترنت.'
                      : 'Cannot connect to AI service. Please check your internet connection.'),
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  isArabic ? 'موافق' : 'OK',
                  style: GoogleFonts.poppins(color: AppColors.eagleGold),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('AI connectivity check failed', source: 'SettingsScreen', error: e, stackTrace: stackTrace);
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.darkSurface,
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 32.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    isArabic ? 'خطأ في الاتصال' : 'Connection Error',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              isArabic
                  ? 'حدث خطأ أثناء التحقق من اتصال AI: $e'
                  : 'An error occurred while checking AI connection: $e',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  isArabic ? 'موافق' : 'OK',
                  style: GoogleFonts.poppins(color: AppColors.eagleGold),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);
    final isArabic = currentLocale.languageCode == 'ar';
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n?.settings ?? 'Settings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: AdaptivePageWrapper(
        padding: EdgeInsets.zero,
        enableScroll: false, // ListView يمرر نفسه
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
          // 1. General
          SettingsSectionCard(
            title: l10n?.general ?? 'General',
            children: [
              SettingsTile(
                leading: Icons.language,
                title: l10n?.language ?? 'Language',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getCurrentLanguageFlag(currentLocale.languageCode),
                      style: TextStyle(fontSize: 24.sp),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.chevron_right, size: 20.sp),
                  ],
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => const LanguageSelectionSheet(),
                  );
                },
              ),
              Divider(height: 1.h),
              SettingsTile(
                leading: _getThemeIcon(themeMode),
                title: l10n?.theme ?? 'Theme',
                trailing: _buildThemeButtons(context, ref, themeMode, l10n, isArabic),
              ),
              Divider(height: 1.h),
              SettingsTile(
                leading: Icons.star,
                iconColor: AppColors.eagleGold,
                title: l10n?.upgradeToPro ?? 'Premium Subscription',
                subtitle: ref.watch(subscriptionProvider).isPro
                    ? (l10n?.activeSubscription ?? 'Active Subscription')
                    : (l10n?.upgradeForAdditionalFeatures ?? 'Upgrade for additional features'),
                trailing: ref.watch(subscriptionProvider).isPro
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          isArabic ? 'مشترك' : 'Active',
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Icon(Icons.arrow_forward_ios, size: 16.sp, color: AppColors.eagleGold),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaywallScreen(),
                    ),
                  );
                  AppLogger.event('Premium subscription tapped', source: 'SettingsScreen');
                },
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 2. Audio & Accessibility
          SettingsSectionCard(
            title: l10n?.audio ?? 'Audio',
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n?.speakingSpeed ?? 'Speaking Speed',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${_ttsSpeed.toStringAsFixed(1)}x',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _ttsSpeed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      label: '${_ttsSpeed.toStringAsFixed(1)}x',
                      onChanged: (value) {
                        _saveTtsSpeed(value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 3. Notifications
          SettingsSectionCard(
            title: l10n?.notifications ?? 'Notifications / Benachrichtigungen',
            children: [
              SettingsTile(
                leading: Icons.notifications_active,
                iconSize: 28.sp,
                title: l10n?.dailyReminder ?? 'Daily Reminder',
                subtitle: l10n?.dailyReminderDescription ?? 'Get reminded to study daily',
                trailing: Switch(
                  value: _isReminderEnabled,
                  onChanged: (value) async {
                    setState(() {
                      _isReminderEnabled = value;
                    });
                    await UserPreferencesService.saveReminderEnabled(value);
                    
                    if (value) {
                      await NotificationService.scheduleDailyNotification(_reminderTime);
                      if (mounted && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n?.reminderEnabled ?? 'Daily reminder enabled',
                            ),
                          ),
                        );
                      }
                    } else {
                      await NotificationService.cancelNotifications();
                      if (mounted && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n?.reminderDisabled ?? 'Daily reminder disabled',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              if (_isReminderEnabled) ...[
                Divider(height: 1.h),
                SettingsTile(
                  leading: Icons.access_time,
                  iconSize: 28.sp,
                  title: l10n?.reminderTime ?? 'Time / Uhrzeit',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _reminderTime.format(context),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _reminderTime,
                    );
                    
                    if (pickedTime != null) {
                      setState(() {
                        _reminderTime = pickedTime;
                      });
                      await UserPreferencesService.saveReminderTime(pickedTime);
                      
                      if (_isReminderEnabled) {
                        await NotificationService.scheduleDailyNotification(pickedTime);
                        if (mounted && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n?.reminderTimeUpdated ?? 'Reminder time updated',
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ],
          ),

          SizedBox(height: 16.h),

          // 4. Data & Privacy
          SettingsSectionCard(
            title: l10n?.data ?? 'Data',
            children: [
              SettingsTile(
                leading: Icons.refresh,
                iconColor: Colors.red,
                title: l10n?.resetProgress ?? 'Reset Progress',
                textColor: Colors.red,
                onTap: _showResetConfirmation,
              ),
              Divider(height: 1.h),
              SettingsTile(
                leading: Icons.balance,
                iconColor: Colors.blue,
                title: l10n?.legalInformation ?? 'Legal Information',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LegalScreen()),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 5. About & Support
          SettingsSectionCard(
            title: l10n?.about ?? 'About',
            children: [
              SettingsTile(
                leading: Icons.info_outline,
                iconColor: AppColors.eagleGold,
                title: l10n?.about ?? 'About',
                subtitle: currentLocale.languageCode == 'ar'
                    ? 'تعرف على التطبيق والميزات'
                    : 'Learn about the app and features',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 6. Advanced
          SettingsSectionCard(
            title: currentLocale.languageCode == 'ar' ? 'متقدم' : 'Advanced',
            children: [
              SettingsTile(
                leading: Icons.auto_awesome,
                iconColor: AppColors.eagleGold,
                title: currentLocale.languageCode == 'ar' 
                    ? 'فحص اتصال AI' 
                    : 'Check AI Status',
                subtitle: currentLocale.languageCode == 'ar'
                    ? 'التحقق من اتصال خدمة AI'
                    : 'Test AI service connection',
                onTap: _checkAiConnectivity,
              ),
              Divider(height: 1.h),
              SettingsTile(
                leading: Icons.bug_report,
                iconColor: AppColors.eagleGold,
                title: currentLocale.languageCode == 'ar' 
                    ? 'سجلات التصحيح' 
                    : 'Debug Logging',
                subtitle: currentLocale.languageCode == 'ar'
                    ? 'تفعيل/تعطيل سجلات التصحيح'
                    : 'Enable/disable debug logs',
                trailing: Switch(
                  value: AppLogger.enabled,
                  onChanged: (value) {
                    setState(() {
                      AppLogger.enabled = value;
                    });
                    AppLogger.event('Debug logging ${value ? 'enabled' : 'disabled'}', source: 'SettingsScreen');
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 7. Danger Zone
          DangerZoneCard(
            title: l10n?.dangerZone ?? 'Danger Zone',
            children: [
              SettingsTile(
                leading: Icons.delete_forever,
                iconColor: Colors.red.shade300,
                title: l10n?.resetAppData ?? 'Reset App Data',
                textColor: Colors.red.shade300,
                subtitle: l10n?.resetAppDataDescription ?? 'This will delete all app data and cannot be undone',
                trailing: Icon(Icons.chevron_right, color: Colors.red.shade300),
                onTap: _showFactoryResetConfirmation,
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Future<void> _showFactoryResetConfirmation() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 32),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n?.factoryReset ?? 'Factory Reset?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '${l10n?.factoryResetMessage ?? 'This will delete ALL app data including:'}\n'
          '• ${l10n?.allProgressAndAnswers ?? 'All progress and answers'}\n'
          '• ${l10n?.studyHistory ?? 'Study history'}\n'
          '• ${l10n?.settings ?? 'Settings'}\n'
          '• ${l10n?.streaks ?? 'Streaks'}\n\n'
          '${l10n?.cannotBeUndone ?? 'This action CANNOT be undone!'}',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n?.cancel ?? 'Cancel',
              style: const TextStyle(color: AppColors.eagleGold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(
              l10n?.resetEverything ?? 'Reset Everything',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // حذف جميع البيانات من Hive
        await HiveService.deleteFromDisk();
        await FavoritesService.deleteFromDisk();
        await UserPreferencesService.clearAll();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?.appDataResetSuccess ?? 'App data reset successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          // إعادة تشغيل التطبيق - العودة إلى AppInitializer
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n?.errorResettingApp ?? 'Error resetting app:'} $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }


  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  Widget _buildThemeButtons(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
    AppLocalizations? l10n,
    bool isArabic,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSmallThemeButton(
          context,
          ref,
          ThemeMode.light,
          Icons.light_mode,
          currentMode,
        ),
        SizedBox(width: 4.w),
        _buildSmallThemeButton(
          context,
          ref,
          ThemeMode.dark,
          Icons.dark_mode,
          currentMode,
        ),
        SizedBox(width: 4.w),
        _buildSmallThemeButton(
          context,
          ref,
          ThemeMode.system,
          Icons.brightness_auto,
          currentMode,
        ),
      ],
    );
  }

  Widget _buildSmallThemeButton(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
    IconData icon,
    ThemeMode currentMode,
  ) {
    final isSelected = currentMode == mode;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(themeProvider.notifier).setThemeMode(mode);
        },
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.eagleGold.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(
            icon,
            size: 18.sp,
            color: isSelected
                ? AppColors.eagleGold
                : (isDark ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }


}

