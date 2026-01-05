# 🔐 دليل إعداد التوقيع لتطبيق Android (Android Signing Setup)

## 📋 نظرة عامة

هذا الدليل يشرح كيفية إعداد التوقيع (Signing) لتطبيق Flutter Android للرفع على Google Play Store.

---

## 🔑 الخطوة 1: إنشاء ملف upload-keystore.jks

### ⚠️ ملاحظة مهمة: Java Runtime

إذا ظهرت رسالة خطأ "Unable to locate a Java Runtime"، لا تقلق! السكريبت محدث تلقائياً لاستخدام Java من Android Studio.

### الطريقة 1: استخدام السكريبت الجاهز (موصى به)

السكريبت محدث تلقائياً لاستخدام Java من Android Studio:

```bash
cd /Users/obadadallo/Documents/politik_test/android
./create_keystore.sh
```

### الطريقة 2: استخدام الأمر مباشرة

إذا كنت تفضل استخدام الأمر مباشرة، استخدم المسار الكامل لـ keytool من Android Studio:

```bash
cd /Users/obadadallo/Documents/politik_test/android
/Applications/Android\ Studio.app/Contents/jbr/Contents/Home/bin/keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### الطريقة 3: استخدام Java من Android Studio (بدون مسار كامل)

يمكنك أيضاً تعيين JAVA_HOME مؤقتاً:

```bash
cd /Users/obadadallo/Documents/politik_test/android
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 📝 معلومات ستحتاج لإدخالها:

عند تنفيذ الأمر، سيطلب منك إدخال المعلومات التالية:

1. **كلمة مرور المستودع (Keystore password)**: 
   - أدخل كلمة مرور قوية (مثال: `YOUR_STRONG_PASSWORD`)
   - **⚠️ احفظ هذه الكلمة في مكان آمن!**

2. **إعادة إدخال كلمة المرور**: 
   - أعد إدخال نفس كلمة المرور

3. **الاسم الأول والأخير**: 
   - أدخل اسمك (مثال: `Your Name`)

4. **اسم الوحدة التنظيمية**: 
   - يمكنك تركها فارغة أو إدخال اسم شركتك

5. **اسم المنظمة**: 
   - اسم شركتك أو منظمتك (مثال: `Eagle Test`)

6. **اسم المدينة أو المنطقة**: 
   - اسم مدينتك

7. **اسم الولاية أو المقاطعة**: 
   - اسم ولايتك أو مقاطعتك

8. **رمز البلد بخطين**: 
   - رمز البلد (مثال: `DE` لألمانيا، `US` للولايات المتحدة، `SY` لسوريا)

9. **التأكيد**: 
   - اكتب `yes` للتأكيد

10. **كلمة مرور المفتاح (Key password)**: 
    - استخدم نفس كلمة مرور المستودع أو اضغط Enter لاستخدام نفس الكلمة

### ⚠️ تحذير مهم:

- **احفظ ملف `upload-keystore.jks` في مكان آمن** - لا تفقده أبداً!
- **احفظ كلمة المرور في مكان آمن** - ستحتاجها في كل مرة تريد بناء نسخة Release
- **لا ترفع ملف `upload-keystore.jks` إلى Git** - أضفه إلى `.gitignore` (موجود بالفعل ✅)

---

## 📄 الخطوة 2: تحديث ملف key.properties

الملف موجود بالفعل في: `android/key.properties`

### المحتوى المطلوب:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

**⚠️ مهم**: استبدل `YOUR_KEYSTORE_PASSWORD` و `YOUR_KEY_PASSWORD` بكلمات المرور الفعلية التي استخدمتها عند إنشاء keystore.

### 📝 شرح الحقول:

- **storePassword**: كلمة مرور المستودع (Keystore password) التي أدخلتها عند إنشاء الملف
- **keyPassword**: كلمة مرور المفتاح (Key password) - عادة نفس كلمة مرور المستودع
- **keyAlias**: اسم المفتاح (Alias) - استخدم `upload` كما هو
- **storeFile**: اسم ملف المستودع - يجب أن يكون `upload-keystore.jks`

### ⚠️ تحذير أمني:

- **لا ترفع ملف `key.properties` إلى Git** - أضفه إلى `.gitignore` (موجود بالفعل ✅)
- احفظ نسخة احتياطية من الملف في مكان آمن

---

## 🔧 الخطوة 3: التحقق من build.gradle.kts

الملف `android/app/build.gradle.kts` محدث بالفعل ويحتوي على:

```kotlin
// Load keystore properties from android/key.properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ...
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as? String
            keyPassword = keystoreProperties["keyPassword"] as? String
            keystoreProperties["storeFile"]?.let { storeFileValue ->
                // المسار النسبي من android/app/ إلى android/upload-keystore.jks
                storeFile = file("../$storeFileValue")
            }
            storePassword = keystoreProperties["storePassword"] as? String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // ...
        }
    }
}
```

✅ **الملف محدث وجاهز للاستخدام!**

---

## 🚀 الخطوة 4: بناء ملف App Bundle

بعد إكمال الخطوات السابقة، يمكنك بناء ملف App Bundle الموقع:

```bash
cd /Users/obadadallo/Documents/politik_test
flutter build appbundle
```

الملف الناتج سيكون في:
```
build/app/outputs/bundle/release/app-release.aab
```

هذا الملف جاهز للرفع على Google Play Console.

---

## ✅ التحقق من التوقيع

للتحقق من أن الملف موقع بشكل صحيح:

```bash
cd /Users/obadadallo/Documents/politik_test
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

إذا كان التوقيع صحيحاً، سترى:
```
jar verified.
```

---

## 📝 ملاحظات إضافية

### 1. إضافة إلى .gitignore

الملفات التالية موجودة بالفعل في `.gitignore`:
- `*.jks`
- `**/key.properties`
- `upload-keystore.jks`

### 2. نسخ احتياطية

احفظ نسخة احتياطية من:
- ملف `upload-keystore.jks`
- ملف `key.properties`
- كلمات المرور في مكان آمن

### 3. صحة المفتاح

صلاحية المفتاح 10000 يوم (حوالي 27 سنة) - كافية للاستخدام طويل الأمد.

---

## 🆘 استكشاف الأخطاء

### خطأ: "Keystore file not found"
**الحل:**
- تأكد من أن ملف `upload-keystore.jks` موجود في مجلد `android/`
- تحقق من المسار في `key.properties` - يجب أن يكون `upload-keystore.jks` فقط (بدون مسار)

### خطأ: "Password incorrect"
**الحل:**
- تحقق من كلمات المرور في `key.properties`
- تأكد من تطابق كلمات المرور مع ما أدخلته عند إنشاء الملف
- تأكد من عدم وجود مسافات إضافية في بداية أو نهاية القيم

### خطأ: "Alias not found"
**الحل:**
- تأكد من أن `keyAlias` في `key.properties` يطابق الاسم الذي استخدمته عند إنشاء الملف (يجب أن يكون `upload`)

### خطأ: "Signing config not found"
**الحل:**
- تأكد من أن `signingConfig = signingConfigs.getByName("release")` موجود في `buildTypes { release { ... } }`

---

## 📋 ملخص الأوامر السريعة

```bash
# 1. الانتقال إلى مجلد android
cd /Users/obadadallo/Documents/politik_test/android

# 2. إنشاء ملف التوقيع
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 3. العودة إلى مجلد المشروع
cd ..

# 4. بناء ملف App Bundle
flutter build appbundle

# 5. التحقق من التوقيع (اختياري)
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

---

## ✅ قائمة التحقق النهائية

- [ ] ملف `upload-keystore.jks` موجود في `android/`
- [ ] ملف `key.properties` محدث بالبيانات الصحيحة
- [ ] ملف `build.gradle.kts` يحتوي على `signingConfigs` و `signingConfig`
- [ ] تم إضافة الملفات إلى `.gitignore`
- [ ] تم حفظ نسخة احتياطية من الملفات وكلمات المرور
- [ ] تم بناء ملف App Bundle بنجاح باستخدام `flutter build appbundle`
- [ ] تم التحقق من التوقيع بنجاح

---

**🎉 بعد إكمال جميع الخطوات، ستكون جاهزاً لرفع التطبيق على Google Play Store!**
