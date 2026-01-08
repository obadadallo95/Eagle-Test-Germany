# 🔴 إصلاح عاجل: تفعيل المصادقة المجهولة في Supabase

## المشكلة المكتشفة

من السجلات (Logs):
```
AuthApiException: Anonymous sign-ins are disabled (statusCode: 422)
```

**السبب الجذري:** المصادقة المجهولة (Anonymous Authentication) **معطلة** في Supabase Dashboard.

**النتيجة:** 
- ❌ لا يتم إنشاء حساب في Supabase
- ❌ `AuthService.signInSilently()` يفشل
- ❌ `SyncService.createUserProfile()` لا يعمل (لأنه لا يوجد `user_id`)
- ❌ التطبيق يعمل في وضع Offline فقط

---

## ✅ الحل الفوري (5 دقائق)

### الخطوة 1: فتح Supabase Dashboard
1. اذهب إلى: https://supabase.com/dashboard
2. اختر مشروعك (Project)

### الخطوة 2: تفعيل Anonymous Authentication
1. من القائمة الجانبية: `Authentication`
2. اختر: `Providers` (أو `Settings`)
3. ابحث عن: `Anonymous`
4. **فعّل** المفتاح (Toggle) بجانب `Anonymous`
5. **احفظ** التغييرات

### الخطوة 3: التحقق
1. أعد تشغيل التطبيق
2. تحقق من Logs - يجب أن ترى:
   ```
   ✅ Anonymous authentication successful
   ✅ User profile created successfully
   ```
3. تحقق من Supabase:
   - `Authentication` → `Users` → يجب أن ترى مستخدم جديد
   - `Table Editor` → `user_profiles` → يجب أن ترى سجل جديد

---

## 📸 دليل مرئي (Screenshots Guide)

### في Supabase Dashboard:

**المسار:**
```
Dashboard → Your Project → Authentication → Providers → Anonymous
```

**ما يجب أن تراه:**
- ✅ Toggle مفعّل (ON) بجانب `Anonymous`
- ✅ `Enable anonymous sign-ins` مفعّل

---

## 🔍 التحقق من الإصلاح

### 1. تحقق من Logs في التطبيق:
```
✅ [APPLOG] INFO | AuthService
   Anonymous authentication successful
   Auth User ID: [user-id-here]

✅ [APPLOG] INFO | SyncService
   User profile created successfully
```

### 2. تحقق من Supabase Dashboard:
- **Authentication → Users:**
  - يجب أن ترى مستخدم جديد
  - User ID يبدأ بـ `anon-` أو `00000000-...`

- **Table Editor → user_profiles:**
  - يجب أن ترى سجل جديد
  - `user_id` يطابق User ID من Authentication

---

## ⚠️ إذا استمرت المشكلة

### تحقق من:
1. **Site URL صحيح:**
   - `Authentication` → `URL Configuration`
   - تأكد أن `Site URL` صحيح

2. **RLS Policies:**
   - `Table Editor` → `user_profiles` → `Policies`
   - تأكد أن هناك Policy تسمح بـ INSERT للمستخدمين الجدد

3. **Database Trigger:**
   - `Database` → `Triggers`
   - تأكد أن Trigger لإنشاء `user_profiles` مفعّل

---

## 📝 ملاحظات

- **Anonymous Authentication** لا يحتاج email أو password
- كل مستخدم يحصل على `user_id` فريد تلقائياً
- البيانات محفوظة في جدول `user_profiles` في Supabase
- التطبيق يعمل Offline حتى بدون Supabase، لكن الحسابات لا تُحفظ

---

## ✅ بعد التفعيل

بعد تفعيل Anonymous Authentication:
1. ✅ التطبيق سيعمل بشكل طبيعي
2. ✅ الحسابات ستُحفظ في Supabase
3. ✅ المزامنة (Sync) ستعمل
4. ✅ Leaderboard سيعمل

---

**تاريخ:** $(date)  
**الحالة:** 🔴 **عاجل - يجب التفعيل قبل الإنتاج**

