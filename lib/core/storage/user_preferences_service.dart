import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة لحفظ تفضيلات المستخدم (الولاية وتاريخ الامتحان)
class UserPreferencesService {
  static const String _keySelectedState = 'selected_state';
  static const String _keyExamDate = 'exam_date';
  static const String _keyIsFirstLaunch = 'is_first_launch';
  static const String _keyCurrentStreak = 'current_streak';
  static const String _keyLastStudyDate = 'last_study_date';
  static const String _keyIsReminderOn = 'is_reminder_on';
  static const String _keyReminderTime = 'reminder_time';
  static const String _keyUserName = 'user_name';
  static const String _keyUserAvatarPath = 'user_avatar_path';
  static const String _keyAllowNameSync = 'allow_name_sync';
  static const String _keyNameChangeCount = 'name_change_count';
  static const String _keyOriginalName = 'original_name'; // للتحقق من التغيير الأول

  /// التحقق من أول إطلاق للتطبيق
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFirstLaunch) ?? true;
  }

  /// تعيين أن التطبيق تم إطلاقه (ليس أول مرة)
  static Future<void> setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFirstLaunch, false);
  }

  /// حفظ الولاية المختارة
  static Future<void> saveSelectedState(String stateCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedState, stateCode);
  }

  /// جلب الولاية المحفوظة
  static Future<String?> getSelectedState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedState);
  }

  /// حفظ تاريخ الامتحان
  static Future<void> saveExamDate(DateTime examDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyExamDate, examDate.toIso8601String());
  }

  /// جلب تاريخ الامتحان
  static Future<DateTime?> getExamDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_keyExamDate);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  /// حساب الأيام المتبقية حتى الامتحان
  static Future<int?> getDaysUntilExam() async {
    final examDate = await getExamDate();
    if (examDate == null) return null;
    
    final now = DateTime.now();
    final difference = examDate.difference(now);
    return difference.inDays;
  }

  /// حفظ الـ Streak الحالي
  static Future<void> saveCurrentStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentStreak, streak);
  }

  /// جلب الـ Streak الحالي
  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCurrentStreak) ?? 0;
  }

  /// حفظ آخر تاريخ دراسة
  static Future<void> saveLastStudyDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastStudyDate, date.toIso8601String());
  }

  /// جلب آخر تاريخ دراسة
  static Future<DateTime?> getLastStudyDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_keyLastStudyDate);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  /// تحديث الـ Streak تلقائياً عند فتح التطبيق
  static Future<int> updateStreak() async {
    final lastStudyDate = await getLastStudyDate();
    final currentStreak = await getCurrentStreak();
    final now = DateTime.now();

    if (lastStudyDate == null) {
      // أول مرة
      await saveLastStudyDate(now);
      await saveCurrentStreak(1);
      return 1;
    }

    final daysDifference = now.difference(lastStudyDate).inDays;

    if (daysDifference == 0) {
      // نفس اليوم - لا تغيير
      return currentStreak;
    } else if (daysDifference == 1) {
      // يوم متتالي - زيادة الـ streak
      final newStreak = currentStreak + 1;
      await saveCurrentStreak(newStreak);
      await saveLastStudyDate(now);
      return newStreak;
    } else {
      // انقطاع - إعادة تعيين
      await saveCurrentStreak(1);
      await saveLastStudyDate(now);
      return 1;
    }
  }

  /// جلب SharedPreferences instance
  static Future<SharedPreferences> getSharedPreferences() async {
    return await SharedPreferences.getInstance();
  }

  /// حفظ حالة الإشعارات (مفعل/معطل)
  static Future<void> saveReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsReminderOn, enabled);
  }

  /// جلب حالة الإشعارات
  static Future<bool> getReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsReminderOn) ?? false;
  }

  /// حفظ وقت الإشعار (TimeOfDay كـ String "HH:mm")
  static Future<void> saveReminderTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await prefs.setString(_keyReminderTime, timeString);
  }

  /// جلب وقت الإشعار
  static Future<TimeOfDay?> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_keyReminderTime);
    if (timeString != null) {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }
    return const TimeOfDay(hour: 20, minute: 0); // Default: 20:00
  }

  /// حفظ اسم المستخدم
  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }

  /// جلب اسم المستخدم
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  /// حفظ مسار صورة المستخدم (محلي)
  static Future<void> saveUserAvatarPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserAvatarPath, path);
  }

  /// جلب مسار صورة المستخدم
  static Future<String?> getUserAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserAvatarPath);
  }

  /// حفظ إعداد السماح بمزامنة الاسم في قاعدة البيانات
  static Future<void> saveAllowNameSync(bool allow) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAllowNameSync, allow);
  }

  /// جلب إعداد السماح بمزامنة الاسم
  static Future<bool> getAllowNameSync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAllowNameSync) ?? false; // Default: false (privacy-first)
  }

  /// جلب عدد مرات تغيير الاسم
  static Future<int> getNameChangeCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyNameChangeCount) ?? 0;
  }

  /// زيادة عدد مرات تغيير الاسم
  static Future<int> incrementNameChangeCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = await getNameChangeCount();
    final newCount = currentCount + 1;
    await prefs.setInt(_keyNameChangeCount, newCount);
    return newCount;
  }

  /// حفظ الاسم الأصلي (للتحقق من التغيير الأول)
  static Future<void> saveOriginalName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_keyOriginalName);
    if (existing == null && name.isNotEmpty) {
      await prefs.setString(_keyOriginalName, name);
    }
  }

  /// جلب الاسم الأصلي
  static Future<String?> getOriginalName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyOriginalName);
  }

  /// مسح جميع التفضيلات
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySelectedState);
    await prefs.remove(_keyExamDate);
    await prefs.remove(_keyIsFirstLaunch);
    await prefs.remove(_keyCurrentStreak);
    await prefs.remove(_keyLastStudyDate);
    await prefs.remove(_keyIsReminderOn);
    await prefs.remove(_keyReminderTime);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserAvatarPath);
    await prefs.remove(_keyAllowNameSync);
  }
}

