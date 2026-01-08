# 🔴 عاجل: إنشاء جدول user_profiles في Supabase

## المشكلة المكتشفة

من السجلات:
```
PostgrestException: Could not find the table 'public.user_profiles' in the schema cache
```

**السبب:** جدول `user_profiles` **غير موجود** في Supabase!

**النتيجة:**
- ❌ لا يمكن إنشاء حسابات المستخدمين
- ❌ جميع محاولات حفظ Profile تفشل
- ❌ التطبيق لا يعمل بشكل صحيح

---

## ✅ الحل: إنشاء الجدول في Supabase

### الطريقة 1: استخدام SQL Editor (الأسهل)

1. **افتح Supabase Dashboard**
   - اذهب إلى: https://supabase.com/dashboard
   - اختر مشروعك

2. **افتح SQL Editor**
   - من القائمة الجانبية: `SQL Editor`
   - اضغط `New Query`

3. **انسخ والصق الكود التالي:**

```sql
-- Create the table
CREATE TABLE IF NOT EXISTS public.user_profiles (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT,
    avatar_url TEXT,
    organization_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON public.user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_organization_id ON public.user_profiles(organization_id) WHERE organization_id IS NOT NULL;

-- Enable Row Level Security (RLS)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can read own profile"
    ON public.user_profiles
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
    ON public.user_profiles
    FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
    ON public.user_profiles
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update updated_at on row update
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Create function to automatically create profile when user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (user_id, created_at, updated_at)
    VALUES (NEW.id, NOW(), NOW())
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to automatically create profile when user is created
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Grant permissions
GRANT SELECT, INSERT, UPDATE ON public.user_profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.user_profiles TO anon;
```

4. **اضغط `Run`** (أو `Ctrl+Enter`)

5. **تحقق من النجاح:**
   - يجب أن ترى: `Success. No rows returned`
   - اذهب إلى: `Table Editor` → يجب أن ترى جدول `user_profiles`

---

### الطريقة 2: استخدام Table Editor (GUI)

1. **افتح Table Editor**
   - من القائمة: `Table Editor`
   - اضغط `New Table`

2. **إنشاء الجدول:**
   - **Table name:** `user_profiles`
   - **Schema:** `public`

3. **إضافة الأعمدة:**

| Column Name | Type | Default | Nullable | Primary Key |
|------------|------|---------|----------|-------------|
| `user_id` | `uuid` | - | ❌ No | ✅ Yes |
| `name` | `text` | - | ✅ Yes | ❌ No |
| `avatar_url` | `text` | - | ✅ Yes | ❌ No |
| `organization_id` | `uuid` | - | ✅ Yes | ❌ No |
| `created_at` | `timestamptz` | `now()` | ❌ No | ❌ No |
| `updated_at` | `timestamptz` | `now()` | ❌ No | ❌ No |

4. **إضافة Foreign Key:**
   - اضغط على `user_id` → `Add Foreign Key`
   - **Referenced Table:** `auth.users`
   - **Referenced Column:** `id`
   - **On Delete:** `Cascade`

5. **تفعيل RLS:**
   - اضغط `Enable RLS` في إعدادات الجدول

6. **إضافة Policies:**
   - اذهب إلى `Authentication` → `Policies`
   - أضف Policies كما في الطريقة 1

---

## 🔍 التحقق من الإصلاح

### 1. تحقق من الجدول:
- `Table Editor` → `user_profiles` → يجب أن ترى الجدول

### 2. تحقق من Triggers:
- `Database` → `Triggers` → يجب أن ترى:
  - `on_auth_user_created` (يُنشئ Profile تلقائياً)
  - `set_updated_at` (يحدّث updated_at)

### 3. تحقق من Policies:
- `Authentication` → `Policies` → `user_profiles` → يجب أن ترى 3 policies

### 4. اختبر التطبيق:
- أعد تشغيل التطبيق
- يجب أن ترى في Logs:
  ```
  ✅ User profile created successfully
  ```
- تحقق من `Table Editor` → `user_profiles` → يجب أن ترى سجل جديد

---

## 📋 هيكل الجدول

```sql
user_profiles
├── user_id (UUID, PRIMARY KEY, FK → auth.users.id)
├── name (TEXT, nullable)
├── avatar_url (TEXT, nullable)
├── organization_id (UUID, nullable)
├── created_at (TIMESTAMPTZ, default: NOW())
└── updated_at (TIMESTAMPTZ, default: NOW())
```

---

## ⚠️ ملاحظات مهمة

1. **RLS Policies:** يجب تفعيلها حتى يعمل الجدول بشكل صحيح
2. **Trigger:** `on_auth_user_created` يُنشئ Profile تلقائياً عند إنشاء مستخدم جديد
3. **Permissions:** تم منح الصلاحيات لـ `authenticated` و `anon` (للمصادقة المجهولة)

---

## ✅ بعد الإنشاء

بعد إنشاء الجدول:
1. ✅ التطبيق سيعمل بشكل طبيعي
2. ✅ الحسابات ستُحفظ في Supabase
3. ✅ Profile سيُنشأ تلقائياً عند تسجيل الدخول
4. ✅ المزامنة (Sync) ستعمل

---

**تاريخ:** $(date)  
**الحالة:** 🔴 **عاجل - يجب الإنشاء قبل الإنتاج**

