import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// Reusable card wrapper for settings sections
class SettingsSectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final Color? backgroundColor;
  final Color? borderColor;

  const SettingsSectionCard({
    super.key,
    this.title,
    required this.children,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      color: backgroundColor ?? theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: borderColor ?? AppColors.eagleGold.withValues(alpha: isDark ? 0.2 : 0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Divider(height: 1.h, color: theme.dividerColor),
          ],
          ...children,
        ],
      ),
    );
  }
}

