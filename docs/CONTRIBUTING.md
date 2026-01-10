# 🤝 Contributing Guide / دليل المساهمة

## Table of Contents / جدول المحتويات

- [Code Style / نمط الكود](#code-style--نمط-الكود)
- [Naming Conventions / قواعد التسمية](#naming-conventions--قواعد-التسمية)
- [Git Workflow / سير عمل Git](#git-workflow--سير-عمل-git)
- [Pull Request Process / عملية Pull Request](#pull-request-process--عملية-pull-request)
- [Testing Guidelines / إرشادات الاختبار](#testing-guidelines--إرشادات-الاختبار)

---

## Code Style / نمط الكود

### Dart Style Guide / دليل نمط Dart

<div dir="rtl">

**الالتزام بـ**: [Effective Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)

**أدوات**:
- `dart format .` - تنسيق الكود تلقائياً
- `flutter analyze` - فحص الأخطاء والتحذيرات

</div>

**Follow**: [Effective Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)

**Tools**:
- `dart format .` - Auto-format code
- `flutter analyze` - Check for errors and warnings

### Formatting Rules / قواعد التنسيق

```dart
// ✅ GOOD: Use trailing commas
final list = [
  'item1',
  'item2',
  'item3', // trailing comma
];

// ✅ GOOD: Consistent indentation (2 spaces)
class MyClass {
  void myMethod() {
    if (condition) {
      // code
    }
  }
}

// ❌ BAD: Inconsistent spacing
class MyClass{
void myMethod(){
if(condition){
// code
}}}
```

---

## Naming Conventions / قواعد التسمية

### Files / الملفات

<div dir="rtl">

**القاعدة**: snake_case

**أمثلة**:
- ✅ `daily_plan_provider.dart`
- ✅ `exam_result_screen.dart`
- ✅ `user_preferences_service.dart`
- ❌ `DailyPlanProvider.dart` (PascalCase)
- ❌ `exam-result-screen.dart` (kebab-case)

</div>

**Rule**: snake_case

**Examples**:
- ✅ `daily_plan_provider.dart`
- ✅ `exam_result_screen.dart`
- ✅ `user_preferences_service.dart`
- ❌ `DailyPlanProvider.dart` (PascalCase)
- ❌ `exam-result-screen.dart` (kebab-case)

### Classes / الفئات

<div dir="rtl">

**القاعدة**: PascalCase

**أمثلة**:
- ✅ `DashboardScreen`
- ✅ `SmartDailyPlanGenerator`
- ✅ `SyncService`
- ❌ `dashboardScreen` (camelCase)
- ❌ `sync_service` (snake_case)

</div>

**Rule**: PascalCase

**Examples**:
- ✅ `DashboardScreen`
- ✅ `SmartDailyPlanGenerator`
- ✅ `SyncService`
- ❌ `dashboardScreen` (camelCase)
- ❌ `sync_service` (snake_case)

### Variables & Functions / المتغيرات والدوال

<div dir="rtl">

**القاعدة**: camelCase

**أمثلة**:
- ✅ `dailyPlan`
- ✅ `getUserProgress()`
- ✅ `isProUser`
- ❌ `daily_plan` (snake_case)
- ❌ `GetUserProgress()` (PascalCase)

</div>

**Rule**: camelCase

**Examples**:
- ✅ `dailyPlan`
- ✅ `getUserProgress()`
- ✅ `isProUser`
- ❌ `daily_plan` (snake_case)
- ❌ `GetUserProgress()` (PascalCase)

### Private Members / الأعضاء الخاصة

<div dir="rtl">

**القاعدة**: `_` prefix + camelCase

**أمثلة**:
- ✅ `_currentIndex`
- ✅ `_onButtonPressed()`
- ✅ `_isLoading`
- ❌ `currentIndex` (public)
- ❌ `__doubleUnderscore` (double underscore)

</div>

**Rule**: `_` prefix + camelCase

**Examples**:
- ✅ `_currentIndex`
- ✅ `_onButtonPressed()`
- ✅ `_isLoading`
- ❌ `currentIndex` (public)
- ❌ `__doubleUnderscore` (double underscore)

### Constants / الثوابت

<div dir="rtl">

**القاعدة**: `lowerCamelCase` أو `UPPER_SNAKE_CASE` للثوابت العامة

**أمثلة**:
- ✅ `maxQuestionsPerDay` (class constant)
- ✅ `API_BASE_URL` (global constant)
- ✅ `entitlementId` (static const)

</div>

**Rule**: `lowerCamelCase` or `UPPER_SNAKE_CASE` for global constants

**Examples**:
- ✅ `maxQuestionsPerDay` (class constant)
- ✅ `API_BASE_URL` (global constant)
- ✅ `entitlementId` (static const)

---

## Architecture Rules / قواعد البنية المعمارية

### Layer Separation / فصل الطبقات

<div dir="rtl">

**القاعدة**: لا تخلط الطبقات

**✅ صحيح**:
```dart
// Domain Layer
class SmartDailyPlanGenerator {
  static Future<DailyPlan> generate() async {
    // Pure business logic
  }
}

// Presentation Layer
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(dailyPlanProvider);
    // UI code
  }
}
```

**❌ خطأ**:
```dart
// ❌ Domain layer using Flutter widgets
class SmartDailyPlanGenerator {
  Widget buildWidget() { // NO!
    return Text('Hello');
  }
}

// ❌ Presentation layer with business logic
class DashboardScreen {
  Future<DailyPlan> generatePlan() { // NO!
    // Business logic in UI layer
  }
}
```

</div>

**Rule**: Don't mix layers

**✅ Correct**:
```dart
// Domain Layer
class SmartDailyPlanGenerator {
  static Future<DailyPlan> generate() async {
    // Pure business logic
  }
}

// Presentation Layer
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(dailyPlanProvider);
    // UI code
  }
}
```

**❌ Wrong**:
```dart
// ❌ Domain layer using Flutter widgets
class SmartDailyPlanGenerator {
  Widget buildWidget() { // NO!
    return Text('Hello');
  }
}

// ❌ Presentation layer with business logic
class DashboardScreen {
  Future<DailyPlan> generatePlan() { // NO!
    // Business logic in UI layer
  }
}
```

### State Management / إدارة الحالة

<div dir="rtl">

**القاعدة**: استخدم Riverpod Providers

**✅ صحيح**:
```dart
// Provider definition
final dailyPlanProvider = FutureProvider<DailyPlan>((ref) {
  return SmartDailyPlanGenerator.generate();
});

// Usage in widget
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(dailyPlanProvider);
    return planAsync.when(
      data: (plan) => Text(plan.explanation),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

</div>

**Rule**: Use Riverpod Providers

**✅ Correct**:
```dart
// Provider definition
final dailyPlanProvider = FutureProvider<DailyPlan>((ref) {
  return SmartDailyPlanGenerator.generate();
});

// Usage in widget
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(dailyPlanProvider);
    return planAsync.when(
      data: (plan) => Text(plan.explanation),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

---

## Git Workflow / سير عمل Git

### Branch Naming / تسمية الفروع

<div dir="rtl">

**القاعدة**: `type/description`

**الأنواع**:
- `feature/` - ميزة جديدة
- `fix/` - إصلاح خطأ
- `refactor/` - إعادة هيكلة
- `docs/` - تحديث الوثائق
- `test/` - إضافة اختبارات

**أمثلة**:
- ✅ `feature/daily-challenge`
- ✅ `fix/exam-result-calculation`
- ✅ `refactor/sync-service`
- ✅ `docs/architecture-update`
- ❌ `new-feature` (no type prefix)
- ❌ `fix_bug` (underscore)

</div>

**Rule**: `type/description`

**Types**:
- `feature/` - New feature
- `fix/` - Bug fix
- `refactor/` - Code refactoring
- `docs/` - Documentation update
- `test/` - Adding tests

**Examples**:
- ✅ `feature/daily-challenge`
- ✅ `fix/exam-result-calculation`
- ✅ `refactor/sync-service`
- ✅ `docs/architecture-update`
- ❌ `new-feature` (no type prefix)
- ❌ `fix_bug` (underscore)

### Commit Messages / رسائل الالتزام

<div dir="rtl">

**القاعدة**: [Conventional Commits](https://www.conventionalcommits.org/)

**الصيغة**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**الأنواع**:
- `feat`: ميزة جديدة
- `fix`: إصلاح خطأ
- `docs`: تحديث الوثائق
- `style`: تنسيق الكود
- `refactor`: إعادة هيكلة
- `test`: إضافة اختبارات
- `chore`: مهام صيانة

**أمثلة**:
```
feat(dashboard): add daily plan widget

Add a new widget to display the daily study plan
on the dashboard screen.

Closes #123
```

```
fix(sync): resolve progress merge conflict

Fix issue where progress merging was causing
data loss for Pro users.

Fixes #456
```

</div>

**Rule**: [Conventional Commits](https://www.conventionalcommits.org/)

**Format**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation update
- `style`: Code formatting
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples**:
```
feat(dashboard): add daily plan widget

Add a new widget to display the daily study plan
on the dashboard screen.

Closes #123
```

```
fix(sync): resolve progress merge conflict

Fix issue where progress merging was causing
data loss for Pro users.

Fixes #456
```

---

## Pull Request Process / عملية Pull Request

### Before Submitting / قبل الإرسال

<div dir="rtl">

1. ✅ تأكد من أن الكود يتبع نمط المشروع
2. ✅ قم بتشغيل `flutter analyze` و `dart format .`
3. ✅ أضف اختبارات إذا لزم الأمر
4. ✅ حدّث الوثائق إذا لزم الأمر
5. ✅ تأكد من أن جميع الاختبارات تمر

</div>

1. ✅ Ensure code follows project style
2. ✅ Run `flutter analyze` and `dart format .`
3. ✅ Add tests if needed
4. ✅ Update documentation if needed
5. ✅ Ensure all tests pass

### PR Template / قالب Pull Request

```markdown
## Description / الوصف
Brief description of changes

## Type of Change / نوع التغيير
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing / الاختبار
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Manual testing performed

## Checklist / قائمة التحقق
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings generated
```

---

## Testing Guidelines / إرشادات الاختبار

### Unit Tests / اختبارات الوحدة

<div dir="rtl">

**الموقع**: `test/`

**التركيز**: Domain Layer و Use Cases

**مثال**:
```dart
// test/domain/usecases/smart_daily_plan_generator_test.dart
void main() {
  group('SmartDailyPlanGenerator', () {
    test('generates plan with correct question count', () async {
      final plan = await SmartDailyPlanGenerator.generate();
      expect(plan.questionIds.length, greaterThanOrEqualTo(3));
      expect(plan.questionIds.length, lessThanOrEqualTo(7));
    });
  });
}
```

</div>

**Location**: `test/`

**Focus**: Domain Layer and Use Cases

**Example**:
```dart
// test/domain/usecases/smart_daily_plan_generator_test.dart
void main() {
  group('SmartDailyPlanGenerator', () {
    test('generates plan with correct question count', () async {
      final plan = await SmartDailyPlanGenerator.generate();
      expect(plan.questionIds.length, greaterThanOrEqualTo(3));
      expect(plan.questionIds.length, lessThanOrEqualTo(7));
    });
  });
}
```

### Widget Tests / اختبارات الويدجتات

<div dir="rtl">

**التركيز**: Presentation Layer

**مثال**:
```dart
// test/presentation/screens/dashboard_test.dart
void main() {
  testWidgets('DashboardScreen displays daily plan', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: DashboardScreen()),
      ),
    );
    
    expect(find.text('Today\'s Focus'), findsOneWidget);
  });
}
```

</div>

**Focus**: Presentation Layer

**Example**:
```dart
// test/presentation/screens/dashboard_test.dart
void main() {
  testWidgets('DashboardScreen displays daily plan', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: DashboardScreen()),
      ),
    );
    
    expect(find.text('Today\'s Focus'), findsOneWidget);
  });
}
```

---

## Code Review Guidelines / إرشادات مراجعة الكود

### What to Look For / ما يجب البحث عنه

<div dir="rtl">

1. **البنية المعمارية**: هل الكود في الطبقة الصحيحة؟
2. **الأداء**: هل هناك تحسينات ممكنة؟
3. **الأمان**: هل هناك مشاكل أمنية؟
4. **الوثائق**: هل الكود موثق بشكل كافٍ؟
5. **الاختبارات**: هل هناك تغطية اختبار كافية؟

</div>

1. **Architecture**: Is code in the correct layer?
2. **Performance**: Are there possible optimizations?
3. **Security**: Are there security issues?
4. **Documentation**: Is code sufficiently documented?
5. **Tests**: Is there adequate test coverage?

---

## Documentation Standards / معايير الوثائق

### Code Comments / تعليقات الكود

<div dir="rtl">

**استخدم**: Dart Doc comments للدوال العامة

**مثال**:
```dart
/// Generates a smart daily study plan based on user progress.
/// 
/// Returns a [DailyPlan] with question IDs and explanation.
/// This method is deterministic: same inputs → same outputs.
static Future<DailyPlan> generate() async {
  // Implementation
}
```

</div>

**Use**: Dart Doc comments for public functions

**Example**:
```dart
/// Generates a smart daily study plan based on user progress.
/// 
/// Returns a [DailyPlan] with question IDs and explanation.
/// This method is deterministic: same inputs → same outputs.
static Future<DailyPlan> generate() async {
  // Implementation
}
```

---

## Questions? / أسئلة؟

<div dir="rtl">

إذا كان لديك أي أسئلة حول المساهمة، يرجى:
1. فتح Issue على GitHub
2. مراجعة الوثائق الموجودة
3. التواصل مع الفريق

</div>

If you have questions about contributing, please:
1. Open an Issue on GitHub
2. Review existing documentation
3. Contact the team

---

**Thank you for contributing! / شكراً لمساهمتك!**

