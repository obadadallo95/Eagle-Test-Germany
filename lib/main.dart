import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/storage/hive_service.dart';
import 'core/storage/user_preferences_service.dart';
import 'core/storage/favorites_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/subscription_service.dart';
import 'core/services/sync_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/remote_config_service.dart';
import 'core/config/env_config.dart';
import 'core/debug/app_logger.dart';
import 'core/exceptions/app_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/onboarding/setup_screen.dart';
import 'presentation/screens/maintenance/maintenance_screen.dart';
import 'presentation/widgets/force_update_dialog.dart';
import 'presentation/screens/study/study_screen.dart';
import 'presentation/screens/review/review_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/stats/statistics_screen.dart';

// Global navigator key for navigation from notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize core services
  try {
    await HiveService.init(); 
  } catch (e, stack) {
    AppLogger.error('Failed to init HiveService', source: 'main', error: e, stackTrace: stack);
  }

  try {
    await FavoritesService.init();
  } catch (e, stack) {
    AppLogger.error('Failed to init FavoritesService', source: 'main', error: e, stackTrace: stack);
  }

  try {
    await SubscriptionService.init();
  } catch (e, stack) {
    AppLogger.error('Failed to init SubscriptionService', source: 'main', error: e, stackTrace: stack);
  }
  
  // Set navigator key for notifications
  NotificationService.navigatorKey = navigatorKey;
  
  try {
    await NotificationService.init();
  } catch (e, stack) {
    AppLogger.error('Failed to init NotificationService', source: 'main', error: e, stackTrace: stack);
  }

  try {
    // تحديث الـ Streak عند بدء التطبيق
    await UserPreferencesService.updateStreak();
  } catch (e, stack) {
    AppLogger.error('Failed to update streak', source: 'main', error: e, stackTrace: stack);
  }
  
  // Initialize Supabase (with error handling for offline mode)
  try {
    AppLogger.functionStart('Supabase.init', source: 'main');
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
    
      // Attempt silent sign-in (anonymous authentication)
      // AuthService handles sign-in and profile verification (relies on Trigger)
      final authSuccess = await AuthService.signInSilently();
      
      if (!authSuccess) {
        AppLogger.error(
          'CRITICAL: Authentication failed. This may be because Anonymous sign-ins are disabled in Supabase. '
          'Please check Supabase Dashboard: Authentication → Providers → Anonymous → Enable it.',
          source: 'main',
        );
      }
      
      if (authSuccess) {
        // CRITICAL: Ensure user profile exists in database
        // This is a fallback if the Trigger didn't fire
        try {
          // Blocking wait for profile creation
          await SyncService.createUserProfile();
          
          // Verify that profile was actually created
          final profileExists = await SyncService.verifyUserProfileExists();
          if (!profileExists) {
            AppLogger.error(
              'CRITICAL: User profile verification failed after creation. Profile may not exist in database.',
              source: 'main',
            );
            // Retry once after a short delay
            await Future.delayed(const Duration(seconds: 2));
            await SyncService.createUserProfile();
            final retryVerified = await SyncService.verifyUserProfileExists();
            if (!retryVerified) {
              AppLogger.error(
                'CRITICAL: User profile still not found after retry. User account may not be saved.',
                source: 'main',
              );
            }
          } else {
            AppLogger.info('User profile verified successfully', source: 'main');
          }
        } catch (e, stackTrace) {
          AppLogger.error(
            'CRITICAL: Failed to create user profile. App will continue but user account may not be saved.',
            source: 'main',
            error: e,
            stackTrace: stackTrace,
          );
          // App continues to work offline, but user account may not be saved
        }
        
        // Sync progress on app start and restore if needed (non-blocking)
        // For Pro users: Restore shared progress from cloud
        // For Free users: Sync local progress to cloud
        _syncAndRestoreProgressOnStartup().catchError((e) {
          AppLogger.warn('Background sync/restore on startup failed (non-critical): $e', source: 'main');
        });
      } else {
        AppLogger.warn('Authentication failed. App will work in offline mode.', source: 'main');
        // Continue - app works offline
      }
    
    AppLogger.event('Supabase initialized successfully', source: 'main');
    AppLogger.functionEnd('Supabase.init', source: 'main');
  } catch (e, stackTrace) {
    // CRITICAL: App MUST still launch even if Supabase fails
    // This ensures offline functionality is always available
    AppLogger.error(
      'Failed to initialize Supabase. App will continue in offline mode.',
      source: 'main',
      error: e,
      stackTrace: stackTrace,
    );
    // Don't rethrow - allow app to continue working offline
  }
  
  // تحميل الثيم المحفوظ بشكل متزامن قبل بناء التطبيق
  final savedThemeMode = await ThemeNotifier.loadThemeMode();
  
  runApp(ProviderScope(
    child: MyApp(initialThemeMode: savedThemeMode),
  ));
}

/// Sync and restore progress on app startup
/// 
/// **Pro Feature Only**: This only works for Pro subscribers.
/// Free users cannot sync or restore progress from cloud.
/// 
/// For Pro users: Restores shared progress from cloud (via revenuecat_customer_id) and merges with local
/// 
/// This runs before the app becomes interactive to ensure progress is synced.
Future<void> _syncAndRestoreProgressOnStartup() async {
  try {
    if (!SyncService.isAvailable) {
      AppLogger.info('Supabase not available. Skipping startup sync.', source: 'main');
      return;
    }

    // Check Pro status FIRST - Only Pro users can sync/restore
    final isPro = await SubscriptionService.isProUser();
    if (!isPro) {
      AppLogger.info('Free user detected. Cloud sync/restore is disabled (Pro feature only).', source: 'main');
      return;
    }

    AppLogger.info('Starting progress sync/restore on startup for Pro user...', source: 'main');

    // First: Restore progress from cloud (merges with local automatically)
    final restored = await SyncService.restoreProgressFromCloud();
    if (restored) {
      AppLogger.info('Progress restored and merged from cloud on startup', source: 'main');
    } else {
      AppLogger.info('No cloud progress to restore (first launch or no cloud data)', source: 'main');
    }

    // Second: Sync local progress to cloud (updates cloud with latest local data)
    await SyncService.syncProgressToCloud();
    
    AppLogger.info('Progress sync/restore completed on startup', source: 'main');
  } catch (e, stackTrace) {
    AppLogger.error(
      'Failed to sync/restore progress on startup',
      source: 'main',
      error: e,
      stackTrace: stackTrace,
    );
    // Don't rethrow - non-critical operation, app should continue
  }
}

/// Widget للتحقق من أول إطلاق وإرسال المستخدم إلى الشاشة المناسبة
class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  bool _isLoading = true;
  bool _isFirstLaunch = true;
  String? _maintenanceMessage;
  ForceUpdateException? _forceUpdateException;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Check app status (maintenance mode, version check)
      await RemoteConfigService.checkAppStatus();
      
      // Step 2: Check first launch
      final isFirst = await UserPreferencesService.isFirstLaunch();
      
      if (mounted) {
        setState(() {
          _isFirstLaunch = isFirst;
          _isLoading = false;
        });
      }
    } on MaintenanceException catch (e) {
      // App is in maintenance mode - show maintenance screen
      if (mounted) {
        setState(() {
          _maintenanceMessage = e.message;
          _isLoading = false;
        });
      }
    } on ForceUpdateException catch (e) {
      // App version is too old - show force update dialog
      if (mounted) {
        setState(() {
          _forceUpdateException = e;
          _isLoading = false;
        });
        // Show dialog after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ForceUpdateDialog.show(context, e);
          }
        });
      }
    } catch (e) {
      // Other errors (network, etc.) - allow app to continue
      AppLogger.warn('App status check failed, continuing normally: $e', source: 'AppInitializer');
      final isFirst = await UserPreferencesService.isFirstLaunch();
      if (mounted) {
        setState(() {
          _isFirstLaunch = isFirst;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.darkSurface,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.eagleGold,
          ),
        ),
      );
    }

    // Show maintenance screen if in maintenance mode
    if (_maintenanceMessage != null) {
      return MaintenanceScreen(message: _maintenanceMessage!);
    }

    // Show force update dialog if needed (handled in initState)
    if (_forceUpdateException != null) {
      // Return a blocking screen while dialog is shown
      return const Scaffold(
        backgroundColor: AppColors.darkSurface,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.eagleGold,
          ),
        ),
      );
    }

    // Normal flow: show setup or main screen
    return _isFirstLaunch ? const SetupScreen() : const MainScreen();
  }
}

class MyApp extends ConsumerWidget {
  final ThemeMode initialThemeMode;
  
  const MyApp({super.key, required this.initialThemeMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // تهيئة الثيم بالقيمة المحملة مسبقاً (مرة واحدة فقط)
    final themeNotifier = ref.read(themeProvider.notifier);
    if (!themeNotifier.isInitialized) {
      themeNotifier.initializeWith(initialThemeMode);
    }
    
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);
    final isRtl = locale.languageCode == 'ar'; // العربية فقط RTL

    return ScreenUtilInit(
      designSize: const Size(360, 690), // Standard mobile design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Eagle Test: Germany',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode, // Use theme from provider (light, dark, or system)
          locale: locale,
          supportedLocales: const [
            Locale('en'),
            Locale('de'),
            Locale('ar'),
            Locale('tr'),
            Locale('uk'),
            Locale('ru'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            // تطبيق RTL للغات التي تدعمها
            return Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            );
          },
          home: const AppInitializer(),
          routes: {
            '/study': (context) => const StudyScreen(),
            '/review': (context) => const ReviewScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/statistics': (context) => const StatisticsScreen(),
          },
        );
      },
    );
  }
}
