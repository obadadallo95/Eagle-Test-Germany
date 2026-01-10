import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/points_provider.dart';

/// Widget لعرض النقاط في AppBar
/// يعرض إجمالي النقاط مع أيقونة جميلة وتأثيرات بصرية
class PointsDisplayWidget extends ConsumerWidget {
  const PointsDisplayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalPoints = ref.watch(totalPointsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;

    return FadeInRight(
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryGold.withValues(alpha: 0.2),
              primaryGold.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: primaryGold.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة النقاط
            Icon(
              Icons.stars_rounded,
              color: primaryGold,
              size: 20.sp,
            ),
            SizedBox(width: 6.w),
            // عدد النقاط
            Text(
              _formatPoints(totalPoints),
              style: AppTypography.bodyL.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryGold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// تنسيق النقاط (إضافة فواصل للأرقام الكبيرة)
  String _formatPoints(int points) {
    if (points < 1000) {
      return points.toString();
    } else if (points < 1000000) {
      return '${(points / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(points / 1000000).toStringAsFixed(1)}M';
    }
  }
}

