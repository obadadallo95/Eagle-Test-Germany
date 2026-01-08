import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/debug/app_logger.dart';

/// Customer Center Button Widget
/// 
/// This widget provides a button to open RevenueCat Customer Center
/// where users can:
/// - View subscription details
/// - Manage subscription (cancel, renew)
/// - Restore purchases
/// - Contact support
/// 
/// Note: Customer Center must be configured in RevenueCat Dashboard
class CustomerCenterButton extends StatelessWidget {
  final bool isPro;
  final VoidCallback? onOpened;

  const CustomerCenterButton({
    super.key,
    required this.isPro,
    this.onOpened,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return OutlinedButton.icon(
      onPressed: () => _openCustomerCenter(context),
      icon: Icon(
        Icons.settings,
        size: 20.sp,
      ),
      label: AutoSizeText(
        isArabic ? 'إدارة الاشتراك' : 'Manage Subscription',
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Future<void> _openCustomerCenter(BuildContext context) async {
    try {
      // Present Customer Center
      await SubscriptionService.presentCustomerCenter();
      
      // Call callback if provided
      onOpened?.call();
      
      AppLogger.event('Customer Center opened',
          source: 'CustomerCenterButton');
    } catch (e) {
      AppLogger.error('Failed to open Customer Center',
          source: 'CustomerCenterButton', error: e);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? 'فشل فتح مركز إدارة الاشتراك'
                  : 'Failed to open Customer Center',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

