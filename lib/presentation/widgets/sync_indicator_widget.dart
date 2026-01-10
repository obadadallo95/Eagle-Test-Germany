import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/subscription_service.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Sync indicator widget that shows sync status in AppBar
/// 
/// **Pro Feature Only**: This widget only appears for Pro users.
/// Free users will see nothing (SizedBox.shrink).
/// 
/// Displays a small spinner when syncing, or a checkmark when synced.
class SyncIndicatorWidget extends ConsumerStatefulWidget {
  const SyncIndicatorWidget({super.key});

  @override
  ConsumerState<SyncIndicatorWidget> createState() => _SyncIndicatorWidgetState();
}

class _SyncIndicatorWidgetState extends ConsumerState<SyncIndicatorWidget> {
  bool _isSyncing = false;
  bool _lastSyncSuccess = false;
  bool _isPro = false; // Track Pro status to hide widget for Free users
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAndCheckSync();
  }

  Future<void> _initializeAndCheckSync() async {
    // Check Pro status first
    final isPro = await SubscriptionService.isProUser();
    if (mounted) {
      setState(() {
        _isPro = isPro;
        _isInitialized = true;
      });
    }
    
    // Only proceed with sync if Pro user
    if (isPro) {
      _checkSyncStatus();
      _startPeriodicSyncCheck();
    }
  }

  void _startPeriodicSyncCheck() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isPro) {
        _checkSyncStatus();
        _startPeriodicSyncCheck();
      }
    });
  }

  Future<void> _checkSyncStatus() async {
    if (!SyncService.isAvailable || !_isPro) {
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    try {
      await SyncService.syncProgressToCloud();
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _lastSyncSuccess = true;
        });
        // Reset success indicator after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _lastSyncSuccess = false;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _lastSyncSuccess = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    
    // COMPLETELY HIDE for Free users - no icon at all
    if (!_isInitialized || !_isPro || !SyncService.isAvailable) {
      return const SizedBox.shrink();
    }

    Widget iconWidget;
    String tooltip;

    if (_isSyncing) {
      iconWidget = SizedBox(
        width: 20.w,
        height: 20.h,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(primaryGold),
        ),
      );
      tooltip = l10n?.syncingProgress ?? 'Syncing progress...';
    } else if (_lastSyncSuccess) {
      iconWidget = Icon(
        Icons.cloud_done,
        size: 20.sp,
        color: primaryGold,
      );
      tooltip = l10n?.progressSynced ?? 'Progress synced';
    } else {
      // Pro user: show gold cloud icon
      iconWidget = Icon(
        Icons.cloud,
        size: 20.sp,
        color: primaryGold.withValues(alpha: 0.7),
      );
      tooltip = l10n?.cloudSync ?? 'Cloud sync';
    }

    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: iconWidget,
      ),
    );
  }
}
