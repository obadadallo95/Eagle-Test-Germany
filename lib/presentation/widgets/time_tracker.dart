import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/storage/hive_service.dart';

/// Widget لتتبع وقت الدراسة
/// يبدأ العد عند initState ويحفظ الوقت عند dispose
/// يستخدم نظام تجميع ذكي لتقليل استهلاك الموارد
class TimeTracker extends StatefulWidget {
  final Widget child;

  const TimeTracker({
    super.key,
    required this.child,
  });

  @override
  State<TimeTracker> createState() => _TimeTrackerState();
}

class _TimeTrackerState extends State<TimeTracker> with WidgetsBindingObserver {
  DateTime? _startTime;
  bool _isActive = true;
  Timer? _periodicSaveTimer;
  DateTime? _lastPeriodicSave;
  static const int _periodicSaveIntervalSeconds = 60; // حفظ كل دقيقة

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTime = DateTime.now();
    _lastPeriodicSave = DateTime.now();
    
    // بدء الحفظ الدوري
    _startPeriodicSave();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _periodicSaveTimer?.cancel();
    _saveStudyTime(force: true); // إجبار الحفظ عند الإغلاق
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App went to background - save current accumulated time
      _saveStudyTime(force: true);
      _isActive = false;
      _periodicSaveTimer?.cancel();
    } else if (state == AppLifecycleState.resumed && !_isActive) {
      // App resumed - restart timer
      _startTime = DateTime.now();
      _isActive = true;
      _lastPeriodicSave = DateTime.now();
      _startPeriodicSave();
    }
  }

  /// بدء الحفظ الدوري
  void _startPeriodicSave() {
    _periodicSaveTimer?.cancel();
    _periodicSaveTimer = Timer.periodic(
      const Duration(seconds: _periodicSaveIntervalSeconds),
      (timer) {
        if (_isActive && _startTime != null) {
          _saveStudyTime(periodic: true);
        }
      },
    );
  }

  /// حفظ وقت الدراسة (مع تجميع ذكي)
  void _saveStudyTime({bool force = false, bool periodic = false}) {
    if (!_isActive && !force) return;

    final now = DateTime.now();
    
    if (periodic) {
      // في الحفظ الدوري، احسب الوقت منذ آخر حفظ دوري
      if (_lastPeriodicSave != null && _startTime != null) {
        final timeSinceLastSave = now.difference(_lastPeriodicSave!).inSeconds;
        if (timeSinceLastSave >= 10) { // فقط إذا مر 10 ثواني على الأقل
          HiveService.addStudyTime(timeSinceLastSave);
          _lastPeriodicSave = now;
          _startTime = now; // إعادة تعيين وقت البداية
        }
      }
    } else if (_startTime != null) {
      // حفظ فوري (عند الإغلاق أو تغيير الحالة)
      final elapsed = now.difference(_startTime!).inSeconds;
      if (elapsed >= 10 || force) { // حفظ إذا كان 10 ثواني أو أكثر، أو إذا كان إجبار
        HiveService.addStudyTime(elapsed);
        _startTime = null;
      }
    }

    if (force) {
      // إجبار الحفظ الفوري في Hive
      HiveService.forceFlushStudyTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

