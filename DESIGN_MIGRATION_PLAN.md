# 🎨 خطة تحديث التصميم - Eagle Test Germany

## 📋 نظرة عامة

هذه الخطة تشرح كيفية تحديث جميع الصفحات لاستخدام نظام التصميم الجديد (Design System v3.0).

---

## 🎯 الأهداف

1. ✅ استبدال الألوان القديمة بالجديدة
2. ✅ استخدام نظام Typography الجديد (Poppins + Inter)
3. ✅ استخدام نظام Spacing الجديد (4px grid)
4. ✅ دعم الثيم النهاري والليلي
5. ✅ إضافة ThemeSelector لصفحة الإعدادات

---

## 🔄 جدول التحويل

### الألوان (AppColors)

| القديم | الجديد | الاستخدام |
|--------|--------|----------|
| `eagleGold` | `gold` | اللون الذهبي الأساسي |
| `primaryGold` | `gold` | اللون الذهبي الأساسي |
| `germanRed` | `errorDark` / `errorLight` | أخطاء، إجابات خاطئة |
| `primaryRed` | `errorDark` / `errorLight` | أخطاء |
| `darkCharcoal` | `darkBg` / `darkSurface` | خلفيات داكنة |
| `deepBlack` | `darkBg` | خلفية التطبيق |
| `darkSurface` (قديم) | `darkSurface` (جديد) | الكروت |
| `correctGreen` | `successDark` / `successLight` | إجابات صحيحة |
| `wrongRed` | `errorDark` / `errorLight` | إجابات خاطئة |

### دعم الثيمين

```dart
// ❌ الطريقة القديمة
color: AppColors.eagleGold

// ✅ الطريقة الجديدة (لون ثابت)
color: AppColors.gold

// ✅ الطريقة الجديدة (لون متغير حسب الثيم)
final isDark = Theme.of(context).brightness == Brightness.dark;
color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary
// أو
color: AppColors.textPrimary(Theme.of(context).brightness)
```

---

## 📱 الصفحات المطلوب تحديثها

### المرحلة 1: الأساسية (الأولوية القصوى) ⭐⭐⭐

| # | الصفحة | المسار | الحالة | الملاحظات |
|---|--------|--------|--------|----------|
| 1 | **Settings** | `settings/settings_screen.dart` | ⏳ | إضافة ThemeSelector |
| 2 | **Main Screen** | `main_screen.dart` | ⏳ | Bottom Navigation |
| 3 | **Dashboard** | `dashboard/dashboard_screen.dart` | ⏳ | 28 مرجع لـ eagleGold |
| 4 | **Study** | `study/study_screen.dart` | ⏳ | Topic cards |
| 5 | **Question/Exam** | `exam_screen.dart` | ⏳ | Answer options |

### المرحلة 2: الامتحانات والنتائج ⭐⭐

| # | الصفحة | المسار | الحالة | الملاحظات |
|---|--------|--------|--------|----------|
| 6 | **Exam Landing** | `exam/exam_landing_screen.dart` | ⏳ | شاشة بدء الامتحان |
| 7 | **Exam Detail** | `exam/exam_detail_screen.dart` | ⏳ | 25+ مرجع |
| 8 | **Exam Result** | `exam/exam_result_screen.dart` | ⏳ | نتيجة الامتحان |
| 9 | **Daily Challenge** | `daily_challenge/daily_challenge_screen.dart` | ⏳ | 30+ مرجع |
| 10 | **Daily Result** | `daily_challenge/daily_challenge_result_dialog.dart` | ⏳ | نتيجة التحدي |

### المرحلة 3: الشاشات الثانوية ⭐

| # | الصفحة | المسار | الحالة | الملاحظات |
|---|--------|--------|--------|----------|
| 11 | **Profile** | `profile/profile_dashboard_screen.dart` | ⏳ | صفحة الملف الشخصي |
| 12 | **Statistics** | `stats/statistics_screen.dart` | ⏳ | الإحصائيات |
| 13 | **Review** | `review/review_screen.dart` | ⏳ | مراجعة الأخطاء |
| 14 | **Favorites** | `favorites/favorites_screen.dart` | ⏳ | المفضلة |
| 15 | **Glossary** | `glossary/glossary_screen.dart` | ⏳ | المصطلحات |

### المرحلة 4: الإعدادات والقانونية

| # | الصفحة | المسار | الحالة | الملاحظات |
|---|--------|--------|--------|----------|
| 16 | **About** | `settings/about_screen.dart` | ⏳ | حول التطبيق |
| 17 | **Language** | `settings/language_screen.dart` | ⏳ | اختيار اللغة |
| 18 | **Legal** | `settings/legal_screen.dart` | ⏳ | الشروط والخصوصية |
| 19 | **State Selection** | `settings/state_selection_sheet.dart` | ⏳ | اختيار الولاية |

### المرحلة 5: الاشتراكات والخاصة

| # | الصفحة | المسار | الحالة | الملاحظات |
|---|--------|--------|--------|----------|
| 20 | **Paywall** | `subscription/paywall_screen.dart` | ⏳ | صفحة الاشتراك |
| 21 | **Onboarding** | `onboarding/setup_screen.dart` | ⏳ | شاشة الإعداد الأولي |
| 22 | **Maintenance** | `maintenance/maintenance_screen.dart` | ⏳ | شاشة الصيانة |
| 23 | **Drive Mode** | `drive_mode_screen.dart` | ⏳ | وضع القيادة |

### المرحلة 6: Widgets المشتركة

| # | الويدجت | المسار | الحالة |
|---|---------|--------|--------|
| 24 | Settings Section | `settings/widgets/settings_section_card.dart` | ⏳ |
| 25 | Settings Tile | `settings/widgets/settings_tile.dart` | ⏳ |
| 26 | Section Header | `settings/widgets/section_header.dart` | ⏳ |
| 27 | Danger Zone | `settings/widgets/danger_zone_card.dart` | ⏳ |

---

## 🛠️ خطوات التحديث لكل صفحة

### 1. إضافة الاستيرادات

```dart
// إضافة في أعلى الملف
import 'package:politik_test/core/theme/theme.dart';
// أو
import 'package:politik_test/core/theme/app_colors.dart';
import 'package:politik_test/core/theme/app_typography.dart';
import 'package:politik_test/core/theme/app_spacing.dart';
```

### 2. تعريف متغيرات الثيم

```dart
@override
Widget build(BuildContext context) {
  // إضافة في بداية build method
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final theme = Theme.of(context);
  
  // ...
}
```

### 3. استبدال الألوان

```dart
// ❌ قبل
backgroundColor: AppColors.eagleGold,
color: AppColors.darkCharcoal,

// ✅ بعد
backgroundColor: AppColors.gold,
color: isDark ? AppColors.darkBg : AppColors.lightBg,
```

### 4. استبدال Typography

```dart
// ❌ قبل
style: TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.white,
)

// ✅ بعد
style: AppTypography.h2.copyWith(
  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
)
```

### 5. استبدال Spacing

```dart
// ❌ قبل
padding: EdgeInsets.all(16),
SizedBox(height: 8),

// ✅ بعد
padding: AppSpacing.all(AppSpacing.lg),
SizedBox(height: AppSpacing.sm),
// أو
AppSpacing.sm.vGap, // باستخدام Extension
```

---

## 📊 إحصائيات التحديث

### عدد المراجع المطلوب تحديثها (تقريبي)

| اللون القديم | عدد المراجع |
|-------------|-------------|
| `eagleGold` | ~150 |
| `darkCharcoal` | ~20 |
| `correctGreen` | ~30 |
| `wrongRed` | ~30 |
| `germanRed` | ~10 |
| **المجموع** | **~240** |

---

## ⏱️ الجدول الزمني المقترح

| المرحلة | المدة | الوصف |
|--------|-------|-------|
| المرحلة 1 | 1-2 ساعة | الصفحات الأساسية (5 صفحات) |
| المرحلة 2 | 1-2 ساعة | الامتحانات والنتائج (5 صفحات) |
| المرحلة 3 | 1 ساعة | الشاشات الثانوية (5 صفحات) |
| المرحلة 4 | 30 دقيقة | الإعدادات والقانونية (4 صفحات) |
| المرحلة 5 | 30 دقيقة | الاشتراكات والخاصة (4 صفحات) |
| المرحلة 6 | 30 دقيقة | Widgets المشتركة (4 ملفات) |
| **المجموع** | **~6 ساعات** | |

---

## ✅ قائمة التحقق لكل صفحة

- [ ] استبدال جميع مراجع `eagleGold` → `gold`
- [ ] استبدال جميع مراجع `darkCharcoal` → `darkBg` / `darkSurface`
- [ ] استبدال جميع مراجع `correctGreen` → `successDark`
- [ ] استبدال جميع مراجع `wrongRed` → `errorDark`
- [ ] استبدال جميع مراجع `germanRed` → `errorDark`
- [ ] إضافة دعم Light mode للألوان
- [ ] استخدام `AppTypography` للنصوص
- [ ] استخدام `AppSpacing` للتباعد
- [ ] اختبار Light mode
- [ ] اختبار Dark mode
- [ ] اختبار RTL (العربية)

---

## 🚀 البدء

### الأمر للبحث عن المراجع القديمة:

```bash
# البحث عن eagleGold
grep -r "eagleGold" lib/presentation/

# البحث عن جميع الألوان القديمة
grep -rE "(eagleGold|darkCharcoal|correctGreen|wrongRed|germanRed|primaryGold)" lib/presentation/
```

---

## 📝 ملاحظات مهمة

1. **الاختبار**: اختبر كل صفحة في كلا الثيمين (Dark + Light)
2. **RTL**: تأكد أن الصفحات تعمل بشكل صحيح مع اللغة العربية
3. **التدرج**: لا تحاول تحديث كل شيء دفعة واحدة
4. **النسخ الاحتياطي**: احفظ التغييرات بعد كل مرحلة
5. **الألوان القديمة**: ستبقى تعمل (deprecated) لكن يُفضل التحديث

---

**تاريخ الإنشاء:** يناير 2026  
**آخر تحديث:** يناير 2026  
**الحالة:** جاري التنفيذ 🔄

