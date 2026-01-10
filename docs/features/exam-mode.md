# 📝 Exam Mode Feature / ميزة وضع الامتحان

## Overview / نظرة عامة

<div dir="rtl">

**وضع الامتحان** يوفر محاكاة كاملة لامتحان الجنسية الألمانية. يدعم أنواع متعددة من الامتحانات: Regular, Paper, Voice, و Scan.

</div>

**Exam Mode** provides a complete simulation of the German citizenship test. Supports multiple exam types: Regular, Paper, Voice, and Scan.

---

## Location / الموقع

**Files**:
- `lib/presentation/screens/exam/exam_landing_screen.dart`
- `lib/presentation/screens/exam/exam_detail_screen.dart`
- `lib/presentation/screens/exam/exam_result_screen.dart`
- `lib/presentation/screens/exam/paper_exam_config_screen.dart`
- `lib/presentation/screens/exam/voice_exam_screen.dart`
- `lib/presentation/screens/exam/scan_exam_screen.dart`

---

## Exam Types / أنواع الامتحانات

### 1. Regular Exam / الامتحان العادي

<div dir="rtl">

- 30 سؤال عام + 3 أسئلة خاصة بالولاية
- وقت محدد (60 دقيقة)
- تتبع الوقت
- حفظ التقدم تلقائياً

</div>

- 30 general questions + 3 state-specific questions
- Time limit (60 minutes)
- Time tracking
- Auto-save progress

### 2. Paper Exam / امتحان ورقي

<div dir="rtl">

- امتحان قابل للطباعة
- إمكانية تصحيح الورقة
- حفظ النتيجة

</div>

- Printable exam
- Paper correction capability
- Save results

### 3. Voice Exam / امتحان صوتي

<div dir="rtl">

- امتحان باستخدام Text-to-Speech
- مناسب للقيادة أو الاستماع
- تحكم صوتي

</div>

- Exam using Text-to-Speech
- Suitable for driving or listening
- Voice control

### 4. Scan Exam / امتحان مسح

<div dir="rtl">

- مسح QR Code لامتحان ورقي
- تصحيح تلقائي
- حفظ النتيجة

</div>

- Scan QR Code from paper exam
- Auto-correction
- Save results

---

## Features / الميزات

### 1. Exam Configuration / إعداد الامتحان

<div dir="rtl">

- اختيار نوع الامتحان
- اختيار الولاية (للسئلة الخاصة)
- إعدادات الوقت
- اختيار اللغة

</div>

- Select exam type
- Select state (for state-specific questions)
- Time settings
- Language selection

### 2. Exam Interface / واجهة الامتحان

<div dir="rtl">

- عرض السؤال الحالي
- عداد الأسئلة (X/33)
- عداد الوقت
- زر الإنهاء المبكر
- حفظ تلقائي

</div>

- Display current question
- Question counter (X/33)
- Time counter
- Early finish button
- Auto-save

### 3. Results / النتائج

<div dir="rtl">

- النتيجة النهائية (X/33)
- النسبة المئوية
- حالة النجاح/الرسوب (17/33 للنجاح)
- تفاصيل كل سؤال
- إمكانية المراجعة

</div>

- Final score (X/33)
- Percentage
- Pass/Fail status (17/33 to pass)
- Details for each question
- Review option

---

## Data Flow / تدفق البيانات

```
ExamLandingScreen
    ↓
User selects exam type
    ↓
ExamDetailScreen
    ↓
ExamProvider generates exam
    ↓
QuestionRepository.getExamQuestions()
    ↓
User answers questions
    ↓
ExamProvider tracks answers
    ↓
User finishes exam
    ↓
ExamResultScreen displays results
    ↓
HiveService.saveExamResult()
```

---

## Key Components / المكونات الرئيسية

### Screens / الشاشات

- `ExamLandingScreen`: Exam type selection
- `ExamDetailScreen`: Main exam interface
- `ExamResultScreen`: Results display
- `PaperExamConfigScreen`: Paper exam configuration
- `PaperCorrectionScreen`: Paper correction
- `VoiceExamScreen`: Voice exam interface
- `ScanExamScreen`: QR code scanning

### Providers / المزودات

- `examProvider`: Exam state management
- `questionProvider`: Question data
- `localeProvider`: Language selection

### Services / الخدمات

- `QuestionRepository`: Question data access
- `HiveService`: Exam history storage
- `PdfExamService`: PDF generation
- `ExamReadinessCalculator`: Readiness calculation

### Entities / الكيانات

- `Question`: Question entity
- `ExamResult`: Exam result entity

---

## Exam Logic / منطق الامتحان

### Question Selection / اختيار الأسئلة

<div dir="rtl">

1. **30 سؤال عام**: يتم اختيارها عشوائياً من 300 سؤال عام
2. **3 أسئلة خاصة بالولاية**: يتم اختيارها من أسئلة الولاية المختارة
3. **عدم التكرار**: لا يتم تكرار الأسئلة في نفس الامتحان

</div>

1. **30 General Questions**: Randomly selected from 300 general questions
2. **3 State Questions**: Selected from chosen state's questions
3. **No Duplicates**: No question repeats in same exam

### Scoring / التقييم

<div dir="rtl">

- **النجاح**: 17/33 على الأقل (51.5%)
- **الرسوب**: أقل من 17/33
- **النقاط**: 10 نقاط لكل إجابة صحيحة

</div>

- **Pass**: At least 17/33 (51.5%)
- **Fail**: Less than 17/33
- **Points**: 10 points per correct answer

### Time Management / إدارة الوقت

<div dir="rtl">

- **الوقت الكلي**: 60 دقيقة
- **الوقت المتبقي**: يتم عرضه بشكل مستمر
- **تحذير**: عند انتهاء الوقت، يتم إنهاء الامتحان تلقائياً

</div>

- **Total Time**: 60 minutes
- **Time Remaining**: Continuously displayed
- **Warning**: When time expires, exam auto-finishes

---

## Usage Example / مثال الاستخدام

```dart
// Starting an exam
class ExamDetailScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examState = ref.watch(examProvider);
    
    return Scaffold(
      body: Column(
        children: [
          TimeTracker(remainingTime: examState.remainingTime),
          QuestionCard(question: examState.currentQuestion),
          AnswerOptions(
            options: examState.currentQuestion.answers,
            onAnswerSelected: (answerId) {
              ref.read(examProvider.notifier).answerQuestion(answerId);
            },
          ),
        ],
      ),
    );
  }
}
```

---

## PDF Generation / توليد PDF

<div dir="rtl">

للامتحان الورقي:
- توليد PDF للامتحان
- QR Code للتصحيح
- إمكانية الطباعة
- إمكانية المشاركة

</div>

For paper exam:
- Generate PDF for exam
- QR Code for correction
- Print capability
- Share capability

**Implementation**:
- `PdfExamService.generateExamPdf()`
- Uses `pdf` and `printing` packages

---

## Related Features / الميزات ذات الصلة

- [Dashboard](./dashboard.md)
- [Study Mode](./study-mode.md)
- [Review Mode](./review-mode.md)
- [Statistics](./statistics.md)
- [Progress Tracking](./progress-tracking.md)

---

## Technical Details / التفاصيل التقنية

### State Management / إدارة الحالة

<div dir="rtl">

- استخدام `StateNotifier` في `examProvider`
- حفظ الحالة عند التنقل
- استعادة الحالة عند العودة

</div>

- Uses `StateNotifier` in `examProvider`
- Saves state when navigating
- Restores state when returning

### Auto-Save / الحفظ التلقائي

<div dir="rtl">

- يتم حفظ التقدم كل 30 ثانية
- يتم حفظ عند الإجابة على سؤال
- يتم حفظ عند إنهاء الامتحان

</div>

- Progress saved every 30 seconds
- Saved when answering a question
- Saved when finishing exam

---

## Future Enhancements / التحسينات المستقبلية

<div dir="rtl">

- امتحانات مخصصة حسب الموضوع
- وضع الامتحان المتقدم
- تحليل مفصل للأخطاء

</div>

- Custom exams by topic
- Advanced exam mode
- Detailed error analysis

