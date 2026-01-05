import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Standardized settings tile with consistent styling
class SettingsTile extends StatelessWidget {
  final IconData? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;
  final double? iconSize;

  const SettingsTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.textColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: leading != null
          ? Icon(
              leading,
              size: iconSize ?? 28.sp,
              color: iconColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.7),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          color: textColor ?? theme.colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: trailing ?? (onTap != null 
          ? Icon(
              Icons.chevron_right, 
              size: 20.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ) 
          : null),
      onTap: onTap,
    );
  }
}

