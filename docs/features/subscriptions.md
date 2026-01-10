# 💳 Subscriptions Feature / ميزة الاشتراكات

## Overview / نظرة عامة

<div dir="rtl">

**الاشتراكات** تدير اشتراكات Pro عبر RevenueCat. توفر ميزات متقدمة مثل Cloud Sync، AI Tutor المتقدم، وإزالة الإعلانات.

</div>

**Subscriptions** manages Pro subscriptions via RevenueCat. Provides advanced features like Cloud Sync, advanced AI Tutor, and ad removal.

---

## Location / الموقع

**File**: `lib/core/services/subscription_service.dart`

---

## Features / الميزات

### 1. Subscription Types / أنواع الاشتراكات

<div dir="rtl">

- **Monthly**: اشتراك شهري
- **Yearly**: اشتراك سنوي (أفضل قيمة)
- **Lifetime**: اشتراك مدى الحياة

</div>

- **Monthly**: Monthly subscription
- **Yearly**: Yearly subscription (best value)
- **Lifetime**: Lifetime subscription

### 2. Pro Features / ميزات Pro

<div dir="rtl">

- ✅ **Cloud Sync**: مزامنة عبر الأجهزة (حتى 3 أجهزة)
- ✅ **AI Tutor**: شرح ذكي غير محدود
- ✅ **Advanced Statistics**: إحصائيات متقدمة
- ✅ **No Ads**: بدون إعلانات
- ✅ **Priority Support**: دعم ذو أولوية

</div>

- ✅ **Cloud Sync**: Sync across devices (up to 3 devices)
- ✅ **AI Tutor**: Unlimited intelligent explanations
- ✅ **Advanced Statistics**: Advanced statistics
- ✅ **No Ads**: No advertisements
- ✅ **Priority Support**: Priority support

### 3. Cross-Device Restore / استرداد عبر الأجهزة

<div dir="rtl">

- **Apple ID / Google Account**: استرداد تلقائي عبر Apple/Google
- **Supabase Backup**: نسخة احتياطية في Supabase
- **RevenueCat Customer ID**: ربط عبر الأجهزة

</div>

- **Apple ID / Google Account**: Auto restore via Apple/Google
- **Supabase Backup**: Backup in Supabase
- **RevenueCat Customer ID**: Cross-device linking

---

## Implementation / التنفيذ

### RevenueCat Integration / تكامل RevenueCat

<div dir="rtl">

**التهيئة**:
```dart
await Purchases.configure(
  PurchasesConfiguration(apiKey)
    ..appUserID = supabaseUserId, // Link to Supabase
);
```

**Entitlement ID**: `Eagle Test Pro`

</div>

**Initialization**:
```dart
await Purchases.configure(
  PurchasesConfiguration(apiKey)
    ..appUserID = supabaseUserId, // Link to Supabase
);
```

**Entitlement ID**: `Eagle Test Pro`

### Subscription Check / التحقق من الاشتراك

<div dir="rtl">

**مصدران**:
1. **RevenueCat**: للاشتراكات المدفوعة
2. **Supabase**: للاشتراكات التجريبية

**الأولوية**: Supabase (للاشتراكات التجريبية) ثم RevenueCat

</div>

**Two Sources**:
1. **RevenueCat**: For paid subscriptions
2. **Supabase**: For trial subscriptions

**Priority**: Supabase (for trials) then RevenueCat

---

## Data Flow / تدفق البيانات

### Purchase Flow / تدفق الشراء

```
User taps "Subscribe"
    ↓
PaywallScreen displays offerings
    ↓
User selects package (Monthly/Yearly/Lifetime)
    ↓
SubscriptionService.purchasePackage()
    ↓
RevenueCat processes payment
    ↓
Verify entitlement is active
    ↓
Sync to Supabase
    ↓
Save RevenueCat Customer ID
    ↓
Track device (enforce 3-device limit)
    ↓
Activate Pro features
```

### Restore Flow / تدفق الاسترداد

```
User taps "Restore Purchases"
    ↓
SubscriptionService.restorePurchases()
    ↓
Check Supabase first (same device)
    ↓
If not found, restore from RevenueCat
    ↓
Verify Apple/Google Account ownership
    ↓
Verify subscription ownership
    ↓
Sync to Supabase
    ↓
Activate Pro features
```

---

## Key Components / المكونات الرئيسية

### Services / الخدمات

- `SubscriptionService`: Main subscription service
- `SyncService`: Cloud sync (Pro only)
- `AuthService`: Authentication

### Screens / الشاشات

- `PaywallScreen`: Subscription purchase screen
- `RevenueCatPaywallScreen`: RevenueCat paywall
- `ProfileDashboardScreen`: Subscription management

---

## Usage Example / مثال الاستخدام

```dart
// Check Pro status
final isPro = await SubscriptionService.isProUser();

if (isPro) {
  // Show Pro features
  enableCloudSync();
  enableAdvancedAI();
} else {
  // Show paywall
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => PaywallScreen()),
  );
}

// Purchase subscription
final package = offerings.current?.availablePackages.first;
if (package != null) {
  final result = await SubscriptionService.purchasePackage(package);
  if (result != null) {
    // Purchase successful
    showSuccessMessage('Pro activated!');
  }
}
```

---

## Device Limit / حد الأجهزة

<div dir="rtl">

**القاعدة**: Pro users يمكنهم المزامنة على 3 أجهزة فقط

**المنطق**:
1. عند الشراء أو الاسترداد، يتم تتبع الجهاز
2. إذا كان هناك 3 أجهزة نشطة، يتم إلغاء تفعيل أقدم جهاز
3. الجهاز الحالي دائماً نشط

</div>

**Rule**: Pro users can sync on 3 devices only

**Logic**:
1. On purchase or restore, device is tracked
2. If 3 active devices exist, oldest device is deactivated
3. Current device is always active

---

## Security / الأمان

<div dir="rtl">

- **التحقق من الملكية**: يتم التحقق من أن الاشتراك ينتمي للمستخدم
- **Apple/Google Verification**: RevenueCat يتحقق تلقائياً
- **Supabase Backup**: نسخة احتياطية في Supabase

</div>

- **Ownership Verification**: Verify subscription belongs to user
- **Apple/Google Verification**: RevenueCat auto-verifies
- **Supabase Backup**: Backup in Supabase

---

## Related Features / الميزات ذات الصلة

- [Cloud Sync](./cloud-sync.md)
- [AI Tutor](./ai-tutor.md)
- [Progress Tracking](./progress-tracking.md)

---

## Technical Details / التفاصيل التقنية

### API Keys / مفاتيح API

<div dir="rtl">

**الموقع**: `lib/core/services/subscription_service.dart`

**Test Key**: للبيئة التطويرية
**Production Key**: للإنتاج (null = تعطيل RevenueCat)

</div>

**Location**: `lib/core/services/subscription_service.dart`

**Test Key**: For development
**Production Key**: For production (null = disable RevenueCat)

### Error Handling / معالجة الأخطاء

<div dir="rtl">

- **Purchase Cancelled**: المستخدم ألغى الشراء
- **Network Error**: خطأ في الشبكة
- **Invalid API Key**: مفتاح API غير صحيح
- **Test Store Error**: في وضع التطوير

</div>

- **Purchase Cancelled**: User cancelled purchase
- **Network Error**: Network error
- **Invalid API Key**: Invalid API key
- **Test Store Error**: In development mode

---

## Future Enhancements / التحسينات المستقبلية

<div dir="rtl">

- اشتراكات تجريبية مجانية
- عروض خاصة
- اشتراكات عائلية
- إحصائيات الاشتراكات

</div>

- Free trial subscriptions
- Special offers
- Family subscriptions
- Subscription statistics

