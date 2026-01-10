// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Eagle Test: Germany';

  @override
  String get startExam => 'Prüfung starten';

  @override
  String get quickPractice => 'Schnellübung';

  @override
  String get stats => 'Statistiken';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get theme => 'Design';

  @override
  String daysLeft(int count) {
    return 'Noch $count Tage';
  }

  @override
  String get dailyGoal => 'Tagesziel';

  @override
  String get streak => 'Serie';

  @override
  String get reviewMistakes => 'Fehler überprüfen';

  @override
  String get next => 'Weiter';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get passed => 'Bestanden!';

  @override
  String get failed => 'Nicht bestanden';

  @override
  String get selectState => 'Bundesland wählen';

  @override
  String get examDate => 'Prüfungstermin';

  @override
  String get save => 'Speichern';

  @override
  String get fullExam => 'Vollständige Prüfung';

  @override
  String get driveMode => 'Fahrmodus';

  @override
  String get reviewDue => 'Überprüfung fällig';

  @override
  String get yourGoal => 'Ihr Ziel';

  @override
  String questions(int count) {
    return '$count Fragen';
  }

  @override
  String question(int count) {
    return '$count Frage';
  }

  @override
  String get welcome => 'Willkommen';

  @override
  String get selectBundesland => 'Wählen Sie Ihr Bundesland';

  @override
  String get whenIsExam => 'Wann ist dein Test?';

  @override
  String get letsStart => 'Los geht\'s!';

  @override
  String get examMode => 'Prüfungsmodus';

  @override
  String questionLabel(int current, int total) {
    return 'Frage $current/$total';
  }

  @override
  String get nextQuestion => 'Nächste Frage';

  @override
  String get finishExam => 'Prüfung beenden';

  @override
  String get examCompleted => 'Prüfung abgeschlossen!';

  @override
  String get showArabic => 'Arabische Übersetzung anzeigen';

  @override
  String get hideArabic => 'Arabisch ausblenden';

  @override
  String get noQuestions => 'Keine Fragen geladen.';

  @override
  String get glossary => 'Wörterbuch';

  @override
  String get general => 'Allgemein';

  @override
  String get darkMode => 'Dunkler Modus';

  @override
  String get audio => 'Audio';

  @override
  String get speakingSpeed => 'Sprechgeschwindigkeit';

  @override
  String get data => 'Daten';

  @override
  String get resetProgress => 'Fortschritt zurücksetzen';

  @override
  String get resetProgressMessage =>
      'Sind Sie sicher, dass Sie Ihren gesamten Fortschritt zurücksetzen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get progressReset => 'Fortschritt erfolgreich zurückgesetzt';

  @override
  String get legal => 'Rechtliches';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get datenschutz => 'Datenschutz';

  @override
  String get termsOfUse => 'Nutzungsbedingungen';

  @override
  String get nutzungsbedingungen => 'Nutzungsbedingungen';

  @override
  String get intellectualProperty => 'Geistiges Eigentum';

  @override
  String get geistigesEigentum => 'Geistiges Eigentum';

  @override
  String get impressum => 'Impressum';

  @override
  String get legalInformation => 'Rechtliche Informationen';

  @override
  String get printExam => 'Prüfung drucken';

  @override
  String get searchGlossary => 'Wörterbuch durchsuchen...';

  @override
  String get chooseLanguage => 'Wählen Sie Ihre bevorzugte Sprache zum Lernen';

  @override
  String get setupComplete => 'Einrichtung abgeschlossen';

  @override
  String get tapToSelect => 'Tippen zum Auswählen';

  @override
  String get completeAllSteps => 'Bitte vervollständigen Sie alle Schritte';

  @override
  String get back => 'Zurück';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get dailyReminder => 'Tägliche Erinnerung';

  @override
  String get dailyReminderDescription =>
      'Lassen Sie sich täglich zum Lernen erinnern';

  @override
  String get reminderTime => 'Uhrzeit';

  @override
  String get reminderEnabled => 'Tägliche Erinnerung aktiviert';

  @override
  String get reminderDisabled => 'Tägliche Erinnerung deaktiviert';

  @override
  String get reminderTimeUpdated => 'Erinnerungszeit aktualisiert';

  @override
  String get about => 'Über die App';

  @override
  String get appVersion => 'Version';

  @override
  String get rateApp => 'App bewerten';

  @override
  String get rateAppDescription =>
      'Wenn Ihnen die App gefällt, bewerten Sie sie bitte im Store';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeLightDesc => 'Heller Modus';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeDarkDesc => 'Dunkler Modus';

  @override
  String get themeSystem => 'System';

  @override
  String get themeSystemDesc => 'Systemeinstellungen folgen';

  @override
  String get quitExam => 'Prüfung beenden?';

  @override
  String get quitExamMessage => 'Ihr Fortschritt geht verloren.';

  @override
  String get stay => 'Bleiben';

  @override
  String get quit => 'Beenden';

  @override
  String get dangerZone => 'Gefahrenzone';

  @override
  String get resetAppData => 'App-Daten zurücksetzen';

  @override
  String get resetAppDataDescription =>
      'Dies löscht alle App-Daten und kann nicht rückgängig gemacht werden';

  @override
  String get factoryReset => 'Werkseinstellung?';

  @override
  String get factoryResetMessage =>
      'Dies löscht ALLE App-Daten einschließlich:';

  @override
  String get allProgressAndAnswers => 'Alle Fortschritte und Antworten';

  @override
  String get studyHistory => 'Lernverlauf';

  @override
  String get streaks => 'Serien';

  @override
  String get cannotBeUndone =>
      'Diese Aktion kann NICHT rückgängig gemacht werden!';

  @override
  String get resetEverything => 'Alles zurücksetzen';

  @override
  String get appDataResetSuccess => 'App-Daten erfolgreich zurückgesetzt';

  @override
  String get errorResettingApp => 'Fehler beim Zurücksetzen der App:';

  @override
  String get totalLearned => 'Gesamt gelernt';

  @override
  String get ofQuestions => 'von 310 Fragen';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get learn => 'Lernen';

  @override
  String get explainWithAi => 'Mit KI erklären';

  @override
  String get upgradeToPro => 'Auf Pro upgraden';

  @override
  String get unlockAiTutor => 'KI-Tutor freischalten';

  @override
  String get upgrade => 'Upgraden';

  @override
  String get upgradeToProMessage =>
      'Upgraden Sie auf Pro, um den KI-Tutor freizuschalten und personalisierte Erklärungen für alle Fragen zu erhalten.';

  @override
  String get aiTutorDailyLimitReached =>
      'Sie haben den KI-Tutor heute 3 Mal verwendet. Abonnieren Sie Pro für unbegrenzte Nutzung.';

  @override
  String get aiExplanation => 'KI-Erklärung';

  @override
  String get aiThinking => 'KI denkt nach...';

  @override
  String get errorLoadingExplanation => 'Fehler beim Laden der Erklärung';

  @override
  String get reviewAnswers => 'Antworten überprüfen';

  @override
  String get mistakesOnly => 'Nur Fehler anzeigen';

  @override
  String get aboutMultiLanguageTitle => 'Mehrsprachige Beherrschung';

  @override
  String get aboutMultiLanguageSubtitle => '6 Sprachen';

  @override
  String get aboutMultiLanguageDescription =>
      'Lösung der Sprachbarriere. Lernen Sie in der Sprache, die Sie am besten verstehen.';

  @override
  String get aboutTranslationTitle => 'Intelligente Kontextübersetzung';

  @override
  String get aboutTranslationSubtitle => 'Präzise Übersetzung';

  @override
  String get aboutTranslationDescription =>
      'Lösung von Missverständnissen. Genaue Übersetzungen komplexer rechtlicher Begriffe, um das richtige Verständnis zu gewährleisten.';

  @override
  String get aboutAiTutorTitle => 'Eagle KI-Tutor';

  @override
  String get aboutAiTutorSubtitle => 'KI-Assistent';

  @override
  String get aboutAiTutorDescription =>
      'Lösung von Verwirrung. Sofortige Erklärungen für jede Frage in Ihrer Muttersprache, um Ihnen zu helfen, Fehler zu verstehen und zu korrigieren.';

  @override
  String get aboutPaperExamTitle => 'Drucken & Offline Üben';

  @override
  String get aboutPaperExamSubtitle => 'Echte Prüfungssimulation';

  @override
  String get aboutPaperExamDescription =>
      'Erstellen Sie offizielle PDF-Prüfungen. Trainieren Sie mit Stift und Papier wie bei der echten Prüfung.';

  @override
  String get aboutDevelopedWith => 'Entwickelt mit ❤️';

  @override
  String get aboutRateUs => 'Bewerten Sie uns';

  @override
  String get aboutSupport => 'Support';

  @override
  String get aboutWebsite => 'Website';

  @override
  String get aboutLoadingVersion => 'Lädt...';

  @override
  String get aboutRoadmapTitle => 'Die Zukunft';

  @override
  String get aboutRoadmapSubtitle => 'Die Zukunft';

  @override
  String get aboutRoadmapVoiceCoach => 'KI-Stimmcoach';

  @override
  String get aboutRoadmapVoiceCoachDesc => 'Aussprachetraining';

  @override
  String get aboutRoadmapLiveBattles => 'Live-Kämpfe';

  @override
  String get aboutRoadmapLiveBattlesDesc => 'Mehrspielermodus';

  @override
  String get aboutRoadmapBureaucracyBot => 'Bürokratie-Bot';

  @override
  String get aboutRoadmapBureaucracyBotDesc => 'Formularhelfer';

  @override
  String get glossaryTapToFlip => 'Zum Umdrehen tippen';

  @override
  String get glossaryPrevious => 'Zurück';

  @override
  String get glossaryNext => 'Weiter';

  @override
  String get glossaryPronounce => 'Aussprechen';

  @override
  String get glossaryListView => 'Listenansicht';

  @override
  String get glossaryFlashcards => 'Karteikarten';

  @override
  String get glossarySearchPlaceholder => 'Glossar durchsuchen...';

  @override
  String get glossaryNoTermsAvailable => 'Keine Begriffe verfügbar';

  @override
  String get glossaryNoTermsFound => 'Keine Begriffe gefunden';

  @override
  String get glossaryDefinition => 'Definition:';

  @override
  String get glossaryExample => 'Beispiel:';

  @override
  String get glossaryShowInQuestionContext => 'Im Fragenkontext anzeigen';

  @override
  String get glossaryRelatedQuestions => 'Verwandte Fragen zu';

  @override
  String get statsOverview => 'Übersicht';

  @override
  String get statsProgress => 'Fortschritt';

  @override
  String get statsToday => 'Heute';

  @override
  String get statsMastered => 'Gelernt';

  @override
  String get statsMinutes => 'Minuten';

  @override
  String get statsQuestions => 'Fragen';

  @override
  String get statsDays => 'Tage';

  @override
  String get statsDay => 'Tag';

  @override
  String get statsProgressCharts => 'Fortschrittsdiagramme';

  @override
  String get statsWeeklyStudyTime => 'Wöchentliche Lernzeit';

  @override
  String get statsExamScoresOverTime => 'Prüfungsergebnisse im Zeitverlauf';

  @override
  String get statsCategoryMastery => 'Kategorienbeherrschung';

  @override
  String get statsSrsInsights => 'SRS-Einblicke';

  @override
  String get statsDue => 'Fällig';

  @override
  String get statsEasy => 'Einfach';

  @override
  String get statsNew => 'Neu';

  @override
  String get statsHard => 'Schwer';

  @override
  String get statsGood => 'Gut';

  @override
  String get statsExamPerformance => 'Prüfungsleistung';

  @override
  String get statsAverageScore => 'Durchschnittspunktzahl';

  @override
  String get statsCompleted => 'Abgeschlossen';

  @override
  String get statsBestScore => 'Beste Punktzahl';

  @override
  String get statsPassRate => 'Bestehensquote';

  @override
  String get statsStudyHabits => 'Lerngewohnheiten';

  @override
  String get statsAvgSession => 'Ø Sitzung';

  @override
  String get statsMin => 'Min';

  @override
  String get statsActiveDays => 'Aktive Tage';

  @override
  String get statsSmartInsights => 'Intelligente Einblicke';

  @override
  String get statsRecommendations => 'Empfehlungen';

  @override
  String get statsRecentExams => 'Letzte Prüfungen';

  @override
  String get statsRefresh => 'Aktualisieren';

  @override
  String statsInsightDueQuestions(int count) {
    return 'Sie haben $count Fragen zur Überprüfung fällig';
  }

  @override
  String get statsInsightFocusNew =>
      'Konzentrieren Sie sich auf neue Fragen, um Ihren Fortschritt zu steigern';

  @override
  String statsInsightKeepPracticing(String score) {
    return 'Weiter üben! Durchschnittspunktzahl: $score%';
  }

  @override
  String statsInsightExcellentStreak(int days) {
    return 'Ausgezeichnet! Sie pflegen eine Lerngewohnheit ($days Tage)';
  }

  @override
  String get statsInsightKeepStudying =>
      'Weiter lernen, um intelligente Einblicke zu erhalten';

  @override
  String get statsScore => 'Punktzahl';

  @override
  String get paperExam => 'Papierprüfung';

  @override
  String get paperExamSimulation => 'Papierprüfung Simulation';

  @override
  String get paperExamDescription =>
      'Erstellen Sie eine realistische PDF-Prüfung zum Drucken';

  @override
  String get paperExamConfiguration => 'Konfiguration';

  @override
  String get paperExamState => 'Bundesland';

  @override
  String get paperExamGeneral => 'Allgemein (Kein Bundesland)';

  @override
  String get paperExamIncludeSolutions => 'Lösungsschlüssel beifügen';

  @override
  String get paperExamIncludeSolutionsDesc => 'Lösungsschlüssel beifügen';

  @override
  String get paperExamShuffle => 'Fragen mischen';

  @override
  String get paperExamShuffleDesc => 'Fragen mischen';

  @override
  String get paperExamGenerate => 'PDF erstellen 📄';

  @override
  String get paperExamGenerating => 'Wird erstellt...';

  @override
  String get paperExamPdfGenerated => 'PDF erfolgreich erstellt!';

  @override
  String get paperExamPrint => 'Drucken';

  @override
  String get paperExamShare => 'Teilen';

  @override
  String get paperExamScan => 'Scannen zum Korrigieren';

  @override
  String get scanExamTitle => 'QR-Code scannen';

  @override
  String get scanExamInstructions => 'QR-Code aus PDF im Rahmen positionieren';

  @override
  String get scanExamProcessing => 'Wird verarbeitet...';

  @override
  String get paperCorrectionTitle => 'Papierprüfung korrigieren';

  @override
  String get paperCorrectionInstructions =>
      'Geben Sie Ihre Antworten vom Papier ein';

  @override
  String get paperCorrectionAnswered => 'beantwortet';

  @override
  String get paperCorrectionFinish => 'Beenden & Bewerten';

  @override
  String get paperCorrectionIncompleteTitle => 'Unvollständige Antworten';

  @override
  String get paperCorrectionIncompleteMessage =>
      'Sie haben nicht alle Fragen beantwortet. Trotzdem fortfahren?';

  @override
  String get paperExamWidgetDescription => 'Drucken & Offline Üben';

  @override
  String get paperExamTutorialTitle => 'Wie man die Papierprüfung verwendet';

  @override
  String get paperExamTutorialStep1Title => 'PDF erstellen';

  @override
  String get paperExamTutorialStep1Desc =>
      'Tippen Sie auf \"Papierprüfung\", wählen Sie Einstellungen (Bundesland, Fragen mischen, Lösungsschlüssel beifügen), dann tippen Sie auf \"PDF erstellen\"';

  @override
  String get paperExamTutorialStep2Title => 'PDF drucken';

  @override
  String get paperExamTutorialStep2Desc =>
      'Drucken Sie das PDF auf Papier. Es wird einen QR-Code oben auf der Seite geben';

  @override
  String get paperExamTutorialStep3Title => 'Auf Papier antworten';

  @override
  String get paperExamTutorialStep3Desc =>
      'Beantworten Sie die Fragen mit Stift und Papier, genau wie bei der echten Prüfung';

  @override
  String get paperExamTutorialStep4Title => 'QR-Code scannen';

  @override
  String get paperExamTutorialStep4Desc =>
      'Öffnen Sie die App, gehen Sie zu \"Papierprüfung\", tippen Sie auf \"Scannen zum Korrigieren\" und scannen Sie den QR-Code vom Papier';

  @override
  String get paperExamTutorialStep5Title =>
      'Antworten eingeben & Punktzahl erhalten';

  @override
  String get paperExamTutorialStep5Desc =>
      'Geben Sie Ihre Antworten vom Papier schnell in die App ein und erhalten Sie sofort Ihre Punktzahl';

  @override
  String get chooseTopic => 'Thema wählen';

  @override
  String get topicSystem => 'Politisches System';

  @override
  String get topicRights => 'Grundrechte';

  @override
  String get topicHistory => 'Deutsche Geschichte';

  @override
  String get topicSociety => 'Gesellschaft';

  @override
  String get topicEurope => 'Deutschland in Europa';

  @override
  String get topicWelfare => 'Arbeit & Bildung';

  @override
  String get learned => 'Gelernt';

  @override
  String get correct => 'Richtig';

  @override
  String get topicQuestions => 'Themenfragen';

  @override
  String get noQuestionsForTopic => 'Keine Fragen für dieses Thema verfügbar';

  @override
  String get allTopicsReviewed => 'Großartig! Alle Fragen wurden überprüft. 🎉';

  @override
  String get topics => 'Themen';

  @override
  String get topicStatistics => 'Themenstatistiken';

  @override
  String get totalQuestions => 'Gesamtfragen';

  @override
  String get questionsAnswered => 'Beantwortete Fragen';

  @override
  String get accuracyRate => 'Genauigkeitsrate';

  @override
  String get mostStudiedTopic => 'Meist studiertes Thema';

  @override
  String get leastStudiedTopic => 'Wenigstens studiertes Thema';

  @override
  String get availableFeatures => 'Verfügbare Funktionen';

  @override
  String get freePlan => 'Kostenlos';

  @override
  String get accessToAllQuestions => 'Zugriff auf alle Fragen';

  @override
  String get adsIfAvailable => 'Werbung (falls vorhanden)';

  @override
  String get oneExamPerDay => 'Ein Prüfung pro Tag';

  @override
  String get proSubscriptionPremium => 'Pro-Abonnement (Premium)';

  @override
  String get unlimitedAiTutor => 'Unbegrenzter KI-Tutor';

  @override
  String get aiTutorFreeLimit => '3 Mal/Tag';

  @override
  String get aiTutorUnlimited => 'Unbegrenzt';

  @override
  String get pdfExamGeneration => 'PDF-Prüfung erstellen';

  @override
  String get noAds => 'Keine Werbung';

  @override
  String get advancedSuccessStatistics => 'Erweiterte Erfolgsstatistiken';

  @override
  String get monthly => 'Monatlich';

  @override
  String get renewsMonthly => 'Erneuert sich monatlich';

  @override
  String get threeMonths => '3 Monate';

  @override
  String get yearly => 'Jährlich';

  @override
  String get mostPopularForExams => 'Am beliebtesten für Prüfungen';

  @override
  String get lifetime => 'Lebenslang';

  @override
  String get oneTimePayment => 'Einmalige Zahlung';

  @override
  String get bestValue => 'Bester Wert';

  @override
  String get activeSubscription => 'Aktives Abonnement';

  @override
  String get upgradeForAdditionalFeatures =>
      'Für zusätzliche Funktionen upgraden';

  @override
  String get dailyChallenge => '🔥 Tägliche Herausforderung';

  @override
  String get challengeCompleted => 'Herausforderung abgeschlossen!';

  @override
  String get challengeExcellent => '🌟 Ausgezeichnet! Du bist ein Meister!';

  @override
  String get challengeGreat => '🎉 Großartige Arbeit! Weiter so!';

  @override
  String get challengeGood => '👍 Gute Anstrengung! Übung macht den Meister!';

  @override
  String get challengeKeepGoing =>
      '💪 Weiter so! Jeder Fehler ist eine Lektion!';

  @override
  String get points => 'Punkte';

  @override
  String get accuracy => 'Genauigkeit';

  @override
  String get time => 'Zeit';

  @override
  String get done => 'Fertig';

  @override
  String get exitChallenge => 'Herausforderung beenden?';

  @override
  String get exitChallengeMessage =>
      'Bist du sicher, dass du beenden möchtest? Dein Fortschritt geht verloren.';

  @override
  String get exit => 'Beenden';

  @override
  String get previous => 'Zurück';

  @override
  String get finish => 'Beenden';

  @override
  String get loading => 'Lädt...';

  @override
  String get errorLoadingQuestions => 'Fehler beim Laden der Fragen';

  @override
  String get retry => 'Wiederholen';

  @override
  String get noQuestionsAvailable => 'Keine Fragen verfügbar';

  @override
  String get completedToday => 'Abgeschlossen!';

  @override
  String get goBack => 'Zurück';

  @override
  String get errorLoadingExam => 'Fehler beim Laden der Prüfung';

  @override
  String get topicState => 'Länderfragen';

  @override
  String get selectStateFirst => 'Bitte wählen Sie zuerst ein Bundesland aus';

  @override
  String get aboutDailyChallengeTitle => '🔥 Tägliche Herausforderung';

  @override
  String get aboutDailyChallengeSubtitle => 'Motivierendes tägliches Lernen';

  @override
  String get aboutDailyChallengeDescription =>
      'Testen Sie sich täglich mit 10 zufälligen Fragen und verdienen Sie Punkte für jede richtige Antwort. Feiern Sie Ihre Erfolge mit unterhaltsamen visuellen Effekten!';

  @override
  String get voiceExam => '🎤 Sprachprüfung (Pro)';

  @override
  String get playAudio => '🔊 Audio abspielen';

  @override
  String get playing => 'Wird abgespielt...';

  @override
  String get voiceExamMode => 'Sprachprüfungsmodus';

  @override
  String get aiCoachTitle => '🎯 KI-Studiencoach';

  @override
  String get aiCoachSubtitle => 'Ihr personalisierter Studienplan';

  @override
  String get aiCoachWeakTopics => 'Schwächste Themen:';

  @override
  String get aiCoachError => 'Fehler beim Laden der Coaching-Beratung';

  @override
  String get aiCoachNoData =>
      'Beginnen Sie mit dem Beantworten von Fragen, um personalisierte Studienberatung zu erhalten!';

  @override
  String get startFocusedPractice => 'Fokussiertes Üben starten';

  @override
  String get unlockAiCoach => 'KI-Coach freischalten';

  @override
  String get aiStudyCoach => 'KI-Studiencoach';

  @override
  String get syncing => 'Synchronisieren...';

  @override
  String get syncError => 'Sync fehlgeschlagen. Offline-Modus.';

  @override
  String get licenseActive => 'Pro-Lizenz Aktiv';

  @override
  String get invalidCode => 'Ungültiger Code';

  @override
  String get guestUser => 'Gastbenutzer';

  @override
  String get proMember => 'PRO-MITGLIED';

  @override
  String get upgradeAccount => 'Konto upgraden';

  @override
  String get subscribeToPro => 'Pro abonnieren';

  @override
  String get orActivateLicense => 'Oder Lizenz aktivieren';

  @override
  String get activateLicense => 'Lizenz aktivieren';

  @override
  String get enterLicenseKey => 'Geben Sie Ihren Lizenzschlüssel ein';

  @override
  String get licenseKey => 'Lizenzschlüssel';

  @override
  String get federalState => 'Bundesland';

  @override
  String get readiness => 'Bereitschaft';

  @override
  String get mastery => 'Beherrschung';

  @override
  String get profile => 'Profil';

  @override
  String get smartAiStudyAlerts => '🎯 Intelligente KI-Lernbenachrichtigungen';

  @override
  String get cloudBackupSync => '☁️ Cloud-Backup & Synchronisation';

  @override
  String get advancedReadinessIndex => '📊 Erweiterter Bereitschaftsindex';

  @override
  String get organizationSupport => '🏢 Organisationsunterstützung';

  @override
  String get enterYourName => 'Geben Sie Ihren Namen ein';

  @override
  String get saveNameToDatabase => 'Namen in Datenbank speichern';

  @override
  String get nameSaved => 'Name gespeichert';

  @override
  String get nameRemoved => 'Name entfernt';

  @override
  String get pickProfilePicture => 'Profilbild auswählen';

  @override
  String get customizeProfileName => '👤 Profilname anpassen';

  @override
  String get nameChangeOnce => 'Einmal';

  @override
  String get nameChangeUnlimited => 'Unbegrenzt';

  @override
  String get topLearners => '🏆 Top Lerner';

  @override
  String get noLeaderboardData => 'Keine Ranglistendaten verfügbar';

  @override
  String get you => 'Du';

  @override
  String get sharedProgressFeature =>
      '🔄 Gemeinsamer Fortschritt auf mehreren Geräten';

  @override
  String get sharedProgressDescription =>
      'Lernen Sie auf bis zu 3 Geräten mit synchronisiertem Fortschritt. Ihre Lerndaten werden automatisch auf allen Ihren Geräten synchronisiert.';

  @override
  String get sharedProgressBenefit =>
      'Greifen Sie von jedem Gerät auf Ihren Fortschritt zu';

  @override
  String get deviceLimit => 'Bis zu 3 Geräten';

  @override
  String get automaticSync => 'Automatische Synchronisation';

  @override
  String get progressRestore =>
      'Fortschritt wiederherstellen, wenn Sie Ihr Gerät verlieren';

  @override
  String get syncingProgress => 'Fortschritt wird synchronisiert...';

  @override
  String get progressSynced => 'Fortschritt synchronisiert';

  @override
  String get cloudSync => 'Cloud-Synchronisation';

  @override
  String get themeTitle => 'Design wählen';

  @override
  String get close => 'Schließen';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get examReadinessReport => 'Prüfungsbereitschaftsbericht';

  @override
  String get overallScore => 'Gesamtpunktzahl';

  @override
  String get componentScores => 'Komponentenpunktzahlen';

  @override
  String get questionMastery => 'Fragenbeherrschung';

  @override
  String get examPerformance => 'Prüfungsleistung';

  @override
  String get studyConsistency => 'Lernkonsistenz';

  @override
  String get stateQuestions => 'Länderfragen';

  @override
  String get statistics => 'Statistiken';

  @override
  String get questionsMastered => 'Beherrschte Fragen';

  @override
  String get correctAnswers => 'Richtige Antworten';

  @override
  String get examsCompleted => 'Abgeschlossene Prüfungen';

  @override
  String get currentStreak => 'Aktuelle Serie';

  @override
  String get studySessionsLast7Days => 'Lernsitzungen (letzte 7 Tage)';

  @override
  String get totalStudyTime => 'Gesamte Lernzeit';

  @override
  String get strengths => 'Stärken';

  @override
  String get weaknesses => 'Schwächen';

  @override
  String get recommendations => 'Empfehlungen';

  @override
  String get tapToViewDetailedReport =>
      'Tippen Sie, um den detaillierten Bericht anzuzeigen';

  @override
  String get excellentFullyReady => 'Ausgezeichnet - Vollständig bereit';

  @override
  String get readyForExam => 'Bereit für Prüfung';

  @override
  String get almostReady => 'Fast bereit';

  @override
  String get needsMoreWork => 'Benötigt mehr Arbeit';

  @override
  String get days => 'Tage';

  @override
  String get hours => 'Stunden';
}
