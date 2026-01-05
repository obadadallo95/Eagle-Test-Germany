import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/services/subscription_service.dart';
import '../../core/debug/app_logger.dart';

/// State class لإدارة حالة الاشتراك
class SubscriptionState {
  final bool isPro;
  final Offerings? offerings;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.isPro = false,
    this.offerings,
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    bool? isPro,
    Offerings? offerings,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      isPro: isPro ?? this.isPro,
      offerings: offerings ?? this.offerings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// StateNotifier لإدارة حالة الاشتراك
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier() : super(const SubscriptionState(isLoading: true)) {
    _initialize();
  }

  /// تهيئة الاشتراك
  Future<void> _initialize() async {
    AppLogger.functionStart('_initialize', source: 'SubscriptionNotifier');
    
    try {
      // التحقق من حالة الاشتراك
      final isPro = await SubscriptionService.checkSubscriptionStatus();
      
      // جلب العروض المتاحة
      final offerings = await SubscriptionService.fetchOfferings();
      
      state = SubscriptionState(
        isPro: isPro,
        offerings: offerings,
        isLoading: false,
      );
      
      AppLogger.event('Subscription initialized', source: 'SubscriptionNotifier', data: {
        'isPro': isPro,
        'hasOfferings': offerings != null,
      });
      
      AppLogger.functionEnd('_initialize', source: 'SubscriptionNotifier');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize subscription', source: 'SubscriptionNotifier', error: e, stackTrace: stackTrace);
      state = SubscriptionState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// شراء Package
  Future<bool> purchasePackage(Package package) async {
    AppLogger.functionStart('purchasePackage', source: 'SubscriptionNotifier');
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final customerInfo = await SubscriptionService.purchasePackage(package);
      
      if (customerInfo != null) {
        final isPro = customerInfo.entitlements.all['pro_access']?.isActive ?? false;
        state = state.copyWith(
          isPro: isPro,
          isLoading: false,
        );
        
        AppLogger.event('Purchase completed', source: 'SubscriptionNotifier', data: {
          'isPro': isPro,
          'packageId': package.identifier,
        });
        
        AppLogger.functionEnd('purchasePackage', source: 'SubscriptionNotifier', result: isPro);
        return isPro;
      } else {
        state = state.copyWith(isLoading: false);
        AppLogger.functionEnd('purchasePackage', source: 'SubscriptionNotifier', result: false);
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Purchase failed', source: 'SubscriptionNotifier', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      AppLogger.functionEnd('purchasePackage', source: 'SubscriptionNotifier', result: false);
      return false;
    }
  }

  /// استعادة المشتريات
  Future<bool> restorePurchases() async {
    AppLogger.functionStart('restorePurchases', source: 'SubscriptionNotifier');
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final customerInfo = await SubscriptionService.restorePurchases();
      
      if (customerInfo != null) {
        final isPro = customerInfo.entitlements.all['pro_access']?.isActive ?? false;
        state = state.copyWith(
          isPro: isPro,
          isLoading: false,
        );
        
        AppLogger.event('Purchases restored', source: 'SubscriptionNotifier', data: {
          'isPro': isPro,
        });
        
        AppLogger.functionEnd('restorePurchases', source: 'SubscriptionNotifier', result: isPro);
        return isPro;
      } else {
        state = state.copyWith(isLoading: false);
        AppLogger.functionEnd('restorePurchases', source: 'SubscriptionNotifier', result: false);
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Restore failed', source: 'SubscriptionNotifier', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      AppLogger.functionEnd('restorePurchases', source: 'SubscriptionNotifier', result: false);
      return false;
    }
  }

  /// إعادة تحميل حالة الاشتراك
  Future<void> refresh() async {
    await _initialize();
  }
}

/// Provider لإدارة حالة الاشتراك
final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier();
});

