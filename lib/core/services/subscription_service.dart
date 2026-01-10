import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../debug/app_logger.dart';

/// خدمة إدارة الاشتراكات باستخدام RevenueCat
///
/// هذه الخدمة توفر:
/// - تهيئة RevenueCat SDK
/// - جلب العروض والمنتجات
/// - شراء واستعادة المشتريات
/// - التحقق من حالة الاشتراك (Eagle Test Pro)
/// - إدارة معلومات العميل
class SubscriptionService {
  /// معرف الاستحقاق (Entitlement) للاشتراك Pro
  ///
  /// ⚠️ ملاحظة: تأكد أن هذا الـ ID يطابق الـ identifier في RevenueCat Dashboard
  /// RevenueCat Dashboard → Entitlements → [Your Entitlement] → Identifier
  ///
  /// إذا كان الـ identifier في RevenueCat مختلف، غيّر هذا المتغير ليطابقه
  static const String entitlementId = 'Eagle Test Pro';

  /// الـ entitlement ID البديل (للتوافق مع الإصدارات السابقة)
  /// يمكن استخدامه كـ fallback إذا كان الـ entitlement ID الرئيسي غير موجود
  static const String fallbackEntitlementId = 'pro_access';

  /// معرفات المنتجات المتوقعة
  static const String monthlyProductId = 'monthly';
  static const String yearlyProductId = 'yearly';
  static const String lifetimeProductId = 'lifetime';

  // API Keys - RevenueCat API Key
  // ⚠️ IMPORTANT: Replace with your actual API key from RevenueCat Dashboard
  // Get it from: Project Settings → API Keys → Public SDK Keys → Android/iOS

  // Test API Key (for development/debug builds)
  static const String _testApiKey = 'test_rFXIKOHeKdBYqpessQtlqMacqlT';

  // Production API Key (for release builds)
  // Get it from: Project Settings → API Keys → Public SDK Keys → Android/iOS (Production)
  // ⚠️ IMPORTANT: Set this to null to disable RevenueCat in release builds (app will work in free mode)
  static const String? _productionApiKey =
      null; // Set to null to disable RevenueCat, or add your production key

  /// Get the appropriate API key based on build mode
  /// - Debug mode: Uses test API key
  /// - Release mode: Uses production API key (or null to disable RevenueCat)
  static String? get _apiKey {
    if (kDebugMode) {
      // Debug mode: Use test API key
      return _testApiKey;
    } else {
      // Release mode: Use production API key (or null to disable)
      return _productionApiKey;
    }
  }

  static bool _isInitialized = false;

  /// تهيئة RevenueCat SDK
  ///
  /// يجب استدعاء هذه الدالة عند بدء التطبيق (في main.dart)
  ///
  /// Features:
  /// - Configures RevenueCat with API key
  /// - Sets up customer info update listener
  /// - Enables debug logging in development
  static Future<void> init() async {
    if (_isInitialized) {
      AppLogger.warn('SubscriptionService already initialized',
          source: 'SubscriptionService');
      return;
    }

    AppLogger.functionStart('SubscriptionService.init',
        source: 'SubscriptionService');

    try {
      // Get the appropriate API key based on build mode
      final apiKey = _apiKey;

      // If no API key is set (production mode without key), skip RevenueCat initialization
      // App will work in free mode without subscriptions
      if (apiKey == null || apiKey.isEmpty) {
        AppLogger.warn(
            'RevenueCat API key not set. App will work in free mode without subscriptions.',
            source: 'SubscriptionService');
        _isInitialized = true; // Mark as initialized to prevent retry loops
        return; // Skip RevenueCat initialization
      }

      // Log which API key is being used (without exposing the full key)
      final apiKeyPreview = apiKey.length > 10
          ? '${apiKey.substring(0, 10)}...${apiKey.substring(apiKey.length - 4)}'
          : '***';
      AppLogger.info(
          'Using API key: $apiKeyPreview (${kDebugMode ? "DEBUG" : "RELEASE"} mode)',
          source: 'SubscriptionService');

      // Enable debug logging in development only
      // In production, use LogLevel.info or LogLevel.warn
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      } else {
        await Purchases.setLogLevel(LogLevel.info);
      }

      // Configure RevenueCat with API key
      // Use Supabase user_id as RevenueCat appUserID for cross-device restore
      String? revenueCatUserId;
      try {
        final supabase = Supabase.instance.client;
        final session = supabase.auth.currentSession;
        if (session != null) {
          // Use Supabase user_id as RevenueCat user ID
          // This ensures subscriptions can be restored across devices
          revenueCatUserId = session.user.id;
          AppLogger.info('Linking RevenueCat to Supabase user: $revenueCatUserId', 
              source: 'SubscriptionService');
        }
      } catch (e) {
        AppLogger.warn('Failed to get Supabase user ID for RevenueCat: $e', 
            source: 'SubscriptionService');
        // Fallback to anonymous if Supabase not available
      }

      await Purchases.configure(
        PurchasesConfiguration(apiKey)
          ..appUserID = revenueCatUserId, // Use Supabase user_id instead of anonymous
      );
      
      // If we have a Supabase user_id, also check if there's an existing RevenueCat customer ID
      if (revenueCatUserId != null) {
        await _linkExistingRevenueCatCustomer(revenueCatUserId);
      }

      // Set up listener for customer info updates
      // This will be called automatically when subscription status changes
      Purchases.addCustomerInfoUpdateListener(_handleCustomerInfoUpdate);

      _isInitialized = true;
      AppLogger.event('RevenueCat initialized successfully',
          source: 'SubscriptionService');
      AppLogger.functionEnd('SubscriptionService.init',
          source: 'SubscriptionService');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize RevenueCat',
          source: 'SubscriptionService', error: e, stackTrace: stackTrace);
      _isInitialized = true; // Mark as initialized to prevent retry loops
      rethrow;
    }
  }

  /// معالج تحديث معلومات العميل
  ///
  /// يتم استدعاء هذه الدالة تلقائياً عند تغيير حالة الاشتراك
  /// (مثلاً: عند شراء اشتراك جديد، أو انتهاء اشتراك)
  static void _handleCustomerInfoUpdate(CustomerInfo customerInfo) {
    AppLogger.functionStart('_handleCustomerInfoUpdate',
        source: 'SubscriptionService');

    final isPro =
        customerInfo.entitlements.all[entitlementId]?.isActive ?? false;

    AppLogger.event('Customer info updated',
        source: 'SubscriptionService',
        data: {
          'isPro': isPro,
          'activeEntitlements': customerInfo.entitlements.active.keys.toList(),
          'allEntitlements': customerInfo.entitlements.all.keys.toList(),
        });

    AppLogger.functionEnd('_handleCustomerInfoUpdate',
        source: 'SubscriptionService');
  }

  /// جلب العروض المتاحة (Offerings) من RevenueCat
  ///
  /// Returns:
  /// - Offerings object if successful
  /// - null if error occurred or no offerings available or RevenueCat not initialized
  ///
  /// The offerings contain packages (Monthly, Yearly, Lifetime) configured in RevenueCat Dashboard
  static Future<Offerings?> fetchOfferings() async {
    AppLogger.functionStart('fetchOfferings', source: 'SubscriptionService');

    try {
      if (!_isInitialized) {
        await init();
      }

      // If RevenueCat is not initialized (no API key), return null
      if (!_isInitialized || _apiKey == null) {
        AppLogger.warn('RevenueCat not initialized. Returning null offerings.',
            source: 'SubscriptionService');
        return null;
      }

      // Fetch offerings from RevenueCat
      final offerings = await Purchases.getOfferings();

      // Log detailed information about fetched offerings
      if (offerings.current != null) {
        final current = offerings.current!;
        final packages = current.availablePackages;

        if (packages.isNotEmpty) {
          // ✅ Successfully fetched offerings with packages
          AppLogger.event('✅ Offerings fetched successfully',
              source: 'SubscriptionService',
              data: {
                'offeringIdentifier': current.identifier,
                'packagesCount': packages.length,
                'packageIdentifiers':
                    packages.map((p) => p.identifier).toList(),
                'packageTypes':
                    packages.map((p) => p.packageType.toString()).toList(),
              });
        } else {
          // ⚠️ Offering exists but has no packages
          AppLogger.warn(
              '⚠️ Offerings are empty! Check Google Play / RevenueCat setup.',
              source: 'SubscriptionService');
          AppLogger.event('Offerings details',
              source: 'SubscriptionService',
              data: {
                'offeringIdentifier': current.identifier,
                'packagesCount': 0,
              });
        }
      } else {
        // ⚠️ No current offering configured
        AppLogger.warn('⚠️ No current offering returned from RevenueCat.',
            source: 'SubscriptionService');
        AppLogger.info(
            'Make sure you have configured an offering in RevenueCat Dashboard',
            source: 'SubscriptionService');
      }

      AppLogger.functionEnd('fetchOfferings',
          source: 'SubscriptionService', result: 'SUCCESS');
      return offerings;
    } catch (e, stackTrace) {
      // ❌ Error fetching offerings
      AppLogger.error('❌ Error fetching offerings: $e',
          source: 'SubscriptionService', error: e, stackTrace: stackTrace);
      AppLogger.functionEnd('fetchOfferings',
          source: 'SubscriptionService', result: 'ERROR');
      return null;
    }
  }

  /// شراء Package (اشتراك)
  ///
  /// Parameters:
  /// - package: The Package to purchase (from offerings)
  ///
  /// Returns:
  /// - CustomerInfo if purchase successful
  /// - null if purchase cancelled, failed, or RevenueCat not initialized
  ///
  /// Error Handling:
  /// - PurchaseCancelledError: User cancelled the purchase
  /// - Other PurchasesError: Purchase failed (network, payment, etc.)
  static Future<CustomerInfo?> purchasePackage(Package package) async {
    AppLogger.functionStart('purchasePackage', source: 'SubscriptionService');
    AppLogger.info('Purchasing package: ${package.identifier}',
        source: 'SubscriptionService');

    try {
      if (!_isInitialized) {
        await init();
      }

      // If RevenueCat is not initialized (no API key), return null
      if (!_isInitialized || _apiKey == null) {
        AppLogger.warn('RevenueCat not initialized. Cannot purchase package.',
            source: 'SubscriptionService');
        return null;
      }

      // Purchase the package
      // This will show the native payment dialog
      final purchaseResult = await Purchases.purchase(PurchaseParams.package(package));

      // Get customer info after purchase
      final customerInfo = purchaseResult.customerInfo;

      // Log purchase result details
      AppLogger.event('Purchase result received',
          source: 'SubscriptionService',
          data: {
            'packageId': package.identifier,
            'packageType': package.packageType.toString(),
            'activeEntitlements':
                customerInfo.entitlements.active.keys.toList(),
            'allEntitlements': customerInfo.entitlements.all.keys.toList(),
          });

      // Verify that the entitlement is now active
      // First, try to find the expected entitlement ID
      var isPro =
          customerInfo.entitlements.all[entitlementId]?.isActive ?? false;

      // If the expected entitlement ID is not found, try the fallback ID
      if (!isPro) {
        isPro =
            customerInfo.entitlements.all[fallbackEntitlementId]?.isActive ??
                false;
        if (isPro) {
          AppLogger.info(
              'Using fallback entitlement ID: $fallbackEntitlementId',
              source: 'SubscriptionService');
        }
      }

      // If still not found, check if there are any active entitlements (last resort)
      // This handles cases where the entitlement ID in RevenueCat Dashboard differs from the code
      if (!isPro && customerInfo.entitlements.active.isNotEmpty) {
        // Check if any active entitlement exists (fallback)
        final activeEntitlementKeys =
            customerInfo.entitlements.active.keys.toList();
        AppLogger.warn(
            '⚠️ Expected entitlement IDs "$entitlementId" and "$fallbackEntitlementId" not found, but found active entitlements: $activeEntitlementKeys',
            source: 'SubscriptionService');

        // If there's at least one active entitlement, consider the purchase successful
        // This is a fallback for cases where entitlement ID doesn't match
        isPro = true;

        AppLogger.info(
            'Using fallback: Purchase considered successful because active entitlements exist',
            source: 'SubscriptionService');
      }

      if (isPro) {
        // CRITICAL: Sync subscription to Supabase and save RevenueCat customer ID
        // This ensures subscription can be restored if user switches devices
        await _syncSubscriptionToSupabase(
          isPro: true, 
          subscriptionType: 'revenuecat',
        );
        
        // Save RevenueCat customer ID to Supabase for restore
        await _saveRevenueCatCustomerId(customerInfo.originalAppUserId);
        
        // Track device and enforce 3-device limit for Pro users
        await _trackDeviceAndEnforceLimit(customerInfo.originalAppUserId);
        
        AppLogger.event('✅ Purchase successful - Pro access activated',
            source: 'SubscriptionService',
            data: {
              'packageId': package.identifier,
              'packageType': package.packageType.toString(),
              'isPro': true,
              'activeEntitlements':
                  customerInfo.entitlements.active.keys.toList(),
              'expectedEntitlementId': entitlementId,
              'revenuecatCustomerId': customerInfo.originalAppUserId,
            });
        AppLogger.functionEnd('purchasePackage',
            source: 'SubscriptionService', result: true);
        return customerInfo;
      } else {
        // Purchase completed but entitlement not active
        AppLogger.warn('⚠️ Purchase completed but entitlement not active',
            source: 'SubscriptionService');
        AppLogger.event('Entitlement check failed',
            source: 'SubscriptionService',
            data: {
              'packageId': package.identifier,
              'entitlementId': entitlementId,
              'activeEntitlements':
                  customerInfo.entitlements.active.keys.toList(),
              'allEntitlements': customerInfo.entitlements.all.keys.toList(),
              'entitlementExists':
                  customerInfo.entitlements.all.containsKey(entitlementId),
              'entitlementActive':
                  customerInfo.entitlements.all[entitlementId]?.isActive ??
                      false,
            });
        AppLogger.functionEnd('purchasePackage',
            source: 'SubscriptionService', result: false);
        return null;
      }
    } on PurchasesError catch (e) {
      // Handle RevenueCat specific errors
      if (e.code == PurchasesErrorCode.purchaseCancelledError) {
        AppLogger.info('Purchase cancelled by user',
            source: 'SubscriptionService');
      } else if (e.readableErrorCode == 'TestStoreSimulatedPurchaseError') {
        // Test Store simulated purchase failure (development mode)
        AppLogger.warn('⚠️ Test Store simulated purchase failure',
            source: 'SubscriptionService');
        AppLogger.info(
            'This is expected in development mode. Use a real test account for actual purchases.',
            source: 'SubscriptionService');
        AppLogger.event('Test Store error details',
            source: 'SubscriptionService',
            data: {
              'errorCode': e.code.toString(),
              'readableErrorCode': e.readableErrorCode,
              'message':
                  'Test Store is simulating purchase failure. This is normal in debug mode.',
            });
      } else {
        // Log detailed error information for other errors
        AppLogger.error('❌ Purchase failed',
            source: 'SubscriptionService',
            error: e,
            stackTrace: StackTrace.current);
        AppLogger.event('Purchase error details',
            source: 'SubscriptionService',
            data: {
              'errorCode': e.code.toString(),
              'errorMessage': e.message,
              'underlyingErrorMessage': e.underlyingErrorMessage,
              'readableErrorCode': e.readableErrorCode,
            });
      }
      AppLogger.functionEnd('purchasePackage',
          source: 'SubscriptionService', result: false);
      return null;
    } catch (e, stackTrace) {
      // Check if it's a PlatformException with TestStoreSimulatedPurchaseError
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('teststoresimulatedpurchaseerror') ||
          errorString.contains('test store') ||
          errorString.contains('simulated purchase')) {
        // Test Store simulated purchase failure (development mode)
        AppLogger.warn('⚠️ Test Store simulated purchase failure',
            source: 'SubscriptionService');
        AppLogger.info(
            'This is expected in development/debug mode. RevenueCat uses Test Store when:',
            source: 'SubscriptionService');
        AppLogger.info('1. App is running in debug mode, OR',
            source: 'SubscriptionService');
        AppLogger.info('2. No valid Google Play account is signed in, OR',
            source: 'SubscriptionService');
        AppLogger.info('3. Products are not activated in Google Play Console',
            source: 'SubscriptionService');
        AppLogger.info(
            'To test real purchases: Use a release build with a test account from Google Play Console',
            source: 'SubscriptionService');
        AppLogger.event('Test Store error',
            source: 'SubscriptionService',
            data: {
              'errorType': e.runtimeType.toString(),
              'errorMessage': e.toString(),
              'note':
                  'This is simulated by RevenueCat Test Store, not a real error',
            });
      } else {
        // Log unexpected errors with full details
        AppLogger.error('❌ Unexpected error during purchase: $e',
            source: 'SubscriptionService', error: e, stackTrace: stackTrace);
        AppLogger.event('Unexpected purchase error',
            source: 'SubscriptionService',
            data: {
              'errorType': e.runtimeType.toString(),
              'errorMessage': e.toString(),
            });
      }
      AppLogger.functionEnd('purchasePackage',
          source: 'SubscriptionService', result: false);
      return null;
    }
  }

  /// استعادة المشتريات السابقة
  ///
  /// ⚠️ مهم: RevenueCat يسترد الاشتراك تلقائياً عبر Apple/Google Account
  /// لكن نحتاج للتحقق من أن المستخدم هو صاحب الاشتراك
  ///
  /// يعمل على مرحلتين:
  /// 1. يتحقق من Supabase أولاً (إذا كان الاشتراك محفوظاً هناك - نفس الجهاز)
  /// 2. يحاول استرداد من RevenueCat (يعمل تلقائياً مع Apple/Google Account)
  ///    - RevenueCat يتحقق تلقائياً من Apple/Google Account
  ///    - إذا كان المستخدم يستخدم نفس Apple/Google Account → يسترد الاشتراك
  ///    - إذا لم يكن → لا يسترد (حماية من السرقة)
  ///
  /// Returns:
  /// - CustomerInfo if purchases were restored (and verified)
  /// - null if no purchases found, verification failed, or error occurred
  static Future<CustomerInfo?> restorePurchases() async {
    AppLogger.functionStart('restorePurchases', source: 'SubscriptionService');

    try {
      // First: Check if subscription exists in Supabase (same device scenario)
      final supabaseStatus = await _checkSubscriptionFromSupabase();
      if (supabaseStatus == true) {
        AppLogger.info('Subscription found in Supabase (same device). No need to restore from RevenueCat.',
            source: 'SubscriptionService');
        // Subscription already exists in Supabase, try to restore RevenueCat link
        await _restoreRevenueCatLink();
        AppLogger.functionEnd('restorePurchases',
            source: 'SubscriptionService', result: true);
        // Return a mock CustomerInfo or get from RevenueCat if linked
        try {
          if (_isInitialized) {
            return await Purchases.getCustomerInfo();
          }
        } catch (e) {
          // Ignore - Supabase subscription is enough
        }
        return null; // Supabase subscription is active
      }

      if (!_isInitialized) {
        await init();
      }

      // CRITICAL: Restore from RevenueCat
      // RevenueCat automatically verifies Apple/Google Account ownership
      // If user is signed in with same Apple/Google Account → restore works
      // If user is NOT signed in or different account → restore fails (security)
      AppLogger.info('Attempting to restore purchases from RevenueCat...', 
          source: 'SubscriptionService');
      AppLogger.info('Note: RevenueCat will verify Apple/Google Account ownership automatically.',
          source: 'SubscriptionService');

      // Restore purchases from RevenueCat
      // This will automatically verify Apple/Google Account
      final customerInfo = await Purchases.restorePurchases();

      // Check if user has active subscription
      var isPro =
          customerInfo.entitlements.all[entitlementId]?.isActive ?? false;

      // Try fallback entitlement ID
      if (!isPro) {
        isPro = customerInfo.entitlements.all[fallbackEntitlementId]?.isActive ?? false;
      }

      // If any active entitlement exists
      if (!isPro && customerInfo.entitlements.active.isNotEmpty) {
        isPro = true;
      }

      if (!isPro) {
        // No active subscription found
        AppLogger.info('No active subscription found in RevenueCat. User may not have purchased or is using different Apple/Google Account.',
            source: 'SubscriptionService');
        AppLogger.functionEnd('restorePurchases',
            source: 'SubscriptionService', result: false);
        return null;
      }

      // CRITICAL: Verify that this subscription belongs to current user
      // RevenueCat already verified Apple/Google Account, but we need to:
      // 1. Check if this RevenueCat customer ID was previously linked to another Supabase user
      // 2. If yes, verify ownership (prevent subscription theft)
      final verificationResult = await _verifySubscriptionOwnership(
        revenuecatCustomerId: customerInfo.originalAppUserId,
      );

      if (!verificationResult) {
        AppLogger.warn(
          '⚠️ Subscription ownership verification failed. '
          'This subscription may belong to another account. '
          'For security, subscription will not be restored.',
          source: 'SubscriptionService',
        );
        AppLogger.functionEnd('restorePurchases',
            source: 'SubscriptionService', result: false);
        return null;
      }

      // If restored and verified successfully, sync to Supabase
      await _syncSubscriptionToSupabase(
        isPro: true,
        subscriptionType: 'revenuecat',
      );
      await _saveRevenueCatCustomerId(customerInfo.originalAppUserId);

      // CRITICAL: Track device and enforce 3-device limit for Pro users
      await _trackDeviceAndEnforceLimit(customerInfo.originalAppUserId);

      AppLogger.event('Purchases restored and verified',
          source: 'SubscriptionService',
          data: {
            'isPro': isPro,
            'source': 'RevenueCat (Apple/Google Account verified)',
            'activeEntitlements':
                customerInfo.entitlements.active.keys.toList(),
            'allEntitlements': customerInfo.entitlements.all.keys.toList(),
            'revenuecatCustomerId': customerInfo.originalAppUserId,
          });

      AppLogger.functionEnd('restorePurchases',
          source: 'SubscriptionService', result: isPro);
      return customerInfo;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to restore purchases',
          source: 'SubscriptionService', error: e, stackTrace: stackTrace);
      
      // Fallback: Check Supabase if RevenueCat restore failed
      try {
        final supabaseStatus = await _checkSubscriptionFromSupabase();
        if (supabaseStatus == true) {
          AppLogger.info('RevenueCat restore failed, but subscription found in Supabase',
              source: 'SubscriptionService');
          return null; // Supabase subscription exists
        }
      } catch (supabaseError) {
        AppLogger.warn('Supabase fallback also failed: $supabaseError',
            source: 'SubscriptionService');
      }
      
      AppLogger.functionEnd('restorePurchases',
          source: 'SubscriptionService', result: false);
      return null;
    }
  }

  /// التحقق من ملكية الاشتراك
  /// 
  /// يتحقق من أن الاشتراك المسترد ينتمي للمستخدم الحالي
  /// 
  /// المنطق:
  /// 1. إذا كان RevenueCat customer ID جديد (لم يربط من قبل) → ✅ مسموح
  /// 2. إذا كان RevenueCat customer ID مربوط بـ Supabase user آخر → ❌ مرفوض (حماية)
  /// 3. إذا كان RevenueCat customer ID مربوط بـ نفس Supabase user → ✅ مسموح
  /// 
  /// Returns:
  /// - true if ownership verified (or new subscription)
  /// - false if ownership verification failed (subscription belongs to another user)
  static Future<bool> _verifySubscriptionOwnership({
    required String revenuecatCustomerId,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      if (session == null) {
        // No Supabase session - can't verify, but RevenueCat already verified Apple/Google Account
        // Allow restore (RevenueCat's verification is sufficient)
        AppLogger.info('No Supabase session. Relying on RevenueCat Apple/Google Account verification.',
            source: 'SubscriptionService');
        return true;
      }

      final currentUserId = session.user.id;

      // Check if this RevenueCat customer ID is linked to any Supabase user
      final existingProfile = await supabase
          .from('user_profiles')
          .select('user_id, revenuecat_customer_id')
          .eq('revenuecat_customer_id', revenuecatCustomerId)
          .maybeSingle();

      if (existingProfile == null) {
        // This RevenueCat customer ID is new (not linked to any Supabase user)
        // This is safe - it's a new subscription or first time linking
        AppLogger.info('RevenueCat customer ID is new. Ownership verified (new subscription).',
            source: 'SubscriptionService');
        return true;
      }

      final linkedUserId = existingProfile['user_id'] as String?;
      
      if (linkedUserId == currentUserId) {
        // Same user - ownership verified ✅
        AppLogger.info('RevenueCat customer ID linked to same Supabase user. Ownership verified.',
            source: 'SubscriptionService');
        return true;
      } else {
        // Different user - potential subscription theft ❌
        AppLogger.warn(
          '⚠️ SECURITY WARNING: RevenueCat customer ID is linked to different Supabase user. '
          'Current user: $currentUserId, Linked user: $linkedUserId. '
          'Subscription restore blocked for security.',
          source: 'SubscriptionService',
        );
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to verify subscription ownership',
          source: 'SubscriptionService', error: e, stackTrace: stackTrace);
      // On error, be conservative - don't allow restore
      return false;
    }
  }

  /// التحقق من حالة الاشتراك (Eagle Test Pro)
  ///
  /// يتحقق من الاشتراك من مصدرين:
  /// 1. RevenueCat (إذا كان مفعّل)
  /// 2. Supabase user_profiles (fallback أو للاشتراكات التجريبية)
  ///
  /// Returns:
  /// - true if user has active Pro subscription (from RevenueCat or Supabase)
  /// - false if no active subscription
  static Future<bool> checkSubscriptionStatus() async {
    AppLogger.functionStart('checkSubscriptionStatus',
        source: 'SubscriptionService');

    try {
      // First: Check Supabase for subscription status (supports trial subscriptions)
      final supabaseStatus = await _checkSubscriptionFromSupabase();
      if (supabaseStatus == true) {
        // User has active subscription in Supabase (trial or paid)
        AppLogger.info('Subscription status from Supabase: TRUE (trial or paid)', 
            source: 'SubscriptionService');
        AppLogger.functionEnd('checkSubscriptionStatus',
            source: 'SubscriptionService', result: true);
        return true;
      }
      // If supabaseStatus is false or null, continue to check RevenueCat

      // Second: Check RevenueCat (if initialized)
      if (!_isInitialized) {
        await init();
      }

      // If RevenueCat is not initialized (no API key), return Supabase result
      if (!_isInitialized || _apiKey == null) {
        AppLogger.warn(
            'RevenueCat not initialized. Using Supabase result only.',
            source: 'SubscriptionService');
        // Return false if Supabase said false, or false if Supabase was unavailable
        final result = supabaseStatus ?? false;
        AppLogger.functionEnd('checkSubscriptionStatus',
            source: 'SubscriptionService', result: result);
        return result;
      }

      // Get current customer info from RevenueCat
      final customerInfo = await Purchases.getCustomerInfo();

      // Check if Pro entitlement is active
      var isPro =
          customerInfo.entitlements.all[entitlementId]?.isActive ?? false;

      // Try fallback entitlement ID
      if (!isPro) {
        isPro = customerInfo.entitlements.all[fallbackEntitlementId]?.isActive ?? false;
      }

      // If RevenueCat says Pro, sync to Supabase
      if (isPro) {
        await _syncSubscriptionToSupabase(isPro: true, subscriptionType: 'revenuecat');
        AppLogger.event('Subscription status checked',
            source: 'SubscriptionService',
            data: {
              'isPro': isPro,
              'source': 'RevenueCat',
              'activeEntitlements':
                  customerInfo.entitlements.active.keys.toList(),
            });
        AppLogger.functionEnd('checkSubscriptionStatus',
            source: 'SubscriptionService', result: isPro);
        return isPro;
      } else {
        // RevenueCat says not Pro, but check if Supabase had a different result
        // (This handles cases where Supabase has trial but RevenueCat doesn't)
        if (supabaseStatus == true) {
          // Supabase says Pro (trial), but RevenueCat says not Pro
          // Return Supabase result (trial takes precedence)
          AppLogger.info('Supabase has trial subscription, RevenueCat does not. Using Supabase result.',
              source: 'SubscriptionService');
          AppLogger.functionEnd('checkSubscriptionStatus',
              source: 'SubscriptionService', result: true);
          return true;
        }
        
        // Both say not Pro
        AppLogger.event('Subscription status checked',
            source: 'SubscriptionService',
            data: {
              'isPro': false,
              'source': 'RevenueCat + Supabase',
              'supabaseStatus': supabaseStatus,
            });
        AppLogger.functionEnd('checkSubscriptionStatus',
            source: 'SubscriptionService', result: false);
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check subscription status',
          source: 'SubscriptionService', error: e, stackTrace: stackTrace);
      
      // Fallback: Check Supabase on error
      try {
        final supabaseStatus = await _checkSubscriptionFromSupabase();
        if (supabaseStatus != null) {
          AppLogger.info('Using Supabase fallback after RevenueCat error: $supabaseStatus',
              source: 'SubscriptionService');
          return supabaseStatus;
        }
      } catch (supabaseError) {
        AppLogger.warn('Supabase fallback also failed: $supabaseError',
            source: 'SubscriptionService');
      }
      
      AppLogger.functionEnd('checkSubscriptionStatus',
          source: 'SubscriptionService', result: false);
      return false;
    }
  }

  /// التحقق من حالة الاشتراك من Supabase
  /// 
  /// يتحقق من:
  /// - is_pro = true
  /// - trial_ends_at (إذا كان في فترة تجريبية)
  /// - subscription_expires_at (إذا كان الاشتراك لم ينته بعد)
  /// 
  /// Returns:
  /// - true if user has active Pro subscription or active trial
  /// - false if no subscription or expired
  /// - null if Supabase not available or error occurred
  static Future<bool?> _checkSubscriptionFromSupabase() async {
    try {
      // Check if Supabase is available
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      if (session == null) {
        return null; // Not authenticated
      }

      final userId = session.user.id;

      // Get user profile from Supabase
      final profile = await supabase
          .from('user_profiles')
          .select('is_pro, subscription_type, subscription_expires_at, trial_ends_at')
          .eq('user_id', userId)
          .maybeSingle();

      if (profile == null) {
        return null; // Profile doesn't exist
      }

      final isPro = profile['is_pro'] as bool? ?? false;
      final subscriptionType = profile['subscription_type'] as String?;
      final subscriptionExpiresAt = profile['subscription_expires_at'] as String?;
      final trialEndsAt = profile['trial_ends_at'] as String?;

      // Check if user has active trial
      if (trialEndsAt != null && trialEndsAt.isNotEmpty) {
        try {
          final trialEndDate = DateTime.parse(trialEndsAt);
          if (DateTime.now().isBefore(trialEndDate)) {
            AppLogger.info('User has active trial until $trialEndsAt', 
                source: 'SubscriptionService');
            return true; // Trial is still active
          } else {
            AppLogger.info('Trial expired on $trialEndsAt', 
                source: 'SubscriptionService');
          }
        } catch (e) {
          AppLogger.warn('Failed to parse trial_ends_at: $trialEndsAt', 
              source: 'SubscriptionService');
        }
      }

      // Check if user has active subscription
      if (isPro && subscriptionType != null) {
        // If lifetime, always return true
        if (subscriptionType.toLowerCase() == 'lifetime') {
          return true;
        }

        // Check expiration date
        if (subscriptionExpiresAt != null && subscriptionExpiresAt.isNotEmpty) {
          try {
            final expiresDate = DateTime.parse(subscriptionExpiresAt);
            if (DateTime.now().isBefore(expiresDate)) {
              return true; // Subscription is still active
            } else {
              AppLogger.info('Subscription expired on $subscriptionExpiresAt', 
                  source: 'SubscriptionService');
              // Update is_pro to false in Supabase
              await supabase
                  .from('user_profiles')
                  .update({'is_pro': false})
                  .eq('user_id', userId);
              return false;
            }
          } catch (e) {
            AppLogger.warn('Failed to parse subscription_expires_at: $subscriptionExpiresAt', 
                source: 'SubscriptionService');
          }
        }

        // If is_pro is true but no expiration date, assume active
        return isPro;
      }

      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check subscription from Supabase',
          source: 'SubscriptionService', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// مزامنة حالة الاشتراك إلى Supabase
  /// 
  /// Parameters:
  /// - isPro: حالة الاشتراك
  /// - subscriptionType: نوع الاشتراك ('monthly', 'yearly', 'lifetime', 'trial', 'revenuecat')
  /// - expiresAt: تاريخ انتهاء الاشتراك (اختياري)
  /// - trialEndsAt: تاريخ انتهاء التجريبي (اختياري)
  static Future<void> _syncSubscriptionToSupabase({
    required bool isPro,
    String? subscriptionType,
    DateTime? expiresAt,
    DateTime? trialEndsAt,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      if (session == null) return;

      final userId = session.user.id;

      final updateData = <String, dynamic>{
        'is_pro': isPro,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (subscriptionType != null) {
        updateData['subscription_type'] = subscriptionType;
      }

      if (expiresAt != null) {
        updateData['subscription_expires_at'] = expiresAt.toIso8601String();
      }

      if (trialEndsAt != null) {
        updateData['trial_ends_at'] = trialEndsAt.toIso8601String();
      }

      await supabase
          .from('user_profiles')
          .update(updateData)
          .eq('user_id', userId);

      AppLogger.event('Subscription synced to Supabase', 
          source: 'SubscriptionService', 
          data: updateData);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to sync subscription to Supabase',
          source: 'SubscriptionService', error: e, stackTrace: stackTrace);
      // Don't rethrow - this is a background sync
    }
  }

  /// حفظ RevenueCat Customer ID في Supabase
  /// 
  /// هذا مهم لاسترداد الاشتراك عند تغيير الجهاز أو حذف التطبيق
  static Future<void> _saveRevenueCatCustomerId(String? customerId) async {
    if (customerId == null || customerId.isEmpty) return;
    
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      if (session == null) return;

      final userId = session.user.id;

      await supabase
          .from('user_profiles')
          .update({
            'revenuecat_customer_id': customerId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      AppLogger.info('RevenueCat Customer ID saved to Supabase: $customerId', 
          source: 'SubscriptionService');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save RevenueCat Customer ID to Supabase',
          source: 'SubscriptionService', error: e, stackTrace: stackTrace);
      // Don't rethrow - this is a background sync
    }
  }

  /// ربط RevenueCat Customer ID موجود مع Supabase user_id
  /// 
  /// عند تهيئة RevenueCat، يتحقق إذا كان هناك RevenueCat customer ID محفوظ
  /// في Supabase ويربطه مع RevenueCat الحالي
  static Future<void> _linkExistingRevenueCatCustomer(String supabaseUserId) async {
    try {
      final supabase = Supabase.instance.client;
      
      // Get saved RevenueCat customer ID from Supabase
      final profile = await supabase
          .from('user_profiles')
          .select('revenuecat_customer_id')
          .eq('user_id', supabaseUserId)
          .maybeSingle();

      final savedCustomerId = profile?['revenuecat_customer_id'] as String?;
      
      if (savedCustomerId != null && savedCustomerId.isNotEmpty) {
        // Link existing RevenueCat customer to current Supabase user
        try {
          await Purchases.logIn(savedCustomerId);
          AppLogger.info('Linked existing RevenueCat customer: $savedCustomerId to Supabase user: $supabaseUserId',
              source: 'SubscriptionService');
        } catch (e) {
          AppLogger.warn('Failed to link RevenueCat customer: $e', 
              source: 'SubscriptionService');
          // If linking fails, RevenueCat will use the Supabase user_id as new customer ID
        }
      } else {
        // No saved customer ID, RevenueCat will use Supabase user_id as customer ID
        AppLogger.info('No existing RevenueCat customer ID found. Using Supabase user_id as RevenueCat customer ID.',
            source: 'SubscriptionService');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to link existing RevenueCat customer',
          source: 'SubscriptionService', error: e, stackTrace: stackTrace);
      // Don't rethrow - app can continue
    }
  }

  /// استعادة ربط RevenueCat عند استرداد المشتريات
  /// 
  /// يحاول ربط RevenueCat customer ID المحفوظ في Supabase مع RevenueCat الحالي
  static Future<void> _restoreRevenueCatLink() async {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      if (session == null || !_isInitialized) return;

      final userId = session.user.id;

      // Get saved RevenueCat customer ID
      final profile = await supabase
          .from('user_profiles')
          .select('revenuecat_customer_id')
          .eq('user_id', userId)
          .maybeSingle();

      final savedCustomerId = profile?['revenuecat_customer_id'] as String?;
      
      if (savedCustomerId != null && savedCustomerId.isNotEmpty) {
        try {
          // Try to identify with saved customer ID
          await Purchases.logIn(savedCustomerId);
          AppLogger.info('Restored RevenueCat link: $savedCustomerId',
              source: 'SubscriptionService');
        } catch (e) {
          AppLogger.warn('Failed to restore RevenueCat link: $e', 
              source: 'SubscriptionService');
          // If restore fails, RevenueCat will use Supabase user_id
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to restore RevenueCat link',
          source: 'SubscriptionService', error: e, stackTrace: stackTrace);
      // Don't rethrow - app can continue
    }
  }

  /// Enforce 3-device limit for Pro subscribers
  /// 
  /// Identifies active devices by last_active_at in user_progress table.
  /// If count > 3, downgrades the oldest device (by last_active_at) to Free.
  /// Always updates current device's last_active_at.
  /// 
  /// This method should be called after successful subscription purchase or restore.
  static Future<void> _trackDeviceAndEnforceLimit(String revenuecatCustomerId) async {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      if (session == null) return;

      final currentUserId = session.user.id;
      final now = DateTime.now().toIso8601String();

      // Count active devices (Pro) with same revenuecat_customer_id
      // Active = has user_progress record with last_active_at within last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
      
      final activeDevices = await supabase
          .from('user_progress')
          .select('user_id, last_active_at')
          .eq('revenuecat_customer_id', revenuecatCustomerId)
          .gte('last_active_at', thirtyDaysAgo) // Active within last 30 days
          .order('last_active_at', ascending: true); // Oldest first

      final deviceCount = activeDevices.length;

      AppLogger.info('Active Pro devices for $revenuecatCustomerId: $deviceCount', 
          source: 'SubscriptionService');

      if (deviceCount >= 3) {
        // Limit reached - downgrade oldest device to Free
        final oldestDevice = activeDevices.first;
        final oldestUserId = oldestDevice['user_id'] as String;

        if (oldestUserId != currentUserId) {
          // Downgrade oldest device (if not current device)
          // Remove revenuecat_customer_id and set is_pro to false in user_profiles
          await supabase
              .from('user_profiles')
              .update({
                'is_pro': false,
                'revenuecat_customer_id': null,
                'subscription_type': null,
                'subscription_expires_at': null,
                'updated_at': now,
              })
              .eq('user_id', oldestUserId);

          // Also remove revenuecat_customer_id from user_progress for that device
          await supabase
              .from('user_progress')
              .update({
                'revenuecat_customer_id': null,
              })
              .eq('user_id', oldestUserId);

          AppLogger.warn(
            'Device limit reached (3 devices). Downgraded oldest device to Free: $oldestUserId',
            source: 'SubscriptionService',
          );
        } else {
          // Current device is the oldest - no need to downgrade it
          AppLogger.info('Current device is the oldest. No downgrade needed.', 
              source: 'SubscriptionService');
        }
      }

      // Update current device's last_active_at in user_progress
      // This ensures the device is tracked as active
      await supabase
          .from('user_progress')
          .update({
            'last_active_at': now,
            'revenuecat_customer_id': revenuecatCustomerId,
          })
          .eq('user_id', currentUserId);

      // Ensure user_profiles is marked as Pro
      await supabase
          .from('user_profiles')
          .update({
            'is_pro': true,
            'revenuecat_customer_id': revenuecatCustomerId,
            'updated_at': now,
          })
          .eq('user_id', currentUserId);

      AppLogger.info('Device tracked and limit enforced: $currentUserId (Pro)', 
          source: 'SubscriptionService');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to track device and enforce limit',
          source: 'SubscriptionService', error: e, stackTrace: stackTrace);
      // Don't rethrow - allow app to continue
    }
  }

  /// جلب معلومات العميل الحالية
  ///
  /// Returns:
  /// - CustomerInfo with all subscription details
  /// - null if error occurred
  ///
  /// CustomerInfo contains:
  /// - Active entitlements
  /// - Active subscriptions
  /// - Purchase history
  /// - Expiration dates
  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      if (!_isInitialized) {
        await init();
      }
      return await Purchases.getCustomerInfo();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get customer info',
          source: 'SubscriptionService', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// فتح Customer Center (مركز إدارة الاشتراك)
  ///
  /// Customer Center allows users to:
  /// - View subscription details
  /// - Manage subscription (cancel, renew)
  /// - Restore purchases
  /// - Contact support
  ///
  /// Note: Customer Center must be configured in RevenueCat Dashboard
  static Future<void> presentCustomerCenter() async {
    AppLogger.functionStart('presentCustomerCenter',
        source: 'SubscriptionService');

    try {
      if (!_isInitialized) {
        await init();
      }

      // Present Customer Center
      // This will show the native Customer Center UI
      await Purchases.presentCodeRedemptionSheet();

      AppLogger.event('Customer Center presented',
          source: 'SubscriptionService');
      AppLogger.functionEnd('presentCustomerCenter',
          source: 'SubscriptionService');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to present Customer Center',
          source: 'SubscriptionService', error: e, stackTrace: stackTrace);
      AppLogger.functionEnd('presentCustomerCenter',
          source: 'SubscriptionService', result: 'ERROR');
    }
  }

  /// التحقق من أن المستخدم لديه اشتراك Pro نشط
  ///
  /// Helper method that combines checkSubscriptionStatus with error handling
  ///
  /// Returns:
  /// - true if user has active Pro subscription
  /// - false otherwise
  static Future<bool> isProUser() async {
    try {
      return await checkSubscriptionStatus();
    } catch (e) {
      AppLogger.error('Error checking Pro status',
          source: 'SubscriptionService', error: e);
      return false;
    }
  }

  /// جلب معلومات الاشتراك الحالي
  ///
  /// Returns:
  /// - CurrentSubscriptionInfo مع معلومات الاشتراك الحالي
  /// - null إذا لم يكن هناك اشتراك نشط
  static Future<CurrentSubscriptionInfo?> getCurrentSubscriptionInfo() async {
    AppLogger.functionStart('getCurrentSubscriptionInfo',
        source: 'SubscriptionService');

    try {
      if (!_isInitialized) {
        await init();
      }

      final customerInfo = await Purchases.getCustomerInfo();

      // البحث عن الـ entitlement النشط
      EntitlementInfo? activeEntitlement;
      if (customerInfo.entitlements.all.containsKey(entitlementId)) {
        activeEntitlement = customerInfo.entitlements.all[entitlementId];
      } else if (customerInfo.entitlements.all
          .containsKey(fallbackEntitlementId)) {
        activeEntitlement =
            customerInfo.entitlements.all[fallbackEntitlementId];
      } else if (customerInfo.entitlements.active.isNotEmpty) {
        // استخدام أول entitlement نشط كـ fallback
        activeEntitlement = customerInfo.entitlements.active.values.first;
      }

      if (activeEntitlement == null || !activeEntitlement.isActive) {
        AppLogger.functionEnd('getCurrentSubscriptionInfo',
            source: 'SubscriptionService', result: 'NO_SUBSCRIPTION');
        return null;
      }

      // البحث عن الـ product ID من الـ entitlement أو active subscriptions
      String? productId;
      DateTime? expirationDate;
      bool isLifetime = false;

      // محاولة الحصول على product ID من الـ entitlement
      final productIdentifier = activeEntitlement.productIdentifier;
      if (productIdentifier.isNotEmpty) {
        final id = productIdentifier.toLowerCase();
        if (id.contains('monthly') || id.contains('month')) {
          productId = 'monthly';
        } else if (id.contains('yearly') ||
            id.contains('year') ||
            id.contains('annual')) {
          productId = 'yearly';
        } else if (id.contains('lifetime') || id.contains('forever')) {
          productId = 'lifetime';
          isLifetime = true;
        } else {
          productId = productIdentifier;
        }
      }

      // إذا لم نجد product ID من الـ entitlement، نبحث في active subscriptions
      if (productId == null) {
        for (final subscriptionId in customerInfo.activeSubscriptions) {
          final id = subscriptionId.toLowerCase();
          if (id.contains('monthly') || id.contains('month')) {
            productId = 'monthly';
            break;
          } else if (id.contains('yearly') ||
              id.contains('year') ||
              id.contains('annual')) {
            productId = 'yearly';
            break;
          } else if (id.contains('lifetime') || id.contains('forever')) {
            productId = 'lifetime';
            isLifetime = true;
            break;
          } else {
            productId = subscriptionId;
          }
        }
      }

      // الحصول على تاريخ الانتهاء من الـ entitlement
      // expirationDate في RevenueCat هو String (ISO 8601 format)
      final rawExpirationDate = activeEntitlement.expirationDate;

      // تحويل String إلى DateTime
      if (rawExpirationDate != null && rawExpirationDate.isNotEmpty) {
        try {
          expirationDate = DateTime.parse(rawExpirationDate);
        } catch (e) {
          AppLogger.warn('Failed to parse expiration date: $rawExpirationDate',
              source: 'SubscriptionService');
          expirationDate = null;
        }
      } else {
        expirationDate = null;
      }

      // إذا كان lifetime، لا يوجد تاريخ انتهاء
      // أو إذا كان تاريخ الانتهاء بعد 10 سنوات (يعتبر lifetime)
      if (isLifetime) {
        expirationDate = null;
      } else if (expirationDate != null &&
          expirationDate
              .isAfter(DateTime.now().add(const Duration(days: 3650)))) {
        isLifetime = true;
        expirationDate = null;
      }

      final info = CurrentSubscriptionInfo(
        productId: productId ?? 'unknown',
        expirationDate: expirationDate,
        isLifetime: isLifetime,
        entitlementId: activeEntitlement.identifier,
      );

      AppLogger.event('Current subscription info retrieved',
          source: 'SubscriptionService',
          data: {
            'productId': info.productId,
            'isLifetime': info.isLifetime,
            'expirationDate': info.expirationDate?.toIso8601String(),
            'daysRemaining': info.daysRemaining,
          });

      AppLogger.functionEnd('getCurrentSubscriptionInfo',
          source: 'SubscriptionService', result: 'SUCCESS');
      return info;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get current subscription info',
          source: 'SubscriptionService', error: e, stackTrace: stackTrace);
      AppLogger.functionEnd('getCurrentSubscriptionInfo',
          source: 'SubscriptionService', result: 'ERROR');
      return null;
    }
  }
}

/// معلومات الاشتراك الحالي
class CurrentSubscriptionInfo {
  final String productId; // 'monthly', 'yearly', 'lifetime'
  final DateTime? expirationDate;
  final bool isLifetime;
  final String entitlementId;

  CurrentSubscriptionInfo({
    required this.productId,
    this.expirationDate,
    required this.isLifetime,
    required this.entitlementId,
  });

  /// حساب الأيام المتبقية حتى انتهاء الاشتراك
  /// Returns null إذا كان lifetime
  int? get daysRemaining {
    if (isLifetime || expirationDate == null) return null;
    final now = DateTime.now();
    final difference = expirationDate!.difference(now);
    return difference.inDays;
  }

  /// الحصول على اسم الباقة بالعربية أو الإنجليزية
  String getPackageName(bool isArabic) {
    if (productId.toLowerCase().contains('monthly') ||
        productId.toLowerCase().contains('month')) {
      return isArabic ? 'شهري' : 'Monthly';
    } else if (productId.toLowerCase().contains('yearly') ||
        productId.toLowerCase().contains('year') ||
        productId.toLowerCase().contains('annual')) {
      return isArabic ? 'سنوي' : 'Yearly';
    } else if (productId.toLowerCase().contains('lifetime') ||
        productId.toLowerCase().contains('forever')) {
      return isArabic ? 'مدى الحياة' : 'Lifetime';
    }
    return productId;
  }
}
