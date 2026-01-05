# 🇩🇪 Deutschland Test App

<div align="center">

<img src="assets/logo/applogo.png" alt="Deutschland Test Logo" width="200" height="200">

![Flutter](https://img.shields.io/badge/Flutter-3.2.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.2.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**Der beste Weg, den Einbürgerungstest zu bestehen.**  
**الطريقة الأمثل لاجتياز امتحان الجنسية الألمانية.**

[Features](#-features--mيزات) • [Installation](#-installation--التثبيت) • [Tech Stack](#-tech-stack--التقنيات) • [Screenshots](#-screenshots--لقطات-الشاشة)

</div>

---

## 📖 Introduction / المقدمة

> **Deutsch:** Diese App hilft Ihnen dabei, sich optimal auf den deutschen Einbürgerungstest vorzubereiten. Mit über 300 Fragen, intelligenten Lernplänen und einem adaptiven Wiederholungssystem können Sie sicher und effizient lernen.

> **العربية:** يساعدك هذا التطبيق على التحضير الأمثل لامتحان الجنسية الألمانية. مع أكثر من 300 سؤال، خطط دراسة ذكية، ونظام تكرار تكيفي، يمكنك التعلم بثقة وكفاءة.

---

## ✨ Features / الميزات

### 🌍 Multi-Language Support / دعم متعدد اللغات
- 🇺🇸 **English** - International support
- 🇩🇪 **Deutsch** - Native German interface
- 🇸🇾 **العربية** - Full RTL support
- 🇹🇷 **Türkçe** - Turkish language
- 🇺🇦 **Українська** - Ukrainian language
- 🇷🇺 **Русский** - Russian language

### 📚 Smart Study Plan / خطة الدراسة الذكية
> **Deutsch:** Automatische Berechnung des täglichen Lernziels basierend auf verbleibenden Tagen bis zur Prüfung.

> **العربية:** حساب تلقائي للهدف اليومي بناءً على الأيام المتبقية حتى الامتحان.

- Daily goal calculation based on exam date
- Progress tracking with visual indicators
- Streak counter for motivation

### 🚗 Drive Mode / وضع القيادة
> **Deutsch:** Lernen Sie hands-free während der Fahrt mit automatischem Text-to-Speech.

> **العربية:** تعلم بدون استخدام اليدين أثناء القيادة مع تحويل النص إلى كلام تلقائي.

- Hands-free learning experience
- Auto-play questions and answers
- Perfect for commuting

### 🔄 Spaced Repetition System (SRS) / نظام التكرار المتباعد
> **Deutsch:** Intelligentes System, das schwierige Fragen häufiger wiederholt.

> **العربية:** نظام ذكي يعيد الأسئلة الصعبة بشكل متكرر.

- Adaptive difficulty tracking
- Automatic review scheduling
- Optimized learning retention

### 🔥 Daily Challenge Mode / وضع التحدي اليومي
> **Deutsch:** Tägliche Herausforderung mit 10 zufälligen Fragen und einem Punktesystem.

> **العربية:** تحدٍ يومي مع 10 أسئلة عشوائية ونظام نقاط.

- 10 random questions daily
- Points system for correct answers
- Gamified experience with celebrations
- Visual feedback and animations

### 🎨 Dark Mode & Themes / الوضع الداكن والثيمات
> **Deutsch:** Schonen Sie Ihre Augen mit dem Dunkelmodus und passen Sie die App an Ihre Vorlieben an.

> **العربية:** احمِ عينيك مع الوضع الداكن وخصص التطبيق حسب تفضيلاتك.

- Light/Dark theme support
- System theme detection
- Customizable TTS speed

### 📊 Progress Tracking / تتبع التقدم
> **Deutsch:** Verfolgen Sie Ihren Fortschritt mit detaillierten Statistiken und Visualisierungen.

> **العربية:** تتبع تقدمك مع إحصائيات وتصورات تفصيلية.

- Visual progress indicators
- Study streak tracking
- Performance analytics
- Points system across all activities

### 🎮 Gamification Features / ميزات التحفيز
> **Deutsch:** Machen Sie das Lernen unterhaltsam mit spielerischen Elementen.

> **العربية:** اجعل التعلم ممتعاً مع عناصر تحفيزية.

- Daily Challenge with points
- Celebration animations
- Achievement tracking
- Visual feedback for progress

---

## 🛠️ Tech Stack / التقنيات

### Core Technologies / التقنيات الأساسية

| Technology | Version | Purpose |
|------------|---------|---------|
| **Flutter** | 3.2.0+ | Cross-platform framework |
| **Dart** | 3.2.0+ | Programming language |
| **Riverpod** | 2.4.9 | State management |
| **Hive** | 2.2.3 | Local database |
| **flutter_tts** | 3.8.5 | Text-to-speech |

### Architecture / البنية المعمارية

```
lib/
├── core/              # Core utilities and themes
│   ├── storage/       # Hive, SharedPreferences services
│   └── theme/         # App themes and colors
├── data/              # Data layer
│   ├── datasources/   # Local data sources
│   ├── models/        # Data models
│   └── repositories/  # Repository implementations
├── domain/            # Business logic
│   ├── entities/      # Domain entities
│   ├── repositories/  # Repository interfaces
│   └── usecases/      # Business use cases
└── presentation/      # UI layer
    ├── providers/     # Riverpod providers
    ├── screens/        # App screens
    └── widgets/        # Reusable widgets
```

### Key Features Implementation / تنفيذ الميزات الرئيسية

- **Clean Architecture**: Separation of concerns with clear layer boundaries
- **State Management**: Riverpod for reactive state management
- **Localization**: Flutter's built-in l10n with 6 language support
- **Storage**: Hive for fast local data persistence
- **Audio**: Flutter TTS for hands-free learning

---

## 📸 Screenshots / لقطات الشاشة

| Screen | Description |
|--------|-------------|
| 🏠 Home Screen | Dashboard with daily goals and quick access |
| 📝 Exam Screen | Full exam mode with progress tracking |
| ⚙️ Settings | Comprehensive settings with language selection |
| 🚗 Drive Mode | Hands-free learning interface |
| 📊 Statistics | Progress visualization and analytics |

> **Note:** Screenshots will be added in future updates.

---

## 🚀 Installation / التثبيت

### Prerequisites / المتطلبات

> **Deutsch:** Stellen Sie sicher, dass Flutter SDK (3.2.0 oder höher) installiert ist.

> **العربية:** تأكد من تثبيت Flutter SDK (3.2.0 أو أحدث).

```bash
flutter --version
```

### Setup Steps / خطوات الإعداد

1. **Clone the repository / استنساخ المستودع**
```bash
git clone https://github.com/yourusername/politik_test.git
cd politik_test
```

2. **Install dependencies / تثبيت التبعيات**
```bash
flutter pub get
```

3. **Generate localization files / إنشاء ملفات الترجمة**
```bash
flutter gen-l10n
```

4. **Run the app / تشغيل التطبيق**
```bash
flutter run
```

### Build for Production / بناء للإنتاج

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

---

## 📱 Usage / الاستخدام

### First Launch / الإطلاق الأول

> **Deutsch:** Beim ersten Start werden Sie durch einen Setup-Assistenten geführt, um Ihr Bundesland und das Prüfungsdatum auszuwählen.

> **العربية:** عند الإطلاق الأول، سيتم توجيهك عبر معالج الإعداد لاختيار ولايتك وتاريخ الامتحان.

1. Select your German state (Bundesland)
2. Choose your exam date
3. Start learning!

### Daily Study / الدراسة اليومية

> **Deutsch:** Die App berechnet automatisch Ihr tägliches Lernziel basierend auf verbleibenden Tagen.

> **العربية:** يحسب التطبيق تلقائياً هدفك اليومي بناءً على الأيام المتبقية.

- Check your daily goal on the home screen
- Complete questions to track progress
- Maintain your study streak!

### Exam Mode / وضع الامتحان

> **Deutsch:** Simulieren Sie den echten Test mit 30 allgemeinen Fragen und 3 bundeslandspezifischen Fragen.

> **العربية:** قم بمحاكاة الاختبار الحقيقي مع 30 سؤال عام و 3 أسئلة خاصة بالولاية.

- Full exam: 33 questions (30 general + 3 state-specific)
- Time tracking
- Instant feedback

---

## 🏗️ Project Structure / هيكل المشروع

```
politik_test/
├── assets/
│   ├── data/          # JSON question files
│   └── images/        # App images and logos
├── lib/
│   ├── core/          # Core utilities
│   ├── data/          # Data layer
│   ├── domain/        # Business logic
│   ├── l10n/          # Localization files
│   └── presentation/  # UI layer
├── l10n.yaml          # Localization config
└── pubspec.yaml       # Dependencies
```

---

## 🤝 Contributing / المساهمة

> **Deutsch:** Beiträge sind willkommen! Bitte erstellen Sie einen Pull Request oder öffnen Sie ein Issue.

> **العربية:** المساهمات مرحب بها! يرجى إنشاء Pull Request أو فتح Issue.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License / الترخيص

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Authors / المؤلفون

- **Development Team** - Initial work

---

## 🙏 Acknowledgments / شكر وتقدير

> **Deutsch:** Vielen Dank an alle, die zu diesem Projekt beigetragen haben.

> **العربية:** شكراً لجميع من ساهم في هذا المشروع.

- Flutter team for the amazing framework
- Riverpod for excellent state management
- All contributors and testers

---

## 📞 Support / الدعم

> **Deutsch:** Bei Fragen oder Problemen öffnen Sie bitte ein Issue auf GitHub.

> **العربية:** للأسئلة أو المشاكل، يرجى فتح Issue على GitHub.

---

<div align="center">

**Made with ❤️ for German citizenship test preparation**

**صُنع بـ ❤️ لتحضير امتحان الجنسية الألمانية**

</div>
