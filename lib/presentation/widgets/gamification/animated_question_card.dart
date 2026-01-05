import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';

/// -----------------------------------------------------------------
/// 🎴 ANIMATED QUESTION CARD / ANIMIERTE FRAGENKARTE / بطاقة السؤال المتحركة
/// -----------------------------------------------------------------
/// Reusable animated question card with slide animation
/// بطاقة قابلة لإعادة الاستخدام مع حركة انزلاقية
/// -----------------------------------------------------------------
class AnimatedQuestionCard extends StatelessWidget {
  final Widget child;
  final Duration slideDuration;
  final Curve slideCurve;
  final EdgeInsets? padding;
  final BoxDecoration? decoration;

  const AnimatedQuestionCard({
    super.key,
    required this.child,
    this.slideDuration = const Duration(milliseconds: 400),
    this.slideCurve = Curves.easeInOutCubic,
    this.padding,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.all(16.w),
      child: SlideInRight(
        duration: slideDuration,
        curve: slideCurve,
        child: Container(
          decoration: decoration ??
              BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.eagleGold.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: SingleChildScrollView(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// -----------------------------------------------------------------
/// 📄 ANIMATED QUESTION VIEW / ANIMIERTE FRAGENANSICHT / عرض الأسئلة المتحرك
/// -----------------------------------------------------------------
/// Wrapper widget that provides PageView-based slide animation for questions
/// يوفر حركة انزلاقية للأسئلة باستخدام PageView
/// -----------------------------------------------------------------
class AnimatedQuestionView extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final PageController? pageController;
  final bool allowSwipe;
  final ValueChanged<int>? onPageChanged;

  const AnimatedQuestionView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.pageController,
    this.allowSwipe = false,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      physics: allowSwipe ? const PageScrollPhysics() : const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        return AnimatedQuestionCard(
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

