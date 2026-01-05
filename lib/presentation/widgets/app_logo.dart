import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// -----------------------------------------------------------------
/// 🎨 APP LOGO WIDGET / APP-LOGO-WIDGET / عنصر شعار التطبيق
/// -----------------------------------------------------------------
/// Reusable widget that displays the app logo.
/// Can be used in splash screens, about screens, or headers.
/// -----------------------------------------------------------------
/// **Deutsch:** Wiederverwendbares Widget, das das App-Logo anzeigt.
/// -----------------------------------------------------------------
/// **العربية:** عنصر قابل لإعادة الاستخدام يعرض شعار التطبيق.
/// -----------------------------------------------------------------
class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool maintainAspectRatio;

  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.maintainAspectRatio = true,
  });

  @override
  Widget build(BuildContext context) {
    // استخدام SizedBox مع Image.asset مباشرة لضمان عرض الصورة كاملة
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(
        'assets/logo/app_icon.png',
        width: width,
        height: height,
        fit: BoxFit.contain, // عرض الصورة كاملة بدون قص - يحافظ على النسبة
        filterQuality: FilterQuality.high, // جودة عالية
        alignment: Alignment.center, // توسيط الصورة
        errorBuilder: (context, error, stackTrace) {
          // Fallback إذا لم يتم العثور على الصورة
          return Container(
            width: width ?? 100.w,
            height: height ?? 100.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.quiz,
              size: 50.sp,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }
}

