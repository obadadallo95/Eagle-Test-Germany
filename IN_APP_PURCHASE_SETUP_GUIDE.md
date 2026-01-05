# دليل تفعيل الشراء داخل التطبيق (In-App Purchase)
## خطوة بخطوة لإعداد RevenueCat و Google Play / App Store

---

## 📋 نظرة عامة

التطبيق يستخدم **RevenueCat** لإدارة الاشتراكات. RevenueCat يوفر طبقة موحدة للتعامل مع Google Play Billing و App Store.

---

## 🚀 الخطوات الأساسية

### 1️⃣ إنشاء حساب RevenueCat

1. اذهب إلى [https://www.revenuecat.com](https://www.revenuecat.com)
2. سجل حساب جديد (مجاني)
3. أنشئ مشروع جديد (Project)
4. أضف تطبيقك:
   - **Android**: أدخل Package Name من `android/app/build.gradle`
   - **iOS**: أدخل Bundle ID من `ios/Runner.xcodeproj`

---

## 📱 إعداد Android (Google Play)

### الخطوة 1: إعداد Google Play Console

1. اذهب إلى [Google Play Console](https://play.google.com/console)
2. افتح تطبيقك
3. اذهب إلى **Monetization** → **Products** → **Subscriptions**
4. أنشئ 3 اشتراكات:
   - **Monthly**: 4.99€ (شهري)
   - **3 Months**: 9.99€ (كل 3 أشهر)
   - **Lifetime**: 19.99€ (مدى الحياة - One-time purchase)

### الخطوة 2: إنشاء Product IDs

لكل اشتراك، أنشئ Product ID:
- `monthly_subscription`
- `three_months_subscription`
- `lifetime_purchase`

### الخطوة 3: ربط RevenueCat مع Google Play

1. في RevenueCat Dashboard:
   - اذهب إلى **Integrations**
   - اختر **Google Play**
   - أدخل Service Account JSON (من Google Cloud Console)
   - انقر **Save**

2. احصل على **Android API Key** من RevenueCat:
   - اذهب إلى **API Keys**
   - انسخ **Public SDK Key** (يبدأ بـ `goog_`)

---

## 🍎 إعداد iOS (App Store)

### الخطوة 1: إعداد App Store Connect

1. اذهب إلى [App Store Connect](https://appstoreconnect.apple.com)
2. افتح تطبيقك
3. اذهب إلى **Features** → **In-App Purchases**
4. أنشئ 3 اشتراكات:
   - **Monthly**: 4.99€
   - **3 Months**: 9.99€
   - **Lifetime**: 19.99€ (Non-Consumable)

### الخطوة 2: إنشاء Product IDs

استخدم نفس Product IDs:
- `monthly_subscription`
- `three_months_subscription`
- `lifetime_purchase`

### الخطوة 3: ربط RevenueCat مع App Store

1. في RevenueCat Dashboard:
   - اذهب إلى **Integrations**
   - اختر **App Store**
   - أدخل Shared Secret (من App Store Connect)
   - انقر **Save**

2. احصل على **iOS API Key** من RevenueCat:
   - اذهب إلى **API Keys**
   - انسخ **Public SDK Key** (يبدأ بـ `appl_`)

---

## 🔧 تحديث الكود

### الخطوة 1: تحديث API Keys

افتح `lib/core/services/subscription_service.dart`:

```dart
// استبدل هذه القيم بـ API Keys الخاصة بك من RevenueCat
static const String _androidApiKey = 'goog_YOUR_ANDROID_KEY_HERE';
static const String _iosApiKey = 'appl_YOUR_IOS_KEY_HERE';
```

### الخطوة 2: إنشاء Entitlement في RevenueCat

1. في RevenueCat Dashboard:
   - اذهب إلى **Entitlements**
   - أنشئ Entitlement جديد باسم `pro_access`
   - ربطه بجميع الاشتراكات الثلاثة

### الخطوة 3: إنشاء Offering

1. في RevenueCat Dashboard:
   - اذهب إلى **Offerings**
   - أنشئ Offering جديد باسم `default`
   - أضف جميع الاشتراكات الثلاثة كـ Packages

---

## 🧪 اختبار الشراء

### Android (Google Play)

1. **استخدام Test Accounts**:
   - في Google Play Console: **Settings** → **License Testing**
   - أضف حساب Gmail الخاص بك كـ Test Account
   - استخدم هذا الحساب على جهاز Android للاختبار

2. **استخدام Test Products**:
   - في Google Play Console: أنشئ نسخة Test من كل Product
   - استخدم Product IDs التي تنتهي بـ `.test`

### iOS (App Store)

1. **استخدام Sandbox Tester**:
   - في App Store Connect: **Users and Access** → **Sandbox Testers**
   - أنشئ حساب Test جديد
   - استخدم هذا الحساب على جهاز iOS للاختبار

---

## 📝 ملاحظات مهمة

### ⚠️ قبل النشر

1. **تأكد من**:
   - ✅ جميع Product IDs متطابقة بين Google Play و App Store
   - ✅ Entitlement `pro_access` مربوط بجميع الاشتراكات
   - ✅ Offering `default` يحتوي على جميع Packages
   - ✅ API Keys محدثة في الكود

2. **اختبار شامل**:
   - ✅ شراء اشتراك شهري
   - ✅ شراء اشتراك 3 أشهر
   - ✅ شراء Lifetime
   - ✅ استعادة المشتريات (Restore Purchases)
   - ✅ إلغاء الاشتراك

### 🔒 الأمان

- **لا تضع API Keys في Git**:
  - استخدم environment variables
  - أو استخدم `flutter_dotenv` مع ملف `.env` في `.gitignore`

### 💰 الأسعار

الأسعار الحالية:
- **Monthly**: 4.99€
- **3 Months**: 9.99€ (Best Value)
- **Lifetime**: 19.99€

يمكنك تغييرها من Google Play Console / App Store Connect.

---

## 🐛 حل المشاكل الشائعة

### المشكلة: "No current offering available"

**الحل**:
1. تأكد من إنشاء Offering في RevenueCat
2. تأكد من ربط Packages بالـ Offering
3. تأكد من أن Offering اسمه `default`

### المشكلة: "Purchase failed"

**الحل**:
1. تأكد من استخدام Test Account على Android
2. تأكد من استخدام Sandbox Tester على iOS
3. تحقق من Logs في RevenueCat Dashboard

### المشكلة: "Entitlement not active"

**الحل**:
1. تأكد من ربط Entitlement `pro_access` بجميع الاشتراكات
2. تأكد من أن الاشتراك نشط في Google Play / App Store

---

## 📚 موارد إضافية

- [RevenueCat Documentation](https://docs.revenuecat.com)
- [Google Play Billing](https://developer.android.com/google/play/billing)
- [App Store In-App Purchase](https://developer.apple.com/in-app-purchase/)

---

## ✅ قائمة التحقق النهائية

- [ ] حساب RevenueCat تم إنشاؤه
- [ ] التطبيق أضيف إلى RevenueCat (Android + iOS)
- [ ] الاشتراكات الثلاثة أنشئت في Google Play Console
- [ ] الاشتراكات الثلاثة أنشئت في App Store Connect
- [ ] Entitlement `pro_access` أنشئ وربط بالاشتراكات
- [ ] Offering `default` أنشئ وأضيف Packages
- [ ] API Keys محدثة في `subscription_service.dart`
- [ ] تم اختبار الشراء على Android (Test Account)
- [ ] تم اختبار الشراء على iOS (Sandbox Tester)
- [ ] تم اختبار استعادة المشتريات
- [ ] تم اختبار إلغاء الاشتراك

---

**ملاحظة**: هذا الدليل يغطي الأساسيات. للحصول على تفاصيل أكثر، راجع وثائق RevenueCat الرسمية.

