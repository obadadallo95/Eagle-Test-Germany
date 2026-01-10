# 📚 Study Mode Feature / ميزة وضع الدراسة

## Overview / نظرة عامة

<div dir="rtl">

**وضع الدراسة** يسمح للمستخدمين بالدراسة حسب المواضيع. يمكن اختيار موضوع معين ودراسة الأسئلة المتعلقة به مع إمكانية الحصول على شرح ذكي من AI Tutor.

</div>

**Study Mode** allows users to study by topics. Users can select a specific topic and study related questions with the option to get intelligent explanations from AI Tutor.

---

## Location / الموقع

**Files**:
- `lib/presentation/screens/study/study_screen.dart`
- `lib/presentation/screens/learn/topic_selection_screen.dart`

---

## Features / الميزات

### 1. Topic Selection / اختيار الموضوع

<div dir="rtl">

المستخدم يختار من قائمة المواضيع:
- **General Questions**: أسئلة عامة (300 سؤال)
- **History**: التاريخ
- **Politics**: السياسة
- **Society**: المجتمع
- **Rights**: الحقوق
- **Welfare**: الرفاهية
- **System**: النظام
- **Europe**: أوروبا
- **State Questions**: أسئلة خاصة بالولاية

</div>

User selects from topic list:
- **General Questions**: General questions (300 questions)
- **History**: History
- **Politics**: Politics
- **Society**: Society
- **Rights**: Rights
- **Welfare**: Welfare
- **System**: System
- **Europe**: Europe
- **State Questions**: State-specific questions

**Implementation**:
- `TopicSelectionScreen`: Topic selection UI
- `QuestionRepository.getQuestionsByTopic()`: Fetches questions by topic

### 2. Question Display / عرض السؤال

<div dir="rtl">

- عرض السؤال باللغة المختارة
- عرض جميع الخيارات
- إمكانية عرض الترجمة (العربية)
- زر لسماع السؤال (TTS)

</div>

- Display question in selected language
- Display all answer options
- Option to show translation (Arabic)
- Button to hear question (TTS)

**Implementation**:
- `QuestionCard` widget
- `flutter_tts` package for text-to-speech

### 3. Answer Feedback / ردود الفعل على الإجابة

<div dir="rtl">

عند الإجابة:
- ✅ إجابة صحيحة: رسالة نجاح + نقاط
- ❌ إجابة خاطئة: عرض الإجابة الصحيحة
- 💡 خيار الحصول على شرح من AI Tutor

</div>

When answering:
- ✅ Correct: Success message + points
- ❌ Wrong: Show correct answer
- 💡 Option to get AI Tutor explanation

**Implementation**:
- `AiTutorService.explainQuestion()`: AI explanation
- `SrsService.updateSrsAfterAnswer()`: Update SRS
- `HiveService.saveAnswer()`: Save progress

### 4. Progress Tracking / تتبع التقدم

<div dir="rtl">

- حفظ كل إجابة في Hive
- تحديث SRS (Spaced Repetition System)
- تحديث النقاط
- تحديث الإحصائيات

</div>

- Save each answer in Hive
- Update SRS (Spaced Repetition System)
- Update points
- Update statistics

---

## Data Flow / تدفق البيانات

```
TopicSelectionScreen
    ↓
User selects topic
    ↓
QuestionRepository.getQuestionsByTopic()
    ↓
LocalDataSource (JSON files)
    ↓
Question entities
    ↓
StudyScreen displays questions
    ↓
User answers
    ↓
SrsService.updateSrsAfterAnswer()
HiveService.saveAnswer()
PointsProvider.update()
```

---

## Key Components / المكونات الرئيسية

### Screens / الشاشات

- `StudyScreen`: Main study interface
- `TopicSelectionScreen`: Topic selection
- `TopicQuestionsScreen`: Questions for selected topic

### Providers / المزودات

- `questionProvider`: Current question
- `pointsProvider`: User points
- `localeProvider`: Selected language

### Services / الخدمات

- `QuestionRepository`: Question data access
- `AiTutorService`: AI explanations
- `SrsService`: Spaced Repetition System
- `HiveService`: Progress storage

### Widgets / الويدجتات

- `QuestionCard`: Question display widget
- `AnimatedQuestionCard`: Animated question card

---

## Usage Example / مثال الاستخدام

```dart
// Topic selection
class TopicSelectionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: topics.length,
      itemBuilder: (context, index) {
        return TopicCard(
          topic: topics[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TopicQuestionsScreen(topic: topics[index]),
              ),
            );
          },
        );
      },
    );
  }
}
```

---

## SRS Integration / تكامل SRS

<div dir="rtl">

عند الإجابة على سؤال:
1. يتم تحديث مستوى الصعوبة في SRS
2. يتم حساب تاريخ المراجعة التالي
3. يتم حفظ البيانات في Hive

**مستويات الصعوبة**:
- 0: New (جديد)
- 1: Hard (صعب)
- 2: Good (جيد)
- 3: Easy (سهل)

</div>

When answering a question:
1. SRS difficulty level is updated
2. Next review date is calculated
3. Data is saved in Hive

**Difficulty Levels**:
- 0: New
- 1: Hard
- 2: Good
- 3: Easy

---

## AI Tutor Integration / تكامل AI Tutor

<div dir="rtl">

المستخدم يمكنه الحصول على شرح ذكي للسؤال:
- يضغط على زر "Explain" / "شرح"
- يتم استدعاء `AiTutorService.explainQuestion()`
- يتم عرض الشرح بصيغة Markdown
- الشرح متاح بجميع اللغات المدعومة

</div>

User can get intelligent explanation for question:
- Presses "Explain" / "شرح" button
- Calls `AiTutorService.explainQuestion()`
- Displays explanation in Markdown format
- Explanation available in all supported languages

**Implementation**:
- Uses Groq API (free, fast)
- Supports 6 languages
- Caches explanations in Hive

---

## Related Features / الميزات ذات الصلة

- [Dashboard](./dashboard.md)
- [AI Tutor](./ai-tutor.md)
- [SRS System](./srs-system.md)
- [Review Mode](./review-mode.md)
- [Favorites](./favorites.md)

---

## Technical Details / التفاصيل التقنية

### Question Loading / تحميل الأسئلة

<div dir="rtl">

- الأسئلة محملة من JSON files محلياً
- لا يحتاج إنترنت للدراسة
- التحميل سريع باستخدام Hive cache

</div>

- Questions loaded from local JSON files
- No internet required for studying
- Fast loading using Hive cache

### State Management / إدارة الحالة

<div dir="rtl">

- استخدام Riverpod Providers
- حفظ الحالة عند التنقل بين الأسئلة
- تحديث تلقائي للإحصائيات

</div>

- Uses Riverpod Providers
- Preserves state when navigating between questions
- Automatic statistics updates

---

## Future Enhancements / التحسينات المستقبلية

<div dir="rtl">

- فلترة الأسئلة حسب الصعوبة
- وضع الدراسة المتقدم (Advanced Study Mode)
- توصيات مخصصة بناءً على الأداء

</div>

- Filter questions by difficulty
- Advanced Study Mode
- Personalized recommendations based on performance

