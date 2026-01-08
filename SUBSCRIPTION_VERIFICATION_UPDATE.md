# تحديث نظام التحقق من الاشتراك

## ما تم تغييره

بعد إنشاء جدول `user_profiles` في Supabase، تم تحديث نظام التحقق من الاشتراك لدعم:

1. ✅ **التحقق من Supabase** - للاشتراكات التجريبية والاشتراكات المحفوظة في Supabase
2. ✅ **التحقق من RevenueCat** - للاشتراكات المدفوعة
3. ✅ **دعم الاشتراك التجريبي** - من خلال حقل `trial_ends_at` في Supabase

---

## التغييرات في الكود

### 1. تحديث `subscription_service.dart`

**قبل:**
- التحقق من RevenueCat فقط
- إذا لم يكن RevenueCat مفعّل → يعتبر المستخدم Pro (للاختبار)

**بعد:**
- التحقق من Supabase أولاً (يدعم التجريبي)
- ثم التحقق من RevenueCat
- مزامنة حالة الاشتراك إلى Supabase تلقائياً

### 2. إضافة حقول جديدة في `user_profiles`

تم إضافة الحقول التالية:
- `is_pro` (BOOLEAN) - هل المستخدم لديه اشتراك Pro نشط
- `subscription_type` (TEXT) - نوع الاشتراك: 'monthly', 'yearly', 'lifetime', 'trial', 'revenuecat'
- `subscription_expires_at` (TIMESTAMPTZ) - تاريخ انتهاء الاشتراك
- `trial_ends_at` (TIMESTAMPTZ) - تاريخ انتهاء التجريبي

---

## كيفية استخدام الاشتراك التجريبي

### 1. إنشاء اشتراك تجريبي في Supabase

```sql
-- مثال: إعطاء مستخدم اشتراك تجريبي لمدة 7 أيام
UPDATE public.user_profiles
SET 
  is_pro = TRUE,
  subscription_type = 'trial',
  trial_ends_at = NOW() + INTERVAL '7 days',
  updated_at = NOW()
WHERE user_id = 'USER_ID_HERE';
```

### 2. التحقق من الاشتراك في الكود

الكود الآن يتحقق تلقائياً من:
1. **Supabase أولاً:**
   - إذا كان `is_pro = TRUE` و `trial_ends_at` في المستقبل → يعتبر Pro
   - إذا كان `is_pro = TRUE` و `subscription_expires_at` في المستقبل → يعتبر Pro
   - إذا كان `subscription_type = 'lifetime'` → يعتبر Pro دائماً

2. **RevenueCat ثانياً:**
   - إذا كان RevenueCat مفعّل → يتحقق من Entitlements
   - إذا كان Pro في RevenueCat → يحدث Supabase تلقائياً

---

## Migration SQL

تم إنشاء ملف migration جديد:
- `supabase_migrations/add_subscription_fields.sql`

**للتطبيق:**
1. افتح Supabase Dashboard → `SQL Editor`
2. انسخ الكود من `add_subscription_fields.sql`
3. الصقه في SQL Editor
4. اضغط `Run`

---

## أمثلة الاستخدام

### إعطاء اشتراك تجريبي لمستخدم

```sql
UPDATE public.user_profiles
SET 
  is_pro = TRUE,
  subscription_type = 'trial',
  trial_ends_at = NOW() + INTERVAL '7 days'
WHERE user_id = 'USER_ID';
```

### إعطاء اشتراك شهري

```sql
UPDATE public.user_profiles
SET 
  is_pro = TRUE,
  subscription_type = 'monthly',
  subscription_expires_at = NOW() + INTERVAL '1 month'
WHERE user_id = 'USER_ID';
```

### إعطاء اشتراك مدى الحياة

```sql
UPDATE public.user_profiles
SET 
  is_pro = TRUE,
  subscription_type = 'lifetime',
  subscription_expires_at = NULL
WHERE user_id = 'USER_ID';
```

---

## ملاحظات مهمة

1. **الأولوية:** Supabase أولاً، ثم RevenueCat
2. **المزامنة:** عند شراء اشتراك من RevenueCat، يتم تحديث Supabase تلقائياً
3. **التجريبي:** يتم التحقق من `trial_ends_at` تلقائياً
4. **الانتهاء:** عند انتهاء الاشتراك، يتم تحديث `is_pro = FALSE` تلقائياً

---

## التحقق من العمل

بعد تطبيق Migration:

1. **تحقق من الجدول:**
   ```sql
   SELECT user_id, is_pro, subscription_type, trial_ends_at, subscription_expires_at
   FROM public.user_profiles;
   ```

2. **اختبر في التطبيق:**
   - أعد تشغيل التطبيق
   - تحقق من Logs - يجب أن ترى: `Subscription status from Supabase: true/false`

3. **اختبر التجريبي:**
   - أنشئ اشتراك تجريبي في Supabase
   - تحقق من أن التطبيق يعتبر المستخدم Pro

---

**تاريخ:** $(date)  
**الحالة:** ✅ جاهز للاستخدام

