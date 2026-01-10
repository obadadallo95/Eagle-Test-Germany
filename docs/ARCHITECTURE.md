# 🏗️ Architecture Documentation / وثائق البنية المعمارية

## Table of Contents / جدول المحتويات

- [Overview / نظرة عامة](#overview--نظرة-عامة)
- [Architecture Pattern / نمط البنية](#architecture-pattern--نمط-البنية)
- [Layer Structure / هيكل الطبقات](#layer-structure--هيكل-الطبقات)
- [Data Flow / تدفق البيانات](#data-flow--تدفق-البيانات)
- [Design Patterns / أنماط التصميم](#design-patterns--أنماط-التصميم)
- [Key Components / المكونات الرئيسية](#key-components--المكونات-الرئيسية)

---

## Overview / نظرة عامة

<div dir="rtl">

### العربية

تطبيق **Eagle Test: Germany** يستخدم **Clean Architecture** مع نهج **Offline-First** ومزامنة سحابية اختيارية. البنية مصممة لضمان:

- ✅ **الفصل بين الطبقات**: Domain, Data, Presentation منفصلة تماماً
- ✅ **الاستقلالية**: كل طبقة تعمل بشكل مستقل
- ✅ **القابلية للاختبار**: سهولة كتابة Unit Tests
- ✅ **المرونة**: سهولة استبدال المكونات
- ✅ **الأداء**: عمل بدون إنترنت مع Hive

</div>

### Deutsch

Die **Eagle Test: Germany** App verwendet **Clean Architecture** mit einem **Offline-First**-Ansatz und optionaler Cloud-Synchronisation. Die Architektur ist darauf ausgelegt, sicherzustellen:

- ✅ **Schichttrennung**: Domain, Data, Presentation vollständig getrennt
- ✅ **Unabhängigkeit**: Jede Schicht arbeitet unabhängig
- ✅ **Testbarkeit**: Einfaches Schreiben von Unit Tests
- ✅ **Flexibilität**: Einfacher Austausch von Komponenten
- ✅ **Leistung**: Funktionieren ohne Internet mit Hive

---

## Architecture Pattern / نمط البنية

### Clean Architecture Layers / طبقات Clean Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  (UI, Widgets, Providers, Screens)                      │
│  ───────────────────────────────────────                 │
│  • Riverpod Providers                                   │
│  • Flutter Widgets                                      │
│  • Screen Components                                     │
└─────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────┐
│                      Domain Layer                        │
│  (Business Logic, Entities, Use Cases)                  │
│  ───────────────────────────────────────                 │
│  • Entities (Question, UserProfile, etc.)               │
│  • Use Cases (SmartDailyPlanGenerator, etc.)           │
│  • Repository Interfaces                                │
└─────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────┐
│                       Data Layer                        │
│  (Data Sources, Models, Repository Implementations)     │
│  ───────────────────────────────────────                 │
│  • Data Sources (Local JSON, Hive)                      │
│  • Models (QuestionModel, etc.)                         │
│  • Repository Implementations                           │
└─────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────┐
│                      Core Layer                          │
│  (Services, Storage, Theme, Utils)                       │
│  ───────────────────────────────────────                 │
│  • Services (Sync, Notification, AI, etc.)              │
│  • Storage (Hive, SharedPreferences)                    │
│  • Theme & Configuration                                 │
└─────────────────────────────────────────────────────────┘
```

---

## Layer Structure / هيكل الطبقات

### 1. Presentation Layer / طبقة العرض

<div dir="rtl">

**الموقع**: `lib/presentation/`

**المسؤولية**: واجهة المستخدم وإدارة الحالة

**المكونات**:
- `screens/`: جميع شاشات التطبيق
- `providers/`: Riverpod Providers لإدارة الحالة
- `widgets/`: ويدجتات قابلة لإعادة الاستخدام

**مثال**:
```dart
// presentation/screens/dashboard/dashboard_screen.dart
class DashboardScreen extends ConsumerStatefulWidget {
  // يستخدم Riverpod Provider للحصول على البيانات
  final dailyPlan = ref.watch(dailyPlanProvider);
}
```

</div>

**Location**: `lib/presentation/`

**Responsibility**: User Interface and State Management

**Components**:
- `screens/`: All app screens
- `providers/`: Riverpod Providers for state management
- `widgets/`: Reusable widgets

**Example**:
```dart
// presentation/screens/dashboard/dashboard_screen.dart
class DashboardScreen extends ConsumerStatefulWidget {
  // Uses Riverpod Provider to get data
  final dailyPlan = ref.watch(dailyPlanProvider);
}
```

### 2. Domain Layer / طبقة المجال

<div dir="rtl">

**الموقع**: `lib/domain/`

**المسؤولية**: منطق الأعمال (Business Logic)

**المكونات**:
- `entities/`: الكيانات الأساسية (Question, UserProfile, etc.)
- `usecases/`: حالات الاستخدام (SmartDailyPlanGenerator, ExamReadinessCalculator)
- `repositories/`: واجهات المستودعات (QuestionRepository)

**مثال**:
```dart
// domain/usecases/smart_daily_plan_generator.dart
class SmartDailyPlanGenerator {
  static Future<DailyPlan> generate() async {
    // منطق الأعمال النقي (بدون UI أو Data dependencies)
  }
}
```

</div>

**Location**: `lib/domain/`

**Responsibility**: Business Logic

**Components**:
- `entities/`: Core entities (Question, UserProfile, etc.)
- `usecases/`: Use cases (SmartDailyPlanGenerator, ExamReadinessCalculator)
- `repositories/`: Repository interfaces (QuestionRepository)

**Example**:
```dart
// domain/usecases/smart_daily_plan_generator.dart
class SmartDailyPlanGenerator {
  static Future<DailyPlan> generate() async {
    // Pure business logic (no UI or Data dependencies)
  }
}
```

### 3. Data Layer / طبقة البيانات

<div dir="rtl">

**الموقع**: `lib/data/`

**المسؤولية**: الوصول إلى البيانات والتخزين

**المكونات**:
- `datasources/`: مصادر البيانات (Local JSON files, Hive)
- `models/`: نماذج البيانات (QuestionModel, GlossaryModel)
- `repositories/`: تطبيقات المستودعات (QuestionRepositoryImpl)

**مثال**:
```dart
// data/repositories/question_repository_impl.dart
class QuestionRepositoryImpl implements QuestionRepository {
  final LocalDataSource _dataSource;
  
  @override
  Future<List<Question>> getQuestions() async {
    // جلب البيانات من LocalDataSource
  }
}
```

</div>

**Location**: `lib/data/`

**Responsibility**: Data Access and Storage

**Components**:
- `datasources/`: Data sources (Local JSON files, Hive)
- `models/`: Data models (QuestionModel, GlossaryModel)
- `repositories/`: Repository implementations (QuestionRepositoryImpl)

**Example**:
```dart
// data/repositories/question_repository_impl.dart
class QuestionRepositoryImpl implements QuestionRepository {
  final LocalDataSource _dataSource;
  
  @override
  Future<List<Question>> getQuestions() async {
    // Fetch data from LocalDataSource
  }
}
```

### 4. Core Layer / الطبقة الأساسية

<div dir="rtl">

**الموقع**: `lib/core/`

**المسؤولية**: المرافق المشتركة والخدمات

**المكونات**:
- `services/`: الخدمات (SyncService, NotificationService, AiTutorService)
- `storage/`: التخزين (HiveService, UserPreferencesService, SrsService)
- `theme/`: الثيمات والألوان
- `config/`: الإعدادات (API Keys, Environment)

**مثال**:
```dart
// core/services/sync_service.dart
class SyncService {
  static Future<void> syncProgressToCloud() async {
    // مزامنة التقدم إلى Supabase
  }
}
```

</div>

**Location**: `lib/core/`

**Responsibility**: Shared Utilities and Services

**Components**:
- `services/`: Services (SyncService, NotificationService, AiTutorService)
- `storage/`: Storage (HiveService, UserPreferencesService, SrsService)
- `theme/`: Themes and Colors
- `config/`: Configuration (API Keys, Environment)

**Example**:
```dart
// core/services/sync_service.dart
class SyncService {
  static Future<void> syncProgressToCloud() async {
    // Sync progress to Supabase
  }
}
```

---

## Data Flow / تدفق البيانات

### Typical Flow / التدفق النموذجي

```
User Action (UI)
    ↓
Presentation Layer (Provider)
    ↓
Domain Layer (Use Case)
    ↓
Domain Layer (Repository Interface)
    ↓
Data Layer (Repository Implementation)
    ↓
Data Layer (DataSource)
    ↓
Storage (Hive/JSON) or Cloud (Supabase)
    ↓
Response flows back up
```

### Example: Loading Questions / مثال: تحميل الأسئلة

```
1. User opens Study Screen
   ↓
2. StudyScreen watches questionProvider
   ↓
3. questionProvider calls QuestionRepository.getQuestions()
   ↓
4. QuestionRepositoryImpl fetches from LocalDataSource
   ↓
5. LocalDataSource loads from JSON files
   ↓
6. Data flows back: JSON → Model → Entity → Provider → UI
```

---

## Design Patterns / أنماط التصميم

### 1. Repository Pattern / نمط المستودع

<div dir="rtl">

**الاستخدام**: فصل منطق الوصول إلى البيانات عن منطق الأعمال

**التطبيق**:
- `domain/repositories/question_repository.dart`: واجهة
- `data/repositories/question_repository_impl.dart`: تطبيق

</div>

**Usage**: Separates data access logic from business logic

**Implementation**:
- `domain/repositories/question_repository.dart`: Interface
- `data/repositories/question_repository_impl.dart`: Implementation

### 2. Provider Pattern (Riverpod) / نمط Provider

<div dir="rtl">

**الاستخدام**: إدارة الحالة بشكل تفاعلي

**التطبيق**:
- `presentation/providers/`: جميع Providers
- مثال: `dailyPlanProvider`, `questionProvider`, `examProvider`

</div>

**Usage**: Reactive state management

**Implementation**:
- `presentation/providers/`: All providers
- Examples: `dailyPlanProvider`, `questionProvider`, `examProvider`

### 3. Use Case Pattern / نمط حالة الاستخدام

<div dir="rtl">

**الاستخدام**: تنظيم منطق الأعمال في حالات استخدام منفصلة

**التطبيق**:
- `domain/usecases/smart_daily_plan_generator.dart`
- `domain/usecases/exam_readiness_calculator.dart`

</div>

**Usage**: Organizing business logic into separate use cases

**Implementation**:
- `domain/usecases/smart_daily_plan_generator.dart`
- `domain/usecases/exam_readiness_calculator.dart`

### 4. Service Pattern / نمط الخدمة

<div dir="rtl">

**الاستخدام**: خدمات قابلة لإعادة الاستخدام عبر التطبيق

**التطبيق**:
- `core/services/sync_service.dart`
- `core/services/notification_service.dart`
- `core/services/ai_tutor_service.dart`

</div>

**Usage**: Reusable services across the app

**Implementation**:
- `core/services/sync_service.dart`
- `core/services/notification_service.dart`
- `core/services/ai_tutor_service.dart`

---

## Key Components / المكونات الرئيسية

### State Management / إدارة الحالة

**Technology**: Riverpod 2.4.9

**Structure**:
```
presentation/providers/
├── daily_plan_provider.dart
├── question_provider.dart
├── exam_provider.dart
├── subscription_provider.dart
└── ...
```

### Local Storage / التخزين المحلي

**Technologies**:
- **Hive**: Fast NoSQL database for user progress
- **SharedPreferences**: Simple key-value storage for preferences

**Structure**:
```
core/storage/
├── hive_service.dart          # User progress, exam history
├── user_preferences_service.dart  # User settings
├── srs_service.dart           # Spaced Repetition System
└── favorites_service.dart     # Favorite questions
```

### Cloud Sync / المزامنة السحابية

**Technology**: Supabase

**Features**:
- Anonymous authentication
- User profiles
- Progress synchronization (Pro only)
- Device tracking (3-device limit for Pro)

**Structure**:
```
core/services/
├── sync_service.dart          # Progress sync
├── auth_service.dart          # Authentication
└── subscription_service.dart  # RevenueCat integration
```

### Offline-First Strategy / استراتيجية Offline-First

<div dir="rtl">

1. **البيانات الأساسية**: مخزنة محلياً في JSON files
2. **تقدم المستخدم**: مخزن في Hive (يعمل بدون إنترنت)
3. **المزامنة**: اختيارية للمشتركين Pro
4. **الاستمرارية**: التطبيق يعمل بالكامل بدون إنترنت

</div>

1. **Core Data**: Stored locally in JSON files
2. **User Progress**: Stored in Hive (works offline)
3. **Sync**: Optional for Pro subscribers
4. **Resilience**: App fully functional without internet

---

## Dependency Flow / تدفق التبعيات

### Dependency Rule / قاعدة التبعيات

```
Presentation → Domain ← Data
     ↓            ↓
    Core ←────────┘
```

**Rules**:
- ✅ Presentation can depend on Domain
- ✅ Data can depend on Domain
- ✅ Domain **cannot** depend on Presentation or Data
- ✅ All layers can depend on Core

### Example / مثال

```dart
// ✅ CORRECT: Presentation depends on Domain
class DashboardScreen {
  final dailyPlan = ref.watch(dailyPlanProvider); // Uses Domain entity
}

// ❌ WRONG: Domain depends on Presentation
class SmartDailyPlanGenerator {
  // Cannot use Flutter widgets here
}
```

---

## Testing Strategy / استراتيجية الاختبار

### Unit Tests / اختبارات الوحدة

<div dir="rtl">

**التركيز**: Domain Layer و Use Cases

**مثال**:
```dart
test('SmartDailyPlanGenerator generates plan correctly', () {
  // Test business logic without UI or Data dependencies
});
```

</div>

**Focus**: Domain Layer and Use Cases

**Example**:
```dart
test('SmartDailyPlanGenerator generates plan correctly', () {
  // Test business logic without UI or Data dependencies
});
```

### Widget Tests / اختبارات الويدجتات

<div dir="rtl">

**التركيز**: Presentation Layer

**مثال**:
```dart
testWidgets('DashboardScreen displays daily plan', (tester) async {
  // Test UI components
});
```

</div>

**Focus**: Presentation Layer

**Example**:
```dart
testWidgets('DashboardScreen displays daily plan', (tester) async {
  // Test UI components
});
```

---

## Best Practices / أفضل الممارسات

### 1. Separation of Concerns / فصل الاهتمامات

<div dir="rtl">

- ✅ كل طبقة لها مسؤولية واحدة واضحة
- ✅ لا تخلط منطق الأعمال مع UI
- ✅ استخدم Use Cases لتنظيم منطق الأعمال

</div>

- ✅ Each layer has one clear responsibility
- ✅ Don't mix business logic with UI
- ✅ Use Use Cases to organize business logic

### 2. Dependency Injection / حقن التبعيات

<div dir="rtl">

- ✅ استخدم Riverpod Providers للتبعيات
- ✅ تجنب Singleton patterns المباشرة
- ✅ اجعل الكود قابل للاختبار

</div>

- ✅ Use Riverpod Providers for dependencies
- ✅ Avoid direct Singleton patterns
- ✅ Make code testable

### 3. Error Handling / معالجة الأخطاء

<div dir="rtl">

- ✅ استخدم AppExceptions في Core
- ✅ معالجة الأخطاء في كل طبقة
- ✅ رسائل خطأ واضحة للمستخدم

</div>

- ✅ Use AppExceptions in Core
- ✅ Handle errors at each layer
- ✅ Clear error messages for users

---

## Conclusion / الخلاصة

<div dir="rtl">

البنية المعمارية مصممة لضمان:
- **القابلية للصيانة**: كود منظم وسهل الفهم
- **القابلية للتوسع**: سهولة إضافة ميزات جديدة
- **الأداء**: عمل سريع وبدون إنترنت
- **الموثوقية**: معالجة أخطاء قوية

</div>

The architecture is designed to ensure:
- **Maintainability**: Organized and easy-to-understand code
- **Scalability**: Easy to add new features
- **Performance**: Fast and offline-capable
- **Reliability**: Strong error handling

