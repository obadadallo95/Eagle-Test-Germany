// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Eagle Test: Germany';

  @override
  String get startExam => 'Почати екзамен';

  @override
  String get quickPractice => 'Швидка практика';

  @override
  String get stats => 'Статистика';

  @override
  String get settings => 'Налаштування';

  @override
  String get language => 'Мова';

  @override
  String get theme => 'Тема';

  @override
  String daysLeft(int count) {
    return 'Залишилося $count днів';
  }

  @override
  String get dailyGoal => 'Щоденна мета';

  @override
  String get streak => 'Днів поспіль';

  @override
  String get reviewMistakes => 'Переглянути помилки';

  @override
  String get next => 'Далі';

  @override
  String get confirm => 'Підтвердити';

  @override
  String get passed => 'Пройдено!';

  @override
  String get failed => 'Не пройдено';

  @override
  String get selectState => 'Виберіть вашу землю';

  @override
  String get examDate => 'Дата екзамену';

  @override
  String get save => 'Зберегти';

  @override
  String get fullExam => 'Повний екзамен';

  @override
  String get driveMode => 'Режим водіння';

  @override
  String get reviewDue => 'Огляд необхідний';

  @override
  String get yourGoal => 'Ваша мета';

  @override
  String questions(int count) {
    return '$count питань';
  }

  @override
  String question(int count) {
    return '$count питання';
  }

  @override
  String get welcome => 'Ласкаво просимо';

  @override
  String get selectBundesland => 'Виберіть вашу землю';

  @override
  String get whenIsExam => 'Коли ваш екзамен?';

  @override
  String get letsStart => 'Почнемо!';

  @override
  String get examMode => 'Режим екзамену';

  @override
  String questionLabel(int current, int total) {
    return 'Питання $current/$total';
  }

  @override
  String get nextQuestion => 'Наступне питання';

  @override
  String get finishExam => 'Завершити екзамен';

  @override
  String get examCompleted => 'Екзамен завершено!';

  @override
  String get showArabic => 'Показати арабський переклад';

  @override
  String get hideArabic => 'Приховати арабську';

  @override
  String get noQuestions => 'Питання не завантажено.';

  @override
  String get glossary => 'Словник';

  @override
  String get general => 'Загальне';

  @override
  String get darkMode => 'Темний режим';

  @override
  String get audio => 'Аудіо';

  @override
  String get speakingSpeed => 'Швидкість мовлення';

  @override
  String get data => 'Дані';

  @override
  String get resetProgress => 'Скинути прогрес';

  @override
  String get resetProgressMessage =>
      'Ви впевнені, що хочете скинути весь ваш прогрес? Цю дію неможливо скасувати.';

  @override
  String get cancel => 'Скасувати';

  @override
  String get progressReset => 'Прогрес успішно скинуто';

  @override
  String get legal => 'Юридичне';

  @override
  String get privacyPolicy => 'Політика конфіденційності';

  @override
  String get datenschutz => 'Захист даних';

  @override
  String get termsOfUse => 'Умови використання';

  @override
  String get nutzungsbedingungen => 'Умови використання';

  @override
  String get intellectualProperty => 'Інтелектуальна власність';

  @override
  String get geistigesEigentum => 'Інтелектуальна власність';

  @override
  String get impressum => 'Юридична інформація';

  @override
  String get legalInformation => 'Юридична інформація';

  @override
  String get printExam => 'Друкувати екзамен';

  @override
  String get searchGlossary => 'Пошук у словнику...';

  @override
  String get chooseLanguage => 'Виберіть мову для навчання';

  @override
  String get setupComplete => 'Готово!';

  @override
  String get tapToSelect => 'Натисніть для вибору';

  @override
  String get completeAllSteps => 'Будь ласка, завершіть усі кроки';

  @override
  String get back => 'Назад';

  @override
  String get notifications => 'Сповіщення';

  @override
  String get dailyReminder => 'Щоденне нагадування';

  @override
  String get dailyReminderDescription =>
      'Отримуйте нагадування про навчання щодня';

  @override
  String get reminderTime => 'Час';

  @override
  String get reminderEnabled => 'Щоденне нагадування увімкнено';

  @override
  String get reminderDisabled => 'Щоденне нагадування вимкнено';

  @override
  String get reminderTimeUpdated => 'Час нагадування оновлено';

  @override
  String get about => 'Про додаток';

  @override
  String get appVersion => 'Версія';

  @override
  String get rateApp => 'Оцінити додаток';

  @override
  String get rateAppDescription =>
      'Якщо вам подобається додаток, будь ласка, оцініть його в магазині';

  @override
  String get themeLight => 'Світла';

  @override
  String get themeLightDesc => 'Світлий режим';

  @override
  String get themeDark => 'Темна';

  @override
  String get themeDarkDesc => 'Темний режим';

  @override
  String get themeSystem => 'Системна';

  @override
  String get themeSystemDesc => 'Слідувати налаштуванням системи';

  @override
  String get quitExam => 'Вийти з екзамену?';

  @override
  String get quitExamMessage => 'Ваш прогрес буде втрачено.';

  @override
  String get stay => 'Залишитися';

  @override
  String get quit => 'Вийти';

  @override
  String get dangerZone => 'Небезпечна зона';

  @override
  String get resetAppData => 'Скинути дані додатку';

  @override
  String get resetAppDataDescription =>
      'Це видалить всі дані додатку і не може бути скасовано';

  @override
  String get factoryReset => 'Скинути до заводських налаштувань?';

  @override
  String get factoryResetMessage => 'Це видалить ВСІ дані додатку, включаючи:';

  @override
  String get allProgressAndAnswers => 'Весь прогрес і відповіді';

  @override
  String get studyHistory => 'Історія навчання';

  @override
  String get streaks => 'Серії';

  @override
  String get cannotBeUndone => 'Цю дію НЕ МОЖНА скасувати!';

  @override
  String get resetEverything => 'Скинути все';

  @override
  String get appDataResetSuccess => 'Дані додатку успішно скинуто';

  @override
  String get errorResettingApp => 'Помилка при скиданні додатку:';

  @override
  String get totalLearned => 'Всього вивчено';

  @override
  String get ofQuestions => 'з 310 питань';

  @override
  String get dashboard => 'Панель керування';

  @override
  String get learn => 'Вчитися';

  @override
  String get explainWithAi => 'Пояснити з ШІ';

  @override
  String get upgradeToPro => 'Оновити до Pro';

  @override
  String get unlockAiTutor => 'Розблокувати ШІ-репетитора';

  @override
  String get upgrade => 'Оновити';

  @override
  String get upgradeToProMessage =>
      'Оновіться до Pro, щоб розблокувати ШІ-репетитора та отримати персоналізовані пояснення для всіх питань.';

  @override
  String get aiTutorDailyLimitReached =>
      'Ви використали ШІ-репетитора 3 рази сьогодні. Підпишіться на Pro для необмеженого використання.';

  @override
  String get aiExplanation => 'Пояснення ШІ';

  @override
  String get aiThinking => 'ШІ думає...';

  @override
  String get errorLoadingExplanation => 'Помилка завантаження пояснення';

  @override
  String get reviewAnswers => 'Перевірити відповіді';

  @override
  String get mistakesOnly => 'Тільки помилки';

  @override
  String get aboutMultiLanguageTitle => 'Багатомовна майстерність';

  @override
  String get aboutMultiLanguageSubtitle => '6 Sprachen';

  @override
  String get aboutMultiLanguageDescription =>
      'Вирішення мовного бар\'єру. Навчайтеся мовою, яку ви найкраще розумієте.';

  @override
  String get aboutTranslationTitle => 'Розумний контекстний переклад';

  @override
  String get aboutTranslationSubtitle => 'Präzise Übersetzung';

  @override
  String get aboutTranslationDescription =>
      'Вирішення непорозуміння. Точні переклади складних юридичних термінів для забезпечення правильного розуміння.';

  @override
  String get aboutAiTutorTitle => 'Eagle AI Репетитор';

  @override
  String get aboutAiTutorSubtitle => 'KI-Assistent';

  @override
  String get aboutAiTutorDescription =>
      'Вирішення плутанини. Миттєві пояснення для кожного питання вашою рідною мовою, щоб допомогти вам зрозуміти помилки та виправити їх.';

  @override
  String get aboutPaperExamTitle => 'Друк та практика офлайн';

  @override
  String get aboutPaperExamSubtitle => 'Реальна симуляція іспиту';

  @override
  String get aboutPaperExamDescription =>
      'Створюйте офіційні PDF-іспити. Тренуйтеся з ручкою та папером, як на справжньому іспиті.';

  @override
  String get aboutDevelopedWith => 'Розроблено з ❤️';

  @override
  String get aboutRateUs => 'Оцініть нас';

  @override
  String get aboutSupport => 'Підтримка';

  @override
  String get aboutWebsite => 'Веб-сайт';

  @override
  String get aboutLoadingVersion => 'Завантаження...';

  @override
  String get aboutRoadmapTitle => 'Майбутнє';

  @override
  String get aboutRoadmapSubtitle => 'Die Zukunft';

  @override
  String get aboutRoadmapVoiceCoach => 'ШІ Голосовий Тренер';

  @override
  String get aboutRoadmapVoiceCoachDesc => 'Тренування Вимови';

  @override
  String get aboutRoadmapLiveBattles => 'Живі Битви';

  @override
  String get aboutRoadmapLiveBattlesDesc => 'Багатокористувацький Режим';

  @override
  String get aboutRoadmapBureaucracyBot => 'Бот Бюрократії';

  @override
  String get aboutRoadmapBureaucracyBotDesc => 'Помічник Форм';

  @override
  String get glossaryTapToFlip => 'Натисніть, щоб перевернути';

  @override
  String get glossaryPrevious => 'Назад';

  @override
  String get glossaryNext => 'Далі';

  @override
  String get glossaryPronounce => 'Вимовити';

  @override
  String get glossaryListView => 'Список';

  @override
  String get glossaryFlashcards => 'Картки';

  @override
  String get glossarySearchPlaceholder => 'Пошук у словнику...';

  @override
  String get glossaryNoTermsAvailable => 'Терміни недоступні';

  @override
  String get glossaryNoTermsFound => 'Терміни не знайдено';

  @override
  String get glossaryDefinition => 'Визначення:';

  @override
  String get glossaryExample => 'Приклад:';

  @override
  String get glossaryShowInQuestionContext => 'Показати в контексті питання';

  @override
  String get glossaryRelatedQuestions => 'Питання, пов\'язані з';

  @override
  String get statsOverview => 'Огляд';

  @override
  String get statsProgress => 'Прогрес';

  @override
  String get statsToday => 'Сьогодні';

  @override
  String get statsMastered => 'Вивчено';

  @override
  String get statsMinutes => 'хвилин';

  @override
  String get statsQuestions => 'питань';

  @override
  String get statsDays => 'днів';

  @override
  String get statsDay => 'день';

  @override
  String get statsProgressCharts => 'Графіки прогресу';

  @override
  String get statsWeeklyStudyTime => 'Тижневий час навчання';

  @override
  String get statsExamScoresOverTime => 'Результати іспитів у часі';

  @override
  String get statsCategoryMastery => 'Опанування категорій';

  @override
  String get statsSrsInsights => 'SRS аналітика';

  @override
  String get statsDue => 'Прострочено';

  @override
  String get statsEasy => 'Легко';

  @override
  String get statsNew => 'Нове';

  @override
  String get statsHard => 'Складно';

  @override
  String get statsGood => 'Добре';

  @override
  String get statsExamPerformance => 'Результати іспитів';

  @override
  String get statsAverageScore => 'Середній бал';

  @override
  String get statsCompleted => 'Завершено';

  @override
  String get statsBestScore => 'Найкращий бал';

  @override
  String get statsPassRate => 'Відсоток складання';

  @override
  String get statsStudyHabits => 'Звички до навчання';

  @override
  String get statsAvgSession => 'Серед. сесія';

  @override
  String get statsMin => 'хв';

  @override
  String get statsActiveDays => 'Активні дні';

  @override
  String get statsSmartInsights => 'Розумна аналітика';

  @override
  String get statsRecommendations => 'Рекомендації';

  @override
  String get statsRecentExams => 'Останні іспити';

  @override
  String get statsRefresh => 'Оновити';

  @override
  String statsInsightDueQuestions(int count) {
    return 'У вас $count питань, що потребують повторення';
  }

  @override
  String get statsInsightFocusNew =>
      'Зосередьтеся на нових питаннях, щоб підвищити свій прогрес';

  @override
  String statsInsightKeepPracticing(String score) {
    return 'Продовжуйте практикуватися! Середній бал: $score%';
  }

  @override
  String statsInsightExcellentStreak(int days) {
    return 'Відмінно! Ви підтримуєте звичку до навчання ($days днів)';
  }

  @override
  String get statsInsightKeepStudying =>
      'Продовжуйте вчитися, щоб отримувати розумну аналітику';

  @override
  String get statsScore => 'Бал';

  @override
  String get paperExam => 'Паперовий іспит';

  @override
  String get paperExamSimulation => 'Симуляція паперового іспиту';

  @override
  String get paperExamDescription =>
      'Створіть реалістичний PDF-іспит для друку';

  @override
  String get paperExamConfiguration => 'Конфігурація';

  @override
  String get paperExamState => 'Земля / Bundesland';

  @override
  String get paperExamGeneral => 'Загальний (без землі)';

  @override
  String get paperExamIncludeSolutions => 'Включити ключ відповідей';

  @override
  String get paperExamIncludeSolutionsDesc => 'Lösungsschlüssel beifügen';

  @override
  String get paperExamShuffle => 'Перемішати питання';

  @override
  String get paperExamShuffleDesc => 'Fragen mischen';

  @override
  String get paperExamGenerate => 'Створити PDF 📄';

  @override
  String get paperExamGenerating => 'Створення...';

  @override
  String get paperExamPdfGenerated => 'PDF успішно створено!';

  @override
  String get paperExamPrint => 'Друк';

  @override
  String get paperExamShare => 'Поділитися';

  @override
  String get paperExamScan => 'Сканувати для виправлення';

  @override
  String get scanExamTitle => 'Сканувати QR-код';

  @override
  String get scanExamInstructions => 'Помістіть QR-код з PDF у рамку';

  @override
  String get scanExamProcessing => 'Обробка...';

  @override
  String get paperCorrectionTitle => 'Виправлення паперового іспиту';

  @override
  String get paperCorrectionInstructions => 'Введіть свої відповіді з паперу';

  @override
  String get paperCorrectionAnswered => 'відповіли';

  @override
  String get paperCorrectionFinish => 'Завершити та оцінити';

  @override
  String get paperCorrectionIncompleteTitle => 'Неповні відповіді';

  @override
  String get paperCorrectionIncompleteMessage =>
      'Ви відповіли не на всі питання. Все одно продовжити?';

  @override
  String get paperExamWidgetDescription => 'Друк та практика офлайн';

  @override
  String get paperExamTutorialTitle => 'Як використовувати паперовий іспит';

  @override
  String get paperExamTutorialStep1Title => 'Створити PDF';

  @override
  String get paperExamTutorialStep1Desc =>
      'Натисніть \"Паперовий іспит\", виберіть налаштування (регіон, перемішати питання, включити рішення), потім натисніть \"Створити PDF\"';

  @override
  String get paperExamTutorialStep2Title => 'Друк PDF';

  @override
  String get paperExamTutorialStep2Desc =>
      'Роздрукуйте PDF на папері. Зверху сторінки буде QR-код';

  @override
  String get paperExamTutorialStep3Title => 'Відповісти на папері';

  @override
  String get paperExamTutorialStep3Desc =>
      'Відповідайте на питання ручкою та папером, як на справжньому іспиті';

  @override
  String get paperExamTutorialStep4Title => 'Сканувати QR-код';

  @override
  String get paperExamTutorialStep4Desc =>
      'Відкрийте додаток, перейдіть до \"Паперовий іспит\", натисніть \"Сканувати для виправлення\" та відскануйте QR-код з паперу';

  @override
  String get paperExamTutorialStep5Title =>
      'Ввести відповіді та отримати оцінку';

  @override
  String get paperExamTutorialStep5Desc =>
      'Швидко введіть свої відповіді з паперу в додаток та отримайте оцінку миттєво';

  @override
  String get chooseTopic => 'Виберіть тему';

  @override
  String get topicSystem => 'Політична система';

  @override
  String get topicRights => 'Основні права';

  @override
  String get topicHistory => 'Німецька історія';

  @override
  String get topicSociety => 'Суспільство';

  @override
  String get topicEurope => 'Німеччина в Європі';

  @override
  String get topicWelfare => 'Робота та освіта';

  @override
  String get learned => 'Вивчено';

  @override
  String get correct => 'Правильно';

  @override
  String get topicQuestions => 'Питання за темою';

  @override
  String get noQuestionsForTopic => 'Немає питань для цієї теми';

  @override
  String get allTopicsReviewed => 'Чудово! Всі питання переглянуто. 🎉';

  @override
  String get topics => 'Теми';

  @override
  String get topicStatistics => 'Статистика тем';

  @override
  String get totalQuestions => 'Всього питань';

  @override
  String get questionsAnswered => 'Відповіді на питання';

  @override
  String get accuracyRate => 'Точність';

  @override
  String get mostStudiedTopic => 'Найбільш вивчена тема';

  @override
  String get leastStudiedTopic => 'Найменш вивчена тема';

  @override
  String get availableFeatures => 'Доступні функції';

  @override
  String get freePlan => 'Безкоштовно';

  @override
  String get accessToAllQuestions => 'Доступ до всіх питань';

  @override
  String get adsIfAvailable => 'Реклама (якщо є)';

  @override
  String get oneExamPerDay => 'Один іспит на день';

  @override
  String get proSubscriptionPremium => 'Pro Підписка (Premium)';

  @override
  String get unlimitedAiTutor => 'Необмежений ШІ-репетитор';

  @override
  String get pdfExamGeneration => 'Створення PDF-іспиту';

  @override
  String get noAds => 'Без реклами';

  @override
  String get advancedSuccessStatistics => 'Розширена статистика успіху';

  @override
  String get monthly => 'Щомісячно';

  @override
  String get renewsMonthly => 'Оновлюється щомісяця';

  @override
  String get threeMonths => '3 місяці';

  @override
  String get yearly => 'Щорічно';

  @override
  String get mostPopularForExams => 'Найпопулярніше для іспитів';

  @override
  String get lifetime => 'На все життя';

  @override
  String get oneTimePayment => 'Одноразовий платіж';

  @override
  String get bestValue => 'Найкраща ціна';

  @override
  String get activeSubscription => 'Активна підписка';

  @override
  String get upgradeForAdditionalFeatures => 'Оновіть для додаткових функцій';

  @override
  String get dailyChallenge => '🔥 Щоденний виклик';

  @override
  String get challengeCompleted => 'Виклик завершено!';

  @override
  String get challengeExcellent => '🌟 Відмінно! Ти майстер!';

  @override
  String get challengeGreat => '🎉 Чудова робота! Продовжуй!';

  @override
  String get challengeGood => '👍 Добра спроба! Практика робить досконалим!';

  @override
  String get challengeKeepGoing => '💪 Продовжуй! Кожна помилка - це урок!';

  @override
  String get points => 'балів';

  @override
  String get accuracy => 'Точність';

  @override
  String get time => 'Час';

  @override
  String get done => 'Готово';

  @override
  String get exitChallenge => 'Вийти з виклику?';

  @override
  String get exitChallengeMessage =>
      'Ви впевнені, що хочете вийти? Ваш прогрес буде втрачено.';

  @override
  String get exit => 'Вийти';

  @override
  String get previous => 'Попереднє';

  @override
  String get finish => 'Завершити';

  @override
  String get loading => 'Завантаження...';

  @override
  String get errorLoadingQuestions => 'Помилка завантаження питань';

  @override
  String get retry => 'Спробувати знову';

  @override
  String get noQuestionsAvailable => 'Питання недоступні';

  @override
  String get completedToday => 'Завершено!';

  @override
  String get goBack => 'Назад';

  @override
  String get errorLoadingExam => 'Помилка завантаження іспиту';

  @override
  String get topicState => 'Питання землі';

  @override
  String get selectStateFirst => 'Будь ласка, спочатку виберіть землю';

  @override
  String get aboutDailyChallengeTitle => '🔥 Щоденний виклик';

  @override
  String get aboutDailyChallengeSubtitle => 'Мотивуюче щоденне навчання';

  @override
  String get aboutDailyChallengeDescription =>
      'Тестуйте себе щодня з 10 випадковими питаннями та заробляйте бали за кожну правильну відповідь. Святкуйте свої досягнення з веселими візуальними ефектами!';
}
