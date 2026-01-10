import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
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
import '../../widgets/theme_selector.dart';

/// -----------------------------------------------------------------
/// ⚙️ SETTINGS SCREEN / EINSTELLUNGEN / شاشة الإعدادات
/// -----------------------------------------------------------------
/// Modern, beautiful settings screen with glassmorphism effects
/// and smooth animations. Redesigned for 2026 best practices.
/// -----------------------------------------------------------------
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with SingleTickerProviderStateMixin {
  double _ttsSpeed = 1.0;
  bool _isReminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
    _loadSettings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    
    if (_isReminderEnabled) {
      await NotificationService.scheduleDailyNotification(_reminderTime);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Text(
          l10n?.resetProgress ?? 'Reset Progress',
          style: AppTypography.h3.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        content: Text(
          l10n?.resetProgressMessage ?? 
          'Are you sure you want to reset all your progress? This action cannot be undone.',
          style: AppTypography.bodyM.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n?.cancel ?? 'Cancel',
              style: AppTypography.button.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorDark),
            child: Text(
              l10n?.confirm ?? 'Confirm',
              style: AppTypography.button.copyWith(color: AppColors.errorDark),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HiveService.clearAll();
      await UserPreferencesService.clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.progressReset ?? 'Progress reset successfully'),
            backgroundColor: AppColors.successDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
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

  Future<void> _checkAiConnectivity() async {
    AppLogger.functionStart('_checkAiConnectivity', source: 'SettingsScreen');
    final currentLocale = ref.read(localeProvider);
    final userLanguage = currentLocale.languageCode;
    final isArabic = userLanguage == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.gold),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isArabic ? 'جاري التحقق...' : 'Checking connection...',
              style: AppTypography.bodyM.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );

    try {
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

      final explanation = await AiTutorService.explainQuestion(
        question: testQuestion,
        userLanguage: userLanguage,
      );

      if (mounted) Navigator.pop(context);

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

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
            title: Row(
              children: [
                Icon(
                  isConnected ? Icons.check_circle : Icons.error_outline,
                  color: isConnected ? AppColors.successDark : AppColors.errorDark,
                  size: 32.sp,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    isConnected
                        ? (isArabic ? 'AI متصل' : 'AI Connected')
                        : (isArabic ? 'AI غير متصل' : 'AI Offline'),
                    style: AppTypography.h3.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
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
              style: AppTypography.bodyM.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  isArabic ? 'موافق' : 'OK',
                  style: AppTypography.button.copyWith(color: AppColors.gold),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('AI connectivity check failed', source: 'SettingsScreen', error: e, stackTrace: stackTrace);
      
      if (mounted) Navigator.pop(context);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
            title: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.errorDark, size: 32.sp),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    isArabic ? 'خطأ في الاتصال' : 'Connection Error',
                    style: AppTypography.h3.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              isArabic
                  ? 'حدث خطأ أثناء التحقق من اتصال AI: $e'
                  : 'An error occurred while checking AI connection: $e',
              style: AppTypography.bodyM.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  isArabic ? 'موافق' : 'OK',
                  style: AppTypography.button.copyWith(color: AppColors.gold),
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
    ref.watch(themeProvider);
    final isArabic = currentLocale.languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(l10n, isDark, primaryGold, isArabic),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      AppColors.darkBg,
                      AppColors.darkBg.withValues(alpha: 0.95),
                      AppColors.darkSurface.withValues(alpha: 0.9),
                    ]
                  : [
                      AppColors.lightBg,
                      AppColors.lightBg.withValues(alpha: 0.98),
                      AppColors.lightSurface.withValues(alpha: 0.95),
                    ],
            ),
          ),
          child: AdaptivePageWrapper(
            padding: EdgeInsets.zero,
            enableScroll: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Hero Header Section
                SliverToBoxAdapter(
                  child: _buildHeroSection(isDark, primaryGold, isArabic),
                ),
                
                // Settings Content
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Appearance Section
                      _buildSectionWithAnimation(
                        delay: 0.1,
                        child: SettingsSectionCard(
                          title: l10n?.appearance ?? 'Appearance',
                          titleIcon: Icons.palette_outlined,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n?.theme ?? 'Theme',
                                    style: AppTypography.h4.copyWith(
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  const ThemeSelector(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // General Section
                      _buildSectionWithAnimation(
                        delay: 0.2,
                        child: SettingsSectionCard(
                          title: l10n?.general ?? 'General',
                          titleIcon: Icons.tune_rounded,
                          children: [
                            SettingsTile(
                              leading: Icons.language_rounded,
                              title: l10n?.language ?? 'Language',
                              subtitle: _getLanguageName(currentLocale.languageCode, isArabic),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getCurrentLanguageFlag(currentLocale.languageCode),
                                    style: TextStyle(fontSize: 24.sp),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Icon(Icons.chevron_right_rounded, size: 20.sp, color: primaryGold),
                                ],
                              ),
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => const LanguageSelectionSheet(),
                                );
                              },
                            ),
                            Divider(height: 1.h, color: primaryGold.withValues(alpha: 0.1)),
                            SettingsTile(
                              leading: Icons.star_rounded,
                              iconColor: primaryGold,
                              title: l10n?.upgradeToPro ?? 'Premium Subscription',
                              subtitle: ref.watch(subscriptionProvider).isPro
                                  ? (l10n?.activeSubscription ?? 'Active Subscription')
                                  : (l10n?.upgradeForAdditionalFeatures ?? 'Upgrade for additional features'),
                              trailing: ref.watch(subscriptionProvider).isPro
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [AppColors.successDark, AppColors.successDark.withValues(alpha: 0.8)],
                                        ),
                                        borderRadius: BorderRadius.circular(20.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.successDark.withValues(alpha: 0.3),
                                            blurRadius: 8.r,
                                            offset: Offset(0, 2.h),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        isArabic ? 'مشترك' : 'Active',
                                        style: AppTypography.badge.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    )
                                  : Icon(Icons.arrow_forward_ios_rounded, size: 16.sp, color: primaryGold),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PaywallScreen()),
                                );
                                AppLogger.event('Premium subscription tapped', source: 'SettingsScreen');
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Audio Section
                      _buildSectionWithAnimation(
                        delay: 0.3,
                        child: SettingsSectionCard(
                          title: l10n?.audio ?? 'Audio',
                          titleIcon: Icons.volume_up_rounded,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.md,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        l10n?.speakingSpeed ?? 'Speaking Speed',
                                        style: AppTypography.h4.copyWith(
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: AppSpacing.xs,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              primaryGold.withValues(alpha: 0.2),
                                              primaryGold.withValues(alpha: 0.15),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12.r),
                                          border: Border.all(
                                            color: primaryGold.withValues(alpha: 0.3),
                                            width: 1.w,
                                          ),
                                        ),
                                        child: Text(
                                          '${_ttsSpeed.toStringAsFixed(1)}x',
                                          style: AppTypography.h4.copyWith(
                                            color: primaryGold,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: primaryGold,
                                      inactiveTrackColor: primaryGold.withValues(alpha: 0.2),
                                      thumbColor: primaryGold,
                                      overlayColor: primaryGold.withValues(alpha: 0.1),
                                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.r),
                                      trackHeight: 4.h,
                                    ),
                                    child: Slider(
                                      value: _ttsSpeed,
                                      min: 0.5,
                                      max: 2.0,
                                      divisions: 15,
                                      label: '${_ttsSpeed.toStringAsFixed(1)}x',
                                      onChanged: _saveTtsSpeed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Notifications Section
                      _buildSectionWithAnimation(
                        delay: 0.4,
                        child: SettingsSectionCard(
                          title: l10n?.notifications ?? 'Notifications',
                          titleIcon: Icons.notifications_active_rounded,
                          children: [
                            SettingsTile(
                              leading: Icons.notifications_active_rounded,
                              iconSize: 28.sp,
                              title: l10n?.dailyReminder ?? 'Daily Reminder',
                              subtitle: l10n?.dailyReminderDescription ?? 'Get reminded to study daily',
                              trailing: Switch(
                                value: _isReminderEnabled,
                                activeThumbColor: primaryGold,
                                activeTrackColor: primaryGold.withValues(alpha: 0.5),
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
                                          content: Text(l10n?.reminderEnabled ?? 'Daily reminder enabled'),
                                          backgroundColor: AppColors.successDark,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                        ),
                                      );
                                    }
                                  } else {
                                    await NotificationService.cancelNotifications();
                                    if (mounted && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n?.reminderDisabled ?? 'Daily reminder disabled'),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                            if (_isReminderEnabled) ...[
                              Divider(height: 1.h, color: primaryGold.withValues(alpha: 0.1)),
                              SettingsTile(
                                leading: Icons.access_time_rounded,
                                iconSize: 28.sp,
                                title: l10n?.reminderTime ?? 'Time',
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryGold.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Text(
                                        _reminderTime.format(context),
                                        style: AppTypography.h4.copyWith(
                                          color: primaryGold,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Icon(Icons.chevron_right_rounded, color: primaryGold),
                                  ],
                                ),
                                onTap: () async {
                                  final pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: _reminderTime,
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.fromSeed(
                                            seedColor: primaryGold,
                                            brightness: isDark ? Brightness.dark : Brightness.light,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
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
                                            content: Text(l10n?.reminderTimeUpdated ?? 'Reminder time updated'),
                                            backgroundColor: AppColors.successDark,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Data Section
                      _buildSectionWithAnimation(
                        delay: 0.5,
                        child: SettingsSectionCard(
                          title: l10n?.data ?? 'Data',
                          titleIcon: Icons.storage_rounded,
                          children: [
                            SettingsTile(
                              leading: Icons.refresh_rounded,
                              iconColor: AppColors.errorDark,
                              title: l10n?.resetProgress ?? 'Reset Progress',
                              textColor: AppColors.errorDark,
                              onTap: _showResetConfirmation,
                            ),
                            Divider(height: 1.h, color: primaryGold.withValues(alpha: 0.1)),
                            SettingsTile(
                              leading: Icons.balance_rounded,
                              iconColor: AppColors.infoDark,
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
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // About Section
                      _buildSectionWithAnimation(
                        delay: 0.6,
                        child: SettingsSectionCard(
                          title: l10n?.about ?? 'About',
                          titleIcon: Icons.info_outline_rounded,
                          children: [
                            SettingsTile(
                              leading: Icons.info_outline_rounded,
                              iconColor: primaryGold,
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
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Advanced Section
                      _buildSectionWithAnimation(
                        delay: 0.7,
                        child: SettingsSectionCard(
                          title: currentLocale.languageCode == 'ar' ? 'متقدم' : 'Advanced',
                          titleIcon: Icons.settings_applications_rounded,
                          children: [
                            SettingsTile(
                              leading: Icons.auto_awesome_rounded,
                              iconColor: primaryGold,
                              title: currentLocale.languageCode == 'ar' 
                                  ? 'فحص اتصال AI' 
                                  : 'Check AI Status',
                              subtitle: currentLocale.languageCode == 'ar'
                                  ? 'التحقق من اتصال خدمة AI'
                                  : 'Test AI service connection',
                              onTap: _checkAiConnectivity,
                            ),
                            Divider(height: 1.h, color: primaryGold.withValues(alpha: 0.1)),
                            SettingsTile(
                              leading: Icons.bug_report_rounded,
                              iconColor: primaryGold,
                              title: currentLocale.languageCode == 'ar' 
                                  ? 'سجلات التصحيح' 
                                  : 'Debug Logging',
                              subtitle: currentLocale.languageCode == 'ar'
                                  ? 'تفعيل/تعطيل سجلات التصحيح'
                                  : 'Enable/disable debug logs',
                              trailing: Switch(
                                value: AppLogger.enabled,
                                activeThumbColor: primaryGold,
                                activeTrackColor: primaryGold.withValues(alpha: 0.5),
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
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Danger Zone
                      _buildSectionWithAnimation(
                        delay: 0.8,
                        child: DangerZoneCard(
                          title: l10n?.dangerZone ?? 'Danger Zone',
                          children: [
                            SettingsTile(
                              leading: Icons.delete_forever_rounded,
                              iconColor: AppColors.errorDark.withValues(alpha: 0.8),
                              title: l10n?.resetAppData ?? 'Reset App Data',
                              textColor: AppColors.errorDark.withValues(alpha: 0.8),
                              subtitle: l10n?.resetAppDataDescription ?? 'This will delete all app data and cannot be undone',
                              trailing: Icon(Icons.chevron_right_rounded, color: AppColors.errorDark.withValues(alpha: 0.8)),
                              onTap: _showFactoryResetConfirmation,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(AppLocalizations? l10n, bool isDark, Color primaryGold, bool isArabic) {
    return AppBar(
      title: Text(
        l10n?.settings ?? 'Settings',
        style: AppTypography.h2.copyWith(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.darkBg.withValues(alpha: 0.95),
                    AppColors.darkSurface.withValues(alpha: 0.85),
                  ]
                : [
                    AppColors.lightBg.withValues(alpha: 0.98),
                    AppColors.lightSurface.withValues(alpha: 0.95),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : primaryGold.withValues(alpha: 0.05),
              blurRadius: 20.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDark, Color primaryGold, bool isArabic) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxl + MediaQuery.of(context).padding.top,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryGold.withValues(alpha: isDark ? 0.2 : 0.15),
                  primaryGold.withValues(alpha: isDark ? 0.1 : 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: primaryGold.withValues(alpha: 0.3),
                width: 2.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryGold.withValues(alpha: isDark ? 0.2 : 0.15),
                  blurRadius: 20.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryGold, primaryGold.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGold.withValues(alpha: 0.4),
                        blurRadius: 12.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.settings_rounded,
                    color: isDark ? AppColors.darkBg : Colors.white,
                    size: 32.sp,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'الإعدادات' : 'Settings',
                        style: AppTypography.h1.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        isArabic ? 'خصص تجربتك' : 'Customize your experience',
                        style: AppTypography.bodyM.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionWithAnimation({required double delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: (600 + delay * 200).round()),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  String _getLanguageName(String code, bool isArabic) {
    final names = {
      'en': isArabic ? 'الإنجليزية' : 'English',
      'de': isArabic ? 'الألمانية' : 'Deutsch',
      'ar': isArabic ? 'العربية' : 'Arabic',
      'tr': isArabic ? 'التركية' : 'Türkçe',
      'uk': isArabic ? 'الأوكرانية' : 'Українська',
      'ru': isArabic ? 'الروسية' : 'Русский',
    };
    return names[code] ?? code;
  }

  Future<void> _showFactoryResetConfirmation() async {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppColors.errorDark, size: 32),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n?.factoryReset ?? 'Factory Reset?',
                style: AppTypography.h3.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
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
          style: AppTypography.bodyM.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n?.cancel ?? 'Cancel',
              style: AppTypography.button.copyWith(color: AppColors.gold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorDark),
            child: Text(
              l10n?.resetEverything ?? 'Reset Everything',
              style: AppTypography.button.copyWith(color: AppColors.errorDark),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await HiveService.deleteFromDisk();
        await FavoritesService.deleteFromDisk();
        await UserPreferencesService.clearAll();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?.appDataResetSuccess ?? 'App data reset successfully'),
              backgroundColor: AppColors.successDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          );
          
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
              backgroundColor: AppColors.errorDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          );
        }
      }
    }
  }
}
