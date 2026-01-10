# 🇩🇪 Eagle Test: Germany - دليل المطور

<div dir="rtl">

## نظرة عامة

**Eagle Test: Germany** هو تطبيق Flutter متقدم لتحضير امتحان الجنسية الألمانية. التطبيق مبني على Clean Architecture ويستخدم نهج Offline-First مع مزامنة سحابية اختيارية.

## المميزات الرئيسية

- ✅ **Clean Architecture**: فصل واضح بين الطبقات (Domain, Data, Presentation)
- ✅ **Offline-First**: يعمل بدون إنترنت باستخدام Hive
- ✅ **Cloud Sync**: مزامنة اختيارية عبر Supabase (للمشتركين Pro)
- ✅ **State Management**: Riverpod للتحكم في الحالة
- ✅ **Multi-language**: دعم 6 لغات (العربية، الألمانية، الإنجليزية، التركية، الأوكرانية، الروسية)
- ✅ **AI Tutor**: شرح ذكي للأسئلة باستخدام Groq API
- ✅ **SRS**: نظام التكرار المتباعد الذكي
- ✅ **Gamification**: نقاط، تحديات يومية، إحصائيات
- ✅ **Subscriptions**: إدارة الاشتراكات عبر RevenueCat

## التقنيات المستخدمة

### Core Technologies
- **Flutter**: 3.2.0+
- **Dart**: 3.2.0+
- **Riverpod**: 2.4.9 (State Management)
- **Hive**: 2.2.3 (Local Database)
- **Supabase**: 2.5.6 (Cloud Backend)

### Key Packages
- `flutter_riverpod`: إدارة الحالة
- `hive_flutter`: قاعدة بيانات محلية
- `supabase_flutter`: مزامنة سحابية
- `purchases_flutter`: إدارة الاشتراكات
- `flutter_tts`: تحويل النص إلى كلام
- `google_generative_ai`: AI Tutor (Groq API)
- `flutter_local_notifications`: إشعارات ذكية

## هيكل المشروع

```
lib/
├── core/              # المرافق الأساسية
│   ├── config/        # إعدادات البيئة (API Keys)
│   ├── services/      # الخدمات (Sync, Notifications, AI)
│   ├── storage/       # التخزين (Hive, SharedPreferences)
│   ├── theme/         # الثيمات والألوان
│   └── utils/         # أدوات مساعدة
├── data/              # طبقة البيانات
│   ├── datasources/   # مصادر البيانات (JSON files)
│   ├── models/        # نماذج البيانات
│   └── repositories/  # تطبيقات المستودعات
├── domain/            # منطق الأعمال
│   ├── entities/      # الكيانات
│   ├── repositories/  # واجهات المستودعات
│   └── usecases/      # حالات الاستخدام
└── presentation/      # طبقة الواجهة
    ├── providers/     # Riverpod Providers
    ├── screens/       # الشاشات
    └── widgets/       # الويدجتات القابلة لإعادة الاستخدام
```

## الإعداد والتشغيل

### المتطلبات
- Flutter SDK 3.2.0 أو أحدث
- Dart 3.2.0 أو أحدث
- Android Studio / VS Code
- Git

### خطوات الإعداد

1. **استنساخ المشروع**
```bash
git clone <repository-url>
cd politik_test
```

2. **تثبيت التبعيات**
```bash
flutter pub get
```

3. **إعداد Supabase** (اختياري)
   - أنشئ مشروع Supabase جديد
   - قم بتشغيل ملفات SQL من `supabase_migrations/`
   - أضف المفاتيح في `lib/core/config/env_config.dart`

4. **إعداد RevenueCat** (اختياري)
   - أنشئ حساب RevenueCat
   - أضف API Key في `lib/core/services/subscription_service.dart`

5. **إعداد Groq API** (لـ AI Tutor)
   - احصل على API Key من https://console.groq.com
   - أضفه في `lib/core/config/api_config.dart`

6. **تشغيل التطبيق**
```bash
flutter run
```

## البناء للإنتاج

### Android
```bash
flutter build apk --release
# أو
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## الوثائق

- [ARCHITECTURE.md](./ARCHITECTURE.md) - البنية المعمارية التفصيلية
- [CONTRIBUTING.md](./CONTRIBUTING.md) - دليل المساهمة
- [FEATURES_INDEX.md](./FEATURES_INDEX.md) - فهرس الميزات
- [features/](./features/) - وثائق الميزات الفردية

## الدعم

للأسئلة أو المشاكل، يرجى فتح Issue على GitHub.

---

**صُنع بـ ❤️ لتحضير امتحان الجنسية الألمانية**

</div>

