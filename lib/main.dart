import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/hive_service.dart';
import 'core/storage/user_preferences_service.dart';
import 'core/storage/favorites_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/subscription_service.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/onboarding/setup_screen.dart';
import 'presentation/screens/study/study_screen.dart';
import 'presentation/screens/review/review_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/stats/statistics_screen.dart';

// Global navigator key for navigation from notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init(); // This already calls SrsService.init() internally
  await FavoritesService.init(); // Initialize favorites service
  await SubscriptionService.init(); // Initialize RevenueCat subscription service
  
  // Set navigator key for notifications
  NotificationService.navigatorKey = navigatorKey;
  
  await NotificationService.init();
  // تحديث الـ Streak عند بدء التطبيق
  await UserPreferencesService.updateStreak();
  
  // تحميل الثيم المحفوظ بشكل متزامن قبل بناء التطبيق
  final savedThemeMode = await ThemeNotifier.loadThemeMode();
  
  runApp(ProviderScope(
    child: MyApp(initialThemeMode: savedThemeMode),
  ));
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

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final isFirst = await UserPreferencesService.isFirstLaunch();
    setState(() {
      _isFirstLaunch = isFirst;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
