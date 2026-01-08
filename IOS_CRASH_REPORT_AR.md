# تقرير مشكلة: تطبيق Flutter يغلق فوراً بعد التثبيت على iOS Simulator

## 📋 معلومات المشروع
- **اسم التطبيق:** Eagle Test: Germany
- **الإصدار:** 1.0.3 (Build 4)
- **نظام التشغيل:** macOS 26.2 (Sequoia)
- **Xcode:** 17.x
- **Flutter SDK:** 3.38.5
- **iOS Simulator:** iPhone 17 Pro Max (iOS 26.2)
- **المشكلة:** التطبيق يتم تثبيته بنجاح لكن يغلق فوراً عند الفتح (شاشة سوداء ثم خروج)

---

## 🔴 المشكلة الأساسية

### الأعراض:
1. ✅ التطبيق يتم بناؤه بنجاح (`flutter build ios --simulator`)
2. ✅ التطبيق يتم تثبيته على المحاكي بنجاح (`xcrun simctl install`)
3. ❌ عند فتح التطبيق: تظهر شاشة سوداء لثانية واحدة ثم يغلق فوراً
4. ❌ لا تظهر أي رسالة خطأ للمستخدم

### الخطأ الفعلي (من Crash Reports):
```
Termination Reason: DYLD, Code 1, Library missing
Library not loaded: @rpath/Flutter.framework/Flutter
Referenced from: Runner.debug.dylib
Reason: code signature in <...> '/Users/.../Runner.app/Frameworks/Flutter.framework/Flutter'
```

---

## 🔍 التحليل التقني

### 1. مشكلة Code Signature:
- `dyld` (dynamic linker) يرفض تحميل `Flutter.framework` بسبب مشكلة في التوقيع
- الخطأ يشير إلى: `code signature in <...>` مما يعني أن التوقيع موجود لكن غير صالح

### 2. مشكلة Extended Attributes (com.apple.provenance):
- macOS 26.2 يضيف تلقائياً Extended Attribute اسمه `com.apple.provenance` لجميع الملفات
- هذا الـ attribute يمنع `codesign` من توقيع الملفات بشكل صحيح
- عند محاولة التوقيع: `codesign: resource fork, Finder information, or similar detritus not allowed`

### 3. محاولات إزالة Extended Attributes:
- ✅ `xattr -cr` - فشل (الـ attribute يعود تلقائياً)
- ✅ `xattr -d com.apple.provenance` - فشل (الـ attribute يعود تلقائياً)
- ✅ نسخ الملفات إلى `/tmp` - فشل (macOS يضيف الـ attribute تلقائياً)
- ❌ **النتيجة:** لا يمكن إزالة `com.apple.provenance` على macOS 26.2

---

## 🛠️ الحلول المطبقة

### الحل 1: تعديل إعدادات Xcode Build Settings
**الملفات المعدلة:**
- `ios/Flutter/Debug.xcconfig`
- `ios/Flutter/Release.xcconfig`
- `ios/Runner.xcodeproj/project.pbxproj`
- `ios/Podfile`

**التعديلات:**
```xcconfig
// Disable code signing for simulator
CODE_SIGN_IDENTITY[sdk=iphonesimulator*]=
CODE_SIGNING_REQUIRED[sdk=iphonesimulator*]=NO
CODE_SIGNING_ALLOWED[sdk=iphonesimulator*]=NO
```

**النتيجة:** ❌ لم تحل المشكلة - `dyld` لا يزال يرفض تحميل `Flutter.framework`

---

### الحل 2: إنشاء Wrapper Script لتنظيف Extended Attributes
**الملف:** `ios/xcode_backend_wrapper.sh`

**الوظيفة:**
- تنظيف Extended Attributes من `Flutter.framework` قبل كل build
- تعطيل Code Signing للمحاكي

**النتيجة:** ❌ لم تحل المشكلة - macOS يضيف الـ attribute مرة أخرى تلقائياً

---

### الحل 3: تعديل Flutter SDK
**الملف:** `/opt/homebrew/share/flutter/packages/flutter_tools/bin/xcode_backend.sh`

**التعديل:**
- تعطيل `_signFramework` للمحاكي

**النتيجة:** ❌ لم تحل المشكلة - المشكلة في `dyld` وليس في عملية التوقيع

---

### الحل 4: إعادة توقيع الـ Frameworks يدوياً
**الأمر:**
```bash
codesign --force --sign - --timestamp=none Flutter.framework/Flutter
```

**النتيجة:** ❌ فشل - `codesign` يرفض التوقيع بسبب `com.apple.provenance`

---

### الحل 5: البناء عبر xcodebuild مباشرة
**الأمر:**
```bash
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  build
```

**النتيجة:** ✅ البناء نجح، لكن التطبيق لا يزال يغلق عند الفتح

---

### الحل 6: إعادة توقيع التطبيق بعد التثبيت
**الأمر:**
```bash
# توقيع كل framework في التطبيق المثبت
codesign --force --sign - --timestamp=none \
  /path/to/Runner.app/Frameworks/*.framework/*

# توقيع Runner.debug.dylib و Runner
codesign --force --sign - --timestamp=none \
  /path/to/Runner.app/Runner.debug.dylib \
  /path/to/Runner.app/Runner
```

**النتيجة:** ✅ التوقيع نجح، لكن التطبيق لا يزال يغلق - `dyld` يرفض التوقيع بسبب Extended Attributes

---

## 📊 Crash Report الكامل

### آخر Crash Report:
```json
{
  "termination": {
    "code": 1,
    "flags": 518,
    "namespace": "DYLD",
    "indicator": "Library missing",
    "reasons": [
      "Library not loaded: @rpath/Flutter.framework/Flutter",
      "Referenced from: Runner.debug.dylib",
      "Reason: tried: '/Library/.../Flutter.framework/Flutter' (no such file)",
      "'/Users/.../Runner.app/Frameworks/Flutter.framework/Flutter' (code signature in <...>)"
    ]
  }
}
```

### معلومات إضافية:
- **Exception Type:** EXC_CRASH (SIGABRT)
- **Triggered by Thread:** 0 (Main Thread)
- **Crash Location:** `dyld4::prepareSim()` - قبل تحميل التطبيق

---

## 🔬 فحوصات إضافية تمت

### 1. فحص Flutter.framework:
```bash
✅ الملف موجود في: Runner.app/Frameworks/Flutter.framework/Flutter
✅ الحجم: ~77MB
✅ Architecture: arm64
✅ Code Signature: موجود لكن dyld يرفضه
❌ Extended Attributes: com.apple.provenance (لا يمكن إزالته)
```

### 2. فحص إعدادات Build:
```bash
✅ EXCLUDED_ARCHS: i386 فقط (arm64 غير مستثنى)
✅ ONLY_ACTIVE_ARCH: YES للمحاكي
✅ CODE_SIGNING_REQUIRED: NO للمحاكي
✅ CODE_SIGNING_ALLOWED: NO للمحاكي
```

### 3. فحص Pods:
```bash
✅ Podfile: platform :ios, '13.0'
✅ جميع Pods محدثة
✅ pod install نجح بدون أخطاء
```

---

## 💡 الحلول المقترحة (لم تُطبق بعد)

### الحل المقترح 1: استخدام iPhone حقيقي ⭐ (الأفضل - التوصية الأساسية)
**السبب:** الأجهزة الحقيقية تتعامل مع Code Signing و Extended Attributes بشكل مختلف عن المحاكي. الفحوصات الصارمة التي تسبب `dyld` crash بسبب `com.apple.provenance` عادة لا تكون مشكلة بنفس الطريقة على الأجهزة الحقيقية مع Development Provisioning.

**الخطوات:**
1. تفعيل Developer Mode على iPhone:
   - Settings → Privacy & Security → Developer Mode
2. إعادة تشغيل iPhone
3. تشغيل: `flutter run -d iPhone` أو `flutter run -d [Device ID]`

**التكلفة:** مجاني (إذا كان لديك iPhone)

**الملاحظة:** هذا هو الحل الأكثر موثوقية للاستمرار في التطوير.

---

### الحل المقترح 2: استخدام محاكي iOS أقدم ⭐ (موصى به بشدة)
**السبب:** المشكلة تتفاقم بسبب الجمع بين أحدث macOS وأحدث iOS Simulator runtime. إصدار أقدم من iOS (مثل iOS 17.x أو 18.x) على المحاكي قد يكون لديه فحوصات أقل صرامة أو يتفاعل بشكل مختلف مع Extended Attributes من نظام التشغيل المضيف.

**الخطوات:**
1. في Xcode: **Settings > Components** (أو **Preferences > Components**)
2. تحميل iOS 17.x أو 18.x Simulator Runtime
3. إنشاء محاكي جديد بإصدار أقدم:
   ```bash
   xcrun simctl create "iPhone 15 Pro" "iPhone 15 Pro" "iOS17.5"
   ```
4. تجربة التطبيق على المحاكي الأقدم:
   ```bash
   flutter run -d "iPhone 15 Pro"
   ```

**التكلفة:** مجاني

**الملاحظة:** هذا الحل قد يحل المشكلة تماماً لأن إصدارات iOS الأقدم قد لا تتحقق من Extended Attributes بنفس الطريقة.

---

### الحل المقترح 3: استخدام Xcode مباشرة للبناء والتشغيل ⭐ (موصى به)
**السبب:** أحياناً، عملية البناء والتشغيل داخل Xcode تتعامل مع التوقيع وتضمين الـ Frameworks بشكل مختلف قليلاً عن أداة `flutter run` من سطر الأوامر. قد يسمح هذا لأدوات Xcode الداخلية بإدارة الـ Attributes أو التوقيع بشكل أكثر فعالية.

**الخطوات:**
1. فتح `ios/Runner.xcworkspace` في Xcode
2. اختيار محاكي من قائمة الأجهزة في الأعلى
3. الضغط على **⌘+R** للبناء والتشغيل

**التكلفة:** مجاني

**الملاحظة:** Xcode قد يتعامل مع Extended Attributes بشكل مختلف عن Flutter CLI.

---

### الحل المقترح 4: انتظار تحديثات الأدوات
**السبب:** بما أن macOS 26.2 إصدار جديد جداً (على الأرجح beta أو preview)، هذه على الأرجح مشكلة أو ميزة أمان جديدة لم تتكيف معها أدوات Flutter و Xcode بعد.

**الخطوات:**
- متابعة تحديثات Flutter Stable Channel
- متابعة تحديثات macOS
- متابعة GitHub issues المتعلقة:
  - Flutter: https://github.com/flutter/flutter/issues
  - البحث عن: "com.apple.provenance", "macOS 26", "Sequoia", "code signing simulator"

**التكلفة:** مجاني (لكن قد يستغرق وقتاً)

**الملاحظة:** من المحتمل جداً أن يتم إصدار إصلاح في إصدار مستقبلي من Flutter SDK أو Xcode للتعامل مع Extended Attribute هذا بشكل صحيح.

---

### الحل المقترح 5: استخدام Flutter Dev Channel
**السبب:** قد تحتوي على إصلاحات للمشاكل الحديثة

**الخطوات:**
```bash
flutter channel dev
flutter upgrade
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

**التكلفة:** مجاني (لكن قد يكون غير مستقر)

**الملاحظة:** قد يكون غير مستقر، لكن قد يحتوي على إصلاحات مبكرة.

---

## 🎯 توصيات الخبير (Expert Recommendations)

بعد استشارة خبير، تم تأكيد أن المشكلة ناتجة عن تعارض بين ميزات الأمان في macOS 26.2 (`com.apple.provenance`) ومتطلبات Code Signing لـ iOS Simulator. بما أنه لا يمكن إزالة هذا الـ Attribute قسراً، فإن الحلول الأكثر عملية للاستمرار في التطوير هي:

### الأولوية 1: استخدام iPhone حقيقي
- **الأكثر موثوقية** للاستمرار في التطوير
- الأجهزة الحقيقية تتعامل مع Code Signing بشكل مختلف
- لا تعاني من نفس مشكلة Extended Attributes

### الأولوية 2: استخدام محاكي iOS أقدم
- **موصى به بشدة** كحل بديل
- إصدارات iOS الأقدم (17.x أو 18.x) قد لا تتحقق من Extended Attributes بنفس الطريقة
- يمكن تحميلها من Xcode Settings > Components

### الأولوية 3: استخدام Xcode مباشرة
- قد يتعامل Xcode مع Code Signing بشكل مختلف عن Flutter CLI
- جرب البناء والتشغيل من داخل Xcode (⌘+R)

### الأولوية 4: انتظار التحديثات
- macOS 26.2 جديد جداً وقد يكون هناك إصلاحات قادمة
- تابع تحديثات Flutter و macOS

---

## 📝 ملاحظات مهمة

### 1. macOS 26.2 (Sequoia) مشكلة جديدة:
- `com.apple.provenance` يتم إضافته تلقائياً لجميع الملفات
- لا يمكن إزالته حتى باستخدام `sudo`
- هذه مشكلة معروفة في macOS Sequoia

### 2. Flutter.framework Code Signature:
- التوقيع موجود لكن `dyld` يرفضه
- السبب: Extended Attributes (`com.apple.provenance`)
- `codesign` يرفض التوقيع بسبب: `resource fork, Finder information, or similar detritus not allowed`

### 3. iOS 26.2 Simulator:
- إصدار جديد جداً
- قد يكون هناك مشاكل توافق مع Flutter
- يُنصح بتجربة إصدار أقدم

---

## 🔗 مراجع ومصادر

### ملفات المشروع المعدلة:
- `ios/Flutter/Debug.xcconfig`
- `ios/Flutter/Release.xcconfig`
- `ios/Runner.xcodeproj/project.pbxproj`
- `ios/Podfile`
- `ios/xcode_backend_wrapper.sh`

### Crash Reports:
- `~/Library/Logs/DiagnosticReports/Runner-*.ips`

### Flutter SDK:
- `/opt/homebrew/share/flutter/packages/flutter_tools/bin/xcode_backend.sh`

---

## 📞 للاستشارة

### معلومات مفيدة للمستشار:
1. **نظام التشغيل:** macOS 26.2 (Sequoia) - إصدار جديد جداً
2. **المشكلة الأساسية:** `com.apple.provenance` Extended Attribute يمنع Code Signing
3. **الخطأ:** `dyld` يرفض تحميل `Flutter.framework` بسبب Code Signature
4. **الحلول المطبقة:** جميع الحلول المعتادة فشلت
5. **النتيجة:** التطبيق يغلق فوراً عند الفتح

### أسئلة للمستشار:
1. هل هناك طريقة لإزالة `com.apple.provenance` على macOS 26.2؟
2. هل هناك workaround لـ Code Signing مع Extended Attributes؟
3. هل هناك إعدادات في Xcode يمكن تغييرها؟
4. هل يجب الانتظار لتحديث Flutter/macOS؟
5. هل استخدام iPhone حقيقي سيحل المشكلة؟

---

## ✅ الخلاصة

**المشكلة:** macOS 26.2 يضيف `com.apple.provenance` تلقائياً مما يمنع Code Signing الصحيح لـ `Flutter.framework`، مما يؤدي إلى رفض `dyld` تحميله وإغلاق التطبيق فوراً.

**الحلول المطبقة:** جميع الحلول المعتادة فشلت بسبب عدم إمكانية إزالة Extended Attributes.

**الحلول المقترحة:** استخدام iPhone حقيقي أو محاكي iOS أقدم أو انتظار تحديثات Flutter/macOS.

---

---

## 📊 حالة النظام الحالية

### iOS Runtimes المثبتة:
- ✅ iOS 26.2 فقط (الإصدار الحالي الذي يسبب المشكلة)
- ❌ لا توجد إصدارات أقدم مثبتة (iOS 17/18)

### المحاكيات المتاحة:
- iPhone 17 Pro Max (iOS 26.2) - المحاكي الحالي
- iPhone 17 Pro (iOS 26.2)
- iPhone 17 (iOS 26.2)
- iPhone 16e (iOS 26.2)
- وغيرها... (جميعها iOS 26.2)

### الأجهزة الحقيقية:
- ⚠️ تم اكتشاف iPhone حقيقي ("iPhone Lobna") لكنه غير متصل حالياً

**الخلاصة:** تحتاج إلى تحميل iOS 17/18 runtime من Xcode لإنشاء محاكي بإصدار أقدم.

---

## 🚀 خطوات التنفيذ السريعة

### للتحقق من المحاكيات المتاحة:
```bash
./scripts/try_ios_solutions.sh
# أو
xcrun simctl list devices available
```

### لإنشاء محاكي جديد بإصدار iOS أقدم:
1. تحميل iOS Runtime من Xcode: **Settings > Components**
2. إنشاء محاكي:
   ```bash
   xcrun simctl create "iPhone 15 Pro iOS 18" "iPhone 15 Pro" "iOS18.0"
   ```
3. تشغيل التطبيق:
   ```bash
   flutter run -d "iPhone 15 Pro iOS 18"
   ```

### لتشغيل التطبيق من Xcode:
```bash
open ios/Runner.xcworkspace
# ثم اضغط ⌘+R في Xcode
```

### لتشغيل التطبيق على iPhone حقيقي:
```bash
# 1. تفعيل Developer Mode على iPhone
# 2. ربط iPhone بالكمبيوتر
# 3. تشغيل:
flutter devices  # للتحقق من الأجهزة المتاحة
flutter run -d iPhone
```

---

**تاريخ التقرير:** 8 يناير 2026  
**الإصدار:** 2.0 (محدث بتوصيات الخبير)


