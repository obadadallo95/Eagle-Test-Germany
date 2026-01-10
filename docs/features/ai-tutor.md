# 🤖 AI Tutor Feature / ميزة المعلم الذكي

## Overview / نظرة عامة

<div dir="rtl">

**AI Tutor** يوفر شرحاً ذكياً للأسئلة باستخدام Groq API. يشرح لماذا الإجابة الصحيحة صحيحة باللغة المختارة من المستخدم.

</div>

**AI Tutor** provides intelligent explanations for questions using Groq API. Explains why the correct answer is correct in the user's selected language.

---

## Location / الموقع

**File**: `lib/core/services/ai_tutor_service.dart`

---

## Features / الميزات

### 1. Intelligent Explanations / الشروحات الذكية

<div dir="rtl">

- شرح واضح ومختصر (2-4 جمل)
- استخدام Markdown للتنسيق
- كلمات مفتاحية بخط عريض
- سياق ذو صلة عند الحاجة

</div>

- Clear and concise explanation (2-4 sentences)
- Markdown formatting
- Bold keywords
- Relevant context when needed

### 2. Multi-Language Support / دعم متعدد اللغات

<div dir="rtl">

يدعم 6 لغات:
- العربية (ar)
- الإنجليزية (en)
- الألمانية (de)
- التركية (tr)
- الأوكرانية (uk)
- الروسية (ru)

</div>

Supports 6 languages:
- Arabic (ar)
- English (en)
- German (de)
- Turkish (tr)
- Ukrainian (uk)
- Russian (ru)

### 3. Free & Fast / مجاني وسريع

<div dir="rtl">

- **Groq API**: مجاني تماماً (لا يحتاج بطاقة ائتمان)
- **سرعة**: سريع جداً (يستخدم TPU)
- **جودة**: شرح دقيق ومفيد

</div>

- **Groq API**: Completely free (no credit card needed)
- **Speed**: Very fast (uses TPU)
- **Quality**: Accurate and helpful explanations

---

## Implementation / التنفيذ

### API Configuration / إعداد API

<div dir="rtl">

**الموقع**: `lib/core/config/api_config.dart`

**المتطلبات**:
1. الحصول على API Key من https://console.groq.com
2. إضافة API Key في `api_config.dart`
3. اختيار النموذج (model)

**النماذج المتاحة**:
- `llama-3.1-8b-instant`: سريع ومجاني (الافتراضي)
- `mixtral-8x7b-32768`: أكثر دقة
- `llama-3.1-70b-versatile`: أقوى لكن أبطأ

</div>

**Location**: `lib/core/config/api_config.dart`

**Requirements**:
1. Get API Key from https://console.groq.com
2. Add API Key in `api_config.dart`
3. Select model

**Available Models**:
- `llama-3.1-8b-instant`: Fast and free (default)
- `mixtral-8x7b-32768`: More accurate
- `llama-3.1-70b-versatile`: More powerful but slower

### Service Structure / هيكل الخدمة

```dart
class AiTutorService {
  /// Explain question in selected language
  static Future<String> explainQuestion({
    required Question question,
    required String userLanguage,
  }) async {
    // 1. Build prompt with question and answers
    // 2. Call Groq API
    // 3. Parse response
    // 4. Return explanation
  }
}
```

---

## Data Flow / تدفق البيانات

```
User requests explanation
    ↓
AiTutorService.explainQuestion()
    ↓
Build prompt (question + answers + language)
    ↓
Call Groq API (HTTP POST)
    ↓
Parse JSON response
    ↓
Extract explanation text
    ↓
Return Markdown explanation
    ↓
Display in UI (Markdown widget)
```

---

## Usage Example / مثال الاستخدام

```dart
// In StudyScreen or ExamScreen
class QuestionCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Question display
        Text(question.text),
        
        // Explanation button
        ElevatedButton(
          onPressed: () async {
            final explanation = await AiTutorService.explainQuestion(
              question: question,
              userLanguage: ref.read(localeProvider).languageCode,
            );
            
            showDialog(
              context: context,
              builder: (_) => ExplanationDialog(explanation: explanation),
            );
          },
          child: Text('Explain / شرح'),
        ),
      ],
    );
  }
}
```

---

## Prompt Engineering / هندسة الـ Prompt

<div dir="rtl">

**System Prompt**:
```
You are an expert German Citizenship Tutor. 
Explain answers clearly and concisely in the requested language. 
Use Markdown with **bold** for keywords. 
Keep explanations 2-4 sentences (80-120 words).
```

**User Prompt**:
```
Question: [Question text]

Answers:
✓ [Correct answer]
✗ [Wrong answer 1]
✗ [Wrong answer 2]
✗ [Wrong answer 3]

Explain in [Language] why the correct answer (✓) is right. 
Include context if relevant. Write ONLY in [Language].
```

</div>

**System Prompt**:
```
You are an expert German Citizenship Tutor. 
Explain answers clearly and concisely in the requested language. 
Use Markdown with **bold** for keywords. 
Keep explanations 2-4 sentences (80-120 words).
```

**User Prompt**:
```
Question: [Question text]

Answers:
✓ [Correct answer]
✗ [Wrong answer 1]
✗ [Wrong answer 2]
✗ [Wrong answer 3]

Explain in [Language] why the correct answer (✓) is right. 
Include context if relevant. Write ONLY in [Language].
```

---

## Error Handling / معالجة الأخطاء

<div dir="rtl">

**حالات الخطأ**:
1. **API Key غير موجود**: استخدام Mock explanation
2. **خطأ في الشبكة**: رسالة خطأ باللغة المختارة
3. **Rate Limit**: رسالة "حاول مرة أخرى لاحقاً"
4. **Timeout**: رسالة خطأ بعد 30 ثانية

</div>

**Error Cases**:
1. **No API Key**: Use Mock explanation
2. **Network Error**: Error message in selected language
3. **Rate Limit**: "Try again later" message
4. **Timeout**: Error message after 30 seconds

**Implementation**:
```dart
try {
  final explanation = await AiTutorService.explainQuestion(...);
  // Display explanation
} catch (e) {
  // Show error message in user's language
  showErrorDialog(context, errorMessage);
}
```

---

## Caching / التخزين المؤقت

<div dir="rtl">

- **التخزين**: يتم حفظ الشروحات في Hive
- **المدة**: الشروحات محفوظة بشكل دائم
- **الفائدة**: تقليل استدعاءات API وتحسين الأداء

</div>

- **Storage**: Explanations saved in Hive
- **Duration**: Explanations saved permanently
- **Benefit**: Reduce API calls and improve performance

**Implementation**:
- `HiveService.recordAiTutorUsage()`: Track usage
- Cache key: `ai_explanation_${questionId}_${language}`

---

## Related Features / الميزات ذات الصلة

- [Study Mode](./study-mode.md)
- [Exam Mode](./exam-mode.md)
- [Review Mode](./review-mode.md)
- [Dashboard](./dashboard.md)

---

## Technical Details / التفاصيل التقنية

### API Configuration / إعداد API

<div dir="rtl">

**Endpoint**: `https://api.groq.com/openai/v1/chat/completions`

**Headers**:
- `Content-Type: application/json`
- `Authorization: Bearer {API_KEY}`

**Request Body**:
```json
{
  "model": "llama-3.1-8b-instant",
  "messages": [
    {"role": "system", "content": "..."},
    {"role": "user", "content": "..."}
  ],
  "max_tokens": 250,
  "temperature": 0.5
}
```

</div>

**Endpoint**: `https://api.groq.com/openai/v1/chat/completions`

**Headers**:
- `Content-Type: application/json`
- `Authorization: Bearer {API_KEY}`

**Request Body**:
```json
{
  "model": "llama-3.1-8b-instant",
  "messages": [
    {"role": "system", "content": "..."},
    {"role": "user", "content": "..."}
  ],
  "max_tokens": 250,
  "temperature": 0.5
}
```

### Performance / الأداء

<div dir="rtl">

- **متوسط الوقت**: 1-3 ثوانٍ
- **Timeout**: 30 ثانية
- **Retry**: لا يوجد (يستخدم Mock عند الفشل)

</div>

- **Average Time**: 1-3 seconds
- **Timeout**: 30 seconds
- **Retry**: None (uses Mock on failure)

---

## Future Enhancements / التحسينات المستقبلية

<div dir="rtl">

- تخزين مؤقت محسّن
- شرح تفصيلي أكثر
- إمكانية طرح أسئلة متابعة
- تحليل الأخطاء الشائعة

</div>

- Improved caching
- More detailed explanations
- Follow-up questions capability
- Common mistakes analysis

