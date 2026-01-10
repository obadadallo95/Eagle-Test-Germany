import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';

/// -----------------------------------------------------------------
/// 🔧 MAINTENANCE SCREEN / WARTUNGSSCHIRM / شاشة الصيانة
/// -----------------------------------------------------------------
/// Blocking screen shown when app is in maintenance mode.
/// User cannot proceed until maintenance is complete.
/// -----------------------------------------------------------------
class MaintenanceScreen extends StatelessWidget {
  final String message;
  
  const MaintenanceScreen({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    
    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: AdaptivePageWrapper(
          enableScroll: true,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Maintenance Icon
                  Icon(
                    Icons.build,
                    size: 80.sp,
                    color: primaryGold,
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Title
                  AutoSizeText(
                    isArabic ? 'التطبيق قيد الصيانة' : 'App Under Maintenance',
                    style: AppTypography.h1.copyWith(
                      color: textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    minFontSize: 20.sp,
                    stepGranularity: 1.sp,
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Message
                  AutoSizeText(
                    message,
                    style: AppTypography.bodyL.copyWith(
                      color: textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 10,
                    minFontSize: 12.sp,
                    stepGranularity: 1.sp,
                  ),
                  
                  SizedBox(height: 48.h),
                  
                  // Retry Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Reload the app by restarting
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                    icon: Icon(Icons.refresh, size: 24.sp),
                    label: Text(
                      isArabic ? 'إعادة المحاولة' : 'Retry',
                      style: AppTypography.button.copyWith(
                        fontSize: 16.sp,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 16.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

