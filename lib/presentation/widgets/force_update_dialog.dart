import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/exceptions/app_exceptions.dart';

/// -----------------------------------------------------------------
/// 🔄 FORCE UPDATE DIALOG / ZWANGS-UPDATE-DIALOG / حوار التحديث الإلزامي
/// -----------------------------------------------------------------
/// Dialog shown when app version is too old and must be updated.
/// Blocks app usage until user updates.
/// -----------------------------------------------------------------
class ForceUpdateDialog extends StatelessWidget {
  final ForceUpdateException exception;

  const ForceUpdateDialog({
    super.key,
    required this.exception,
  });

  /// Show the force update dialog (blocks app usage)
  static Future<void> show(
      BuildContext context, ForceUpdateException exception) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User cannot dismiss - must update
      builder: (context) => ForceUpdateDialog(exception: exception),
    );
  }

  Future<void> _openStore() async {
    // Android: Google Play Store
    // iOS: App Store
    // For now, we'll use a generic approach
    const androidUrl =
        'https://play.google.com/store/apps/details?id=com.eagletest.germany';
    // TODO: Detect platform and use iOS URL when on iOS
    // const iosUrl = 'https://apps.apple.com/app/id123456789'; // Replace with actual App Store ID

    final url =
        Uri.parse(androidUrl); // TODO: Detect platform and use appropriate URL

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return PopScope(
      canPop: false, // Prevent back button from dismissing
      child: AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.system_update,
              color: AppColors.eagleGold,
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AutoSizeText(
                isArabic ? 'تحديث مطلوب' : 'Update Required',
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                minFontSize: 16.sp,
                stepGranularity: 1.sp,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              isArabic
                  ? 'يجب تحديث التطبيق إلى الإصدار ${exception.minSupportedVersion} أو أحدث للاستمرار في الاستخدام.'
                  : 'Please update the app to version ${exception.minSupportedVersion} or later to continue using it.',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.white70,
                height: 1.5,
              ),
              maxLines: 5,
              minFontSize: 12.sp,
              stepGranularity: 1.sp,
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.darkCharcoal,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.eagleGold, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: AutoSizeText(
                      isArabic
                          ? 'الإصدار الحالي: ${exception.currentVersion}'
                          : 'Current version: ${exception.currentVersion}',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.white60,
                      ),
                      maxLines: 2,
                      minFontSize: 10.sp,
                      stepGranularity: 1.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openStore,
              icon: Icon(Icons.download, size: 20.sp),
              label: Text(
                isArabic ? 'تحديث الآن' : 'Update Now',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.eagleGold,
                foregroundColor: AppColors.darkSurface,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
