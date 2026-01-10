import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Reusable card wrapper for settings sections with modern gradient design
class SettingsSectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final Color? backgroundColor;
  final Color? borderColor;
  final IconData? titleIcon;

  const SettingsSectionCard({
    super.key,
    this.title,
    required this.children,
    this.backgroundColor,
    this.borderColor,
    this.titleIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final surfaceColor = backgroundColor ?? 
        (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  surfaceColor,
                  surfaceColor.withValues(alpha: 0.95),
                  AppColors.darkSurface.withValues(alpha: 0.85),
                ]
              : [
                  surfaceColor,
                  surfaceColor.withValues(alpha: 0.98),
                  AppColors.lightSurface.withValues(alpha: 0.95),
                ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: borderColor ?? primaryGold.withValues(alpha: isDark ? 0.15 : 0.2),
          width: 1.5.w,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : primaryGold.withValues(alpha: 0.08),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark
                ? primaryGold.withValues(alpha: 0.05)
                : primaryGold.withValues(alpha: 0.03),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 18.h,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryGold.withValues(alpha: isDark ? 0.1 : 0.08),
                    primaryGold.withValues(alpha: isDark ? 0.05 : 0.04),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: Row(
                children: [
                  if (titleIcon != null) ...[
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: primaryGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        titleIcon,
                        size: 20.sp,
                        color: primaryGold,
                      ),
                    ),
                    SizedBox(width: 12.w),
                  ],
                  Expanded(
                    child: Text(
                      title!,
                      style: AppTypography.h3.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1.h,
              thickness: 1,
              color: primaryGold.withValues(alpha: isDark ? 0.1 : 0.15),
            ),
          ],
          ...children,
        ],
      ),
    );
  }
}

