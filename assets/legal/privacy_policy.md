# Datenschutzerklärung / سياسة الخصوصية

## 1. Datenspeicherung / تخزين البيانات

**Deutsch:**  
Diese App speichert alle Daten ausschließlich lokal auf Ihrem Gerät. Es werden keine Daten an externe Server gesendet oder übertragen.

**العربية:**  
يخزن هذا التطبيق جميع البيانات محلياً على جهازك فقط. لا يتم إرسال أو نقل أي بيانات إلى خوادم خارجية.

### Gespeicherte Daten / البيانات المخزنة

**Deutsch:**
- Ihr ausgewähltes Bundesland (z.B. "SN" für Sachsen)
- Ihr Prüfungstermin (Datum)
- Ihr Lernfortschritt (beantwortete Fragen, richtige/falsche Antworten)
- Ihre Spracheinstellung
- Ihr aktueller Streak (Tage in Folge)
- Ihre TTS-Geschwindigkeitseinstellung
- **Optional:** Ihr Name (nur lokal gespeichert, es sei denn, Sie erlauben die Synchronisation)
- **Optional:** Ihr Profilbild (nur lokal gespeichert, es sei denn, Sie erlauben die Synchronisation)

**العربية:**
- الولاية المختارة (مثل "SN" لساكسونيا)
- تاريخ الامتحان
- تقدم التعلم (الأسئلة المجابة، الإجابات الصحيحة/الخاطئة)
- إعدادات اللغة
- اليوم المتتالي الحالي
- إعدادات سرعة TTS
- **اختياري:** اسمك (محفوظ محلياً فقط، ما لم تسمح بالمزامنة)
- **اختياري:** صورتك الشخصية (محفوظة محلياً فقط، ما لم تسمح بالمزامنة)

### Speichermethode / طريقة التخزين

**Deutsch:**  
Die Daten werden mit Hive (lokale Datenbank) und SharedPreferences auf Ihrem Gerät gespeichert. Diese Daten sind nur auf Ihrem Gerät zugänglich und werden nicht synchronisiert.

**العربية:**  
يتم تخزين البيانات باستخدام Hive (قاعدة بيانات محلية) و SharedPreferences على جهازك. هذه البيانات متاحة فقط على جهازك ولا يتم مزامنتها.

### Datensynchronisation / مزامنة البيانات

**Deutsch:**  
Wir nutzen Supabase (gehostet in Deutschland/EU), um Ihren Lizenzstatus und Lernfortschritt zu synchronisieren. Wir verwenden eine anonyme Authentifizierung; es sind keine E-Mail oder persönlichen Daten erforderlich, es sei denn, Sie verknüpfen freiwillig ein Konto.

**Optionale Profildaten / البيانات الشخصية الاختيارية:**
- Sie können optional Ihren Namen und ein Profilbild hinzufügen
- Diese Daten werden **standardmäßig nur lokal** auf Ihrem Gerät gespeichert
- Sie können wählen, ob diese Daten in unserer Datenbank synchronisiert werden sollen (über die Einstellung "Name in Datenbank speichern")
- **Kostenlose Nutzer:** Können ihren Namen **einmal** ändern
- **Pro-Nutzer:** Können ihren Namen **unbegrenzt** oft ändern
- Profilbilder werden nur synchronisiert, wenn Sie die Synchronisation aktiviert haben

**Gemeinsamer Fortschritt (Pro-Funktion) / التقدم المشترك (ميزة Pro):**
- **Pro-Abonnenten** können ihren Lernfortschritt auf **bis zu 3 Geräten** synchronisieren
- Der Fortschritt wird automatisch zwischen allen Geräten synchronisiert
- Wenn Sie Ihr Gerät verlieren, können Sie Ihren Fortschritt auf einem neuen Gerät wiederherstellen
- Der Fortschritt wird über einen RevenueCat Customer ID verknüpft, der mit Ihrem Apple/Google Account verknüpft ist
- **Kostenlose Nutzer:** Der Fortschritt ist gerätespezifisch und wird nicht zwischen Geräten synchronisiert

**العربية:**  
نستخدم Supabase (مستضاف في ألمانيا/الاتحاد الأوروبي) لمزامنة حالة الترخيص وتقدم التعلم. نستخدم المصادقة المجهولة؛ لا يلزم البريد الإلكتروني أو البيانات الشخصية ما لم تقم بربط حساب طواعية.

**البيانات الشخصية الاختيارية:**
- يمكنك اختيارياً إضافة اسمك وصورة شخصية
- يتم حفظ هذه البيانات **افتراضياً محلياً فقط** على جهازك
- يمكنك اختيار ما إذا كانت هذه البيانات يجب أن تتم مزامنتها في قاعدة البيانات لدينا (من خلال إعداد "حفظ الاسم في قاعدة البيانات")
- **المستخدمون المجانيون:** يمكنهم تغيير اسمهم **مرة واحدة** فقط
- **مشتركو Pro:** يمكنهم تغيير اسمهم **بلا حدود**
- يتم مزامنة الصور الشخصية فقط إذا قمت بتفعيل المزامنة

**التقدم المشترك (ميزة Pro):**
- يمكن لمشتركي **Pro** مزامنة تقدم التعلم على **ما يصل إلى 3 أجهزة**
- يتم مزامنة التقدم تلقائياً بين جميع الأجهزة
- إذا فقدت جهازك، يمكنك استعادة تقدمك على جهاز جديد
- يتم ربط التقدم عبر RevenueCat Customer ID المرتبط بحساب Apple/Google الخاص بك
- **المستخدمون المجانيون:** التقدم خاص بكل جهاز ولا يتم مزامنته بين الأجهزة

## 2. Kamera-Zugriff / الوصول إلى الكاميرا

**Deutsch:**  
Diese App verwendet die Kamera Ihres Geräts **ausschließlich** zum Scannen von QR-Codes aus PDF-Prüfungsbögen. Die Kamera wird **NICHT** verwendet für:
- Aufnahme von Fotos
- Aufnahme von Videos
- Speicherung von Bildern oder Videos
- Übertragung von Bildern oder Videos an externe Server

**Wie wird die Kamera verwendet?**
- Die Kamera wird nur aktiviert, wenn Sie die Funktion "QR-Code scannen" in der App verwenden
- Die Kamera-Daten werden **nur lokal** auf Ihrem Gerät verarbeitet
- Es werden **keine Bilder oder Videos** gespeichert oder übertragen
- Die Kamera wird sofort deaktiviert, nachdem der QR-Code gescannt wurde

**العربية:**  
يستخدم هذا التطبيق كاميرا جهازك **فقط** لمسح رموز QR من أوراق الامتحان PDF. لا يتم استخدام الكاميرا لـ:
- التقاط الصور
- تسجيل الفيديوهات
- تخزين الصور أو الفيديوهات
- نقل الصور أو الفيديوهات إلى خوادم خارجية

**كيف يتم استخدام الكاميرا؟**
- يتم تفعيل الكاميرا فقط عند استخدام وظيفة "مسح QR Code" في التطبيق
- يتم معالجة بيانات الكاميرا **محلياً فقط** على جهازك
- **لا يتم** تخزين أو نقل أي صور أو فيديوهات
- يتم إيقاف الكاميرا فوراً بعد مسح رمز QR

## 3. Text-to-Speech (TTS) / تحويل النص إلى كلام

**Deutsch:**  
Diese App verwendet Flutter TTS, um Fragen auf Deutsch vorzulesen. Die TTS-Funktion arbeitet vollständig offline auf Ihrem Gerät. Es werden keine Audio-Daten an externe Dienste gesendet.

**العربية:**  
يستخدم هذا التطبيق Flutter TTS لقراءة الأسئلة باللغة الألمانية. تعمل وظيفة TTS بالكامل دون اتصال على جهازك. لا يتم إرسال أي بيانات صوتية إلى خدمات خارجية.

## 4. Keine Tracking-Tools / لا توجد أدوات تتبع

**Deutsch:**  
Diese App verwendet keine Analytics-Tools, keine Werbe-IDs und keine Tracking-Mechanismen. Ihre Nutzung wird nicht überwacht oder analysiert.

**العربية:**  
لا يستخدم هذا التطبيق أدوات تحليل أو معرفات إعلانية أو آليات تتبع. لا يتم مراقبة أو تحليل استخدامك.

## 5. DSGVO-Konformität / امتثال DSGVO

**Deutsch:**  
Diese App ist vollständig DSGVO-konform, da:
- Alle Daten lokal gespeichert werden
- Keine Datenübertragung stattfindet
- Keine Drittanbieter-Dienste integriert sind
- Sie volle Kontrolle über Ihre Daten haben

**العربية:**  
هذا التطبيق متوافق بالكامل مع DSGVO لأن:
- جميع البيانات مخزنة محلياً
- لا يتم نقل البيانات
- لا توجد خدمات أطراف ثالثة مدمجة
- لديك سيطرة كاملة على بياناتك

## 6. Ihre Rechte / حقوقك

**Deutsch:**  
Sie haben jederzeit das Recht:
- Ihre gespeicherten Daten einzusehen
- Ihre Daten zu löschen (über die Funktion "Fortschritt zurücksetzen" in den Einstellungen)
- Die App zu deinstallieren (dadurch werden alle Daten gelöscht)

**العربية:**  
لديك الحق في أي وقت:
- الاطلاع على بياناتك المخزنة
- حذف بياناتك (من خلال وظيفة "إعادة تعيين التقدم" في الإعدادات)
- إلغاء تثبيت التطبيق (سيؤدي ذلك إلى حذف جميع البيانات)

## 7. Kontakt / الاتصال

**Deutsch:**  
Bei Fragen zum Datenschutz kontaktieren Sie bitte den App-Entwickler über die Kontaktdaten im Impressum.

**العربية:**  
للأسئلة حول الخصوصية، يرجى الاتصال بمطور التطبيق عبر معلومات الاتصال في Impressum.

## 8. Geräte-Limit für Pro-Abonnenten / حد الأجهزة لمشتركي Pro

**Deutsch:**  
Pro-Abonnenten können ihren Fortschritt auf **bis zu 3 Geräten** gleichzeitig aktivieren. Wenn ein vierter Gerät hinzugefügt wird, wird das älteste Gerät automatisch auf den kostenlosen Plan zurückgesetzt. Dies verhindert Missbrauch und stellt sicher, dass die Funktion fair genutzt wird.

**العربية:**  
يمكن لمشتركي Pro تفعيل تقدمهم على **ما يصل إلى 3 أجهزة** في نفس الوقت. عند إضافة جهاز رابع، يتم إعادة تعيين أقدم جهاز تلقائياً إلى الخطة المجانية. هذا يمنع سوء الاستخدام ويضمن استخدام الميزة بشكل عادل.

---

**Stand / الحالة:** 24. Dezember 2025 / 24 ديسمبر 2025  
**Letzte Aktualisierung / آخر تحديث:** Progress-Synchronisation zwischen Geräten hinzugefügt / تمت إضافة مزامنة التقدم بين الأجهزة

