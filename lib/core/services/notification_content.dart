/// -----------------------------------------------------------------
/// 📢 NOTIFICATION CONTENT / BENACHRICHTIGUNGSINHALT / محتوى الإشعارات
/// -----------------------------------------------------------------
/// Static maps for notification content translations.
/// Used in background tasks where BuildContext is not available.
/// Supports: de, ar, en, tr, uk, ru
/// -----------------------------------------------------------------
class NotificationContent {
  /// Notification titles by language and type
  static const Map<String, Map<String, String>> titles = {
    'ar': {
      'generic': 'وقت الدراسة! 📚',
      'pro': 'تنبيه النسر الذكي 🦅',
    },
    'de': {
      'generic': 'Zeit zu lernen! 📚',
      'pro': 'Smart Eagle Alarm 🦅',
    },
    'en': {
      'generic': 'Time to study! 📚',
      'pro': 'Smart Eagle Alert 🦅',
    },
    'tr': {
      'generic': 'Çalışma zamanı! 📚',
      'pro': 'Akıllı Kartal Uyarısı 🦅',
    },
    'uk': {
      'generic': 'Час навчання! 📚',
      'pro': 'Розумний сигнал Орла 🦅',
    },
    'ru': {
      'generic': 'Время учиться! 📚',
      'pro': 'Умный сигнал Орла 🦅',
    },
  };

  /// Notification bodies by language and scenario
  static const Map<String, Map<String, List<String>>> bodies = {
    'ar': {
      'free_motivation': [
        'حافظ على حماسك! 🔥',
        'استثمر 10 دقائق في مستقبلك.',
        'فعل النسخة الكاملة لتعرف ماذا تنسى.',
        'كل يوم خطوة أقرب لهدفك! 💪',
        'لا تتوقف الآن، أنت على الطريق الصحيح!',
      ],
      'pro_review': [
        'لديك {count} أسئلة ستنساها قريباً. راجعها الآن!',
        'مستوى جاهزيتك منخفض، لنرفعه الآن!',
        '{count} سؤال يحتاج مراجعة فورية.',
        'لا تفوت فرصة تحسين مستواك!',
      ],
      'pro_generic': [
        'حان وقت الدراسة الذكية! 🎯',
        'استمر في التقدم نحو هدفك!',
        'أنت على الطريق الصحيح، استمر!',
      ],
    },
    'de': {
      'free_motivation': [
        'Bleib am Ball! 🔥',
        'Investiere 10 Minuten in deine Zukunft.',
        'Hole dir Pro für bessere Einblicke.',
        'Jeder Tag bringt dich deinem Ziel näher! 💪',
        'Hör jetzt nicht auf, du bist auf dem richtigen Weg!',
      ],
      'pro_review': [
        'Du wirst {count} Fragen bald vergessen. Wiederhole sie jetzt!',
        'Dein Lernstand ist niedrig. Ändern wir das!',
        '{count} Fragen benötigen sofortige Wiederholung.',
        'Verpasse nicht die Chance, dein Niveau zu verbessern!',
      ],
      'pro_generic': [
        'Zeit für intelligentes Lernen! 🎯',
        'Mach weiter Fortschritte zu deinem Ziel!',
        'Du bist auf dem richtigen Weg, mach weiter!',
      ],
    },
    'en': {
      'free_motivation': [
        'Stay motivated! 🔥',
        'Invest 10 minutes in your future.',
        'Get Pro to see what you\'re forgetting.',
        'Every day brings you closer to your goal! 💪',
        'Don\'t stop now, you\'re on the right track!',
      ],
      'pro_review': [
        'You will forget {count} questions soon. Review them now!',
        'Your readiness level is low. Let\'s raise it!',
        '{count} questions need immediate review.',
        'Don\'t miss the chance to improve your level!',
      ],
      'pro_generic': [
        'Time for smart studying! 🎯',
        'Keep making progress toward your goal!',
        'You\'re on the right track, keep going!',
      ],
    },
    'tr': {
      'free_motivation': [
        'Motivasyonunu koru! 🔥',
        'Geleceğine 10 dakika yatırım yap.',
        'Neyi unuttuğunu görmek için Pro\'ya geç.',
        'Her gün hedefine bir adım daha yaklaşıyorsun! 💪',
        'Şimdi durma, doğru yoldasın!',
      ],
      'pro_review': [
        'Yakında {count} soruyu unutacaksın. Şimdi gözden geçir!',
        'Hazırlık seviyen düşük. Hadi yükseltelim!',
        '{count} soru acil gözden geçirme gerektiriyor.',
        'Seviyeni geliştirme şansını kaçırma!',
      ],
      'pro_generic': [
        'Akıllı çalışma zamanı! 🎯',
        'Hedefine doğru ilerlemeye devam et!',
        'Doğru yoldasın, devam et!',
      ],
    },
    'uk': {
      'free_motivation': [
        'Залишайся мотивованим! 🔥',
        'Інвестуй 10 хвилин у своє майбутнє.',
        'Отримай Pro, щоб побачити, що ти забуваєш.',
        'Кожен день наближає тебе до мети! 💪',
        'Не зупиняйся зараз, ти на правильному шляху!',
      ],
      'pro_review': [
        'Ти скоро забудеш {count} питань. Повтори їх зараз!',
        'Твій рівень готовності низький. Підвищимо його!',
        '{count} питань потребують негайного повторення.',
        'Не пропусти можливість покращити свій рівень!',
      ],
      'pro_generic': [
        'Час для розумного навчання! 🎯',
        'Продовжуй рухатися до своєї мети!',
        'Ти на правильному шляху, продовжуй!',
      ],
    },
    'ru': {
      'free_motivation': [
        'Оставайся мотивированным! 🔥',
        'Инвестируй 10 минут в своё будущее.',
        'Получи Pro, чтобы увидеть, что ты забываешь.',
        'Каждый день приближает тебя к цели! 💪',
        'Не останавливайся сейчас, ты на правильном пути!',
      ],
      'pro_review': [
        'Ты скоро забудешь {count} вопросов. Повтори их сейчас!',
        'Твой уровень готовности низкий. Давай повысим его!',
        '{count} вопросов требуют немедленного повторения.',
        'Не упусти шанс улучшить свой уровень!',
      ],
      'pro_generic': [
        'Время для умного обучения! 🎯',
        'Продолжай двигаться к своей цели!',
        'Ты на правильном пути, продолжай!',
      ],
    },
  };

  /// Get notification title based on language and type
  static String getTitle(String languageCode, {bool isPro = false}) {
    final lang = languageCode.toLowerCase();
    final titlesForLang = titles[lang] ?? titles['en']!;
    return isPro ? titlesForLang['pro']! : titlesForLang['generic']!;
  }

  /// Get notification body based on language, user type, and context
  static String getBody(
    String languageCode, {
    bool isPro = false,
    int dueQuestionsCount = 0,
  }) {
    final lang = languageCode.toLowerCase();
    final bodiesForLang = bodies[lang] ?? bodies['en']!;
    
    if (isPro) {
      // Pro user: Check if there are due questions
      if (dueQuestionsCount > 0) {
        // Use pro_review messages and replace {count}
        final reviewMessages = bodiesForLang['pro_review'] ?? bodies['en']!['pro_review']!;
        final randomMessage = reviewMessages[dueQuestionsCount % reviewMessages.length];
        return randomMessage.replaceAll('{count}', dueQuestionsCount.toString());
      } else {
        // Use generic pro messages
        final genericMessages = bodiesForLang['pro_generic'] ?? bodies['en']!['pro_generic']!;
        return genericMessages[DateTime.now().day % genericMessages.length];
      }
    } else {
      // Free user: Use motivation messages
      final motivationMessages = bodiesForLang['free_motivation'] ?? bodies['en']!['free_motivation']!;
      return motivationMessages[DateTime.now().day % motivationMessages.length];
    }
  }
}

