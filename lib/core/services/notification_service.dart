import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/debug/app_logger.dart';
import '../../core/storage/user_preferences_service.dart';
import '../../core/storage/hive_service.dart';
import '../../core/storage/srs_service.dart';
import '../../core/services/subscription_service.dart';
import '../../core/services/notification_content.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/repositories/question_repository_impl.dart';
import '../../domain/entities/question.dart';

/// خدمة الإشعارات الذكية للدراسة
/// يدعم: إشعارات يومية، إشعارات SRS، إشعارات السلسلة، إشعارات التقدم
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  // Notification IDs
  static const int _dailyReminderId = 1;
  static const int _srsReminderId = 2;
  static const int _streakReminderId = 3;
  static const int _progressReminderId = 4;
  
  // Global navigator key for navigation from notifications
  static GlobalKey<NavigatorState>? navigatorKey;

  /// تهيئة خدمة الإشعارات
  static Future<void> init() async {
    // تهيئة قاعدة بيانات Timezone
    tz.initializeTimeZones();
    
    // إعدادات Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // إعدادات iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // إعدادات التهيئة
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    // تهيئة الإشعارات
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // طلب الصلاحيات
    await _requestPermissions();
    
    // إعادة جدولة الإشعارات عند إعادة تشغيل التطبيق
    try {
      await _rescheduleNotificationsIfEnabled();
    } catch (e) {
      // تجاهل الأخطاء في جدولة الإشعارات عند بدء التشغيل
      AppLogger.warn('Failed to reschedule notifications: $e', source: 'NotificationService');
    }
  }

  /// طلب صلاحيات الإشعارات
  static Future<void> _requestPermissions() async {
    // Android 13+ requires explicit permission request
    if (await _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ??
        false) {
      // Permission granted
    }
    
    // iOS permissions are requested during initialization
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// معالج النقر على الإشعار
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    
    // إذا كان هناك navigator key، استخدمه للتنقل
    if (navigatorKey?.currentContext != null && payload != null) {
      // Use Future.microtask to ensure navigation happens after build
      Future.microtask(() {
        final context = navigatorKey?.currentContext;
        if (context == null || !context.mounted) return;
        
        // Parse payload to determine which screen to open
        if (payload == 'daily_reminder') {
          // Navigate to Study screen (index 1 in MainScreen)
          // We'll use a different approach - just open the app
          // The user can navigate manually
        } else if (payload == 'srs_reminder') {
          // Navigate to Review screen
          try {
            if (context.mounted) {
              Navigator.of(context).pushNamed('/review');
            }
          } catch (e) {
            // If route doesn't exist, just open app
          }
        } else if (payload == 'streak_reminder') {
          // Navigate to Dashboard (index 0 in MainScreen)
          // Just open the app
        } else if (payload == 'progress_reminder') {
          // Navigate to Statistics
          try {
            if (context.mounted) {
              Navigator.of(context).pushNamed('/statistics');
            }
          } catch (e) {
            // If route doesn't exist, just open app
          }
        }
      });
    }
  }

  /// إعادة جدولة الإشعارات عند إعادة تشغيل التطبيق
  static Future<void> _rescheduleNotificationsIfEnabled() async {
    final isReminderEnabled = await UserPreferencesService.getReminderEnabled();
    if (isReminderEnabled) {
      final reminderTime = await UserPreferencesService.getReminderTime();
      if (reminderTime != null) {
        await scheduleDailyNotification(reminderTime);
      }
    }
    
    // جدولة إشعارات SRS إذا كانت هناك أسئلة مستحقة
    await _scheduleSrsReminderIfNeeded();
  }

  /// جدولة إشعار يومي
  static Future<void> scheduleDailyNotification(TimeOfDay time) async {
    // التحقق من الصلاحيات أولاً
    final hasPermission = await _checkPermissions();
    if (!hasPermission) {
      await _requestPermissions();
      // Try again after requesting
      final hasPermissionAfter = await _checkPermissions();
      if (!hasPermissionAfter) {
        return; // User denied permission
      }
    }
    
    // إلغاء الإشعارات السابقة
    await cancelNotification(_dailyReminderId);
    
    // تحديد الوقت
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    // إذا كان الوقت قد مضى اليوم، جدوله لليوم التالي
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    // تحويل إلى Timezone
    final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );
    
    // Fetch User Context for dynamic content
    final languageCode = HiveService.getSavedLanguage() ?? 'de';
    final isPro = await SubscriptionService.isProUser();
    
    // Get due questions count for Pro users
    int dueQuestionsCount = 0;
    if (isPro) {
      try {
        final localDataSource = LocalDataSourceImpl();
        final repository = QuestionRepositoryImpl(localDataSource);
        final selectedState = await UserPreferencesService.getSelectedState();
        final result = await repository.getAllQuestions(selectedState);
        
        final allQuestions = result.fold(
          (failure) => <Question>[],
          (questions) => questions,
        );
        
        if (allQuestions.isNotEmpty) {
          final allQuestionIds = allQuestions.map((q) => q.id).toList();
          final dueQuestionIds = SrsService.getDueQuestions(allQuestionIds);
          dueQuestionsCount = dueQuestionIds.length;
        }
      } catch (e) {
        AppLogger.warn('Failed to get due questions count: $e', source: 'NotificationService');
      }
    }
    
    // Generate dynamic notification content
    final title = NotificationContent.getTitle(languageCode, isPro: isPro);
    final body = NotificationContent.getBody(
      languageCode,
      isPro: isPro,
      dueQuestionsCount: dueQuestionsCount,
    );
    
    // إعدادات الإشعار
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Study Reminder',
      channelDescription: 'Reminds you to study daily',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // جدولة الإشعار مع التكرار اليومي
    try {
      await _notifications.zonedSchedule(
        _dailyReminderId,
        title,
        body,
        scheduledTZ,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_reminder',
      );
      
      AppLogger.event('Daily reminder scheduled', source: 'NotificationService', data: {
        'time': '${time.hour}:${time.minute}',
        'language': languageCode,
        'isPro': isPro,
        'dueQuestionsCount': dueQuestionsCount,
      });
    } catch (e) {
      // إذا فشل exactAllowWhileIdle (Android 12+ يتطلب إذن)، استخدم وضع عادي
      try {
        await _notifications.zonedSchedule(
          _dailyReminderId,
          title,
          body,
          scheduledTZ,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'daily_reminder',
        );
      } catch (e2) {
        // إذا فشل أيضاً، استخدم وضع بسيط
        await _notifications.zonedSchedule(
          _dailyReminderId,
          title,
          body,
          scheduledTZ,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'daily_reminder',
        );
      }
    }
  }

  /// جدولة إشعار SRS (أسئلة مستحقة للمراجعة)
  static Future<void> scheduleSrsReminder() async {
    final hasPermission = await _checkPermissions();
    if (!hasPermission) return;
    
    // جلب الأسئلة المستحقة
    final localDataSource = LocalDataSourceImpl();
    final repository = QuestionRepositoryImpl(localDataSource);
    final selectedState = await UserPreferencesService.getSelectedState();
    final result = await repository.getAllQuestions(selectedState);
    
    final allQuestions = result.fold(
      (failure) => <Question>[],
      (questions) => questions,
    );
    
    if (allQuestions.isEmpty) return;
    
    final allQuestionIds = allQuestions.map((q) => q.id).toList();
    final dueQuestionIds = SrsService.getDueQuestions(allQuestionIds);
    
    if (dueQuestionIds.isEmpty) {
      await cancelNotification(_srsReminderId);
      return;
    }
    
    // جدولة إشعار إذا كان هناك 5+ أسئلة مستحقة
    if (dueQuestionIds.length >= 5) {
      final languageCode = (await SharedPreferences.getInstance())
          .getString('language') ?? 'en';
      final notificationText = _getSrsNotificationText(languageCode, dueQuestionIds.length);
      
      // جدولة إشعار بعد ساعتين من الآن
      final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(hours: 2));
      
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'srs_reminder',
        'SRS Review Reminder',
        channelDescription: 'Reminds you to review due questions',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        showWhen: true,
        enableVibration: true,
      );
      
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      try {
        await _notifications.zonedSchedule(
          _srsReminderId,
          notificationText['title'] ?? 'Review Time!',
          notificationText['body'] ?? 'You have questions to review',
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'srs_reminder',
        );
      } catch (e) {
        // استخدام وضع بديل إذا فشل exact
        await _notifications.zonedSchedule(
          _srsReminderId,
          notificationText['title'] ?? 'Review Time!',
          notificationText['body'] ?? 'You have questions to review',
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'srs_reminder',
        );
      }
    }
  }

  /// جدولة إشعار SRS إذا لزم الأمر
  static Future<void> _scheduleSrsReminderIfNeeded() async {
    final isReminderEnabled = await UserPreferencesService.getReminderEnabled();
    if (!isReminderEnabled) return;
    
    await scheduleSrsReminder();
  }

  /// جدولة إشعار السلسلة (عندما تكون السلسلة في خطر)
  static Future<void> scheduleStreakReminder() async {
    final hasPermission = await _checkPermissions();
    if (!hasPermission) return;
    
    final streak = await UserPreferencesService.getCurrentStreak();
    final progress = HiveService.getUserProgress();
    
    // إذا كانت السلسلة >= 3 أيام ولم يدرس اليوم
    if (streak >= 3) {
      final answers = progress?['answers'] as Map<String, dynamic>?;
      if (answers != null) {
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        
        bool studiedToday = false;
        answers.forEach((key, value) {
          if (value is Map && value['timestamp'] != null) {
            try {
              final timestamp = DateTime.parse(value['timestamp'] as String);
              if (timestamp.isAfter(todayStart) || timestamp.isAtSameMomentAs(todayStart)) {
                studiedToday = true;
              }
            } catch (e) {
              // Ignore invalid timestamps
            }
          }
        });
        
        // إذا لم يدرس اليوم، جدول إشعار في المساء
        if (!studiedToday) {
          final languageCode = (await SharedPreferences.getInstance())
              .getString('language') ?? 'en';
          final notificationText = _getStreakNotificationText(languageCode, streak);
          
          // جدولة إشعار في الساعة 8 مساءً
          final now = DateTime.now();
          var scheduledDate = DateTime(now.year, now.month, now.day, 20, 0);
          if (scheduledDate.isBefore(now)) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }
          
          final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);
          
          const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
            'streak_reminder',
            'Streak Reminder',
            channelDescription: 'Reminds you to maintain your study streak',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
          );
          
          const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );
          
          const NotificationDetails notificationDetails = NotificationDetails(
            android: androidDetails,
            iOS: iosDetails,
          );
          
          try {
          try {
            await _notifications.zonedSchedule(
              _streakReminderId,
              notificationText['title'] ?? 'Don\'t Break Your Streak!',
              notificationText['body'] ?? 'Keep your streak alive',
              scheduledTZ,
              notificationDetails,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              payload: 'streak_reminder',
            );
          } catch (e) {
            // استخدام وضع بديل إذا فشل exact
            await _notifications.zonedSchedule(
              _streakReminderId,
              notificationText['title'] ?? 'Don\'t Break Your Streak!',
              notificationText['body'] ?? 'Keep your streak alive',
              scheduledTZ,
              notificationDetails,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              payload: 'streak_reminder',
            );
          }
          } catch (e) {
            // استخدام وضع بديل إذا فشل exact
            await _notifications.zonedSchedule(
              _streakReminderId,
              notificationText['title'] ?? 'Don\'t Break Your Streak!',
              notificationText['body'] ?? 'Keep your streak alive',
              scheduledTZ,
              notificationDetails,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              payload: 'streak_reminder',
            );
          }
        }
      }
    }
  }

  /// التحقق من الصلاحيات
  static Future<bool> _checkPermissions() async {
    // Android
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final granted = await androidImplementation.areNotificationsEnabled();
      if (granted != null) {
        return granted;
      }
    }
    
    // iOS
    final iosImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      final settings = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings ?? false;
    }
    
    return true; // Default to true if platform not detected
  }


  /// الحصول على نص إشعار SRS حسب اللغة
  static Map<String, String> _getSrsNotificationText(String languageCode, int count) {
    switch (languageCode) {
      case 'ar':
        return {
          'title': '📚 وقت المراجعة!',
          'body': 'لديك $count سؤال مستحق للمراجعة',
        };
      case 'de':
        return {
          'title': '📚 Zeit zur Wiederholung!',
          'body': 'Sie haben $count Fragen zur Überprüfung fällig',
        };
      case 'tr':
        return {
          'title': '📚 Gözden Geçirme Zamanı!',
          'body': 'Gözden geçirilmesi gereken $count sorunuz var',
        };
      case 'uk':
        return {
          'title': '📚 Час повторення!',
          'body': 'У вас $count питань, що потребують повторення',
        };
      case 'ru':
        return {
          'title': '📚 Время повторения!',
          'body': 'У вас $count вопросов, требующих повторения',
        };
      default: // en
        return {
          'title': '📚 Review Time!',
          'body': 'You have $count questions due for review',
        };
    }
  }

  /// الحصول على نص إشعار السلسلة حسب اللغة
  static Map<String, String> _getStreakNotificationText(String languageCode, int streak) {
    switch (languageCode) {
      case 'ar':
        return {
          'title': '🔥 لا تكسر سلسلتك!',
          'body': 'لديك $streak أيام متتالية! ادرس اليوم للحفاظ عليها.',
        };
      case 'de':
        return {
          'title': '🔥 Brechen Sie Ihre Serie nicht!',
          'body': 'Sie haben $streak Tage in Folge! Lernen Sie heute, um es zu erhalten.',
        };
      case 'tr':
        return {
          'title': '🔥 Serinizi Kırmayın!',
          'body': '$streak gün üst üste! Bugün çalışarak koruyun.',
        };
      case 'uk':
        return {
          'title': '🔥 Не ламайте свою серію!',
          'body': 'У вас $streak днів поспіль! Вчіться сьогодні, щоб зберегти її.',
        };
      case 'ru':
        return {
          'title': '🔥 Не прерывайте свою серию!',
          'body': 'У вас $streak дней подряд! Учитесь сегодня, чтобы сохранить её.',
        };
      default: // en
        return {
          'title': '🔥 Don\'t Break Your Streak!',
          'body': 'You have $streak days in a row! Study today to keep it.',
        };
    }
  }

  /// إلغاء إشعار معين
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// إلغاء جميع الإشعارات
  static Future<void> cancelNotifications() async {
    await _notifications.cancel(_dailyReminderId);
    await _notifications.cancel(_srsReminderId);
    await _notifications.cancel(_streakReminderId);
    await _notifications.cancel(_progressReminderId);
  }

  /// التحقق من حالة الصلاحيات
  static Future<bool> hasPermission() async {
    return await _checkPermissions();
  }

  /// إرسال إشعار فوري (للاختبار)
  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test',
      'Test Notification',
      channelDescription: 'Test notification channel',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      999,
      'Test Notification',
      'Notifications are working!',
      notificationDetails,
    );
  }
}
