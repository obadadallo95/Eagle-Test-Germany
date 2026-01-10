import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Special red-themed card for destructive actions
class DangerZoneCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const DangerZoneCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final errorColor = isDark ? AppColors.errorDark : AppColors.errorLight;
    
    return Card(
      color: isDark 
          ? AppColors.errorBgDark 
          : AppColors.errorBgLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(
          color: errorColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(
                  Icons.warning, 
                  color: errorColor, 
                  size: AppSpacing.iconLg,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: AppTypography.h3.copyWith(
                    color: errorColor,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: errorColor.withValues(alpha: 0.3),
          ),
          ...children,
        ],
      ),
    );
  }
}

