import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../core/theme/app_colors.dart';
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
    
    return Scaffold(
      backgroundColor: AppColors.darkSurface,
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
                    color: AppColors.eagleGold,
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Title
                  AutoSizeText(
                    isArabic ? 'التطبيق قيد الصيانة' : 'App Under Maintenance',
                    style: GoogleFonts.poppins(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: Colors.white70,
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
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.eagleGold,
                      foregroundColor: AppColors.darkSurface,
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

