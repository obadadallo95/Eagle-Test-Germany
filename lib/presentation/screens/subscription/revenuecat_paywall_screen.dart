import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/debug/app_logger.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';

/// RevenueCat Paywall Screen using official RevenueCat UI
/// 
/// This screen uses the official RevenueCat Paywall UI widget
/// which automatically handles:
/// - Displaying packages from RevenueCat
/// - Purchase flow
/// - Error handling
/// - Restore purchases
/// 
/// To use this screen, ensure you have:
/// 1. Configured offerings in RevenueCat Dashboard
/// 2. Set up products in Google Play Console / App Store Connect
/// 3. Linked products to offerings in RevenueCat
class RevenueCatPaywallScreen extends ConsumerStatefulWidget {
  const RevenueCatPaywallScreen({super.key});

  @override
  ConsumerState<RevenueCatPaywallScreen> createState() =>
      _RevenueCatPaywallScreenState();
}

class _RevenueCatPaywallScreenState
    extends ConsumerState<RevenueCatPaywallScreen> {
  bool _isLoading = true;
  Offerings? _offerings;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final offerings = await SubscriptionService.fetchOfferings();
      
      if (mounted) {
        setState(() {
          _offerings = offerings;
          _isLoading = false;
          
          if (offerings?.current == null) {
            _error = 'No offerings available. Please check RevenueCat configuration.';
          }
        });
      }
    } catch (e) {
      AppLogger.error('Failed to load offerings',
          source: 'RevenueCatPaywallScreen', error: e);
      
      if (mounted) {
        setState(() {
          _error = 'Failed to load subscription options. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Subscription'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AdaptivePageWrapper(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.sp,
                color: Colors.red,
              ),
              SizedBox(height: 16.h),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: _loadOfferings,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_offerings?.current == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 64.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                'No subscription options available.\nPlease check RevenueCat configuration.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp),
              ),
            ],
          ),
        ),
      );
    }

    // Use RevenueCat Paywall UI
    return PaywallView(
      offering: _offerings!.current!,
      onPurchaseCompleted: (customerInfo, storeTransaction) {
        AppLogger.event('Purchase completed from Paywall',
            source: 'RevenueCatPaywallScreen');
        // Close paywall and return success
        Navigator.pop(context, true);
      },
      onRestoreCompleted: (customerInfo) {
        AppLogger.event('Restore completed from Paywall',
            source: 'RevenueCatPaywallScreen');
        // Check if user now has active subscription
        final isPro = customerInfo.entitlements.all[SubscriptionService.entitlementId]?.isActive ?? false;
        if (isPro && mounted) {
          Navigator.pop(context, true);
        }
      },
      onDismiss: () {
        AppLogger.info('Paywall dismissed',
            source: 'RevenueCatPaywallScreen');
      },
    );
  }
}

