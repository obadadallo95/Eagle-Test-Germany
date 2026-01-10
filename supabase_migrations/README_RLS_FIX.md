# إصلاح مشكلة Row Level Security (RLS) في جدول user_progress

## المشكلة
```
PostgrestException(message: new row violates row-level security policy for table "user_progress", code: 42501, details: Forbidden, hint: null)
```

هذا الخطأ يحدث لأن جدول `user_progress` لا يحتوي على سياسات RLS تسمح للمستخدمين بإدراج/تحديث بياناتهم.

## الحل

### الخطوة 1: تطبيق Migration في Supabase

1. افتح Supabase Dashboard
2. اذهب إلى **SQL Editor**
3. انسخ محتوى الملف `add_rls_policies_to_user_progress.sql`
4. الصق الكود في SQL Editor
5. اضغط **Run** لتنفيذ الكود

### الخطوة 2: التحقق من النجاح

بعد تطبيق Migration، يجب أن ترى:
- ✅ 4 سياسات RLS جديدة:
  - `Users can read own progress`
  - `Users can update own progress`
  - `Users can insert own progress`
  - `Users can read shared progress`

### الخطوة 3: التحقق من RLS مفعل

في Supabase Dashboard:
1. اذهب إلى **Table Editor** → `user_progress`
2. افتح **Settings** (⚙️)
3. تأكد من أن **Enable Row Level Security** مفعل ✅

## ما الذي يفعله هذا الإصلاح؟

### السياسات المضافة:

1. **Users can read own progress**: يسمح للمستخدمين بقراءة بياناتهم الخاصة
2. **Users can update own progress**: يسمح للمستخدمين بتحديث بياناتهم الخاصة
3. **Users can insert own progress**: يسمح للمستخدمين بإدراج بيانات جديدة
4. **Users can read shared progress**: يسمح للمستخدمين Pro بقراءة بيانات الأجهزة الأخرى التي تشترك في نفس `revenuecat_customer_id`

### الأمان:

- جميع السياسات تستخدم `auth.uid() = user_id` للتحقق من أن المستخدم يعدل بياناته فقط
- لا يمكن للمستخدمين تعديل بيانات المستخدمين الآخرين
- Pro users يمكنهم قراءة (وليس تعديل) بيانات الأجهزة الأخرى المشتركة

## ملاحظات مهمة:

⚠️ **يجب تطبيق هذا Migration قبل استخدام ميزة Cloud Sync**
⚠️ **تأكد من أن المستخدمين مسجلين دخول بشكل صحيح (Anonymous Auth مفعل)**

## إذا استمرت المشكلة:

1. تحقق من أن Anonymous Authentication مفعل في Supabase:
   - Authentication → Providers → Anonymous → Enable

2. تحقق من أن المستخدم مسجل دخول:
   - في الكود، تأكد من أن `supabase.auth.currentSession` ليس `null`

3. تحقق من أن `user_id` في `syncData` يطابق `auth.uid()`:
   - يجب أن يكون `syncData['user_id'] == session.user.id`

