import 'package:purchases_flutter/purchases_flutter.dart';
import '../debug/app_logger.dart';

/// خدمة إدارة الاشتراكات باستخدام RevenueCat
class SubscriptionService {
  static const String _entitlementId = 'pro_access';
  
  // API Keys - RevenueCat API Key
  // Using test API key for development
  static const String _apiKey = 'test_rFXIKCHeRdDYqpessQtlqMacqlT';
  
  static bool _isInitialized = false;

  /// تهيئة RevenueCat
  static Future<void> init() async {
    if (_isInitialized) {
      AppLogger.warn('SubscriptionService already initialized', source: 'SubscriptionService');
      return;
    }

    AppLogger.functionStart('SubscriptionService.init', source: 'SubscriptionService');
    
    try {
      // تهيئة RevenueCat باستخدام API Key الموحد
      await Purchases.setLogLevel(LogLevel.debug); // في الإنتاج استخدم LogLevel.info
      await Purchases.configure(
        PurchasesConfiguration(_apiKey)
          ..appUserID = null // RevenueCat will generate anonymous ID
      );

      // إعداد listener للتحديثات
      Purchases.addCustomerInfoUpdateListener(_handleCustomerInfoUpdate);

      _isInitialized = true;
      AppLogger.event('RevenueCat initialized successfully', source: 'SubscriptionService');
      AppLogger.functionEnd('SubscriptionService.init', source: 'SubscriptionService');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize RevenueCat', source: 'SubscriptionService', error: e, stackTrace: stackTrace);
      _isInitialized = true; // Mark as initialized to prevent retry loops
      rethrow;
    }
  }

  /// معالج تحديث معلومات العميل
  static void _handleCustomerInfoUpdate(CustomerInfo customerInfo) {
    AppLogger.functionStart('_handleCustomerInfoUpdate', source: 'SubscriptionService');
    final isPro = customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
    AppLogger.event('Customer info updated', source: 'SubscriptionService', data: {
      'isPro': isPro,
      'activeEntitlements': customerInfo.entitlements.active.keys.toList(),
    });
    AppLogger.functionEnd('_handleCustomerInfoUpdate', source: 'SubscriptionService');
  }

  /// جلب العروض المتاحة (Packages)
  /// في حالة فشل الاتصال أو عدم وجود عروض، يتم إرجاع Mock Offerings
  static Future<Offerings?> fetchOfferings() async {
    AppLogger.functionStart('fetchOfferings', source: 'SubscriptionService');
    
    try {
      if (!_isInitialized) {
        await init();
      }

      final offerings = await Purchases.getOfferings();
      
      // التحقق من وجود عروض صالحة
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        AppLogger.event('Offerings fetched successfully', source: 'SubscriptionService', data: {
          'packagesCount': offerings.current!.availablePackages.length,
        });
        AppLogger.functionEnd('fetchOfferings', source: 'SubscriptionService');
        return offerings;
      }
      
      // إذا لم تكن هناك عروض، نستخدم Mock Mode
      AppLogger.warn('No current offering available, using Mock Mode', source: 'SubscriptionService');
      return _createMockOfferings();
    } catch (e) {
      // في حالة حدوث خطأ، نستخدم Mock Mode بدلاً من إرجاع null
      AppLogger.warn('Failed to fetch offerings, using Mock Mode', source: 'SubscriptionService');
      return _createMockOfferings();
    }
  }

  /// إنشاء Mock Offerings للاستخدام أثناء التطوير
  /// تحاكي هيكلية RevenueCat تماماً
  /// ملاحظة: RevenueCat SDK لا يوفر Mock classes مباشرة، لذلك نستخدم طريقة بديلة
  /// بإرجاع null وإضافة fallback في PaywallScreen
  static Offerings? _createMockOfferings() {
    AppLogger.info('Mock Mode: Creating fallback data structure', source: 'SubscriptionService');
    
    // ملاحظة: RevenueCat SDK لا يسمح بإنشاء Package أو StoreProduct مباشرة
    // لذلك سنستخدم علامة خاصة في PaywallScreen لعرض Mock data
    // نعيد null هنا وسيتم التعامل معها في PaywallScreen
    
    AppLogger.event('Mock Mode activated', source: 'SubscriptionService', data: {
      'mode': 'MOCK',
      'note': 'PaywallScreen will use fallback mock data',
    });
    
    // نعيد null وسيتم التعامل معها في PaywallScreen
    return null;
  }

  /// شراء Package
  /// Returns: CustomerInfo if successful, null if cancelled or failed
  static Future<CustomerInfo?> purchasePackage(Package package) async {
    AppLogger.functionStart('purchasePackage', source: 'SubscriptionService');
    AppLogger.info('Purchasing package: ${package.identifier}', source: 'SubscriptionService');
    
    try {
      if (!_isInitialized) {
        await init();
      }

      final purchaserInfo = await Purchases.purchasePackage(package);
      
      // التحقق من الاشتراك النشط
      final isPro = purchaserInfo.entitlements.all[_entitlementId]?.isActive ?? false;
      
      if (isPro) {
        AppLogger.event('Purchase successful', source: 'SubscriptionService', data: {
          'packageId': package.identifier,
          'isPro': true,
        });
        AppLogger.functionEnd('purchasePackage', source: 'SubscriptionService', result: true);
        return purchaserInfo;
      } else {
        AppLogger.warn('Purchase completed but entitlement not active', source: 'SubscriptionService');
        AppLogger.functionEnd('purchasePackage', source: 'SubscriptionService', result: false);
        return null;
      }
    } on PurchasesError catch (e) {
      // معالجة أخطاء RevenueCat
      if (e.code == PurchasesErrorCode.purchaseCancelledError) {
        AppLogger.info('Purchase cancelled by user', source: 'SubscriptionService');
      } else {
        AppLogger.error('Purchase failed', source: 'SubscriptionService', error: e, stackTrace: StackTrace.current);
      }
      AppLogger.functionEnd('purchasePackage', source: 'SubscriptionService', result: false);
      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during purchase', source: 'SubscriptionService', error: e, stackTrace: stackTrace);
      AppLogger.functionEnd('purchasePackage', source: 'SubscriptionService', result: false);
      return null;
    }
  }

  /// استعادة المشتريات السابقة
  static Future<CustomerInfo?> restorePurchases() async {
    AppLogger.functionStart('restorePurchases', source: 'SubscriptionService');
    
    try {
      if (!_isInitialized) {
        await init();
      }

      final customerInfo = await Purchases.restorePurchases();
      
      final isPro = customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
      
      AppLogger.event('Purchases restored', source: 'SubscriptionService', data: {
        'isPro': isPro,
        'activeEntitlements': customerInfo.entitlements.active.keys.toList(),
      });
      
      AppLogger.functionEnd('restorePurchases', source: 'SubscriptionService', result: isPro);
      return customerInfo;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to restore purchases', source: 'SubscriptionService', error: e, stackTrace: stackTrace);
      AppLogger.functionEnd('restorePurchases', source: 'SubscriptionService', result: false);
      return null;
    }
  }

  /// التحقق من حالة الاشتراك
  /// Returns: true if user has active Pro subscription
  static Future<bool> checkSubscriptionStatus() async {
    AppLogger.functionStart('checkSubscriptionStatus', source: 'SubscriptionService');
    
    try {
      if (!_isInitialized) {
        await init();
      }

      final customerInfo = await Purchases.getCustomerInfo();
      final isPro = customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
      
      AppLogger.event('Subscription status checked', source: 'SubscriptionService', data: {
        'isPro': isPro,
        'activeEntitlements': customerInfo.entitlements.active.keys.toList(),
      });
      
      AppLogger.functionEnd('checkSubscriptionStatus', source: 'SubscriptionService', result: isPro);
      return isPro;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check subscription status', source: 'SubscriptionService', error: e, stackTrace: stackTrace);
      AppLogger.functionEnd('checkSubscriptionStatus', source: 'SubscriptionService', result: false);
      return false;
    }
  }

  /// جلب معلومات العميل الحالية
  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      if (!_isInitialized) {
        await init();
      }
      return await Purchases.getCustomerInfo();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get customer info', source: 'SubscriptionService', error: e, stackTrace: stackTrace);
      return null;
    }
  }
}

