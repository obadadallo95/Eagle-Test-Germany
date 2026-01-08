import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('ru'),
    Locale('tr'),
    Locale('uk')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Eagle Test: Germany'**
  String get appTitle;

  /// Button to start the exam
  ///
  /// In en, this message translates to:
  /// **'Start Exam'**
  String get startExam;

  /// Button for quick practice mode
  ///
  /// In en, this message translates to:
  /// **'Quick Practice'**
  String get quickPractice;

  /// Statistics section
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get stats;

  /// Settings section
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language selection
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Theme setting title
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Days remaining until exam
  ///
  /// In en, this message translates to:
  /// **'{count} Days Left'**
  String daysLeft(int count);

  /// Daily study goal
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// Streak days label
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// Button to review mistakes
  ///
  /// In en, this message translates to:
  /// **'Review Mistakes'**
  String get reviewMistakes;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Passed exam message
  ///
  /// In en, this message translates to:
  /// **'Passed!'**
  String get passed;

  /// Failed exam message
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// Select state prompt
  ///
  /// In en, this message translates to:
  /// **'Select your State'**
  String get selectState;

  /// Exam date label
  ///
  /// In en, this message translates to:
  /// **'Exam Date'**
  String get examDate;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Full exam mode
  ///
  /// In en, this message translates to:
  /// **'Full Exam'**
  String get fullExam;

  /// Drive mode for hands-free learning
  ///
  /// In en, this message translates to:
  /// **'Drive Mode'**
  String get driveMode;

  /// Review due questions
  ///
  /// In en, this message translates to:
  /// **'Review Due'**
  String get reviewDue;

  /// Daily goal label
  ///
  /// In en, this message translates to:
  /// **'Your Goal'**
  String get yourGoal;

  /// Number of questions
  ///
  /// In en, this message translates to:
  /// **'{count} Questions'**
  String questions(int count);

  /// Single question
  ///
  /// In en, this message translates to:
  /// **'{count} Question'**
  String question(int count);

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Select German state
  ///
  /// In en, this message translates to:
  /// **'Select your Bundesland'**
  String get selectBundesland;

  /// Exam date question
  ///
  /// In en, this message translates to:
  /// **'When is your exam?'**
  String get whenIsExam;

  /// Start button
  ///
  /// In en, this message translates to:
  /// **'Let\'s Start!'**
  String get letsStart;

  /// Exam mode title
  ///
  /// In en, this message translates to:
  /// **'Exam Mode'**
  String get examMode;

  /// Question counter
  ///
  /// In en, this message translates to:
  /// **'Question {current}/{total}'**
  String questionLabel(int current, int total);

  /// Next question button
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get nextQuestion;

  /// Finish exam button
  ///
  /// In en, this message translates to:
  /// **'Finish Exam'**
  String get finishExam;

  /// Exam completion message
  ///
  /// In en, this message translates to:
  /// **'Exam Completed!'**
  String get examCompleted;

  /// Show Arabic translation button
  ///
  /// In en, this message translates to:
  /// **'Show Arabic Translation'**
  String get showArabic;

  /// Hide Arabic translation button
  ///
  /// In en, this message translates to:
  /// **'Hide Arabic'**
  String get hideArabic;

  /// No questions available message
  ///
  /// In en, this message translates to:
  /// **'No questions loaded.'**
  String get noQuestions;

  /// Glossary dictionary
  ///
  /// In en, this message translates to:
  /// **'Glossary'**
  String get glossary;

  /// General settings section
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// Dark mode toggle label
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Audio settings section
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// TTS speaking speed setting
  ///
  /// In en, this message translates to:
  /// **'Speaking Speed'**
  String get speakingSpeed;

  /// Data settings section
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// Reset progress button
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get resetProgress;

  /// Reset progress confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all your progress? This action cannot be undone.'**
  String get resetProgressMessage;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Progress reset success message
  ///
  /// In en, this message translates to:
  /// **'Progress reset successfully'**
  String get progressReset;

  /// Legal section
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// Privacy policy title
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// German for privacy
  ///
  /// In en, this message translates to:
  /// **'Datenschutz'**
  String get datenschutz;

  /// Terms of use title
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// German for terms of use
  ///
  /// In en, this message translates to:
  /// **'Nutzungsbedingungen'**
  String get nutzungsbedingungen;

  /// Intellectual property title
  ///
  /// In en, this message translates to:
  /// **'Intellectual Property'**
  String get intellectualProperty;

  /// German for intellectual property
  ///
  /// In en, this message translates to:
  /// **'Geistiges Eigentum'**
  String get geistigesEigentum;

  /// Impressum title
  ///
  /// In en, this message translates to:
  /// **'Impressum'**
  String get impressum;

  /// Legal information label
  ///
  /// In en, this message translates to:
  /// **'Legal Information'**
  String get legalInformation;

  /// Print exam PDF button
  ///
  /// In en, this message translates to:
  /// **'Print Exam'**
  String get printExam;

  /// Search glossary placeholder
  ///
  /// In en, this message translates to:
  /// **'Search glossary...'**
  String get searchGlossary;

  /// Language selection subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language for studying'**
  String get chooseLanguage;

  /// Setup completion message
  ///
  /// In en, this message translates to:
  /// **'Setup Complete'**
  String get setupComplete;

  /// Tap to select prompt
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get tapToSelect;

  /// Complete all steps message
  ///
  /// In en, this message translates to:
  /// **'Please complete all steps'**
  String get completeAllSteps;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Daily reminder toggle label
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get dailyReminder;

  /// No description provided for @dailyReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Get reminded to study daily'**
  String get dailyReminderDescription;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reminderTime;

  /// No description provided for @reminderEnabled.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder enabled'**
  String get reminderEnabled;

  /// No description provided for @reminderDisabled.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder disabled'**
  String get reminderDisabled;

  /// No description provided for @reminderTimeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Reminder time updated'**
  String get reminderTimeUpdated;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get appVersion;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @rateAppDescription.
  ///
  /// In en, this message translates to:
  /// **'If you like the app, please rate it in the store'**
  String get rateAppDescription;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Light theme description
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get themeLightDesc;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Dark theme description
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get themeDarkDesc;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// System theme description
  ///
  /// In en, this message translates to:
  /// **'Follow system settings'**
  String get themeSystemDesc;

  /// Quit exam confirmation title
  ///
  /// In en, this message translates to:
  /// **'Quit Exam?'**
  String get quitExam;

  /// Quit exam warning message
  ///
  /// In en, this message translates to:
  /// **'Your progress will be lost.'**
  String get quitExamMessage;

  /// Stay in exam button
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// Quit exam button
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// Danger zone section title
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// Reset app data button
  ///
  /// In en, this message translates to:
  /// **'Reset App Data'**
  String get resetAppData;

  /// Reset app data warning
  ///
  /// In en, this message translates to:
  /// **'This will delete all app data and cannot be undone'**
  String get resetAppDataDescription;

  /// Factory reset confirmation title
  ///
  /// In en, this message translates to:
  /// **'Factory Reset?'**
  String get factoryReset;

  /// Factory reset warning message
  ///
  /// In en, this message translates to:
  /// **'This will delete ALL app data including:'**
  String get factoryResetMessage;

  /// All progress and answers label
  ///
  /// In en, this message translates to:
  /// **'All progress and answers'**
  String get allProgressAndAnswers;

  /// Study history label
  ///
  /// In en, this message translates to:
  /// **'Study history'**
  String get studyHistory;

  /// Streaks label
  ///
  /// In en, this message translates to:
  /// **'Streaks'**
  String get streaks;

  /// Cannot be undone warning
  ///
  /// In en, this message translates to:
  /// **'This action CANNOT be undone!'**
  String get cannotBeUndone;

  /// Reset everything button
  ///
  /// In en, this message translates to:
  /// **'Reset Everything'**
  String get resetEverything;

  /// App data reset success message
  ///
  /// In en, this message translates to:
  /// **'App data reset successfully'**
  String get appDataResetSuccess;

  /// Error resetting app message
  ///
  /// In en, this message translates to:
  /// **'Error resetting app:'**
  String get errorResettingApp;

  /// Total learned questions label
  ///
  /// In en, this message translates to:
  /// **'Total Learned'**
  String get totalLearned;

  /// Of questions label
  ///
  /// In en, this message translates to:
  /// **'of 310 questions'**
  String get ofQuestions;

  /// Dashboard tab label
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Learn tab label
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learn;

  /// No description provided for @explainWithAi.
  ///
  /// In en, this message translates to:
  /// **'Explain with AI'**
  String get explainWithAi;

  /// No description provided for @upgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradeToPro;

  /// No description provided for @unlockAiTutor.
  ///
  /// In en, this message translates to:
  /// **'Unlock AI Tutor'**
  String get unlockAiTutor;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @upgradeToProMessage.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro to unlock AI Tutor and get personalized explanations for all questions.'**
  String get upgradeToProMessage;

  /// No description provided for @aiTutorDailyLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You have used AI Tutor 3 times today. Subscribe to Pro for unlimited usage.'**
  String get aiTutorDailyLimitReached;

  /// No description provided for @aiExplanation.
  ///
  /// In en, this message translates to:
  /// **'AI Explanation'**
  String get aiExplanation;

  /// No description provided for @aiThinking.
  ///
  /// In en, this message translates to:
  /// **'AI is thinking...'**
  String get aiThinking;

  /// No description provided for @errorLoadingExplanation.
  ///
  /// In en, this message translates to:
  /// **'Error loading explanation'**
  String get errorLoadingExplanation;

  /// Button to review all exam answers
  ///
  /// In en, this message translates to:
  /// **'Review Answers'**
  String get reviewAnswers;

  /// Filter toggle to show only wrong answers
  ///
  /// In en, this message translates to:
  /// **'Mistakes Only'**
  String get mistakesOnly;

  /// No description provided for @aboutMultiLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Multi-language Mastery'**
  String get aboutMultiLanguageTitle;

  /// No description provided for @aboutMultiLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'6 Sprachen'**
  String get aboutMultiLanguageSubtitle;

  /// No description provided for @aboutMultiLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Solving the language barrier. Learn in the language you understand best.'**
  String get aboutMultiLanguageDescription;

  /// No description provided for @aboutTranslationTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Context Translation'**
  String get aboutTranslationTitle;

  /// No description provided for @aboutTranslationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Präzise Übersetzung'**
  String get aboutTranslationSubtitle;

  /// No description provided for @aboutTranslationDescription.
  ///
  /// In en, this message translates to:
  /// **'Solving misunderstanding. Accurate translations of complex legal terms to ensure correct understanding.'**
  String get aboutTranslationDescription;

  /// No description provided for @aboutAiTutorTitle.
  ///
  /// In en, this message translates to:
  /// **'Eagle AI Tutor'**
  String get aboutAiTutorTitle;

  /// No description provided for @aboutAiTutorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'KI-Assistent'**
  String get aboutAiTutorSubtitle;

  /// No description provided for @aboutAiTutorDescription.
  ///
  /// In en, this message translates to:
  /// **'Solving confusion. Instant explanations for every question in your native language to help you understand mistakes and correct them.'**
  String get aboutAiTutorDescription;

  /// No description provided for @aboutPaperExamTitle.
  ///
  /// In en, this message translates to:
  /// **'Print & Practice Offline'**
  String get aboutPaperExamTitle;

  /// No description provided for @aboutPaperExamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real Exam Simulation'**
  String get aboutPaperExamSubtitle;

  /// No description provided for @aboutPaperExamDescription.
  ///
  /// In en, this message translates to:
  /// **'Generate official PDF exams. Train with pen and paper like the real test.'**
  String get aboutPaperExamDescription;

  /// No description provided for @aboutDevelopedWith.
  ///
  /// In en, this message translates to:
  /// **'Developed with ❤️'**
  String get aboutDevelopedWith;

  /// No description provided for @aboutRateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get aboutRateUs;

  /// No description provided for @aboutSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get aboutSupport;

  /// No description provided for @aboutWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get aboutWebsite;

  /// No description provided for @aboutLoadingVersion.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get aboutLoadingVersion;

  /// No description provided for @aboutRoadmapTitle.
  ///
  /// In en, this message translates to:
  /// **'The Future'**
  String get aboutRoadmapTitle;

  /// No description provided for @aboutRoadmapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Die Zukunft'**
  String get aboutRoadmapSubtitle;

  /// No description provided for @aboutRoadmapVoiceCoach.
  ///
  /// In en, this message translates to:
  /// **'AI Voice Coach'**
  String get aboutRoadmapVoiceCoach;

  /// No description provided for @aboutRoadmapVoiceCoachDesc.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation Training'**
  String get aboutRoadmapVoiceCoachDesc;

  /// No description provided for @aboutRoadmapLiveBattles.
  ///
  /// In en, this message translates to:
  /// **'Live Battles'**
  String get aboutRoadmapLiveBattles;

  /// No description provided for @aboutRoadmapLiveBattlesDesc.
  ///
  /// In en, this message translates to:
  /// **'Multiplayer Mode'**
  String get aboutRoadmapLiveBattlesDesc;

  /// No description provided for @aboutRoadmapBureaucracyBot.
  ///
  /// In en, this message translates to:
  /// **'Bureaucracy Bot'**
  String get aboutRoadmapBureaucracyBot;

  /// No description provided for @aboutRoadmapBureaucracyBotDesc.
  ///
  /// In en, this message translates to:
  /// **'Form Helper'**
  String get aboutRoadmapBureaucracyBotDesc;

  /// No description provided for @glossaryTapToFlip.
  ///
  /// In en, this message translates to:
  /// **'Tap to flip'**
  String get glossaryTapToFlip;

  /// No description provided for @glossaryPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get glossaryPrevious;

  /// No description provided for @glossaryNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get glossaryNext;

  /// No description provided for @glossaryPronounce.
  ///
  /// In en, this message translates to:
  /// **'Pronounce'**
  String get glossaryPronounce;

  /// No description provided for @glossaryListView.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get glossaryListView;

  /// No description provided for @glossaryFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get glossaryFlashcards;

  /// No description provided for @glossarySearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search glossary...'**
  String get glossarySearchPlaceholder;

  /// No description provided for @glossaryNoTermsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No terms available'**
  String get glossaryNoTermsAvailable;

  /// No description provided for @glossaryNoTermsFound.
  ///
  /// In en, this message translates to:
  /// **'No terms found'**
  String get glossaryNoTermsFound;

  /// No description provided for @glossaryDefinition.
  ///
  /// In en, this message translates to:
  /// **'Definition:'**
  String get glossaryDefinition;

  /// No description provided for @glossaryExample.
  ///
  /// In en, this message translates to:
  /// **'Example:'**
  String get glossaryExample;

  /// No description provided for @glossaryShowInQuestionContext.
  ///
  /// In en, this message translates to:
  /// **'Show in Question Context'**
  String get glossaryShowInQuestionContext;

  /// No description provided for @glossaryRelatedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions related to'**
  String get glossaryRelatedQuestions;

  /// No description provided for @statsOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get statsOverview;

  /// No description provided for @statsProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get statsProgress;

  /// No description provided for @statsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get statsToday;

  /// No description provided for @statsMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get statsMastered;

  /// No description provided for @statsMinutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get statsMinutes;

  /// No description provided for @statsQuestions.
  ///
  /// In en, this message translates to:
  /// **'questions'**
  String get statsQuestions;

  /// No description provided for @statsDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get statsDays;

  /// No description provided for @statsDay.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get statsDay;

  /// No description provided for @statsProgressCharts.
  ///
  /// In en, this message translates to:
  /// **'Progress Charts'**
  String get statsProgressCharts;

  /// No description provided for @statsWeeklyStudyTime.
  ///
  /// In en, this message translates to:
  /// **'Weekly Study Time'**
  String get statsWeeklyStudyTime;

  /// No description provided for @statsExamScoresOverTime.
  ///
  /// In en, this message translates to:
  /// **'Exam Scores Over Time'**
  String get statsExamScoresOverTime;

  /// No description provided for @statsCategoryMastery.
  ///
  /// In en, this message translates to:
  /// **'Category Mastery'**
  String get statsCategoryMastery;

  /// No description provided for @statsSrsInsights.
  ///
  /// In en, this message translates to:
  /// **'SRS Insights'**
  String get statsSrsInsights;

  /// No description provided for @statsDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get statsDue;

  /// No description provided for @statsEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get statsEasy;

  /// No description provided for @statsNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statsNew;

  /// No description provided for @statsHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get statsHard;

  /// No description provided for @statsGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get statsGood;

  /// No description provided for @statsExamPerformance.
  ///
  /// In en, this message translates to:
  /// **'Exam Performance'**
  String get statsExamPerformance;

  /// No description provided for @statsAverageScore.
  ///
  /// In en, this message translates to:
  /// **'Average Score'**
  String get statsAverageScore;

  /// No description provided for @statsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statsCompleted;

  /// No description provided for @statsBestScore.
  ///
  /// In en, this message translates to:
  /// **'Best Score'**
  String get statsBestScore;

  /// No description provided for @statsPassRate.
  ///
  /// In en, this message translates to:
  /// **'Pass Rate'**
  String get statsPassRate;

  /// No description provided for @statsStudyHabits.
  ///
  /// In en, this message translates to:
  /// **'Study Habits'**
  String get statsStudyHabits;

  /// No description provided for @statsAvgSession.
  ///
  /// In en, this message translates to:
  /// **'Avg Session'**
  String get statsAvgSession;

  /// No description provided for @statsMin.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get statsMin;

  /// No description provided for @statsActiveDays.
  ///
  /// In en, this message translates to:
  /// **'Active Days'**
  String get statsActiveDays;

  /// No description provided for @statsSmartInsights.
  ///
  /// In en, this message translates to:
  /// **'Smart Insights'**
  String get statsSmartInsights;

  /// No description provided for @statsRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get statsRecommendations;

  /// No description provided for @statsRecentExams.
  ///
  /// In en, this message translates to:
  /// **'Recent Exams'**
  String get statsRecentExams;

  /// No description provided for @statsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get statsRefresh;

  /// No description provided for @statsInsightDueQuestions.
  ///
  /// In en, this message translates to:
  /// **'You have {count} questions due for review'**
  String statsInsightDueQuestions(int count);

  /// No description provided for @statsInsightFocusNew.
  ///
  /// In en, this message translates to:
  /// **'Focus on new questions to boost your progress'**
  String get statsInsightFocusNew;

  /// No description provided for @statsInsightKeepPracticing.
  ///
  /// In en, this message translates to:
  /// **'Keep practicing! Average score: {score}%'**
  String statsInsightKeepPracticing(String score);

  /// No description provided for @statsInsightExcellentStreak.
  ///
  /// In en, this message translates to:
  /// **'Excellent! You\'re maintaining a study habit ({days} days)'**
  String statsInsightExcellentStreak(int days);

  /// No description provided for @statsInsightKeepStudying.
  ///
  /// In en, this message translates to:
  /// **'Keep studying to get smart insights'**
  String get statsInsightKeepStudying;

  /// No description provided for @statsScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get statsScore;

  /// Paper exam feature title
  ///
  /// In en, this message translates to:
  /// **'Paper Exam'**
  String get paperExam;

  /// Paper exam simulation title
  ///
  /// In en, this message translates to:
  /// **'Paper Exam Simulation'**
  String get paperExamSimulation;

  /// Paper exam description
  ///
  /// In en, this message translates to:
  /// **'Generate a realistic PDF exam for printing'**
  String get paperExamDescription;

  /// Configuration section title
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get paperExamConfiguration;

  /// State selection label
  ///
  /// In en, this message translates to:
  /// **'State / Bundesland'**
  String get paperExamState;

  /// General state option
  ///
  /// In en, this message translates to:
  /// **'General (No State)'**
  String get paperExamGeneral;

  /// Include solutions switch label
  ///
  /// In en, this message translates to:
  /// **'Include Answer Key'**
  String get paperExamIncludeSolutions;

  /// Include solutions description in German
  ///
  /// In en, this message translates to:
  /// **'Lösungsschlüssel beifügen'**
  String get paperExamIncludeSolutionsDesc;

  /// Shuffle questions switch label
  ///
  /// In en, this message translates to:
  /// **'Shuffle Questions'**
  String get paperExamShuffle;

  /// Shuffle questions description in German
  ///
  /// In en, this message translates to:
  /// **'Fragen mischen'**
  String get paperExamShuffleDesc;

  /// Generate PDF button
  ///
  /// In en, this message translates to:
  /// **'Generate PDF 📄'**
  String get paperExamGenerate;

  /// Generating PDF message
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get paperExamGenerating;

  /// PDF generated success message
  ///
  /// In en, this message translates to:
  /// **'PDF Generated Successfully!'**
  String get paperExamPdfGenerated;

  /// Print button
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get paperExamPrint;

  /// Share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get paperExamShare;

  /// Scan QR code button
  ///
  /// In en, this message translates to:
  /// **'Scan to Correct'**
  String get paperExamScan;

  /// Scan exam screen title
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanExamTitle;

  /// Scan exam instructions
  ///
  /// In en, this message translates to:
  /// **'Position QR Code from PDF within frame'**
  String get scanExamInstructions;

  /// Scan exam processing message
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get scanExamProcessing;

  /// Paper correction screen title
  ///
  /// In en, this message translates to:
  /// **'Paper Exam Correction'**
  String get paperCorrectionTitle;

  /// Paper correction instructions
  ///
  /// In en, this message translates to:
  /// **'Enter your answers from the paper'**
  String get paperCorrectionInstructions;

  /// Answered count label
  ///
  /// In en, this message translates to:
  /// **'answered'**
  String get paperCorrectionAnswered;

  /// Finish and grade button
  ///
  /// In en, this message translates to:
  /// **'Finish & Grade'**
  String get paperCorrectionFinish;

  /// Incomplete answers dialog title
  ///
  /// In en, this message translates to:
  /// **'Incomplete Answers'**
  String get paperCorrectionIncompleteTitle;

  /// Incomplete answers dialog message
  ///
  /// In en, this message translates to:
  /// **'You have not answered all questions. Continue anyway?'**
  String get paperCorrectionIncompleteMessage;

  /// Paper exam widget description
  ///
  /// In en, this message translates to:
  /// **'Print & Practice Offline'**
  String get paperExamWidgetDescription;

  /// Paper exam tutorial title
  ///
  /// In en, this message translates to:
  /// **'How to Use Paper Exam'**
  String get paperExamTutorialTitle;

  /// Tutorial step 1 title
  ///
  /// In en, this message translates to:
  /// **'Create PDF'**
  String get paperExamTutorialStep1Title;

  /// Tutorial step 1 description
  ///
  /// In en, this message translates to:
  /// **'Tap \"Paper Exam\", choose settings (state, shuffle, include solutions), then tap \"Generate PDF\"'**
  String get paperExamTutorialStep1Desc;

  /// Tutorial step 2 title
  ///
  /// In en, this message translates to:
  /// **'Print PDF'**
  String get paperExamTutorialStep2Title;

  /// Tutorial step 2 description
  ///
  /// In en, this message translates to:
  /// **'Print the PDF on paper. There will be a QR Code at the top of the page'**
  String get paperExamTutorialStep2Desc;

  /// Tutorial step 3 title
  ///
  /// In en, this message translates to:
  /// **'Answer on Paper'**
  String get paperExamTutorialStep3Title;

  /// Tutorial step 3 description
  ///
  /// In en, this message translates to:
  /// **'Answer the questions using pen and paper, just like the real exam'**
  String get paperExamTutorialStep3Desc;

  /// Tutorial step 4 title
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get paperExamTutorialStep4Title;

  /// Tutorial step 4 description
  ///
  /// In en, this message translates to:
  /// **'Open the app, go to \"Paper Exam\", tap \"Scan to Correct\", and scan the QR Code from the paper'**
  String get paperExamTutorialStep4Desc;

  /// Tutorial step 5 title
  ///
  /// In en, this message translates to:
  /// **'Enter Answers & Get Score'**
  String get paperExamTutorialStep5Title;

  /// Tutorial step 5 description
  ///
  /// In en, this message translates to:
  /// **'Quickly enter your answers from the paper into the app and get your score instantly'**
  String get paperExamTutorialStep5Desc;

  /// Topic selection screen title
  ///
  /// In en, this message translates to:
  /// **'Choose Topic'**
  String get chooseTopic;

  /// Political system topic title
  ///
  /// In en, this message translates to:
  /// **'Political System'**
  String get topicSystem;

  /// Basic rights topic title
  ///
  /// In en, this message translates to:
  /// **'Basic Rights'**
  String get topicRights;

  /// German history topic title
  ///
  /// In en, this message translates to:
  /// **'German History'**
  String get topicHistory;

  /// Society topic title
  ///
  /// In en, this message translates to:
  /// **'Society'**
  String get topicSociety;

  /// Germany in Europe topic title
  ///
  /// In en, this message translates to:
  /// **'Germany in Europe'**
  String get topicEurope;

  /// Work and education topic title
  ///
  /// In en, this message translates to:
  /// **'Work & Education'**
  String get topicWelfare;

  /// Number of learned questions
  ///
  /// In en, this message translates to:
  /// **'Learned'**
  String get learned;

  /// Number of correct answers
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// Topic questions screen title
  ///
  /// In en, this message translates to:
  /// **'Topic Questions'**
  String get topicQuestions;

  /// Message when no questions available for topic
  ///
  /// In en, this message translates to:
  /// **'No questions available for this topic'**
  String get noQuestionsForTopic;

  /// Message when all topic questions are reviewed
  ///
  /// In en, this message translates to:
  /// **'Great job! All questions reviewed. 🎉'**
  String get allTopicsReviewed;

  /// Topics section title
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get topics;

  /// Topic statistics section title
  ///
  /// In en, this message translates to:
  /// **'Topic Statistics'**
  String get topicStatistics;

  /// Total questions label
  ///
  /// In en, this message translates to:
  /// **'Total Questions'**
  String get totalQuestions;

  /// Questions answered label
  ///
  /// In en, this message translates to:
  /// **'Questions Answered'**
  String get questionsAnswered;

  /// Accuracy rate label
  ///
  /// In en, this message translates to:
  /// **'Accuracy Rate'**
  String get accuracyRate;

  /// Most studied topic label
  ///
  /// In en, this message translates to:
  /// **'Most Studied Topic'**
  String get mostStudiedTopic;

  /// Least studied topic label
  ///
  /// In en, this message translates to:
  /// **'Least Studied Topic'**
  String get leastStudiedTopic;

  /// Available features section title
  ///
  /// In en, this message translates to:
  /// **'Available Features'**
  String get availableFeatures;

  /// Free plan label
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freePlan;

  /// Access to all questions feature
  ///
  /// In en, this message translates to:
  /// **'Access to all questions'**
  String get accessToAllQuestions;

  /// Ads if available feature
  ///
  /// In en, this message translates to:
  /// **'Ads (if available)'**
  String get adsIfAvailable;

  /// One exam per day feature
  ///
  /// In en, this message translates to:
  /// **'One exam per day'**
  String get oneExamPerDay;

  /// Pro subscription premium label
  ///
  /// In en, this message translates to:
  /// **'Pro Subscription (Premium)'**
  String get proSubscriptionPremium;

  /// Unlimited AI Tutor feature
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI Tutor'**
  String get unlimitedAiTutor;

  /// AI Tutor free plan limit
  ///
  /// In en, this message translates to:
  /// **'3 times/day'**
  String get aiTutorFreeLimit;

  /// AI Tutor unlimited for Pro
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get aiTutorUnlimited;

  /// PDF exam generation feature
  ///
  /// In en, this message translates to:
  /// **'PDF Exam Generation'**
  String get pdfExamGeneration;

  /// No ads feature
  ///
  /// In en, this message translates to:
  /// **'No Ads'**
  String get noAds;

  /// Advanced success statistics feature
  ///
  /// In en, this message translates to:
  /// **'Advanced Success Statistics'**
  String get advancedSuccessStatistics;

  /// Monthly subscription period
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Renews monthly description
  ///
  /// In en, this message translates to:
  /// **'Renews monthly'**
  String get renewsMonthly;

  /// Three months subscription period
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get threeMonths;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// Most popular for exams description
  ///
  /// In en, this message translates to:
  /// **'Most Popular for Exams'**
  String get mostPopularForExams;

  /// Lifetime subscription period
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lifetime;

  /// One-time payment description
  ///
  /// In en, this message translates to:
  /// **'One-time payment'**
  String get oneTimePayment;

  /// Best value badge
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValue;

  /// Active subscription status
  ///
  /// In en, this message translates to:
  /// **'Active Subscription'**
  String get activeSubscription;

  /// Upgrade for additional features description
  ///
  /// In en, this message translates to:
  /// **'Upgrade for additional features'**
  String get upgradeForAdditionalFeatures;

  /// No description provided for @dailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'🔥 Daily Challenge'**
  String get dailyChallenge;

  /// No description provided for @challengeCompleted.
  ///
  /// In en, this message translates to:
  /// **'Challenge Completed!'**
  String get challengeCompleted;

  /// No description provided for @challengeExcellent.
  ///
  /// In en, this message translates to:
  /// **'🌟 Excellent! You\'re a master!'**
  String get challengeExcellent;

  /// No description provided for @challengeGreat.
  ///
  /// In en, this message translates to:
  /// **'🎉 Great job! Keep it up!'**
  String get challengeGreat;

  /// No description provided for @challengeGood.
  ///
  /// In en, this message translates to:
  /// **'👍 Good effort! Practice makes perfect!'**
  String get challengeGood;

  /// No description provided for @challengeKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'💪 Keep going! Every mistake is a lesson!'**
  String get challengeKeepGoing;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get points;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @exitChallenge.
  ///
  /// In en, this message translates to:
  /// **'Exit Challenge?'**
  String get exitChallenge;

  /// No description provided for @exitChallengeMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit? Your progress will be lost.'**
  String get exitChallengeMessage;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @errorLoadingQuestions.
  ///
  /// In en, this message translates to:
  /// **'Error loading questions'**
  String get errorLoadingQuestions;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noQuestionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No questions available'**
  String get noQuestionsAvailable;

  /// No description provided for @completedToday.
  ///
  /// In en, this message translates to:
  /// **'Completed!'**
  String get completedToday;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @errorLoadingExam.
  ///
  /// In en, this message translates to:
  /// **'Error loading exam'**
  String get errorLoadingExam;

  /// No description provided for @topicState.
  ///
  /// In en, this message translates to:
  /// **'State Questions'**
  String get topicState;

  /// No description provided for @selectStateFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a state first'**
  String get selectStateFirst;

  /// No description provided for @aboutDailyChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'🔥 Daily Challenge'**
  String get aboutDailyChallengeTitle;

  /// No description provided for @aboutDailyChallengeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Motivating Daily Learning'**
  String get aboutDailyChallengeSubtitle;

  /// No description provided for @aboutDailyChallengeDescription.
  ///
  /// In en, this message translates to:
  /// **'Test yourself daily with 10 random questions and earn points for each correct answer. Celebrate your achievements with fun visual effects!'**
  String get aboutDailyChallengeDescription;

  /// Voice exam mode title
  ///
  /// In en, this message translates to:
  /// **'🎤 Voice Exam (Pro)'**
  String get voiceExam;

  /// Play audio button
  ///
  /// In en, this message translates to:
  /// **'🔊 Play Audio'**
  String get playAudio;

  /// Playing audio status
  ///
  /// In en, this message translates to:
  /// **'Playing...'**
  String get playing;

  /// Voice exam mode feature name
  ///
  /// In en, this message translates to:
  /// **'Voice Exam Mode'**
  String get voiceExamMode;

  /// AI coaching card title
  ///
  /// In en, this message translates to:
  /// **'🎯 AI Study Coach'**
  String get aiCoachTitle;

  /// AI coaching card subtitle
  ///
  /// In en, this message translates to:
  /// **'Your personalized study plan'**
  String get aiCoachSubtitle;

  /// Weakest topics label
  ///
  /// In en, this message translates to:
  /// **'Weakest Topics:'**
  String get aiCoachWeakTopics;

  /// Error message for AI coaching
  ///
  /// In en, this message translates to:
  /// **'Failed to load coaching advice'**
  String get aiCoachError;

  /// Message when no user data is available for AI coaching
  ///
  /// In en, this message translates to:
  /// **'Start answering questions to get personalized study advice!'**
  String get aiCoachNoData;

  /// Button to start focused practice on weak topics
  ///
  /// In en, this message translates to:
  /// **'Start Focused Practice'**
  String get startFocusedPractice;

  /// Unlock AI coach button for free users
  ///
  /// In en, this message translates to:
  /// **'Unlock AI Coach'**
  String get unlockAiCoach;

  /// AI Study Coach feature name
  ///
  /// In en, this message translates to:
  /// **'AI Study Coach'**
  String get aiStudyCoach;

  /// Sync in progress message
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// Sync error message
  ///
  /// In en, this message translates to:
  /// **'Sync failed. Working offline.'**
  String get syncError;

  /// Active license status message
  ///
  /// In en, this message translates to:
  /// **'Pro License Active'**
  String get licenseActive;

  /// Invalid license code message
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code'**
  String get invalidCode;

  /// Guest user label
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// Pro member badge text
  ///
  /// In en, this message translates to:
  /// **'PRO MEMBER'**
  String get proMember;

  /// Upgrade account title
  ///
  /// In en, this message translates to:
  /// **'Upgrade Your Account'**
  String get upgradeAccount;

  /// Subscribe to Pro button text
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Pro'**
  String get subscribeToPro;

  /// Or activate license button text
  ///
  /// In en, this message translates to:
  /// **'Or Activate License'**
  String get orActivateLicense;

  /// Activate license dialog title
  ///
  /// In en, this message translates to:
  /// **'Activate License'**
  String get activateLicense;

  /// Enter license key prompt
  ///
  /// In en, this message translates to:
  /// **'Enter your license key'**
  String get enterLicenseKey;

  /// License key input label
  ///
  /// In en, this message translates to:
  /// **'License Key'**
  String get licenseKey;

  /// Federal state selection label
  ///
  /// In en, this message translates to:
  /// **'Federal State'**
  String get federalState;

  /// Readiness score label
  ///
  /// In en, this message translates to:
  /// **'Readiness'**
  String get readiness;

  /// Mastery questions label
  ///
  /// In en, this message translates to:
  /// **'Mastery'**
  String get mastery;

  /// Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Smart AI study alerts feature name
  ///
  /// In en, this message translates to:
  /// **'🎯 Smart AI Study Alerts'**
  String get smartAiStudyAlerts;

  /// Cloud backup and sync feature name
  ///
  /// In en, this message translates to:
  /// **'☁️ Cloud Backup & Sync'**
  String get cloudBackupSync;

  /// Advanced readiness index feature name
  ///
  /// In en, this message translates to:
  /// **'📊 Advanced Readiness Index'**
  String get advancedReadinessIndex;

  /// Organization support feature name
  ///
  /// In en, this message translates to:
  /// **'🏢 Organization Support'**
  String get organizationSupport;

  /// Placeholder for name input field
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// Toggle label for allowing name sync to database
  ///
  /// In en, this message translates to:
  /// **'Save name to database'**
  String get saveNameToDatabase;

  /// Message when name is saved
  ///
  /// In en, this message translates to:
  /// **'Name saved'**
  String get nameSaved;

  /// Message when name is removed
  ///
  /// In en, this message translates to:
  /// **'Name removed'**
  String get nameRemoved;

  /// Button text for picking profile picture
  ///
  /// In en, this message translates to:
  /// **'Pick Profile Picture'**
  String get pickProfilePicture;

  /// Feature name for profile name customization
  ///
  /// In en, this message translates to:
  /// **'👤 Customize Profile Name'**
  String get customizeProfileName;

  /// Text indicating name can be changed once (free plan)
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get nameChangeOnce;

  /// Text indicating unlimited name changes (pro plan)
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get nameChangeUnlimited;

  /// Title for leaderboard card
  ///
  /// In en, this message translates to:
  /// **'🏆 Top Learners'**
  String get topLearners;

  /// Message when no leaderboard data is available
  ///
  /// In en, this message translates to:
  /// **'No leaderboard data available'**
  String get noLeaderboardData;

  /// Label indicating current user in leaderboard
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// Shared progress feature name for Pro subscription
  ///
  /// In en, this message translates to:
  /// **'🔄 Shared Progress Across Devices'**
  String get sharedProgressFeature;

  /// Description of shared progress feature
  ///
  /// In en, this message translates to:
  /// **'Study on up to 3 devices with synchronized progress. Your learning data is automatically synced across all your devices.'**
  String get sharedProgressDescription;

  /// Benefit of shared progress feature
  ///
  /// In en, this message translates to:
  /// **'Access your progress from any device'**
  String get sharedProgressBenefit;

  /// Device limit for Pro subscription
  ///
  /// In en, this message translates to:
  /// **'Up to 3 devices'**
  String get deviceLimit;

  /// Automatic sync feature
  ///
  /// In en, this message translates to:
  /// **'Automatic sync'**
  String get automaticSync;

  /// Progress restore feature
  ///
  /// In en, this message translates to:
  /// **'Restore progress if you lose your device'**
  String get progressRestore;

  /// Tooltip shown when progress is being synced
  ///
  /// In en, this message translates to:
  /// **'Syncing progress...'**
  String get syncingProgress;

  /// Tooltip shown when progress sync is complete
  ///
  /// In en, this message translates to:
  /// **'Progress synced'**
  String get progressSynced;

  /// Tooltip for cloud sync indicator
  ///
  /// In en, this message translates to:
  /// **'Cloud sync'**
  String get cloudSync;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'ru',
        'tr',
        'uk'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
