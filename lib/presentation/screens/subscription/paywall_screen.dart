import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/subscription_provider.dart';
import '../../../core/debug/app_logger.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/services/sync_service.dart';

/// -----------------------------------------------------------------
/// 💎 PAYWALL SCREEN / PREMIUM / شاشة الاشتراك
/// -----------------------------------------------------------------
/// Modern, balanced paywall design - features + pricing visible together
/// -----------------------------------------------------------------
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> 
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  CurrentSubscriptionInfo? _currentSubscription;
  Package? _selectedPackage;
  bool _showAllFeatures = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadCurrentSubscription();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentSubscription() async {
    final info = await SubscriptionService.getCurrentSubscriptionInfo();
    if (mounted) {
      setState(() {
        _currentSubscription = info;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final subscriptionState = ref.watch(subscriptionProvider);
    final subscriptionNotifier = ref.read(subscriptionProvider.notifier);
    final isPro = subscriptionState.isPro;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      body: subscriptionState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.eagleGold),
            )
          : Stack(
              children: [
                // Background
                _buildBackground(),
                
                // Main content
                SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Header with close button
                        _buildHeader(context),
                        
                        // Scrollable content
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              children: [
                                // Logo + Title
                                _buildHeroSection(isArabic),
                                
                                SizedBox(height: 20.h),
                                
                                // If lifetime subscriber
                                if (isPro && _currentSubscription?.isLifetime == true)
                                  _buildLifetimeCard(isArabic)
                                else ...[
                                  // TOP 3 KEY FEATURES (Always visible)
                                  _buildTopFeatures(isArabic),
                                  
                                  SizedBox(height: 20.h),
                                  
                                  // PRICING CARDS
                                  _buildPricingSection(
                                    subscriptionState.offerings,
                                    subscriptionNotifier,
                                    isArabic,
                                    isPro: isPro,
                                  ),
                                  
                                  SizedBox(height: 16.h),
                                  
                                  // MORE FEATURES (Expandable)
                                  _buildMoreFeatures(isArabic),
                                ],
                                
                                SizedBox(height: 12.h),
                                
                                // Restore purchases
                                _buildRestoreButton(subscriptionNotifier, isArabic),
                                
                                SizedBox(height: 100.h), // Space for sticky button
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Sticky CTA Button
                if (!isPro || _currentSubscription?.isLifetime != true)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildStickyCTA(subscriptionNotifier, isArabic),
                  ),
              ],
            ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.eagleGold.withValues(alpha: 0.08),
            const Color(0xFF0D0D12),
            const Color(0xFF0D0D12),
          ],
          stops: const [0.0, 0.35, 1.0],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // PRO Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.eagleGold, AppColors.eagleGold.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.eagleGold.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium, size: 16.sp, color: Colors.white),
                SizedBox(width: 6.w),
                Text(
                  'PRO',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          // Close button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 22.sp, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isArabic) {
    return Column(
      children: [
        // App Logo
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.eagleGold.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Image.asset(
              'assets/logo/app_icon.png',
              width: 80.w,
              height: 80.w,
              fit: BoxFit.contain,
            ),
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // Title
        Text(
          isArabic ? 'اشتراك Pro' : 'Go Pro',
          style: GoogleFonts.poppins(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: 6.h),
        
        // Subtitle
        Text(
          isArabic 
            ? 'افتح جميع الميزات المتقدمة'
            : 'Unlock all premium features',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  /// TOP 3 KEY FEATURES - Always visible, prominent
  Widget _buildTopFeatures(bool isArabic) {
    final l10n = AppLocalizations.of(context);
    
    final topFeatures = [
      {
        'icon': Icons.all_inclusive,
        'title': isArabic ? 'مساعد ذكي غير محدود' : 'Unlimited AI Tutor',
        'subtitle': isArabic ? 'اسأل بلا حدود' : 'Ask unlimited questions',
        'color': const Color(0xFF9C27B0),
      },
      {
        'icon': Icons.devices,
        'title': isArabic ? 'مزامنة 3 أجهزة' : '3-Device Sync',
        'subtitle': isArabic ? 'تقدمك محفوظ دائماً' : 'Progress saved everywhere',
        'color': const Color(0xFF2196F3),
      },
      {
        'icon': Icons.psychology,
        'title': l10n?.smartAiStudyAlerts ?? (isArabic ? 'تنبيهات ذكية' : 'Smart Alerts'),
        'subtitle': isArabic ? 'تذكيرات مخصصة' : 'Personalized reminders',
        'color': const Color(0xFF4CAF50),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            children: [
              Icon(Icons.star, size: 18.sp, color: AppColors.eagleGold),
              SizedBox(width: 8.w),
              Text(
                isArabic ? 'أهم المميزات' : 'Top Features',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        // Feature cards
        ...topFeatures.map((feature) {
          return Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: (feature['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: (feature['color'] as Color).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: (feature['color'] as Color).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: feature['color'] as Color,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['title'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        feature['subtitle'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                // Check icon
                Icon(
                  Icons.check_circle,
                  color: feature['color'] as Color,
                  size: 22.sp,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPricingSection(
    Offerings? offerings,
    SubscriptionNotifier notifier,
    bool isArabic, {
    bool isPro = false,
  }) {
    final packages = offerings?.current?.availablePackages ?? [];
    
    List<Package> availablePackages = [];
    if (isPro && _currentSubscription != null && !_currentSubscription!.isLifetime) {
      availablePackages = packages.where((package) {
        final packageId = package.identifier.toLowerCase();
        final currentProductId = _currentSubscription!.productId.toLowerCase();
        
        if (currentProductId.contains('monthly') || currentProductId.contains('month')) {
          return packageId.contains('yearly') || packageId.contains('year') || 
                 packageId.contains('annual') || packageId.contains('lifetime') || 
                 packageId.contains('forever');
        }
        if (currentProductId.contains('yearly') || currentProductId.contains('year') || 
            currentProductId.contains('annual')) {
          return packageId.contains('lifetime') || packageId.contains('forever');
        }
        return true;
      }).toList();
    } else {
      availablePackages = packages;
    }

    if (availablePackages.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort: Monthly -> Yearly -> Lifetime
    availablePackages.sort((a, b) {
      int aOrder = _getPackageOrder(a);
      int bOrder = _getPackageOrder(b);
      return aOrder.compareTo(bOrder);
    });

    // Default to yearly
    _selectedPackage ??= availablePackages.firstWhere(
      (p) => p.identifier.toLowerCase().contains('yearly') || 
             p.identifier.toLowerCase().contains('annual'),
      orElse: () => availablePackages.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Text(
            isArabic ? 'اختر خطتك' : 'Choose Your Plan',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        
        // Package cards
        ...availablePackages.map((package) {
          final isSelected = _selectedPackage?.identifier == package.identifier;
          final isYearly = _isYearly(package);
          final isLifetime = _isLifetime(package);
          
          return GestureDetector(
            onTap: () => setState(() => _selectedPackage = package),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          AppColors.eagleGold.withValues(alpha: 0.15),
                          AppColors.eagleGold.withValues(alpha: 0.05),
                        ],
                      )
                    : null,
                color: isSelected ? null : const Color(0xFF1A1A24),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isSelected 
                      ? AppColors.eagleGold 
                      : Colors.white.withValues(alpha: 0.08),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Radio button
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.eagleGold : Colors.white30,
                        width: 2,
                      ),
                      color: isSelected ? AppColors.eagleGold : Colors.transparent,
                    ),
                    child: isSelected
                        ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                        : null,
                  ),
                  
                  SizedBox(width: 12.w),
                  
                  // Package info
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          _getPackageTitle(package, isArabic),
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (isYearly) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.green, Colors.green.shade700],
                              ),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              isArabic ? 'الأفضل' : 'BEST',
                              style: GoogleFonts.poppins(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        if (isLifetime) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.eagleGold, AppColors.eagleGold.withValues(alpha: 0.7)],
                              ),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              '∞',
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        package.storeProduct.priceString,
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.eagleGold : Colors.white,
                        ),
                      ),
                      if (!isLifetime)
                        Text(
                          _getPricePeriod(package, isArabic),
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.white54,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  /// MORE FEATURES - Expandable section
  Widget _buildMoreFeatures(bool isArabic) {
    final l10n = AppLocalizations.of(context);
    
    final moreFeatures = [
      {'icon': Icons.cloud_upload, 'name': l10n?.cloudBackupSync ?? 'Cloud Backup'},
      {'icon': Icons.analytics, 'name': l10n?.advancedReadinessIndex ?? 'Readiness Index'},
      {'icon': Icons.picture_as_pdf, 'name': l10n?.pdfExamGeneration ?? 'PDF Exams'},
      {'icon': Icons.mic, 'name': l10n?.voiceExamMode ?? 'Voice Mode'},
      {'icon': Icons.school, 'name': l10n?.aiStudyCoach ?? 'AI Coach'},
      {'icon': Icons.business, 'name': l10n?.organizationSupport ?? 'Organization Support'},
      {'icon': Icons.person, 'name': isArabic ? 'تخصيص الملف الشخصي' : 'Profile Customization'},
    ];

    return Column(
      children: [
        // Toggle button
        GestureDetector(
          onTap: () => setState(() => _showAllFeatures = !_showAllFeatures),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showAllFeatures ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.eagleGold,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  _showAllFeatures
                      ? (isArabic ? 'إخفاء المزيد' : 'Show Less')
                      : (isArabic ? '+${moreFeatures.length} ميزة أخرى' : '+${moreFeatures.length} More Features'),
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.eagleGold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Expandable content
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            margin: EdgeInsets.only(top: 12.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A24),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: moreFeatures.map((feature) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.eagleGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        feature['icon'] as IconData,
                        size: 16.sp,
                        color: AppColors.eagleGold,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        (feature['name'] as String).replaceAll(RegExp(r'[🎯☁️📊🏢👤🔄]'), '').trim(),
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          crossFadeState: _showAllFeatures 
              ? CrossFadeState.showSecond 
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildLifetimeCard(bool isArabic) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.eagleGold.withValues(alpha: 0.2),
            AppColors.eagleGold.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.eagleGold, width: 2),
      ),
      child: Column(
        children: [
          Icon(
            Icons.workspace_premium,
            size: 56.sp,
            color: AppColors.eagleGold,
          ),
          SizedBox(height: 16.h),
          Text(
            '🎉 ${isArabic ? 'عضو مدى الحياة!' : 'Lifetime Member!'}',
            style: GoogleFonts.poppins(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.eagleGold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            isArabic
                ? 'أنت تملك أفضل باقة. استمتع بجميع الميزات إلى الأبد!'
                : 'You have the best plan. Enjoy all features forever!',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.white70,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreButton(SubscriptionNotifier notifier, bool isArabic) {
    return TextButton(
      onPressed: _isProcessing 
          ? null 
          : () => _handleRestorePurchases(notifier, isArabic),
      child: Text(
        isArabic ? 'استعادة المشتريات' : 'Restore purchases',
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          color: Colors.white54,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildStickyCTA(SubscriptionNotifier notifier, bool isArabic) {
    if (_selectedPackage == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0D0D12).withValues(alpha: 0),
            const Color(0xFF0D0D12),
            const Color(0xFF0D0D12),
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: _isProcessing 
              ? null 
              : () => _handlePurchase(_selectedPackage!, notifier, isArabic),
          child: Container(
            height: 56.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.eagleGold,
                  AppColors.eagleGold.withValues(alpha: 0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.eagleGold.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: _isProcessing
                  ? SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isArabic ? 'اشترك الآن' : 'Subscribe Now',
                          style: GoogleFonts.poppins(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods
  int _getPackageOrder(Package package) {
    final id = package.identifier.toLowerCase();
    if (id.contains('monthly') || id.contains('month')) return 1;
    if (id.contains('yearly') || id.contains('year') || id.contains('annual')) return 2;
    if (id.contains('lifetime') || id.contains('forever')) return 3;
    return 0;
  }

  bool _isYearly(Package package) {
    final id = package.identifier.toLowerCase();
    return id.contains('yearly') || id.contains('year') || id.contains('annual');
  }

  bool _isLifetime(Package package) {
    final id = package.identifier.toLowerCase();
    return id.contains('lifetime') || id.contains('forever');
  }

  String _getPackageTitle(Package package, bool isArabic) {
    final id = package.identifier.toLowerCase();
    if (id.contains('lifetime') || id.contains('forever')) {
      return isArabic ? 'مدى الحياة' : 'Lifetime';
    }
    if (id.contains('yearly') || id.contains('year') || id.contains('annual')) {
      return isArabic ? 'سنوي' : 'Yearly';
    }
    if (id.contains('monthly') || id.contains('month')) {
      return isArabic ? 'شهري' : 'Monthly';
    }
    return package.identifier;
  }

  String _getPricePeriod(Package package, bool isArabic) {
    final id = package.identifier.toLowerCase();
    if (id.contains('yearly') || id.contains('year') || id.contains('annual')) {
      return isArabic ? '/سنة' : '/year';
    }
    if (id.contains('monthly') || id.contains('month')) {
      return isArabic ? '/شهر' : '/month';
    }
    return '';
  }

  Future<void> _handlePurchase(
    Package package,
    SubscriptionNotifier notifier,
    bool isArabic,
  ) async {
    setState(() => _isProcessing = true);

    try {
      final success = await notifier.purchasePackage(package);

      if (mounted) {
        if (success) {
          await _loadCurrentSubscription();
          
          SyncService.createUserProfile().catchError((e) {
            AppLogger.warn('Failed to create user profile after purchase: $e', source: 'PaywallScreen');
          });
          
          SyncService.syncProgressToCloud().catchError((e) {
            AppLogger.warn('Failed to sync progress after purchase: $e', source: 'PaywallScreen');
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic ? 'تم الاشتراك بنجاح! 🎉' : 'Subscription successful! 🎉',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
            ),
          );

          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic ? 'تم إلغاء الشراء' : 'Purchase cancelled',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Purchase error', source: 'PaywallScreen', error: e, stackTrace: StackTrace.current);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic ? 'حدث خطأ أثناء الشراء' : 'An error occurred',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleRestorePurchases(
    SubscriptionNotifier notifier,
    bool isArabic,
  ) async {
    setState(() => _isProcessing = true);

    try {
      final success = await notifier.restorePurchases();

      if (mounted) {
        if (success) {
          await _loadCurrentSubscription();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic ? 'تم استعادة المشتريات! ✓' : 'Purchases restored! ✓',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
            ),
          );

          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic ? 'لم يتم العثور على مشتريات' : 'No purchases found',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Restore error', source: 'PaywallScreen', error: e, stackTrace: StackTrace.current);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic ? 'حدث خطأ أثناء الاستعادة' : 'An error occurred',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void didUpdateWidget(PaywallScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadCurrentSubscription();
  }
}
