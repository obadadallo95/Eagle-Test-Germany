# ☁️ Cloud Sync Feature / ميزة المزامنة السحابية

## Overview / نظرة عامة

<div dir="rtl">

**Cloud Sync** يسمح للمشتركين Pro بمزامنة تقدمهم عبر الأجهزة. يستخدم Supabase كخادم خلفي ويوفر مزامنة ذكية مع دعم حتى 3 أجهزة.

</div>

**Cloud Sync** allows Pro subscribers to sync their progress across devices. Uses Supabase as backend and provides intelligent sync with support for up to 3 devices.

---

## Location / الموقع

**File**: `lib/core/services/sync_service.dart`

---

## Features / الميزات

### 1. Progress Synchronization / مزامنة التقدم

<div dir="rtl">

- **مزامنة إلى السحابة**: رفع التقدم المحلي إلى Supabase
- **استعادة من السحابة**: تنزيل التقدم من السحابة
- **دمج ذكي**: دمج التقدم المحلي والسحابي بذكاء

</div>

- **Sync to Cloud**: Upload local progress to Supabase
- **Restore from Cloud**: Download progress from cloud
- **Smart Merge**: Intelligently merge local and cloud progress

### 2. Multi-Device Support / دعم متعدد الأجهزة

<div dir="rtl">

- **حتى 3 أجهزة**: Pro users يمكنهم المزامنة على 3 أجهزة
- **مزامنة مشتركة**: نفس التقدم على جميع الأجهزة
- **تتبع الأجهزة**: تتبع الأجهزة النشطة

</div>

- **Up to 3 Devices**: Pro users can sync on 3 devices
- **Shared Progress**: Same progress on all devices
- **Device Tracking**: Track active devices

### 3. Offline-First / Offline-First

<div dir="rtl">

- **يعمل بدون إنترنت**: التطبيق يعمل بالكامل بدون إنترنت
- **مزامنة عند الاتصال**: يتم المزامنة تلقائياً عند الاتصال
- **عدم فقدان البيانات**: البيانات محفوظة محلياً دائماً

</div>

- **Works Offline**: App fully functional without internet
- **Sync on Connect**: Automatically syncs when connected
- **No Data Loss**: Data always saved locally

---

## Architecture / البنية المعمارية

### Database Schema / مخطط قاعدة البيانات

<div dir="rtl">

**Tables**:
1. `user_profiles`: معلومات المستخدم
2. `user_progress`: تقدم المستخدم

**user_profiles**:
- `user_id`: معرف المستخدم (Supabase Auth)
- `revenuecat_customer_id`: معرف RevenueCat (للمزامنة المشتركة)
- `is_pro`: حالة الاشتراك
- `name`: اسم المستخدم (اختياري)

**user_progress**:
- `user_id`: معرف المستخدم
- `revenuecat_customer_id`: معرف RevenueCat (للمزامنة المشتركة)
- `questions_learned`: عدد الأسئلة المتعلمة
- `exams_passed`: عدد الامتحانات المجتازة
- `readiness_score`: درجة الاستعداد (0-100)
- `answered_questions`: JSON array of question IDs
- `exams_passed_ids`: JSON array of exam IDs
- `last_sync_at`: آخر وقت مزامنة
- `last_active_at`: آخر وقت نشاط

</div>

**Tables**:
1. `user_profiles`: User information
2. `user_progress`: User progress

**user_profiles**:
- `user_id`: User ID (Supabase Auth)
- `revenuecat_customer_id`: RevenueCat customer ID (for shared sync)
- `is_pro`: Subscription status
- `name`: User name (optional)

**user_progress**:
- `user_id`: User ID
- `revenuecat_customer_id`: RevenueCat customer ID (for shared sync)
- `questions_learned`: Number of questions learned
- `exams_passed`: Number of exams passed
- `readiness_score`: Readiness score (0-100)
- `answered_questions`: JSON array of question IDs
- `exams_passed_ids`: JSON array of exam IDs
- `last_sync_at`: Last sync timestamp
- `last_active_at`: Last activity timestamp

---

## Data Flow / تدفق البيانات

### Sync to Cloud / المزامنة إلى السحابة

```
User action triggers sync
    ↓
SyncService.syncProgressToCloud()
    ↓
Check Pro status (SubscriptionService.isProUser())
    ↓
Get local progress (HiveService.getUserProgress())
    ↓
Get cloud progress (Supabase)
    ↓
Merge progress (ProgressMerger.merge())
    ↓
Save merged to local (HiveService.saveUserProgress())
    ↓
Upload merged to cloud (Supabase.upsert())
```

### Restore from Cloud / الاستعادة من السحابة

```
App startup or manual restore
    ↓
SyncService.restoreProgressFromCloud()
    ↓
Check Pro status
    ↓
Fetch cloud progress (Supabase)
    ↓
Get local progress (HiveService)
    ↓
Merge progress (ProgressMerger.merge())
    ↓
Save merged to local (HiveService)
```

---

## Key Components / المكونات الرئيسية

### Services / الخدمات

- `SyncService`: Main sync service
- `SubscriptionService`: Pro status check
- `ProgressMerger`: Intelligent progress merging
- `HiveService`: Local storage
- `AuthService`: Authentication

### Utilities / الأدوات

- `ProgressMerger`: Merges local and cloud progress
- `AppLogger`: Logging

---

## Progress Merging / دمج التقدم

<div dir="rtl">

**الخوارزمية**:
1. **الأسئلة**: دمج جميع الأسئلة المجابة (من كلا المصدرين)
2. **الامتحانات**: دمج جميع الامتحانات المجتازة
3. **الأحدث يفوز**: إذا كان نفس السؤال في كلا المصدرين، الأحدث يفوز
4. **لا فقدان**: لا يتم فقدان أي بيانات

</div>

**Algorithm**:
1. **Questions**: Merge all answered questions (from both sources)
2. **Exams**: Merge all passed exams
3. **Latest Wins**: If same question in both sources, latest wins
4. **No Loss**: No data is lost

**Implementation**:
```dart
// core/utils/progress_merger.dart
class ProgressMerger {
  static Map<String, dynamic> merge({
    required Map<String, dynamic> local,
    Map<String, dynamic>? cloud,
  }) {
    // Intelligent merging logic
  }
}
```

---

## Device Limit / حد الأجهزة

<div dir="rtl">

**القاعدة**: Pro users يمكنهم المزامنة على 3 أجهزة فقط

**المنطق**:
1. عند المزامنة، يتم حساب الأجهزة النشطة (آخر 30 يوم)
2. إذا كان هناك 3 أجهزة نشطة، يتم إلغاء تفعيل أقدم جهاز
3. الجهاز الحالي دائماً نشط

</div>

**Rule**: Pro users can sync on 3 devices only

**Logic**:
1. On sync, count active devices (last 30 days)
2. If 3 active devices exist, deactivate oldest device
3. Current device is always active

**Implementation**:
```dart
// In SubscriptionService
static Future<void> _trackDeviceAndEnforceLimit(
  String revenuecatCustomerId,
) async {
  // Count active devices
  // Enforce 3-device limit
}
```

---

## Usage Example / مثال الاستخدام

```dart
// Manual sync trigger
Future<void> syncProgress() async {
  try {
    await SyncService.syncProgressToCloud();
    showSuccessMessage('Progress synced successfully');
  } catch (e) {
    showErrorMessage('Sync failed: $e');
  }
}

// Auto-sync on startup (in main.dart)
Future<void> _syncAndRestoreProgressOnStartup() async {
  final isPro = await SubscriptionService.isProUser();
  if (!isPro) return;
  
  await SyncService.restoreProgressFromCloud();
  await SyncService.syncProgressToCloud();
}
```

---

## Security / الأمان

<div dir="rtl">

- **مصادقة مجهولة**: لا يحتاج email أو password
- **Row Level Security**: Supabase RLS يحمي البيانات
- **مزامنة مشفرة**: جميع الاتصالات مشفرة (HTTPS)
- **التحقق من الملكية**: يتم التحقق من ملكية الاشتراك

</div>

- **Anonymous Auth**: No email or password needed
- **Row Level Security**: Supabase RLS protects data
- **Encrypted Sync**: All connections encrypted (HTTPS)
- **Ownership Verification**: Subscription ownership verified

---

## Related Features / الميزات ذات الصلة

- [Subscriptions](./subscriptions.md)
- [Progress Tracking](./progress-tracking.md)
- [Offline-First](./offline-first.md)

---

## Technical Details / التفاصيل التقنية

### Sync Triggers / محفزات المزامنة

<div dir="rtl">

1. **عند بدء التطبيق**: استعادة ومزامنة تلقائية
2. **بعد إجابة سؤال**: مزامنة تلقائية (خلفية)
3. **بعد إنهاء امتحان**: مزامنة تلقائية
4. **يدوياً**: من إعدادات الملف الشخصي

</div>

1. **On App Start**: Auto restore and sync
2. **After Answering Question**: Auto sync (background)
3. **After Finishing Exam**: Auto sync
4. **Manually**: From profile settings

### Error Handling / معالجة الأخطاء

<div dir="rtl">

- **لا إنترنت**: التطبيق يعمل بشكل طبيعي (offline)
- **خطأ في المزامنة**: لا يتم فقدان البيانات (محفوظة محلياً)
- **Retry Logic**: إعادة المحاولة تلقائياً عند الاتصال

</div>

- **No Internet**: App works normally (offline)
- **Sync Error**: No data loss (saved locally)
- **Retry Logic**: Auto retry when connected

---

## Future Enhancements / التحسينات المستقبلية

<div dir="rtl">

- مزامنة في الوقت الفعلي
- حل النزاعات المتقدم
- نسخ احتياطية تلقائية
- إحصائيات متقدمة

</div>

- Real-time sync
- Advanced conflict resolution
- Automatic backups
- Advanced statistics

