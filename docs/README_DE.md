# 🇩🇪 Eagle Test: Germany - Entwicklerhandbuch

## Übersicht

**Eagle Test: Germany** ist eine fortgeschrittene Flutter-Anwendung zur Vorbereitung auf den deutschen Einbürgerungstest. Die App basiert auf Clean Architecture und verwendet einen Offline-First-Ansatz mit optionaler Cloud-Synchronisation.

## Hauptmerkmale

- ✅ **Clean Architecture**: Klare Trennung zwischen Schichten (Domain, Data, Presentation)
- ✅ **Offline-First**: Funktioniert ohne Internet mit Hive
- ✅ **Cloud Sync**: Optionale Synchronisation über Supabase (für Pro-Abonnenten)
- ✅ **State Management**: Riverpod für State-Verwaltung
- ✅ **Multi-Language**: Unterstützung für 6 Sprachen (Arabisch, Deutsch, Englisch, Türkisch, Ukrainisch, Russisch)
- ✅ **AI Tutor**: Intelligente Erklärungen mit Groq API
- ✅ **SRS**: Intelligentes Spaced Repetition System
- ✅ **Gamification**: Punkte, tägliche Herausforderungen, Statistiken
- ✅ **Subscriptions**: Abonnementverwaltung über RevenueCat

## Verwendete Technologien

### Core Technologies
- **Flutter**: 3.2.0+
- **Dart**: 3.2.0+
- **Riverpod**: 2.4.9 (State Management)
- **Hive**: 2.2.3 (Lokale Datenbank)
- **Supabase**: 2.5.6 (Cloud Backend)

### Wichtige Pakete
- `flutter_riverpod`: State-Verwaltung
- `hive_flutter`: Lokale Datenbank
- `supabase_flutter`: Cloud-Synchronisation
- `purchases_flutter`: Abonnementverwaltung
- `flutter_tts`: Text-zu-Sprache
- `google_generative_ai`: AI Tutor (Groq API)
- `flutter_local_notifications`: Intelligente Benachrichtigungen

## Projektstruktur

```
lib/
├── core/              # Kern-Utilities
│   ├── config/        # Umgebungskonfiguration (API Keys)
│   ├── services/      # Services (Sync, Notifications, AI)
│   ├── storage/       # Speicher (Hive, SharedPreferences)
│   ├── theme/         # Themes und Farben
│   └── utils/         # Hilfsfunktionen
├── data/              # Datenebene
│   ├── datasources/   # Datenquellen (JSON-Dateien)
│   ├── models/        # Datenmodelle
│   └── repositories/  # Repository-Implementierungen
├── domain/            # Geschäftslogik
│   ├── entities/      # Entitäten
│   ├── repositories/  # Repository-Schnittstellen
│   └── usecases/      # Use Cases
└── presentation/      # UI-Ebene
    ├── providers/     # Riverpod Providers
    ├── screens/       # Bildschirme
    └── widgets/       # Wiederverwendbare Widgets
```

## Setup und Ausführung

### Voraussetzungen
- Flutter SDK 3.2.0 oder höher
- Dart 3.2.0 oder höher
- Android Studio / VS Code
- Git

### Setup-Schritte

1. **Repository klonen**
```bash
git clone <repository-url>
cd politik_test
```

2. **Abhängigkeiten installieren**
```bash
flutter pub get
```

3. **Supabase einrichten** (optional)
   - Neues Supabase-Projekt erstellen
   - SQL-Dateien aus `supabase_migrations/` ausführen
   - Schlüssel in `lib/core/config/env_config.dart` hinzufügen

4. **RevenueCat einrichten** (optional)
   - RevenueCat-Konto erstellen
   - API-Key in `lib/core/services/subscription_service.dart` hinzufügen

5. **Groq API einrichten** (für AI Tutor)
   - API-Key von https://console.groq.com erhalten
   - In `lib/core/config/api_config.dart` hinzufügen

6. **App ausführen**
```bash
flutter run
```

## Build für Produktion

### Android
```bash
flutter build apk --release
# oder
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Dokumentation

- [ARCHITECTURE.md](./ARCHITECTURE.md) - Detaillierte Architektur
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Beitragsrichtlinien
- [FEATURES_INDEX.md](./FEATURES_INDEX.md) - Feature-Index
- [features/](./features/) - Einzelne Feature-Dokumentationen

## Support

Bei Fragen oder Problemen bitte ein Issue auf GitHub öffnen.

---

**Made with ❤️ for German citizenship test preparation**

