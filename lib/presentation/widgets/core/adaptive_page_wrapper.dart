import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// -----------------------------------------------------------------
/// 📱 ADAPTIVE PAGE WRAPPER / ADAPTIVE SEITENWRAPPER / الحاوية الذكية
/// -----------------------------------------------------------------
/// Smart wrapper widget that adapts to all screen sizes (smartwatches to tablets)
/// Ensures no overflow errors and provides responsive padding and safe areas
/// حاوية ذكية تتكيف مع جميع أحجام الشاشات (من الساعات الذكية إلى الأجهزة اللوحية)
/// تضمن عدم وجود أخطاء overflow وتوفر padding و safe area متجاوبة
/// -----------------------------------------------------------------
class AdaptivePageWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool enableSafeArea;
  final bool enableScroll;
  final ScrollPhysics? physics;
  final AlignmentGeometry? alignment;

  const AdaptivePageWrapper({
    super.key,
    required this.child,
    this.padding,
    this.enableSafeArea = true,
    this.enableScroll = true,
    this.physics,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // تحديد حجم الشاشة
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;
        
        // تحديد إذا كانت الشاشة صغيرة (ساعة ذكية)
        final isSmallScreen = screenHeight < 400 || screenWidth < 300;
        
        // Padding متجاوب
        final responsivePadding = padding ?? EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8.w : 16.w,
          vertical: isSmallScreen ? 8.h : 16.h,
        );

        Widget content = child;

        // إضافة Alignment إذا كان محدد
        if (alignment != null) {
          content = Align(
            alignment: alignment!,
            child: content,
          );
        }

        // إضافة ConstrainedBox لضمان عدم تجاوز الحدود
        content = ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
            maxWidth: constraints.maxWidth,
          ),
          child: content,
        );

        // إضافة Padding
        content = Padding(
          padding: responsivePadding,
          child: content,
        );

        // إضافة SingleChildScrollView إذا كان التمرير مفعلاً
        if (enableScroll) {
          content = SingleChildScrollView(
            physics: physics ?? const AlwaysScrollableScrollPhysics(),
            child: content,
          );
        }

        // إضافة SafeArea إذا كان مفعلاً
        if (enableSafeArea) {
          content = SafeArea(
            child: content,
          );
        }

        return content;
      },
    );
  }
}

