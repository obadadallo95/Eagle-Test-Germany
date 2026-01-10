# 📊 Dashboard Feature / ميزة لوحة التحكم

## Overview / نظرة عامة

<div dir="rtl">

**لوحة التحكم** هي الشاشة الرئيسية في التطبيق. تعرض الخطة اليومية للدراسة، التقدم، الإحصائيات السريعة، والوصول السريع للميزات الرئيسية.

</div>

The **Dashboard** is the main screen of the application. It displays the daily study plan, progress, quick statistics, and quick access to main features.

---

## Location / الموقع

**File**: `lib/presentation/screens/dashboard/dashboard_screen.dart`

---

## Features / الميزات

### 1. Daily Plan Widget / ويدجت الخطة اليومية

<div dir="rtl">

يعرض الخطة اليومية الذكية التي يتم إنشاؤها تلقائياً بناءً على:
- الأسئلة الضعيفة (SRS difficulty < 2)
- الأسئلة المستحقة للمراجعة (SRS due)
- قرب تاريخ الامتحان
- مستوى نشاط المستخدم

</div>

Displays the smart daily plan automatically generated based on:
- Weak questions (SRS difficulty < 2)
- Questions due for review (SRS due)
- Exam date proximity
- User activity level

**Implementation**:
- Uses `SmartDailyPlanGenerator` (Domain Layer)
- Provider: `dailyPlanProvider`
- Entity: `DailyPlan`

### 2. Progress Indicators / مؤشرات التقدم

<div dir="rtl">

- **Exam Readiness Score**: نسبة الاستعداد للامتحان (0-100%)
- **Questions Learned**: عدد الأسئلة التي تم تعلمها
- **Exams Passed**: عدد الامتحانات التي تم اجتيازها
- **Study Streak**: عدد الأيام المتتالية للدراسة

</div>

- **Exam Readiness Score**: Readiness percentage (0-100%)
- **Questions Learned**: Number of questions learned
- **Exams Passed**: Number of exams passed
- **Study Streak**: Consecutive study days

**Implementation**:
- Uses `ExamReadinessCalculator` (Domain Layer)
- Provider: `examReadinessProvider`
- Storage: `HiveService.getUserProgress()`

### 3. Quick Actions / الإجراءات السريعة

<div dir="rtl">

- **Start Study**: بدء الدراسة
- **Take Exam**: بدء امتحان
- **Daily Challenge**: التحدي اليومي
- **Review Mistakes**: مراجعة الأخطاء

</div>

- **Start Study**: Begin studying
- **Take Exam**: Start an exam
- **Daily Challenge**: Daily challenge
- **Review Mistakes**: Review mistakes

### 4. Points Display / عرض النقاط

<div dir="rtl">

يعرض النقاط الحالية للمستخدم. النقاط تُكتسب من:
- إجابة صحيحة في الدراسة
- اجتياز امتحان
- إكمال التحدي اليومي
- الحفاظ على السلسلة (Streak)

</div>

Displays current user points. Points are earned from:
- Correct answers in study mode
- Passing exams
- Completing daily challenges
- Maintaining study streak

**Implementation**:
- Provider: `pointsProvider`
- Storage: `HiveService.getUserProgress()`

---

## Data Flow / تدفق البيانات

```
DashboardScreen
    ↓
dailyPlanProvider (Riverpod)
    ↓
SmartDailyPlanGenerator.generate() (Domain)
    ↓
HiveService.getUserProgress() (Data)
    ↓
Hive Database (Storage)
```

---

## Key Components / المكونات الرئيسية

### Providers / المزودات

- `dailyPlanProvider`: Daily study plan
- `examReadinessProvider`: Exam readiness score
- `pointsProvider`: User points
- `progressStoryProvider`: Weekly progress story

### Services / الخدمات

- `SmartDailyPlanGenerator`: Generates daily plan
- `ExamReadinessCalculator`: Calculates readiness
- `HiveService`: Local storage

---

## Usage Example / مثال الاستخدام

```dart
// In DashboardScreen
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyPlanAsync = ref.watch(dailyPlanProvider);
    final readinessAsync = ref.watch(examReadinessProvider);
    
    return dailyPlanAsync.when(
      data: (plan) => DailyPlanWidget(plan: plan),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => ErrorWidget(err),
    );
  }
}
```

---

## Related Features / الميزات ذات الصلة

- [Study Mode](./study-mode.md)
- [Exam Mode](./exam-mode.md)
- [Daily Challenge](./daily-challenge.md)
- [Progress Tracking](./progress-tracking.md)
- [SRS System](./srs-system.md)

---

## Technical Details / التفاصيل التقنية

### Refresh Strategy / استراتيجية التحديث

<div dir="rtl">

- يتم تحديث الخطة اليومية تلقائياً عند فتح الشاشة
- يتم تحديث الإحصائيات عند تغيير التبويب
- يتم حفظ الحالة باستخدام `PageStorageKey`

</div>

- Daily plan refreshes automatically when screen opens
- Statistics update when tab changes
- State is preserved using `PageStorageKey`

### Performance / الأداء

<div dir="rtl">

- استخدام `FutureProvider` للبيانات غير المتزامنة
- تخزين مؤقت للبيانات في Provider
- تحميل البيانات بشكل تدريجي

</div>

- Uses `FutureProvider` for async data
- Data caching in Provider
- Progressive data loading

---

## Future Enhancements / التحسينات المستقبلية

<div dir="rtl">

- إضافة رسوم بيانية للتقدم
- إشعارات ذكية بناءً على التقدم
- توصيات مخصصة للدراسة

</div>

- Add progress charts
- Smart notifications based on progress
- Personalized study recommendations

