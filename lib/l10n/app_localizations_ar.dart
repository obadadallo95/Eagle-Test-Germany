// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Eagle Test: Germany';

  @override
  String get startExam => 'ابدأ الامتحان';

  @override
  String get quickPractice => 'تمرين سريع';

  @override
  String get stats => 'الإحصائيات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String daysLeft(int count) {
    return 'باقي $count يوم';
  }

  @override
  String get dailyGoal => 'الهدف اليومي';

  @override
  String get streak => 'التتابع';

  @override
  String get reviewMistakes => 'مراجعة الأخطاء';

  @override
  String get next => 'التالي';

  @override
  String get confirm => 'تأكيد';

  @override
  String get passed => 'ناجح!';

  @override
  String get failed => 'لم تنجح';

  @override
  String get selectState => 'اختر المقاطعة';

  @override
  String get examDate => 'موعد الامتحان';

  @override
  String get save => 'حفظ';

  @override
  String get fullExam => 'امتحان كامل';

  @override
  String get driveMode => 'وضع القيادة';

  @override
  String get reviewDue => 'مراجعة مستحقة';

  @override
  String get yourGoal => 'هدفك اليوم';

  @override
  String questions(int count) {
    return '$count أسئلة';
  }

  @override
  String question(int count) {
    return '$count سؤال';
  }

  @override
  String get welcome => 'مرحباً';

  @override
  String get selectBundesland => 'اختر ولايتك';

  @override
  String get whenIsExam => 'متى موعد امتحانك؟';

  @override
  String get letsStart => 'لنبدأ!';

  @override
  String get examMode => 'وضع الامتحان';

  @override
  String questionLabel(int current, int total) {
    return 'السؤال $current/$total';
  }

  @override
  String get nextQuestion => 'السؤال التالي';

  @override
  String get finishExam => 'إنهاء الامتحان';

  @override
  String get examCompleted => 'تم إكمال الامتحان!';

  @override
  String get showArabic => 'إظهار الترجمة العربية';

  @override
  String get hideArabic => 'إخفاء العربية';

  @override
  String get noQuestions => 'لم يتم تحميل أي أسئلة.';

  @override
  String get glossary => 'القاموس';

  @override
  String get general => 'عام';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get audio => 'الصوت';

  @override
  String get speakingSpeed => 'سرعة الكلام';

  @override
  String get data => 'البيانات';

  @override
  String get resetProgress => 'إعادة تعيين التقدم';

  @override
  String get resetProgressMessage =>
      'هل أنت متأكد من أنك تريد إعادة تعيين جميع تقدمك؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get progressReset => 'تم إعادة تعيين التقدم بنجاح';

  @override
  String get legal => 'قانوني';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get datenschutz => 'حماية البيانات';

  @override
  String get termsOfUse => 'شروط الاستخدام';

  @override
  String get nutzungsbedingungen => 'شروط الاستخدام';

  @override
  String get intellectualProperty => 'حقوق الملكية الفكرية';

  @override
  String get geistigesEigentum => 'الملكية الفكرية';

  @override
  String get impressum => 'معلومات قانونية';

  @override
  String get legalInformation => 'معلومات قانونية';

  @override
  String get printExam => 'طباعة الامتحان';

  @override
  String get searchGlossary => 'ابحث في القاموس...';

  @override
  String get chooseLanguage => 'اختر لغتك المفضلة للدراسة';

  @override
  String get setupComplete => 'تم الإعداد بنجاح';

  @override
  String get tapToSelect => 'اضغط للاختيار';

  @override
  String get completeAllSteps => 'يرجى إكمال جميع الخطوات';

  @override
  String get back => 'السابق';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get dailyReminder => 'تذكير يومي';

  @override
  String get dailyReminderDescription => 'احصل على تذكير للدراسة يومياً';

  @override
  String get reminderTime => 'الوقت';

  @override
  String get reminderEnabled => 'تم تفعيل التذكير اليومي';

  @override
  String get reminderDisabled => 'تم إلغاء التذكير اليومي';

  @override
  String get reminderTimeUpdated => 'تم تحديث وقت التذكير';

  @override
  String get about => 'حول التطبيق';

  @override
  String get appVersion => 'الإصدار';

  @override
  String get rateApp => 'قيم التطبيق';

  @override
  String get rateAppDescription => 'إذا أعجبك التطبيق، يرجى تقييمه في المتجر';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeLightDesc => 'وضع فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeDarkDesc => 'وضع داكن';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeSystemDesc => 'يتبع إعدادات النظام';

  @override
  String get quitExam => 'إنهاء الامتحان؟';

  @override
  String get quitExamMessage => 'سيتم فقدان تقدمك.';

  @override
  String get stay => 'البقاء';

  @override
  String get quit => 'إنهاء';

  @override
  String get dangerZone => 'منطقة الخطر';

  @override
  String get resetAppData => 'إعادة تعيين بيانات التطبيق';

  @override
  String get resetAppDataDescription =>
      'سيؤدي هذا إلى حذف جميع بيانات التطبيق ولا يمكن التراجع عنه';

  @override
  String get factoryReset => 'إعادة تعيين المصنع؟';

  @override
  String get factoryResetMessage =>
      'سيؤدي هذا إلى حذف جميع بيانات التطبيق بما في ذلك:';

  @override
  String get allProgressAndAnswers => 'جميع التقدم والإجابات';

  @override
  String get studyHistory => 'سجل الدراسة';

  @override
  String get streaks => 'الأيام المتتالية';

  @override
  String get cannotBeUndone => 'لا يمكن التراجع عن هذا الإجراء!';

  @override
  String get resetEverything => 'إعادة تعيين كل شيء';

  @override
  String get appDataResetSuccess => 'تم إعادة تعيين بيانات التطبيق بنجاح';

  @override
  String get errorResettingApp => 'خطأ في إعادة تعيين التطبيق:';

  @override
  String get totalLearned => 'إجمالي المتعلم';

  @override
  String get ofQuestions => 'من 310 سؤال';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get learn => 'التعلم';

  @override
  String get explainWithAi => 'شرح بالذكاء الاصطناعي';

  @override
  String get upgradeToPro => 'ترقية إلى Pro';

  @override
  String get unlockAiTutor => 'فتح معلم الذكاء الاصطناعي';

  @override
  String get upgrade => 'ترقية';

  @override
  String get upgradeToProMessage =>
      'قم بالترقية إلى Pro لفتح معلم الذكاء الاصطناعي والحصول على شروحات مخصصة لجميع الأسئلة.';

  @override
  String get aiTutorDailyLimitReached =>
      'لقد استخدمت المساعد الذكي 3 مرات اليوم. اشترك في Pro للحصول على استخدام غير محدود.';

  @override
  String get aiExplanation => 'شرح الذكاء الاصطناعي';

  @override
  String get aiThinking => 'الذكاء الاصطناعي يفكر...';

  @override
  String get errorLoadingExplanation => 'خطأ في تحميل الشرح';

  @override
  String get reviewAnswers => 'مراجعة الإجابات';

  @override
  String get mistakesOnly => 'الأخطاء فقط';

  @override
  String get aboutMultiLanguageTitle => 'دعم 6 لغات';

  @override
  String get aboutMultiLanguageSubtitle => '6 Sprachen';

  @override
  String get aboutMultiLanguageDescription =>
      'حل مشكلة حاجز اللغة. تعلم باللغة التي تفهمها بشكل أفضل.';

  @override
  String get aboutTranslationTitle => 'ترجمة ذكية';

  @override
  String get aboutTranslationSubtitle => 'Präzise Übersetzung';

  @override
  String get aboutTranslationDescription =>
      'حل مشكلة سوء الفهم. ترجمات دقيقة للمصطلحات القانونية المعقدة لضمان الفهم الصحيح.';

  @override
  String get aboutAiTutorTitle => 'Eagle AI Tutor';

  @override
  String get aboutAiTutorSubtitle => 'KI-Assistent';

  @override
  String get aboutAiTutorDescription =>
      'حل مشكلة عدم الفهم. شروحات فورية لكل سؤال بلغتك الأم لمساعدتك على فهم الأخطاء وتصحيحها.';

  @override
  String get aboutPaperExamTitle => 'طباعة وممارسة بدون إنترنت';

  @override
  String get aboutPaperExamSubtitle => 'محاكاة الامتحان الحقيقي';

  @override
  String get aboutPaperExamDescription =>
      'قم بإنشاء امتحانات PDF رسمية. تدرب بالقلم والورق كما في الامتحان الحقيقي.';

  @override
  String get aboutDevelopedWith => 'مطور بـ ❤️';

  @override
  String get aboutRateUs => 'قيمنا';

  @override
  String get aboutSupport => 'الدعم';

  @override
  String get aboutWebsite => 'الموقع';

  @override
  String get aboutLoadingVersion => 'جاري التحميل...';

  @override
  String get aboutRoadmapTitle => 'المستقبل';

  @override
  String get aboutRoadmapSubtitle => 'Die Zukunft';

  @override
  String get aboutRoadmapVoiceCoach => 'مدرب الصوت بالذكاء الاصطناعي';

  @override
  String get aboutRoadmapVoiceCoachDesc => 'تدريب النطق';

  @override
  String get aboutRoadmapLiveBattles => 'معارك مباشرة';

  @override
  String get aboutRoadmapLiveBattlesDesc => 'وضع متعدد اللاعبين';

  @override
  String get aboutRoadmapBureaucracyBot => 'بوت البيروقراطية';

  @override
  String get aboutRoadmapBureaucracyBotDesc => 'مساعد النماذج';

  @override
  String get glossaryTapToFlip => 'اضغط للقلب';

  @override
  String get glossaryPrevious => 'السابق';

  @override
  String get glossaryNext => 'التالي';

  @override
  String get glossaryPronounce => 'نطق';

  @override
  String get glossaryListView => 'قائمة';

  @override
  String get glossaryFlashcards => 'بطاقات';

  @override
  String get glossarySearchPlaceholder => 'ابحث في القاموس...';

  @override
  String get glossaryNoTermsAvailable => 'لا توجد مصطلحات';

  @override
  String get glossaryNoTermsFound => 'لم يتم العثور على مصطلحات';

  @override
  String get glossaryDefinition => 'التعريف:';

  @override
  String get glossaryExample => 'مثال:';

  @override
  String get glossaryShowInQuestionContext => 'عرض في سياق السؤال';

  @override
  String get glossaryRelatedQuestions => 'الأسئلة المرتبطة بـ';

  @override
  String get statsOverview => 'نظرة عامة';

  @override
  String get statsProgress => 'التقدم';

  @override
  String get statsToday => 'اليوم';

  @override
  String get statsMastered => 'متعلم';

  @override
  String get statsMinutes => 'دقيقة';

  @override
  String get statsQuestions => 'سؤال';

  @override
  String get statsDays => 'أيام';

  @override
  String get statsDay => 'يوم';

  @override
  String get statsProgressCharts => 'مخططات التقدم';

  @override
  String get statsWeeklyStudyTime => 'وقت الدراسة الأسبوعي';

  @override
  String get statsExamScoresOverTime => 'نتائج الامتحانات عبر الزمن';

  @override
  String get statsCategoryMastery => 'إتقان الفئات';

  @override
  String get statsSrsInsights => 'رؤى SRS';

  @override
  String get statsDue => 'مستحقة';

  @override
  String get statsEasy => 'سهلة';

  @override
  String get statsNew => 'جديدة';

  @override
  String get statsHard => 'صعبة';

  @override
  String get statsGood => 'جيدة';

  @override
  String get statsExamPerformance => 'أداء الامتحانات';

  @override
  String get statsAverageScore => 'متوسط النتيجة';

  @override
  String get statsCompleted => 'مكتمل';

  @override
  String get statsBestScore => 'أفضل نتيجة';

  @override
  String get statsPassRate => 'معدل النجاح';

  @override
  String get statsStudyHabits => 'عادات الدراسة';

  @override
  String get statsAvgSession => 'متوسط الجلسة';

  @override
  String get statsMin => 'دقيقة';

  @override
  String get statsActiveDays => 'أيام نشطة';

  @override
  String get statsSmartInsights => 'رؤى ذكية';

  @override
  String get statsRecommendations => 'توصيات';

  @override
  String get statsRecentExams => 'الامتحانات الأخيرة';

  @override
  String get statsRefresh => 'تحديث';

  @override
  String statsInsightDueQuestions(int count) {
    return 'لديك $count سؤال مستحق للمراجعة';
  }

  @override
  String get statsInsightFocusNew => 'ركز على الأسئلة الجديدة لزيادة تقدمك';

  @override
  String statsInsightKeepPracticing(String score) {
    return 'استمر في الممارسة! النتيجة المتوسطة $score%';
  }

  @override
  String statsInsightExcellentStreak(int days) {
    return 'ممتاز! أنت تحافظ على عادة الدراسة ($days أيام)';
  }

  @override
  String get statsInsightKeepStudying => 'استمر في الدراسة للحصول على رؤى ذكية';

  @override
  String get statsScore => 'النتيجة';

  @override
  String get paperExam => 'امتحان ورقي';

  @override
  String get paperExamSimulation => 'محاكاة امتحان ورقي';

  @override
  String get paperExamDescription => 'قم بإنشاء امتحان PDF واقعي للطباعة';

  @override
  String get paperExamConfiguration => 'الإعدادات';

  @override
  String get paperExamState => 'الولاية / Bundesland';

  @override
  String get paperExamGeneral => 'عام (بدون ولاية)';

  @override
  String get paperExamIncludeSolutions => 'تضمين الحلول';

  @override
  String get paperExamIncludeSolutionsDesc => 'Lösungsschlüssel beifügen';

  @override
  String get paperExamShuffle => 'خلط الأسئلة';

  @override
  String get paperExamShuffleDesc => 'Fragen mischen';

  @override
  String get paperExamGenerate => 'إنشاء PDF 📄';

  @override
  String get paperExamGenerating => 'جاري الإنشاء...';

  @override
  String get paperExamPdfGenerated => 'تم إنشاء PDF بنجاح!';

  @override
  String get paperExamPrint => 'طباعة';

  @override
  String get paperExamShare => 'مشاركة';

  @override
  String get paperExamScan => 'مسح للتصحيح';

  @override
  String get scanExamTitle => 'مسح QR Code';

  @override
  String get scanExamInstructions => 'ضع QR Code من PDF داخل الإطار';

  @override
  String get scanExamProcessing => 'جاري المعالجة...';

  @override
  String get paperCorrectionTitle => 'تصحيح الامتحان الورقي';

  @override
  String get paperCorrectionInstructions => 'أدخل إجاباتك من الورقة';

  @override
  String get paperCorrectionAnswered => 'إجابة';

  @override
  String get paperCorrectionFinish => 'إنهاء وتصحيح';

  @override
  String get paperCorrectionIncompleteTitle => 'إجابات غير مكتملة';

  @override
  String get paperCorrectionIncompleteMessage =>
      'لم تقم بالإجابة على جميع الأسئلة. هل تريد المتابعة؟';

  @override
  String get paperExamWidgetDescription => 'طباعة وممارسة بدون إنترنت';

  @override
  String get paperExamTutorialTitle => 'كيفية استخدام الامتحان الورقي';

  @override
  String get paperExamTutorialStep1Title => 'إنشاء PDF';

  @override
  String get paperExamTutorialStep1Desc =>
      'اضغط على \"امتحان ورقي\" واختر الإعدادات (الولاية، خلط الأسئلة، تضمين الحلول) ثم اضغط \"إنشاء PDF\"';

  @override
  String get paperExamTutorialStep2Title => 'طباعة PDF';

  @override
  String get paperExamTutorialStep2Desc =>
      'اطبع PDF على ورق. سيكون هناك QR Code في أعلى الصفحة';

  @override
  String get paperExamTutorialStep3Title => 'أجب على الورقة';

  @override
  String get paperExamTutorialStep3Desc =>
      'أجب على الأسئلة باستخدام القلم والورقة كما في الامتحان الحقيقي';

  @override
  String get paperExamTutorialStep4Title => 'مسح QR Code';

  @override
  String get paperExamTutorialStep4Desc =>
      'افتح التطبيق واذهب إلى \"امتحان ورقي\" ثم اضغط \"Scan to Correct\" وامسح QR Code من الورقة';

  @override
  String get paperExamTutorialStep5Title => 'أدخل الإجابات واحصل على النتيجة';

  @override
  String get paperExamTutorialStep5Desc =>
      'أدخل إجاباتك من الورقة في التطبيق بسرعة واحصل على النتيجة فوراً';

  @override
  String get chooseTopic => 'اختر الموضوع';

  @override
  String get topicSystem => 'النظام السياسي';

  @override
  String get topicRights => 'الحقوق الأساسية';

  @override
  String get topicHistory => 'التاريخ الألماني';

  @override
  String get topicSociety => 'المجتمع';

  @override
  String get topicEurope => 'ألمانيا في أوروبا';

  @override
  String get topicWelfare => 'العمل والتعليم';

  @override
  String get learned => 'تم تعلمها';

  @override
  String get correct => 'صحيحة';

  @override
  String get topicQuestions => 'أسئلة الموضوع';

  @override
  String get noQuestionsForTopic => 'لا توجد أسئلة في هذا الموضوع';

  @override
  String get allTopicsReviewed => 'رائع! تمت مراجعة جميع أسئلة هذا الموضوع. 🎉';

  @override
  String get topics => 'المواضيع';

  @override
  String get topicStatistics => 'إحصائيات المواضيع';

  @override
  String get totalQuestions => 'إجمالي الأسئلة';

  @override
  String get questionsAnswered => 'الأسئلة المجابة';

  @override
  String get accuracyRate => 'معدل الدقة';

  @override
  String get mostStudiedTopic => 'أكثر موضوع تمت دراسته';

  @override
  String get leastStudiedTopic => 'أقل موضوع تمت دراسته';

  @override
  String get availableFeatures => 'الميزات المتاحة';

  @override
  String get freePlan => 'مجاني';

  @override
  String get accessToAllQuestions => 'الوصول لكل الأسئلة';

  @override
  String get adsIfAvailable => 'الإعلانات (إن وجدت)';

  @override
  String get oneExamPerDay => 'امتحان واحد يومياً';

  @override
  String get proSubscriptionPremium => 'اشتراك Pro (Premium)';

  @override
  String get unlimitedAiTutor => 'AI Tutor غير محدود';

  @override
  String get aiTutorFreeLimit => '3 مرات/يوم';

  @override
  String get aiTutorUnlimited => 'غير محدود';

  @override
  String get pdfExamGeneration => 'إنشاء امتحان PDF';

  @override
  String get noAds => 'بدون إعلانات';

  @override
  String get advancedSuccessStatistics => 'إحصائيات النجاح المتقدمة';

  @override
  String get monthly => 'شهري';

  @override
  String get renewsMonthly => 'تجديد شهري';

  @override
  String get threeMonths => '3 شهور';

  @override
  String get yearly => 'سنوي';

  @override
  String get mostPopularForExams => 'الأكثر شعبية للامتحانات';

  @override
  String get lifetime => 'مدى الحياة';

  @override
  String get oneTimePayment => 'دفعة واحدة';

  @override
  String get bestValue => 'أفضل قيمة';

  @override
  String get activeSubscription => 'مشترك نشط';

  @override
  String get upgradeForAdditionalFeatures => 'ترقية للحصول على ميزات إضافية';

  @override
  String get dailyChallenge => '🔥 التحدي اليومي';

  @override
  String get challengeCompleted => 'تم إكمال التحدي!';

  @override
  String get challengeExcellent => '🌟 ممتاز! أنت سيد!';

  @override
  String get challengeGreat => '🎉 عمل رائع! استمر!';

  @override
  String get challengeGood => '👍 جهد جيد! الممارسة تصنع الكمال!';

  @override
  String get challengeKeepGoing => '💪 استمر! كل خطأ هو درس!';

  @override
  String get points => 'نقاط';

  @override
  String get accuracy => 'الدقة';

  @override
  String get time => 'الوقت';

  @override
  String get done => 'تم';

  @override
  String get exitChallenge => 'إنهاء التحدي؟';

  @override
  String get exitChallengeMessage =>
      'هل أنت متأكد من أنك تريد الخروج؟ سيتم فقدان تقدمك.';

  @override
  String get exit => 'خروج';

  @override
  String get previous => 'السابق';

  @override
  String get finish => 'إنهاء';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get errorLoadingQuestions => 'خطأ في تحميل الأسئلة';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noQuestionsAvailable => 'لا توجد أسئلة متاحة';

  @override
  String get completedToday => 'مكتمل!';

  @override
  String get goBack => 'العودة';

  @override
  String get errorLoadingExam => 'خطأ في تحميل الامتحان';

  @override
  String get topicState => 'أسئلة الولاية';

  @override
  String get selectStateFirst => 'يرجى اختيار الولاية أولاً';

  @override
  String get aboutDailyChallengeTitle => '🔥 التحدي اليومي';

  @override
  String get aboutDailyChallengeSubtitle => 'تعلم يومي محفز';

  @override
  String get aboutDailyChallengeDescription =>
      'اختبر نفسك يومياً مع 10 أسئلة عشوائية واحصل على نقاط لكل إجابة صحيحة. احتفل بإنجازاتك مع تأثيرات بصرية ممتعة!';

  @override
  String get voiceExam => '🎤 امتحان صوتي (Pro)';

  @override
  String get playAudio => '🔊 تشغيل الصوت';

  @override
  String get playing => 'جاري التشغيل...';

  @override
  String get voiceExamMode => 'وضع الامتحان الصوتي';

  @override
  String get aiCoachTitle => '🎯 الموجه الذكي';

  @override
  String get aiCoachSubtitle => 'خطة دراسية مخصصة';

  @override
  String get aiCoachWeakTopics => 'أضعف المواضيع:';

  @override
  String get aiCoachError => 'فشل تحميل النصيحة';

  @override
  String get aiCoachNoData =>
      'ابدأ الإجابة على الأسئلة للحصول على نصيحة دراسية مخصصة!';

  @override
  String get startFocusedPractice => 'ابدأ التدريب المركز';

  @override
  String get unlockAiCoach => 'فتح الموجه الذكي';

  @override
  String get aiStudyCoach => 'الموجه الذكي للدراسة';

  @override
  String get syncing => 'جاري المزامنة...';

  @override
  String get syncError => 'فشلت المزامنة. العمل دون إنترنت.';

  @override
  String get licenseActive => 'النسخة الاحترافية مفعلة';

  @override
  String get invalidCode => 'الكود غير صالح أو منتهي';

  @override
  String get guestUser => 'مستخدم ضيف';

  @override
  String get proMember => 'عضو برو';

  @override
  String get upgradeAccount => 'قم بترقية حسابك';

  @override
  String get subscribeToPro => 'اشتراك برو';

  @override
  String get orActivateLicense => 'أو قم بتفعيل الترخيص';

  @override
  String get activateLicense => 'تفعيل الترخيص';

  @override
  String get enterLicenseKey => 'أدخل رمز الترخيص الخاص بك';

  @override
  String get licenseKey => 'رمز الترخيص';

  @override
  String get federalState => 'الولاية الفيدرالية';

  @override
  String get readiness => 'الجاهزية';

  @override
  String get mastery => 'المتعلم';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get smartAiStudyAlerts => '🎯 تنبيهات الدراسة الذكية';

  @override
  String get cloudBackupSync => '☁️ النسخ الاحتياطي السحابي والمزامنة';

  @override
  String get advancedReadinessIndex => '📊 مؤشر الجاهزية المتقدم';

  @override
  String get organizationSupport => '🏢 دعم المؤسسات';

  @override
  String get enterYourName => 'أدخل اسمك';

  @override
  String get saveNameToDatabase => 'حفظ الاسم في قاعدة البيانات';

  @override
  String get nameSaved => 'تم حفظ الاسم';

  @override
  String get nameRemoved => 'تم حذف الاسم';

  @override
  String get pickProfilePicture => 'اختر صورة الملف الشخصي';

  @override
  String get customizeProfileName => '👤 تخصيص اسم الملف الشخصي';

  @override
  String get nameChangeOnce => 'مرة واحدة';

  @override
  String get nameChangeUnlimited => 'غير محدود';

  @override
  String get topLearners => '🏆 أفضل المتعلمين';

  @override
  String get noLeaderboardData => 'لا توجد بيانات للوحة المتصدرين';

  @override
  String get you => 'أنت';

  @override
  String get sharedProgressFeature => '🔄 التقدم المشترك بين الأجهزة';

  @override
  String get sharedProgressDescription =>
      'ادرس على ما يصل إلى 3 أجهزة مع تقدم متزامن. يتم مزامنة بيانات التعلم تلقائياً عبر جميع أجهزتك.';

  @override
  String get sharedProgressBenefit => 'الوصول إلى تقدمك من أي جهاز';

  @override
  String get deviceLimit => 'حتى 3 أجهزة';

  @override
  String get automaticSync => 'مزامنة تلقائية';

  @override
  String get progressRestore => 'استعادة التقدم في حالة فقدان جهازك';

  @override
  String get syncingProgress => 'جاري مزامنة التقدم...';

  @override
  String get progressSynced => 'تمت مزامنة التقدم';

  @override
  String get cloudSync => 'مزامنة السحابة';
}
