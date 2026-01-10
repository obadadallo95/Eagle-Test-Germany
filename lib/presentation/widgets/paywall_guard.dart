import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import '../providers/subscription_provider.dart';
import '../screens/subscription/paywall_screen.dart';

/// Widget لحماية الميزات المدفوعة
/// يعرض paywall إذا لم يكن المستخدم Pro
class PaywallGuard extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onUpgradePressed;

  const PaywallGuard({
    super.key,
    required this.child,
    this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final isPro = subscriptionState.isPro;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;

    if (subscriptionState.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: primaryGold,
        ),
      );
    }

    if (isPro) {
      return child;
    } else {
      // عرض PaywallScreen بدلاً من child
      return _buildPaywallOverlay(context);
    }
  }

  Widget _buildPaywallOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    
    return GestureDetector(
      onTap: () => _navigateToPaywall(context),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg.withValues(alpha: 0.8) : AppColors.lightBg.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 64.sp,
                color: primaryGold,
              ),
              SizedBox(height: 16.h),
              AutoSizeText(
                AppLocalizations.of(context)?.upgradeToPro ?? 'Upgrade to Pro',
                style: AppTypography.h3.copyWith(
                  color: textPrimary,
                ),
                maxLines: 1,
              ),
              SizedBox(height: 8.h),
              AutoSizeText(
                AppLocalizations.of(context)?.unlockAiTutor ?? 'Unlock AI Tutor',
                style: AppTypography.bodyM.copyWith(
                  color: textSecondary,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => _navigateToPaywall(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: AutoSizeText(
                  AppLocalizations.of(context)?.upgrade ?? 'Upgrade',
                  style: AppTypography.button.copyWith(
                    fontSize: 16.sp,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPaywall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaywallScreen(),
      ),
    ).then((result) {
      // إذا تم الشراء بنجاح، يمكن إعادة بناء الـ widget
      if (result == true) {
        // الـ state سيتم تحديثه تلقائياً عبر subscriptionProvider
      }
    });
  }

}

