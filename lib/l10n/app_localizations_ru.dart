// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Eagle Test: Germany';

  @override
  String get startExam => 'Начать экзамен';

  @override
  String get quickPractice => 'Быстрая практика';

  @override
  String get stats => 'Статистика';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Тема';

  @override
  String daysLeft(int count) {
    return 'Осталось $count дней';
  }

  @override
  String get dailyGoal => 'Ежедневная цель';

  @override
  String get streak => 'Дней подряд';

  @override
  String get reviewMistakes => 'Просмотреть ошибки';

  @override
  String get next => 'Далее';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get passed => 'Пройдено!';

  @override
  String get failed => 'Не пройдено';

  @override
  String get selectState => 'Выберите вашу землю';

  @override
  String get examDate => 'Дата экзамена';

  @override
  String get save => 'Сохранить';

  @override
  String get fullExam => 'Полный экзамен';

  @override
  String get driveMode => 'Режим вождения';

  @override
  String get reviewDue => 'Требуется обзор';

  @override
  String get yourGoal => 'Ваша цель';

  @override
  String questions(int count) {
    return '$count вопросов';
  }

  @override
  String question(int count) {
    return '$count вопрос';
  }

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String get selectBundesland => 'Выберите вашу землю';

  @override
  String get whenIsExam => 'Когда ваш экзамен?';

  @override
  String get letsStart => 'Начнем!';

  @override
  String get examMode => 'Режим экзамена';

  @override
  String questionLabel(int current, int total) {
    return 'Вопрос $current/$total';
  }

  @override
  String get nextQuestion => 'Следующий вопрос';

  @override
  String get finishExam => 'Завершить экзамен';

  @override
  String get examCompleted => 'Экзамен завершен!';

  @override
  String get showArabic => 'Показать арабский перевод';

  @override
  String get hideArabic => 'Скрыть арабский';

  @override
  String get noQuestions => 'Вопросы не загружены.';

  @override
  String get glossary => 'Словарь';

  @override
  String get general => 'Общие';

  @override
  String get darkMode => 'Темный режим';

  @override
  String get audio => 'Аудио';

  @override
  String get speakingSpeed => 'Скорость речи';

  @override
  String get data => 'Данные';

  @override
  String get resetProgress => 'Сбросить прогресс';

  @override
  String get resetProgressMessage =>
      'Вы уверены, что хотите сбросить весь ваш прогресс? Это действие нельзя отменить.';

  @override
  String get cancel => 'Отмена';

  @override
  String get progressReset => 'Прогресс успешно сброшен';

  @override
  String get legal => 'Юридическое';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get datenschutz => 'Защита данных';

  @override
  String get termsOfUse => 'Условия использования';

  @override
  String get nutzungsbedingungen => 'Условия использования';

  @override
  String get intellectualProperty => 'Интеллектуальная собственность';

  @override
  String get geistigesEigentum => 'Интеллектуальная собственность';

  @override
  String get impressum => 'Юридическая информация';

  @override
  String get legalInformation => 'Юридическая информация';

  @override
  String get printExam => 'Печать экзамена';

  @override
  String get searchGlossary => 'Поиск в словаре...';

  @override
  String get chooseLanguage => 'Выберите предпочитаемый язык для обучения';

  @override
  String get setupComplete => 'Готово!';

  @override
  String get tapToSelect => 'Нажмите для выбора';

  @override
  String get completeAllSteps => 'Пожалуйста, завершите все шаги';

  @override
  String get back => 'Назад';

  @override
  String get notifications => 'Уведомления';

  @override
  String get dailyReminder => 'Ежедневное напоминание';

  @override
  String get dailyReminderDescription =>
      'Получайте напоминание об учебе ежедневно';

  @override
  String get reminderTime => 'Время';

  @override
  String get reminderEnabled => 'Ежедневное напоминание включено';

  @override
  String get reminderDisabled => 'Ежедневное напоминание отключено';

  @override
  String get reminderTimeUpdated => 'Время напоминания обновлено';

  @override
  String get about => 'О приложении';

  @override
  String get appVersion => 'Версия';

  @override
  String get rateApp => 'Оценить приложение';

  @override
  String get rateAppDescription =>
      'Если вам нравится приложение, пожалуйста, оцените его в магазине';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeLightDesc => 'Светлый режим';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeDarkDesc => 'Тёмный режим';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeSystemDesc => 'Следовать настройкам системы';

  @override
  String get quitExam => 'Выйти из экзамена?';

  @override
  String get quitExamMessage => 'Ваш прогресс будет потерян.';

  @override
  String get stay => 'Остаться';

  @override
  String get quit => 'Выйти';

  @override
  String get dangerZone => 'Опасная зона';

  @override
  String get resetAppData => 'Сбросить данные приложения';

  @override
  String get resetAppDataDescription =>
      'Это удалит все данные приложения и не может быть отменено';

  @override
  String get factoryReset => 'Сброс к заводским настройкам?';

  @override
  String get factoryResetMessage =>
      'Это удалит ВСЕ данные приложения, включая:';

  @override
  String get allProgressAndAnswers => 'Весь прогресс и ответы';

  @override
  String get studyHistory => 'История обучения';

  @override
  String get streaks => 'Серии';

  @override
  String get cannotBeUndone => 'Это действие НЕ МОЖЕТ быть отменено!';

  @override
  String get resetEverything => 'Сбросить все';

  @override
  String get appDataResetSuccess => 'Данные приложения успешно сброшены';

  @override
  String get errorResettingApp => 'Ошибка при сбросе приложения:';

  @override
  String get totalLearned => 'Всего изучено';

  @override
  String get ofQuestions => 'из 310 вопросов';

  @override
  String get dashboard => 'Панель управления';

  @override
  String get learn => 'Учиться';

  @override
  String get explainWithAi => 'Объяснить с ИИ';

  @override
  String get upgradeToPro => 'Обновить до Pro';

  @override
  String get unlockAiTutor => 'Разблокировать ИИ-репетитора';

  @override
  String get upgrade => 'Обновить';

  @override
  String get upgradeToProMessage =>
      'Обновитесь до Pro, чтобы разблокировать ИИ-репетитора и получить персонализированные объяснения для всех вопросов.';

  @override
  String get aiTutorDailyLimitReached =>
      'Вы использовали ИИ-репетитора 3 раза сегодня. Подпишитесь на Pro для неограниченного использования.';

  @override
  String get aiExplanation => 'Объяснение ИИ';

  @override
  String get aiThinking => 'ИИ думает...';

  @override
  String get errorLoadingExplanation => 'Ошибка загрузки объяснения';

  @override
  String get reviewAnswers => 'Проверить ответы';

  @override
  String get mistakesOnly => 'Только ошибки';

  @override
  String get aboutMultiLanguageTitle => 'Многоязычное мастерство';

  @override
  String get aboutMultiLanguageSubtitle => '6 Sprachen';

  @override
  String get aboutMultiLanguageDescription =>
      'Решение языкового барьера. Учитесь на языке, который вы лучше всего понимаете.';

  @override
  String get aboutTranslationTitle => 'Умный контекстный перевод';

  @override
  String get aboutTranslationSubtitle => 'Präzise Übersetzung';

  @override
  String get aboutTranslationDescription =>
      'Решение недопонимания. Точные переводы сложных юридических терминов для обеспечения правильного понимания.';

  @override
  String get aboutAiTutorTitle => 'Eagle AI Репетитор';

  @override
  String get aboutAiTutorSubtitle => 'KI-Assistent';

  @override
  String get aboutAiTutorDescription =>
      'Решение путаницы. Мгновенные объяснения для каждого вопроса на вашем родном языке, чтобы помочь вам понять ошибки и исправить их.';

  @override
  String get aboutPaperExamTitle => 'Печать и практика офлайн';

  @override
  String get aboutPaperExamSubtitle => 'Реальная симуляция экзамена';

  @override
  String get aboutPaperExamDescription =>
      'Создавайте официальные PDF-экзамены. Тренируйтесь с ручкой и бумагой, как на настоящем экзамене.';

  @override
  String get aboutDevelopedWith => 'Разработано с ❤️';

  @override
  String get aboutRateUs => 'Оцените нас';

  @override
  String get aboutSupport => 'Поддержка';

  @override
  String get aboutWebsite => 'Веб-сайт';

  @override
  String get aboutLoadingVersion => 'Загрузка...';

  @override
  String get aboutRoadmapTitle => 'Будущее';

  @override
  String get aboutRoadmapSubtitle => 'Die Zukunft';

  @override
  String get aboutRoadmapVoiceCoach => 'ИИ Голосовой Тренер';

  @override
  String get aboutRoadmapVoiceCoachDesc => 'Тренировка Произношения';

  @override
  String get aboutRoadmapLiveBattles => 'Живые Битвы';

  @override
  String get aboutRoadmapLiveBattlesDesc => 'Многопользовательский Режим';

  @override
  String get aboutRoadmapBureaucracyBot => 'Бот Бюрократии';

  @override
  String get aboutRoadmapBureaucracyBotDesc => 'Помощник Форм';

  @override
  String get glossaryTapToFlip => 'Нажмите, чтобы перевернуть';

  @override
  String get glossaryPrevious => 'Назад';

  @override
  String get glossaryNext => 'Далее';

  @override
  String get glossaryPronounce => 'Произнести';

  @override
  String get glossaryListView => 'Список';

  @override
  String get glossaryFlashcards => 'Карточки';

  @override
  String get glossarySearchPlaceholder => 'Поиск в словаре...';

  @override
  String get glossaryNoTermsAvailable => 'Термины недоступны';

  @override
  String get glossaryNoTermsFound => 'Термины не найдены';

  @override
  String get glossaryDefinition => 'Определение:';

  @override
  String get glossaryExample => 'Пример:';

  @override
  String get glossaryShowInQuestionContext => 'Показать в контексте вопроса';

  @override
  String get glossaryRelatedQuestions => 'Вопросы, связанные с';

  @override
  String get statsOverview => 'Обзор';

  @override
  String get statsProgress => 'Прогресс';

  @override
  String get statsToday => 'Сегодня';

  @override
  String get statsMastered => 'Изучено';

  @override
  String get statsMinutes => 'минут';

  @override
  String get statsQuestions => 'вопросов';

  @override
  String get statsDays => 'дней';

  @override
  String get statsDay => 'день';

  @override
  String get statsProgressCharts => 'Графики прогресса';

  @override
  String get statsWeeklyStudyTime => 'Еженедельное время учебы';

  @override
  String get statsExamScoresOverTime => 'Результаты экзаменов во времени';

  @override
  String get statsCategoryMastery => 'Освоение категорий';

  @override
  String get statsSrsInsights => 'SRS аналитика';

  @override
  String get statsDue => 'Просрочено';

  @override
  String get statsEasy => 'Легко';

  @override
  String get statsNew => 'Новое';

  @override
  String get statsHard => 'Сложно';

  @override
  String get statsGood => 'Хорошо';

  @override
  String get statsExamPerformance => 'Результаты экзаменов';

  @override
  String get statsAverageScore => 'Средний балл';

  @override
  String get statsCompleted => 'Завершено';

  @override
  String get statsBestScore => 'Лучший балл';

  @override
  String get statsPassRate => 'Процент сдачи';

  @override
  String get statsStudyHabits => 'Привычки к учебе';

  @override
  String get statsAvgSession => 'Сред. сессия';

  @override
  String get statsMin => 'мин';

  @override
  String get statsActiveDays => 'Активные дни';

  @override
  String get statsSmartInsights => 'Умная аналитика';

  @override
  String get statsRecommendations => 'Рекомендации';

  @override
  String get statsRecentExams => 'Последние экзамены';

  @override
  String get statsRefresh => 'Обновить';

  @override
  String statsInsightDueQuestions(int count) {
    return 'У вас $count вопросов, требующих повторения';
  }

  @override
  String get statsInsightFocusNew =>
      'Сосредоточьтесь на новых вопросах, чтобы повысить свой прогресс';

  @override
  String statsInsightKeepPracticing(String score) {
    return 'Продолжайте практиковаться! Средний балл: $score%';
  }

  @override
  String statsInsightExcellentStreak(int days) {
    return 'Отлично! Вы поддерживаете привычку к учебе ($days дней)';
  }

  @override
  String get statsInsightKeepStudying =>
      'Продолжайте учиться, чтобы получать умную аналитику';

  @override
  String get statsScore => 'Балл';

  @override
  String get paperExam => 'Бумажный экзамен';

  @override
  String get paperExamSimulation => 'Симуляция бумажного экзамена';

  @override
  String get paperExamDescription =>
      'Создайте реалистичный PDF-экзамен для печати';

  @override
  String get paperExamConfiguration => 'Конфигурация';

  @override
  String get paperExamState => 'Земля / Bundesland';

  @override
  String get paperExamGeneral => 'Общий (без земли)';

  @override
  String get paperExamIncludeSolutions => 'Включить ключ ответов';

  @override
  String get paperExamIncludeSolutionsDesc => 'Lösungsschlüssel beifügen';

  @override
  String get paperExamShuffle => 'Перемешать вопросы';

  @override
  String get paperExamShuffleDesc => 'Fragen mischen';

  @override
  String get paperExamGenerate => 'Создать PDF 📄';

  @override
  String get paperExamGenerating => 'Создание...';

  @override
  String get paperExamPdfGenerated => 'PDF успешно создан!';

  @override
  String get paperExamPrint => 'Печать';

  @override
  String get paperExamShare => 'Поделиться';

  @override
  String get paperExamScan => 'Сканировать для исправления';

  @override
  String get scanExamTitle => 'Сканировать QR-код';

  @override
  String get scanExamInstructions => 'Поместите QR-код из PDF в рамку';

  @override
  String get scanExamProcessing => 'Обработка...';

  @override
  String get paperCorrectionTitle => 'Исправление бумажного экзамена';

  @override
  String get paperCorrectionInstructions => 'Введите свои ответы с бумаги';

  @override
  String get paperCorrectionAnswered => 'отвечено';

  @override
  String get paperCorrectionFinish => 'Завершить и оценить';

  @override
  String get paperCorrectionIncompleteTitle => 'Неполные ответы';

  @override
  String get paperCorrectionIncompleteMessage =>
      'Вы ответили не на все вопросы. Все равно продолжить?';

  @override
  String get paperExamWidgetDescription => 'Печать и практика офлайн';

  @override
  String get paperExamTutorialTitle => 'Как использовать бумажный экзамен';

  @override
  String get paperExamTutorialStep1Title => 'Создать PDF';

  @override
  String get paperExamTutorialStep1Desc =>
      'Нажмите \"Бумажный экзамен\", выберите настройки (регион, перемешать вопросы, включить решения), затем нажмите \"Создать PDF\"';

  @override
  String get paperExamTutorialStep2Title => 'Печать PDF';

  @override
  String get paperExamTutorialStep2Desc =>
      'Распечатайте PDF на бумаге. Вверху страницы будет QR-код';

  @override
  String get paperExamTutorialStep3Title => 'Ответить на бумаге';

  @override
  String get paperExamTutorialStep3Desc =>
      'Ответьте на вопросы ручкой и бумагой, как на настоящем экзамене';

  @override
  String get paperExamTutorialStep4Title => 'Сканировать QR-код';

  @override
  String get paperExamTutorialStep4Desc =>
      'Откройте приложение, перейдите в \"Бумажный экзамен\", нажмите \"Сканировать для исправления\" и отсканируйте QR-код с бумаги';

  @override
  String get paperExamTutorialStep5Title => 'Ввести ответы и получить оценку';

  @override
  String get paperExamTutorialStep5Desc =>
      'Быстро введите свои ответы с бумаги в приложение и получите оценку мгновенно';

  @override
  String get chooseTopic => 'Выберите тему';

  @override
  String get topicSystem => 'Политическая система';

  @override
  String get topicRights => 'Основные права';

  @override
  String get topicHistory => 'Немецкая история';

  @override
  String get topicSociety => 'Общество';

  @override
  String get topicEurope => 'Германия в Европе';

  @override
  String get topicWelfare => 'Работа и образование';

  @override
  String get learned => 'Изучено';

  @override
  String get correct => 'Правильно';

  @override
  String get topicQuestions => 'Вопросы по теме';

  @override
  String get noQuestionsForTopic => 'Нет вопросов для этой темы';

  @override
  String get allTopicsReviewed => 'Отлично! Все вопросы просмотрены. 🎉';

  @override
  String get topics => 'Темы';

  @override
  String get topicStatistics => 'Статистика тем';

  @override
  String get totalQuestions => 'Всего вопросов';

  @override
  String get questionsAnswered => 'Отвеченные вопросы';

  @override
  String get accuracyRate => 'Точность';

  @override
  String get mostStudiedTopic => 'Наиболее изученная тема';

  @override
  String get leastStudiedTopic => 'Наименее изученная тема';

  @override
  String get availableFeatures => 'Доступные функции';

  @override
  String get freePlan => 'Бесплатно';

  @override
  String get accessToAllQuestions => 'Доступ ко всем вопросам';

  @override
  String get adsIfAvailable => 'Реклама (если есть)';

  @override
  String get oneExamPerDay => 'Один экзамен в день';

  @override
  String get proSubscriptionPremium => 'Pro Подписка (Premium)';

  @override
  String get unlimitedAiTutor => 'Неограниченный ИИ-репетитор';

  @override
  String get pdfExamGeneration => 'Создание PDF-экзамена';

  @override
  String get noAds => 'Без рекламы';

  @override
  String get advancedSuccessStatistics => 'Расширенная статистика успеха';

  @override
  String get monthly => 'Ежемесячно';

  @override
  String get renewsMonthly => 'Обновляется ежемесячно';

  @override
  String get threeMonths => '3 месяца';

  @override
  String get yearly => 'Годовой';

  @override
  String get mostPopularForExams => 'Самое популярное для экзаменов';

  @override
  String get lifetime => 'На всю жизнь';

  @override
  String get oneTimePayment => 'Одноразовый платеж';

  @override
  String get bestValue => 'Лучшая цена';

  @override
  String get activeSubscription => 'Активная подписка';

  @override
  String get upgradeForAdditionalFeatures =>
      'Обновите для дополнительных функций';

  @override
  String get dailyChallenge => '🔥 Ежедневный вызов';

  @override
  String get challengeCompleted => 'Вызов завершен!';

  @override
  String get challengeExcellent => '🌟 Отлично! Ты мастер!';

  @override
  String get challengeGreat => '🎉 Отличная работа! Продолжай!';

  @override
  String get challengeGood =>
      '👍 Хорошая попытка! Практика делает совершенным!';

  @override
  String get challengeKeepGoing => '💪 Продолжай! Каждая ошибка - это урок!';

  @override
  String get points => 'баллов';

  @override
  String get accuracy => 'Точность';

  @override
  String get time => 'Время';

  @override
  String get done => 'Готово';

  @override
  String get exitChallenge => 'Выйти из вызова?';

  @override
  String get exitChallengeMessage =>
      'Вы уверены, что хотите выйти? Ваш прогресс будет потерян.';

  @override
  String get exit => 'Выйти';

  @override
  String get previous => 'Предыдущий';

  @override
  String get finish => 'Завершить';

  @override
  String get loading => 'Загрузка...';

  @override
  String get errorLoadingQuestions => 'Ошибка загрузки вопросов';

  @override
  String get retry => 'Повторить';

  @override
  String get noQuestionsAvailable => 'Вопросы недоступны';

  @override
  String get completedToday => 'Завершено!';

  @override
  String get goBack => 'Назад';

  @override
  String get errorLoadingExam => 'Ошибка загрузки экзамена';

  @override
  String get topicState => 'Вопросы земли';

  @override
  String get selectStateFirst => 'Пожалуйста, сначала выберите землю';

  @override
  String get aboutDailyChallengeTitle => '🔥 Ежедневный вызов';

  @override
  String get aboutDailyChallengeSubtitle => 'Мотивирующее ежедневное обучение';

  @override
  String get aboutDailyChallengeDescription =>
      'Тестируйте себя ежедневно с 10 случайными вопросами и зарабатывайте очки за каждый правильный ответ. Празднуйте свои достижения с забавными визуальными эффектами!';
}
