import 'package:flutter/material.dart';
import '../../core/storage/hive_service.dart';
import '../../core/debug/app_logger.dart';

/// Widget لتتبع وقت الدراسة
/// يبدأ العد عند initState ويحفظ الوقت عند dispose
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTime = DateTime.now();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveStudyTime();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App went to background - save current time
      _saveStudyTime();
      _isActive = false;
    } else if (state == AppLifecycleState.resumed && !_isActive) {
      // App resumed - restart timer
      _startTime = DateTime.now();
      _isActive = true;
    }
  }

  void _saveStudyTime() {
    if (_startTime != null && _isActive) {
      final elapsed = DateTime.now().difference(_startTime!).inSeconds;
      if (elapsed > 10) {
        // Only save if more than 10 seconds to avoid accidental clicks
        HiveService.addStudyTime(elapsed);
        AppLogger.event('Study time saved', source: 'TimeTracker', data: {
          'seconds': elapsed,
        });
      }
      _startTime = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

