/// Translations for Exam Readiness Report
/// 
/// Contains all translatable strings for strengths, weaknesses, and recommendations
class ExamReadinessTranslations {
  ExamReadinessTranslations._();

  // ============================================
  // STRENGTHS
  // ============================================

  static Map<String, Map<String, String>> get strengths => {
    'strongQuestionMastery': {
      'en': 'Strong Question Mastery',
      'ar': 'إتقان قوي للأسئلة',
      'de': 'Starke Fragenbeherrschung',
      'tr': 'Güçlü Soru Ustalığı',
      'uk': 'Сильне оволодіння питаннями',
      'ru': 'Сильное освоение вопросов',
    },
    'strongQuestionMasteryDesc': {
      'en': 'You have mastered {0} questions with a {1}% mastery score.',
      'ar': 'لقد أتقنت {0} سؤالاً بنتيجة إتقان {1}%.',
      'de': 'Sie haben {0} Fragen mit einer Beherrschungspunktzahl von {1}% gemeistert.',
      'tr': '{0} soruyu %{1} ustalık puanıyla öğrendiniz.',
      'uk': 'Ви оволоділи {0} питаннями з балом оволодіння {1}%.',
      'ru': 'Вы освоили {0} вопросов с баллом освоения {1}%.',
    },
    'goodProgressOnQuestions': {
      'en': 'Good Progress on Questions',
      'ar': 'تقدم جيد في الأسئلة',
      'de': 'Gute Fortschritte bei Fragen',
      'tr': 'Sorularda İyi İlerleme',
      'uk': 'Хороший прогрес у питаннях',
      'ru': 'Хороший прогресс в вопросах',
    },
    'goodProgressOnQuestionsDesc': {
      'en': 'You are making good progress with {0} mastered questions.',
      'ar': 'أنت تحرز تقدماً جيداً مع {0} سؤال متقن.',
      'de': 'Sie machen gute Fortschritte mit {0} gemeisterten Fragen.',
      'tr': '{0} öğrenilmiş soruyla iyi ilerleme kaydediyorsunuz.',
      'uk': 'Ви досягаєте хорошого прогресу з {0} оволоділими питаннями.',
      'ru': 'Вы добиваетесь хорошего прогресса с {0} освоенными вопросами.',
    },
    'excellentExamPerformance': {
      'en': 'Excellent Exam Performance',
      'ar': 'أداء ممتاز في الامتحانات',
      'de': 'Ausgezeichnete Prüfungsleistung',
      'tr': 'Mükemmel Sınav Performansı',
      'uk': 'Відмінні результати іспиту',
      'ru': 'Отличные результаты экзамена',
    },
    'excellentExamPerformanceDesc': {
      'en': 'You passed {0} out of {1} exams with a {2}% average score.',
      'ar': 'لقد نجحت في {0} من أصل {1} امتحان بمتوسط {2}%.',
      'de': 'Sie haben {0} von {1} Prüfungen mit einem Durchschnitt von {2}% bestanden.',
      'tr': '{1} sınavdan {0}\'ını %{2} ortalama ile geçtiniz.',
      'uk': 'Ви склали {0} з {1} іспитів із середнім балом {2}%.',
      'ru': 'Вы сдали {0} из {1} экзаменов со средним баллом {2}%.',
    },
    'examExperience': {
      'en': 'Exam Experience',
      'ar': 'خبرة في الامتحانات',
      'de': 'Prüfungserfahrung',
      'tr': 'Sınav Deneyimi',
      'uk': 'Досвід іспиту',
      'ru': 'Опыт экзамена',
    },
    'examExperienceDesc': {
      'en': 'You have completed {0} exam{1} and passed {2}.',
      'ar': 'لقد أكملت {0} امتحان{1} ونجحت في {2}.',
      'de': 'Sie haben {0} Prüfung{1} abgeschlossen und {2} bestanden.',
      'tr': '{0} sınav{1} tamamladınız ve {2}\'ını geçtiniz.',
      'uk': 'Ви завершили {0} іспит{1} і склали {2}.',
      'ru': 'Вы завершили {0} экзамен{1} и сдали {2}.',
    },
    'consistentStudyHabits': {
      'en': 'Consistent Study Habits',
      'ar': 'عادات دراسة منتظمة',
      'de': 'Konsistente Lerngewohnheiten',
      'tr': 'Tutarlı Çalışma Alışkanlıkları',
      'uk': 'Послідовні навчальні звички',
      'ru': 'Последовательные учебные привычки',
    },
    'consistentStudyHabitsDesc': {
      'en': 'You have a {0}-day streak and studied {1} times in the last week.',
      'ar': 'لديك سلسلة {0} يوم ودرست {1} مرة في الأسبوع الماضي.',
      'de': 'Sie haben eine {0}-Tage-Serie und haben in der letzten Woche {1} Mal gelernt.',
      'tr': '{0} günlük bir seriniz var ve geçen hafta {1} kez çalıştınız.',
      'uk': 'У вас є серія {0} днів, і ви вчилися {1} разів минулого тижня.',
      'ru': 'У вас серия {0} дней, и вы учились {1} раз на прошлой неделе.',
    },
    'goodStudyStreak': {
      'en': 'Good Study Streak',
      'ar': 'سلسلة دراسة جيدة',
      'de': 'Gute Lernserie',
      'tr': 'İyi Çalışma Serisi',
      'uk': 'Хороша серія навчання',
      'ru': 'Хорошая серия обучения',
    },
    'goodStudyStreakDesc': {
      'en': 'You have maintained a {0}-day study streak!',
      'ar': 'لقد حافظت على سلسلة دراسة لمدة {0} يوم!',
      'de': 'Sie haben eine {0}-Tage-Lernserie aufrechterhalten!',
      'tr': '{0} günlük bir çalışma serisi sürdürdünüz!',
      'uk': 'Ви підтримували серію навчання {0} днів!',
      'ru': 'Вы поддерживали серию обучения {0} дней!',
    },
    'highActivityLevel': {
      'en': 'High Activity Level',
      'ar': 'مستوى نشاط عالي',
      'de': 'Hohes Aktivitätsniveau',
      'tr': 'Yüksek Aktivite Seviyesi',
      'uk': 'Високий рівень активності',
      'ru': 'Высокий уровень активности',
    },
    'highActivityLevelDesc': {
      'en': 'You have answered {0} questions and studied for {1} hours.',
      'ar': 'لقد أجبت على {0} سؤال ودرست لمدة {1} ساعة.',
      'de': 'Sie haben {0} Fragen beantwortet und {1} Stunden gelernt.',
      'tr': '{0} soru cevapladınız ve {1} saat çalıştınız.',
      'uk': 'Ви відповіли на {0} питань і вчилися {1} годин.',
      'ru': 'Вы ответили на {0} вопросов и учились {1} часов.',
    },
    'highAccuracy': {
      'en': 'High Accuracy',
      'ar': 'دقة عالية',
      'de': 'Hohe Genauigkeit',
      'tr': 'Yüksek Doğruluk',
      'uk': 'Висока точність',
      'ru': 'Высокая точность',
    },
    'highAccuracyDesc': {
      'en': 'You answered {0} out of {1} questions correctly ({2}%).',
      'ar': 'لقد أجبت بشكل صحيح على {0} من أصل {1} سؤال ({2}%).',
      'de': 'Sie haben {0} von {1} Fragen richtig beantwortet ({2}%).',
      'tr': '{1} sorudan {0}\'ını doğru cevapladınız (%{2}).',
      'uk': 'Ви правильно відповіли на {0} з {1} питань ({2}%).',
      'ru': 'Вы правильно ответили на {0} из {1} вопросов ({2}%).',
    },
  };

  // ============================================
  // WEAKNESSES
  // ============================================

  static Map<String, Map<String, String>> get weaknesses => {
    'lowQuestionMastery': {
      'en': 'Low Question Mastery',
      'ar': 'إتقان منخفض للأسئلة',
      'de': 'Niedrige Fragenbeherrschung',
      'tr': 'Düşük Soru Ustalığı',
      'uk': 'Низьке оволодіння питаннями',
      'ru': 'Низкое освоение вопросов',
    },
    'lowQuestionMasteryDesc': {
      'en': 'Your mastery score is {0}%. Focus on reviewing difficult questions.',
      'ar': 'نتيجة إتقانك هي {0}%. ركز على مراجعة الأسئلة الصعبة.',
      'de': 'Ihre Beherrschungspunktzahl beträgt {0}%. Konzentrieren Sie sich auf die Überprüfung schwieriger Fragen.',
      'tr': 'Ustalık puanınız %{0}. Zor soruları gözden geçirmeye odaklanın.',
      'uk': 'Ваш бал оволодіння становить {0}%. Зосередьтеся на перегляді складних питань.',
      'ru': 'Ваш балл освоения составляет {0}%. Сосредоточьтесь на просмотре сложных вопросов.',
    },
    'limitedQuestionCoverage': {
      'en': 'Limited Question Coverage',
      'ar': 'تغطية محدودة للأسئلة',
      'de': 'Begrenzte Fragenabdeckung',
      'tr': 'Sınırlı Soru Kapsamı',
      'uk': 'Обмежене охоплення питань',
      'ru': 'Ограниченное охват вопросов',
    },
    'limitedQuestionCoverageDesc': {
      'en': 'You have only answered {0} questions. Try to answer more questions to improve mastery.',
      'ar': 'لقد أجبت على {0} سؤال فقط. حاول الإجابة على المزيد من الأسئلة لتحسين الإتقان.',
      'de': 'Sie haben nur {0} Fragen beantwortet. Versuchen Sie, mehr Fragen zu beantworten, um die Beherrschung zu verbessern.',
      'tr': 'Sadece {0} soru cevapladınız. Ustalığı artırmak için daha fazla soru cevaplamayı deneyin.',
      'uk': 'Ви відповіли лише на {0} питань. Спробуйте відповісти на більше питань, щоб покращити оволодіння.',
      'ru': 'Вы ответили только на {0} вопросов. Попробуйте ответить на больше вопросов, чтобы улучшить освоение.',
    },
    'lowExamPerformance': {
      'en': 'Low Exam Performance',
      'ar': 'أداء منخفض في الامتحانات',
      'de': 'Niedrige Prüfungsleistung',
      'tr': 'Düşük Sınav Performansı',
      'uk': 'Низькі результати іспиту',
      'ru': 'Низкие результаты экзамена',
    },
    'lowExamPerformanceDesc': {
      'en': 'Your exam average is {0}%. Practice more exam simulations.',
      'ar': 'متوسط امتحاناتك هو {0}%. تدرب على المزيد من محاكاة الامتحانات.',
      'de': 'Ihr Prüfungsdurchschnitt beträgt {0}%. Üben Sie mehr Prüfungssimulationen.',
      'tr': 'Sınav ortalamanız %{0}. Daha fazla sınav simülasyonu yapın.',
      'uk': 'Ваш середній бал іспиту становить {0}%. Практикуйте більше симуляцій іспитів.',
      'ru': 'Ваш средний балл экзамена составляет {0}%. Практикуйте больше симуляций экзаменов.',
    },
    'noExamPractice': {
      'en': 'No Exam Practice',
      'ar': 'لا توجد ممارسة للامتحانات',
      'de': 'Keine Prüfungspraxis',
      'tr': 'Sınav Pratiği Yok',
      'uk': 'Немає практики іспиту',
      'ru': 'Нет практики экзамена',
    },
    'noExamPracticeDesc': {
      'en': 'You haven\'t taken any exam simulations yet. Try taking practice exams to assess your readiness.',
      'ar': 'لم تقم بأي محاكاة للامتحانات بعد. جرب إجراء امتحانات تدريبية لتقييم جاهزيتك.',
      'de': 'Sie haben noch keine Prüfungssimulationen durchgeführt. Versuchen Sie, Übungsprüfungen abzulegen, um Ihre Bereitschaft zu bewerten.',
      'tr': 'Henüz sınav simülasyonu yapmadınız. Hazırlığınızı değerlendirmek için pratik sınavlar yapmayı deneyin.',
      'uk': 'Ви ще не проходили жодних симуляцій іспитів. Спробуйте скласти практичні іспити, щоб оцінити свою готовність.',
      'ru': 'Вы еще не проходили симуляции экзаменов. Попробуйте сдать практические экзамены, чтобы оценить свою готовность.',
    },
    'inconsistentStudyHabits': {
      'en': 'Inconsistent Study Habits',
      'ar': 'عادات دراسة غير منتظمة',
      'de': 'Inkonsistente Lerngewohnheiten',
      'tr': 'Tutarsız Çalışma Alışkanlıkları',
      'uk': 'Непослідовні навчальні звички',
      'ru': 'Непоследовательные учебные привычки',
    },
    'inconsistentStudyHabitsDesc': {
      'en': 'Your current streak is only {0} days. Try to study daily to build consistency.',
      'ar': 'سلسلتك الحالية هي {0} أيام فقط. حاول الدراسة يومياً لبناء الانتظام.',
      'de': 'Ihre aktuelle Serie beträgt nur {0} Tage. Versuchen Sie, täglich zu lernen, um Konsistenz aufzubauen.',
      'tr': 'Mevcut seriniz sadece {0} gün. Tutarlılık oluşturmak için günlük çalışmayı deneyin.',
      'uk': 'Ваша поточна серія становить лише {0} днів. Спробуйте вчитися щодня, щоб побудувати послідовність.',
      'ru': 'Ваша текущая серия составляет всего {0} дней. Попробуйте учиться ежедневно, чтобы построить последовательность.',
    },
    'lowRecentActivity': {
      'en': 'Low Recent Activity',
      'ar': 'نشاط حديث منخفض',
      'de': 'Niedrige kürzliche Aktivität',
      'tr': 'Düşük Son Aktivite',
      'uk': 'Низька недавня активність',
      'ru': 'Низкая недавняя активность',
    },
    'lowRecentActivityDesc': {
      'en': 'You only studied {0} times in the last week. Increase your study frequency.',
      'ar': 'لقد درست {0} مرات فقط في الأسبوع الماضي. زد من تكرار دراستك.',
      'de': 'Sie haben in der letzten Woche nur {0} Mal gelernt. Erhöhen Sie Ihre Lernfrequenz.',
      'tr': 'Geçen hafta sadece {0} kez çalıştınız. Çalışma sıklığınızı artırın.',
      'uk': 'Ви вчилися лише {0} разів минулого тижня. Збільште частоту навчання.',
      'ru': 'Вы учились только {0} раз на прошлой неделе. Увеличьте частоту обучения.',
    },
    'weakStateSpecificKnowledge': {
      'en': 'Weak State-Specific Knowledge',
      'ar': 'معرفة ضعيفة بأسئلة الولاية',
      'de': 'Schwaches länderspezifisches Wissen',
      'tr': 'Zayıf Eyalete Özel Bilgi',
      'uk': 'Слабкі знання конкретної землі',
      'ru': 'Слабкие знания конкретной земли',
    },
    'weakStateSpecificKnowledgeDesc': {
      'en': 'Your state-specific score is {0}%. Focus on your selected state\'s questions.',
      'ar': 'نتيجة أسئلة الولاية هي {0}%. ركز على أسئلة الولاية المختارة.',
      'de': 'Ihr länderspezifischer Punktzahl beträgt {0}%. Konzentrieren Sie sich auf die Fragen Ihres ausgewählten Landes.',
      'tr': 'Eyalete özel puanınız %{0}. Seçtiğiniz eyaletin sorularına odaklanın.',
      'uk': 'Ваш бал конкретної землі становить {0}%. Зосередьтеся на питаннях вашої обраної землі.',
      'ru': 'Ваш балл конкретной земли составляет {0}%. Сосредоточьтесь на вопросах вашей выбранной земли.',
    },
    'lowAnswerAccuracy': {
      'en': 'Low Answer Accuracy',
      'ar': 'دقة إجابات منخفضة',
      'de': 'Niedrige Antwortgenauigkeit',
      'tr': 'Düşük Cevap Doğruluğu',
      'uk': 'Низька точність відповідей',
      'ru': 'Низкая точность ответов',
    },
    'lowAnswerAccuracyDesc': {
      'en': 'Your accuracy is {0}%. Review incorrect answers and study more.',
      'ar': 'دقتك هي {0}%. راجع الإجابات الخاطئة وادرس أكثر.',
      'de': 'Ihre Genauigkeit beträgt {0}%. Überprüfen Sie falsche Antworten und lernen Sie mehr.',
      'tr': 'Doğruluğunuz %{0}. Yanlış cevapları gözden geçirin ve daha fazla çalışın.',
      'uk': 'Ваша точність становить {0}%. Перегляньте неправильні відповіді та вчіться більше.',
      'ru': 'Ваша точность составляет {0}%. Просмотрите неправильные ответы и учитесь больше.',
    },
  };

  // ============================================
  // RECOMMENDATIONS
  // ============================================

  static Map<String, Map<String, String>> get recommendations => {
    'answerMoreQuestions': {
      'en': 'Answer more questions to improve your mastery. Aim for at least 100 questions.',
      'ar': 'أجب على المزيد من الأسئلة لتحسين إتقانك. استهدف 100 سؤال على الأقل.',
      'de': 'Beantworten Sie mehr Fragen, um Ihre Beherrschung zu verbessern. Zielen Sie auf mindestens 100 Fragen.',
      'tr': 'Ustalığınızı artırmak için daha fazla soru cevaplayın. En az 100 soru hedefleyin.',
      'uk': 'Відповідайте на більше питань, щоб покращити оволодіння. Прагніть принаймні 100 питань.',
      'ru': 'Отвечайте на больше вопросов, чтобы улучшить освоение. Стремитесь к минимум 100 вопросам.',
    },
    'reviewDifficultQuestions': {
      'en': 'Review difficult questions using the SRS system to improve mastery.',
      'ar': 'راجع الأسئلة الصعبة باستخدام نظام SRS لتحسين الإتقان.',
      'de': 'Überprüfen Sie schwierige Fragen mit dem SRS-System, um die Beherrschung zu verbessern.',
      'tr': 'Ustalığı artırmak için SRS sistemi kullanarak zor soruları gözden geçirin.',
      'uk': 'Перегляньте складні питання, використовуючи систему SRS, щоб покращити оволодіння.',
      'ru': 'Просмотрите сложные вопросы, используя систему SRS, чтобы улучшить освоение.',
    },
    'takePracticeExams': {
      'en': 'Take practice exams to assess your readiness and get familiar with the exam format.',
      'ar': 'قم بإجراء امتحانات تدريبية لتقييم جاهزيتك والتعرف على تنسيق الامتحان.',
      'de': 'Legen Sie Übungsprüfungen ab, um Ihre Bereitschaft zu bewerten und sich mit dem Prüfungsformat vertraut zu machen.',
      'tr': 'Hazırlığınızı değerlendirmek ve sınav formatına aşina olmak için pratik sınavlar yapın.',
      'uk': 'Складіть практичні іспити, щоб оцінити свою готовність та ознайомитися з форматом іспиту.',
      'ru': 'Сдавайте практические экзамены, чтобы оценить свою готовность и ознакомиться с форматом экзамена.',
    },
    'takeMorePracticeExams': {
      'en': 'Take more practice exams and focus on areas where you scored low.',
      'ar': 'قم بإجراء المزيد من الامتحانات التدريبية وركز على المجالات التي حصلت فيها على درجات منخفضة.',
      'de': 'Legen Sie mehr Übungsprüfungen ab und konzentrieren Sie sich auf Bereiche, in denen Sie niedrige Punktzahlen erzielt haben.',
      'tr': 'Daha fazla pratik sınav yapın ve düşük puan aldığınız alanlara odaklanın.',
      'uk': 'Складіть більше практичних іспитів і зосередьтеся на областях, де ви набрали низькі бали.',
      'ru': 'Сдавайте больше практических экзаменов и сосредоточьтесь на областях, где вы набрали низкие баллы.',
    },
    'buildDailyStudyHabit': {
      'en': 'Build a daily study habit. Try to maintain at least a 7-day streak.',
      'ar': 'ابني عادة دراسة يومية. حاول الحفاظ على سلسلة 7 أيام على الأقل.',
      'de': 'Bauen Sie eine tägliche Lerngewohnheit auf. Versuchen Sie, mindestens eine 7-Tage-Serie aufrechtzuerhalten.',
      'tr': 'Günlük bir çalışma alışkanlığı oluşturun. En az 7 günlük bir seri sürdürmeyi deneyin.',
      'uk': 'Побудуйте щоденну навчальну звичку. Спробуйте підтримувати принаймні 7-денну серію.',
      'ru': 'Постройте ежедневную учебную привычку. Попробуйте поддерживать серию минимум 7 дней.',
    },
    'increaseStudyFrequency': {
      'en': 'Increase your study frequency. Aim for at least 5 study sessions per week.',
      'ar': 'زد من تكرار دراستك. استهدف 5 جلسات دراسة على الأقل أسبوعياً.',
      'de': 'Erhöhen Sie Ihre Lernfrequenz. Zielen Sie auf mindestens 5 Lernsitzungen pro Woche.',
      'tr': 'Çalışma sıklığınızı artırın. Haftada en az 5 çalışma oturumu hedefleyin.',
      'uk': 'Збільште частоту навчання. Прагніть принаймні 5 навчальних сесій на тиждень.',
      'ru': 'Увеличьте частоту обучения. Стремитесь к минимум 5 учебным сессиям в неделю.',
    },
    'focusOnStateQuestions': {
      'en': 'Focus on studying questions specific to your selected state.',
      'ar': 'ركز على دراسة الأسئلة الخاصة بولايتك المختارة.',
      'de': 'Konzentrieren Sie sich auf das Lernen von Fragen, die für Ihr ausgewähltes Land spezifisch sind.',
      'tr': 'Seçtiğiniz eyalete özel soruları çalışmaya odaklanın.',
      'uk': 'Зосередьтеся на вивченні питань, специфічних для вашої обраної землі.',
      'ru': 'Сосредоточьтесь на изучении вопросов, специфичных для вашей выбранной земли.',
    },
    'closeToReady': {
      'en': 'You are close to being ready! Focus on your weakest areas to reach 70%.',
      'ar': 'أنت قريب من الجاهزية! ركز على أضعف مجالاتك للوصول إلى 70%.',
      'de': 'Sie sind fast bereit! Konzentrieren Sie sich auf Ihre schwächsten Bereiche, um 70% zu erreichen.',
      'tr': 'Hazır olmaya yakınsınız! %70\'e ulaşmak için en zayıf alanlarınıza odaklanın.',
      'uk': 'Ви майже готові! Зосередьтеся на найслабших областях, щоб досягти 70%.',
      'ru': 'Вы почти готовы! Сосредоточьтесь на самых слабых областях, чтобы достичь 70%.',
    },
    'continueStudyingRegularly': {
      'en': 'Continue studying regularly. Set a goal to reach 50% readiness first, then aim for 70%.',
      'ar': 'استمر في الدراسة بانتظام. حدد هدفاً للوصول إلى 50% جاهزية أولاً، ثم استهدف 70%.',
      'de': 'Lernen Sie weiterhin regelmäßig. Setzen Sie sich zunächst das Ziel, 50% Bereitschaft zu erreichen, und streben Sie dann 70% an.',
      'tr': 'Düzenli olarak çalışmaya devam edin. Önce %50 hazırlığa ulaşmayı hedefleyin, sonra %70\'i hedefleyin.',
      'uk': 'Продовжуйте вчитися регулярно. Спочатку поставте мету досягти 50% готовності, а потім прагніть 70%.',
      'ru': 'Продолжайте учиться регулярно. Сначала поставьте цель достичь 50% готовности, а затем стремитесь к 70%.',
    },
    'greatProgressKeepItUp': {
      'en': 'Great progress! You are ready for the exam. Continue practicing to reach excellence (85%+).',
      'ar': 'تقدم رائع! أنت جاهز للامتحان. استمر في التدريب للوصول إلى التميز (85%+).',
      'de': 'Großartiger Fortschritt! Sie sind bereit für die Prüfung. Üben Sie weiter, um Exzellenz (85%+) zu erreichen.',
      'tr': 'Harika ilerleme! Sınava hazırsınız. Mükemmelliğe (85%+) ulaşmak için pratik yapmaya devam edin.',
      'uk': 'Чудовий прогрес! Ви готові до іспиту. Продовжуйте практикувати, щоб досягти досконалості (85%+).',
      'ru': 'Отличный прогресс! Вы готовы к экзамену. Продолжайте практиковаться, чтобы достичь совершенства (85%+).',
    },
    'keepUpExcellentWork': {
      'en': 'Keep up the excellent work! Maintain your study habits to stay ready.',
      'ar': 'استمر في العمل الممتاز! حافظ على عادات دراستك للبقاء جاهزاً.',
      'de': 'Machen Sie weiter so! Behalten Sie Ihre Lerngewohnheiten bei, um bereit zu bleiben.',
      'tr': 'Mükemmel işe devam edin! Hazır kalmak için çalışma alışkanlıklarınızı sürdürün.',
      'uk': 'Продовжуйте чудову роботу! Підтримуйте свої навчальні звички, щоб залишатися готовими.',
      'ru': 'Продолжайте отличную работу! Поддерживайте свои учебные привычки, чтобы оставаться готовыми.',
    },
  };

  /// Get translation for a key
  static String get(String key, String languageCode) {
    final lang = languageCode.toLowerCase();
    
    // Try to get from strengths
    if (strengths.containsKey(key)) {
      return strengths[key]![lang] ?? strengths[key]!['en'] ?? key;
    }
    
    // Try to get from weaknesses
    if (weaknesses.containsKey(key)) {
      return weaknesses[key]![lang] ?? weaknesses[key]!['en'] ?? key;
    }
    
    // Try to get from recommendations
    if (recommendations.containsKey(key)) {
      return recommendations[key]![lang] ?? recommendations[key]!['en'] ?? key;
    }
    
    return key;
  }

  /// Format a translation string with placeholders
  static String format(String key, String languageCode, List<dynamic> args) {
    String template = get(key, languageCode);
    
    for (int i = 0; i < args.length; i++) {
      template = template.replaceAll('{$i}', args[i].toString());
    }
    
    return template;
  }
  
  /// Get plural form helper (for exam/exams)
  static String getExamPlural(String languageCode, int count) {
    if (count == 1) return '';
    switch (languageCode) {
      case 'ar':
        return 'ات';
      case 'de':
        return 'e';
      case 'tr':
        return 'lar';
      case 'uk':
        return 'и';
      case 'ru':
        return 'ы';
      default:
        return 's';
    }
  }
}

