# إعداد المصادقة المجهولة في Supabase

## المشكلة

التطبيق يحاول استخدام المصادقة المجهولة (Anonymous Authentication) لكنها **معطلة** في Supabase.

**الخطأ:**
```
AuthApiException: Anonymous sign-ins are disabled
```

## الحل: تفعيل المصادقة المجهولة

### الخطوات:

1. **افتح Supabase Dashboard**
   - اذهب إلى: https://supabase.com/dashboard
   - اختر مشروعك

2. **اذهب إلى Authentication Settings**
   - من القائمة الجانبية: `Authentication` → `Providers`
   - أو: `Authentication` → `Settings`

3. **فعّل Anonymous Sign-In**
   - ابحث عن `Anonymous` في قائمة Providers
   - فعّل المفتاح (Toggle) بجانب `Anonymous`
   - احفظ التغييرات

4. **تحقق من الإعدادات**
   - تأكد أن `Enable anonymous sign-ins` مفعّل
   - تأكد أن `Site URL` صحيح

### بديل: استخدام Email/Password Authentication

إذا كنت تريد استخدام Email/Password بدلاً من Anonymous:

1. فعّل `Email` provider في Supabase
2. غيّر الكود لاستخدام `signUpWithPassword()` بدلاً من `signInAnonymously()`

---

## بعد التفعيل

بعد تفعيل Anonymous Authentication:
1. أعد تشغيل التطبيق
2. يجب أن ترى في Logs: `Anonymous authentication successful`
3. يجب أن ترى: `User profile created successfully`
4. تحقق من Supabase Dashboard → `Authentication` → `Users` → يجب أن ترى مستخدم جديد

---

## التحقق من الحساب في Supabase

1. اذهب إلى: `Authentication` → `Users`
2. ابحث عن مستخدم جديد (User ID يبدأ بـ `anon-` أو `00000000-...`)
3. اذهب إلى: `Table Editor` → `user_profiles`
4. تحقق من وجود سجل جديد مع `user_id` المطابق

---

## ملاحظات

- **Anonymous users** لا يحتاجون email أو password
- كل مستخدم يحصل على `user_id` فريد تلقائياً
- البيانات محفوظة في جدول `user_profiles`

