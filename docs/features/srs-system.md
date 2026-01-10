# 🧠 SRS System Feature / ميزة نظام التكرار المتباعد

## Overview / نظرة عامة

<div dir="rtl">

**SRS (Spaced Repetition System)** هو نظام ذكي لإدارة مراجعة الأسئلة. يعتمد على منحنى النسيان (Forgetting Curve) لتحسين الاحتفاظ بالذاكرة.

</div>

**SRS (Spaced Repetition System)** is an intelligent system for managing question reviews. Based on the Forgetting Curve to improve memory retention.

---

## Location / الموقع

**File**: `lib/core/storage/srs_service.dart`

---

## Features / الميزات

### 1. Difficulty Levels / مستويات الصعوبة

<div dir="rtl">

**4 مستويات**:
- **0 - New**: سؤال جديد (لم يُجاب عليه)
- **1 - Hard**: سؤال صعب (إجابة خاطئة)
- **2 - Good**: سؤال جيد (إجابة صحيحة مرة)
- **3 - Easy**: سؤال سهل (إجابة صحيحة متعددة)

</div>

**4 Levels**:
- **0 - New**: New question (not answered)
- **1 - Hard**: Hard question (wrong answer)
- **2 - Good**: Good question (correct once)
- **3 - Easy**: Easy question (multiple correct)

### 2. Review Scheduling / جدولة المراجعة

<div dir="rtl">

**حساب تاريخ المراجعة**:
- **New (0)**: مراجعة بعد 1 يوم
- **Hard (1)**: مراجعة بعد 10 دقائق (إذا خطأ) أو 1 يوم (إذا صحيح)
- **Good (2)**: مراجعة بعد 3 أيام
- **Easy (3)**: مراجعة بعد 7 أيام

</div>

**Review Date Calculation**:
- **New (0)**: Review after 1 day
- **Hard (1)**: Review after 10 minutes (if wrong) or 1 day (if correct)
- **Good (2)**: Review after 3 days
- **Easy (3)**: Review after 7 days

### 3. Due Questions / الأسئلة المستحقة

<div dir="rtl">

- **الأسئلة المستحقة**: الأسئلة التي يجب مراجعتها اليوم
- **الأولوية**: الأسئلة الأصعب أولاً
- **التحديث التلقائي**: يتم تحديث SRS بعد كل إجابة

</div>

- **Due Questions**: Questions that should be reviewed today
- **Priority**: Harder questions first
- **Auto Update**: SRS updates after each answer

---

## Implementation / التنفيذ

### Data Structure / هيكل البيانات

<div dir="rtl">

**Storage**: Hive Box `srs_data`

**Format**:
```dart
{
  'q_123': {
    'nextReviewDate': '2024-01-15T10:00:00Z',
    'difficultyLevel': 2,
  }
}
```

</div>

**Storage**: Hive Box `srs_data`

**Format**:
```dart
{
  'q_123': {
    'nextReviewDate': '2024-01-15T10:00:00Z',
    'difficultyLevel': 2,
  }
}
```

### Update Logic / منطق التحديث

<div dir="rtl">

**عند الإجابة الصحيحة**:
1. زيادة مستوى الصعوبة (+1)
2. حساب تاريخ المراجعة التالي (أيام أكثر)
3. حفظ في Hive

**عند الإجابة الخاطئة**:
1. تعيين مستوى الصعوبة إلى 1 (Hard)
2. مراجعة بعد 10 دقائق
3. حفظ في Hive

</div>

**On Correct Answer**:
1. Increase difficulty level (+1)
2. Calculate next review date (more days)
3. Save to Hive

**On Wrong Answer**:
1. Set difficulty level to 1 (Hard)
2. Review after 10 minutes
3. Save to Hive

---

## Data Flow / تدفق البيانات

```
User answers question
    ↓
SrsService.updateSrsAfterAnswer(questionId, isCorrect)
    ↓
Calculate new difficulty level
    ↓
Calculate next review date
    ↓
Save to Hive (srs_data box)
    ↓
Question appears in due list when date arrives
```

---

## Key Components / المكونات الرئيسية

### Service / الخدمة

- `SrsService`: Main SRS service

### Methods / الدوال

- `updateSrsAfterAnswer()`: Update SRS after answer
- `getSrsData()`: Get SRS data for question
- `getDueQuestions()`: Get questions due for review
- `getDifficultyLevel()`: Get difficulty level

---

## Usage Example / مثال الاستخدام

```dart
// After user answers a question
Future<void> onAnswerSelected(String answerId) async {
  final isCorrect = answerId == question.correctAnswerId;
  
  // Update SRS
  await SrsService.updateSrsAfterAnswer(
    question.id,
    isCorrect: isCorrect,
  );
  
  // Update points
  if (isCorrect) {
    await PointsProvider.addPoints(10);
  }
  
  // Save progress
  await HiveService.saveAnswer(question.id, answerId, isCorrect);
}
```

---

## Integration with Daily Plan / التكامل مع الخطة اليومية

<div dir="rtl">

**الخطة اليومية** تستخدم SRS لتحديد الأسئلة:
1. **الأسئلة المستحقة**: أولوية عالية
2. **الأسئلة الصعبة**: أولوية متوسطة
3. **الأسئلة الجديدة**: أولوية منخفضة

</div>

**Daily Plan** uses SRS to determine questions:
1. **Due Questions**: High priority
2. **Hard Questions**: Medium priority
3. **New Questions**: Low priority

**Implementation**:
```dart
// In SmartDailyPlanGenerator
final srsDueQuestions = SrsService.getDueQuestions(allQuestionIds);
final weakQuestions = _identifyWeakQuestions(...); // Uses SRS difficulty
```

---

## Related Features / الميزات ذات الصلة

- [Dashboard](./dashboard.md)
- [Study Mode](./study-mode.md)
- [Review Mode](./review-mode.md)
- [Daily Challenge](./daily-challenge.md)

---

## Technical Details / التفاصيل التقنية

### Review Date Calculation / حساب تاريخ المراجعة

<div dir="rtl">

**الصيغة**:
```dart
int daysToAdd = _calculateDaysForLevel(difficultyLevel);
nextReviewDate = now.add(Duration(days: daysToAdd));
```

**الأيام حسب المستوى**:
- Level 0 → 1 day
- Level 1 → 1 day (if correct) or 10 minutes (if wrong)
- Level 2 → 3 days
- Level 3 → 7 days

</div>

**Formula**:
```dart
int daysToAdd = _calculateDaysForLevel(difficultyLevel);
nextReviewDate = now.add(Duration(days: daysToAdd));
```

**Days by Level**:
- Level 0 → 1 day
- Level 1 → 1 day (if correct) or 10 minutes (if wrong)
- Level 2 → 3 days
- Level 3 → 7 days

### Performance / الأداء

<div dir="rtl">

- **التخزين**: Hive (سريع جداً)
- **الاستعلام**: O(1) للوصول إلى بيانات سؤال
- **التحديث**: O(1) لتحديث بيانات سؤال

</div>

- **Storage**: Hive (very fast)
- **Query**: O(1) to access question data
- **Update**: O(1) to update question data

---

## Future Enhancements / التحسينات المستقبلية

<div dir="rtl">

- خوارزمية SRS أكثر تطوراً (SM-2, Anki algorithm)
- تحليل منحنى النسيان
- توصيات مخصصة بناءً على الأداء
- إحصائيات SRS متقدمة

</div>

- More advanced SRS algorithm (SM-2, Anki algorithm)
- Forgetting curve analysis
- Personalized recommendations based on performance
- Advanced SRS statistics

