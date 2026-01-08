import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../providers/locale_provider.dart';
import '../widgets/points_display_widget.dart';
import '../widgets/sync_indicator_widget.dart';
import 'dashboard/dashboard_screen.dart';
import 'study/study_screen.dart';
import 'exam/exam_landing_screen.dart';
import 'profile/profile_dashboard_screen.dart';
import 'dart:async';

/// -----------------------------------------------------------------
/// 📱 MAIN SCREEN / HAUPTBILDSCHIRM / الشاشة الرئيسية
/// -----------------------------------------------------------------
/// Main navigation screen with bottom navigation bar.
/// Controls 4 tabs: Dashboard, Study, Exam, Settings.
/// -----------------------------------------------------------------
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  DateTime? _lastBackPressTime;
  int _dashboardRefreshKey = 0; // Key لتحديث Dashboard

  // إنشاء قائمة الشاشات مع keys ثابتة
  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(key: PageStorageKey('dashboard')),
      const StudyScreen(key: PageStorageKey('study')),
      const ExamLandingScreen(key: PageStorageKey('exam')),
      const ProfileDashboardScreen(key: PageStorageKey('profile')),
    ];
  }
  
  // تحديث Dashboard عند الحاجة
  void _refreshDashboard() {
    setState(() {
      _dashboardRefreshKey++;
      _screens[0] = DashboardScreen(key: ValueKey('dashboard_$_dashboardRefreshKey'));
    });
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    
    // إذا كانت هذه أول مرة أو مر أكثر من ثانيتين
    if (_lastBackPressTime == null || 
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      
      // عرض رسالة "اضغط مرة أخرى للخروج"
      final currentLocale = ref.read(localeProvider);
      final isArabic = currentLocale.languageCode == 'ar';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'اضغط مرة أخرى للخروج' : 'Press back again to exit',
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
          backgroundColor: AppColors.darkSurface,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      return false; // منع الخروج
    }
    
    // إذا تم الضغط مرتين خلال ثانيتين، الخروج
    return true;
  }

  /// جلب عنوان AppBar حسب الشاشة الحالية
  String _getAppBarTitle(int index, AppLocalizations? l10n) {
    switch (index) {
      case 0:
        return l10n?.dashboard ?? 'Dashboard';
      case 1:
        return l10n?.learn ?? 'Learn';
      case 2:
        return l10n?.examMode ?? 'Exam';
      case 3:
        return l10n?.settings ?? 'Settings';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldExit = await _onWillPop();
        if (shouldExit && mounted) {
          SystemNavigator.pop(); // الخروج من التطبيق
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // العنوان (يمكن تخصيصه حسب الشاشة)
              Text(
                _getAppBarTitle(_currentIndex, l10n),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              // عرض النقاط ومؤشر المزامنة
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SyncIndicatorWidget(),
                  SizedBox(width: 8.w),
                  const PointsDisplayWidget(),
                ],
              ),
            ],
          ),
        ),
        body: _screens[_currentIndex],
      bottomNavigationBar: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          
          return NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              if (mounted) {
                // إذا تم التبديل إلى Dashboard، قم بتحديثه
                if (index == 0 && _currentIndex != 0) {
                  _refreshDashboard();
                }
                setState(() {
                  _currentIndex = index;
                });
              }
            },
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            indicatorColor: AppColors.eagleGold.withValues(alpha: 0.2),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.dashboard_outlined,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                selectedIcon: const Icon(Icons.dashboard, color: AppColors.eagleGold),
                label: l10n?.dashboard ?? 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.school_outlined,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                selectedIcon: const Icon(Icons.school, color: AppColors.eagleGold),
                label: l10n?.learn ?? 'Learn',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.assignment_outlined,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                selectedIcon: const Icon(Icons.assignment, color: AppColors.eagleGold),
                label: l10n?.examMode ?? 'Exam',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.person_outline,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                selectedIcon: const Icon(Icons.person, color: AppColors.eagleGold),
                label: l10n?.settings ?? 'Profile',
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}

