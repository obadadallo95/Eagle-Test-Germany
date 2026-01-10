import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Modern settings tile with beautiful icon backgrounds and smooth animations
class SettingsTile extends StatefulWidget {
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
  State<SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<SettingsTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final iconBgColor = widget.iconColor ?? primaryGold;
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 16.h,
            ),
            child: Row(
              children: [
                // Icon with beautiful gradient background
                if (widget.leading != null) ...[
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          iconBgColor.withValues(alpha: isDark ? 0.25 : 0.2),
                          iconBgColor.withValues(alpha: isDark ? 0.15 : 0.12),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: iconBgColor.withValues(alpha: isDark ? 0.3 : 0.25),
                        width: 1.5.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: iconBgColor.withValues(alpha: isDark ? 0.2 : 0.15),
                          blurRadius: 8.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.leading,
                      size: widget.iconSize ?? 24.sp,
                      color: iconBgColor,
                    ),
                  ),
                  SizedBox(width: 16.w),
                ],
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppTypography.bodyL.copyWith(
                          color: widget.textColor ?? 
                              (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          widget.subtitle!,
                          style: AppTypography.bodyS.copyWith(
                            color: isDark 
                                ? AppColors.darkTextSecondary 
                                : AppColors.lightTextSecondary,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Trailing widget
                if (widget.trailing != null)
                  Padding(
                    padding: EdgeInsets.only(left: 12.w),
                    child: widget.trailing!,
                  )
                else if (widget.onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 24.sp,
                    color: primaryGold.withValues(alpha: isDark ? 0.6 : 0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

