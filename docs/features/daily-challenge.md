# 🎮 Daily Challenge Feature / ميزة التحدي اليومي

## Overview / نظرة عامة

<div dir="rtl">

**التحدي اليومي** هو ميزة تحفيزية تقدم 10 أسئلة عشوائية يومياً مع نظام نقاط واحتفالات.

</div>

**Daily Challenge** is a gamified feature that offers 10 random questions daily with a points system and celebrations.

---

## Location / الموقع

**File**: `lib/presentation/screens/daily_challenge/daily_challenge_screen.dart`

---

## Features / الميزات

### 1. Daily Questions / الأسئلة اليومية

<div dir="rtl">

- **10 أسئلة عشوائية**: يتم اختيارها من جميع الأسئلة
- **متنوعة**: مزيج من الأسئلة العامة والخاصة بالولاية
- **جديدة كل يوم**: تحديث يومي في منتصف الليل

</div>

- **10 Random Questions**: Selected from all questions
- **Varied**: Mix of general and state-specific questions
- **New Daily**: Updates daily at midnight

### 2. Points System / نظام النقاط

<div dir="rtl">

- **إجابة صحيحة**: 10 نقاط
- **إجابة خاطئة**: 0 نقاط
- **إكمال التحدي**: 50 نقطة إضافية
- **نتيجة مثالية (10/10)**: 100 نقطة إضافية

</div>

- **Correct Answer**: 10 points
- **Wrong Answer**: 0 points
- **Complete Challenge**: 50 bonus points
- **Perfect Score (10/10)**: 100 bonus points

### 3. Celebrations / الاحتفالات

<div dir="rtl">

- **Confetti**: احتفال عند إكمال التحدي
- **Animations**: رسوم متحركة عند الإجابة الصحيحة
- **Sound Effects**: أصوات النجاح (اختياري)

</div>

- **Confetti**: Celebration when completing challenge
- **Animations**: Animations on correct answers
- **Sound Effects**: Success sounds (optional)

### 4. Results / النتائج

<div dir="rtl">

- **النتيجة النهائية**: X/10
- **النسبة المئوية**: X%
- **النقاط المكتسبة**: X points
- **تفاصيل كل سؤال**: صحيح/خاطئ

</div>

- **Final Score**: X/10
- **Percentage**: X%
- **Points Earned**: X points
- **Question Details**: Correct/Wrong for each

---

## Data Flow / تدفق البيانات

```
User opens Daily Challenge
    ↓
DailyChallengeProvider generates challenge
    ↓
Check if challenge already completed today
    ↓
If not, generate 10 random questions
    ↓
User answers questions
    ↓
Track answers and points
    ↓
On completion, show results
    ↓
Save to Hive (challenge history)
    ↓
Update points (PointsProvider)
```

---

## Key Components / المكونات الرئيسية

### Screens / الشاشات

- `DailyChallengeScreen`: Main challenge interface
- `DailyChallengeResultDialog`: Results dialog

### Providers / المزودات

- `dailyChallengeProvider`: Challenge state
- `pointsProvider`: Points management

### Widgets / الويدجتات

- `CelebrationOverlay`: Confetti and celebrations
- `AnimatedQuestionCard`: Animated question display

---

## Usage Example / مثال الاستخدام

```dart
// Start daily challenge
class DailyChallengeScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeState = ref.watch(dailyChallengeProvider);
    
    return challengeState.when(
      data: (challenge) {
        if (challenge.isCompleted) {
          return CompletedChallengeWidget();
        }
        return ChallengeQuestionsWidget(questions: challenge.questions);
      },
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => ErrorWidget(err),
    );
  }
}
```

---

## Challenge Generation / توليد التحدي

<div dir="rtl">

**الخوارزمية**:
1. جلب جميع الأسئلة المتاحة
2. اختيار 10 أسئلة عشوائياً
3. ضمان التنوع (مزيج من المواضيع)
4. حفظ التحدي في Hive

</div>

**Algorithm**:
1. Fetch all available questions
2. Randomly select 10 questions
3. Ensure variety (mix of topics)
4. Save challenge in Hive

**Implementation**:
```dart
// In DailyChallengeProvider
static Future<DailyChallenge> generateChallenge() async {
  final allQuestions = await QuestionRepository.getAllQuestions();
  final random = Random();
  final selected = allQuestions.toList()..shuffle(random);
  return DailyChallenge(
    questions: selected.take(10).toList(),
    date: DateTime.now(),
  );
}
```

---

## Related Features / الميزات ذات الصلة

- [Dashboard](./dashboard.md)
- [Gamification](./gamification.md)
- [Points System](./points-system.md)
- [Statistics](./statistics.md)

---

## Technical Details / التفاصيل التقنية

### Daily Reset / إعادة تعيين يومية

<div dir="rtl">

- **الوقت**: منتصف الليل (00:00)
- **التحقق**: عند فتح التحدي
- **التحديث**: توليد تحدٍ جديد تلقائياً

</div>

- **Time**: Midnight (00:00)
- **Check**: When opening challenge
- **Update**: Auto-generate new challenge

### State Management / إدارة الحالة

<div dir="rtl">

- استخدام `StateNotifier` في `dailyChallengeProvider`
- حفظ الحالة عند التنقل
- تحديث تلقائي عند الإجابة

</div>

- Uses `StateNotifier` in `dailyChallengeProvider`
- Saves state when navigating
- Auto-updates on answer

---

## Future Enhancements / التحسينات المستقبلية

<div dir="rtl">

- تحديات أسبوعية
- منافسات مع أصدقاء
- إنجازات خاصة
- لوحة المتصدرين

</div>

- Weekly challenges
- Competitions with friends
- Special achievements
- Leaderboard

