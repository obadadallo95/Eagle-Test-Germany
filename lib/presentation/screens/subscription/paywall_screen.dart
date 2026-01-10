import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;

    return Scaffold(
      backgroundColor: bgColor,
      body: subscriptionState.isLoading
          ? Center(
              child: CircularProgressIndicator(color: primaryGold),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryGold.withValues(alpha: 0.08),
            bgColor,
            bgColor,
          ],
          stops: const [0.0, 0.35, 1.0],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    
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
                colors: [AppColors.gold, AppColors.gold.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium, size: 16.sp, color: isDark ? AppColors.darkBg : AppColors.lightTextPrimary),
                SizedBox(width: 6.w),
                Text(
                  'PRO',
                  style: AppTypography.badge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
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
                color: isDark 
                    ? AppColors.darkSurface.withValues(alpha: 0.5)
                    : AppColors.lightSurfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 22.sp, color: textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isArabic) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    
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
                color: primaryGold.withValues(alpha: 0.4),
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
          style: AppTypography.h1.copyWith(
            color: textPrimary,
          ),
        ),
        
        SizedBox(height: 6.h),
        
        // Subtitle
        Text(
          isArabic 
            ? 'افتح جميع الميزات المتقدمة'
            : 'Unlock all premium features',
          style: AppTypography.bodyM.copyWith(
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  /// TOP 3 KEY FEATURES - Always visible, prominent
  Widget _buildTopFeatures(bool isArabic) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    
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
              Icon(Icons.star, size: 18.sp, color: primaryGold),
              SizedBox(width: 8.w),
              Text(
                isArabic ? 'أهم المميزات' : 'Top Features',
                style: AppTypography.h4.copyWith(
                  color: textPrimary,
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
                        style: AppTypography.bodyM.copyWith(
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        feature['subtitle'] as String,
                        style: AppTypography.bodyS.copyWith(
                          color: textSecondary,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    
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
            style: AppTypography.h4.copyWith(
              color: textPrimary,
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
                          primaryGold.withValues(alpha: 0.15),
                          primaryGold.withValues(alpha: 0.05),
                        ],
                      )
                    : null,
                color: isSelected ? null : surfaceColor,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isSelected 
                      ? primaryGold 
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
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
                        color: isSelected ? primaryGold : (isDark ? AppColors.darkBorder : AppColors.lightTextTertiary),
                        width: 2,
                      ),
                      color: isSelected ? primaryGold : Colors.transparent,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check, 
                            size: AppSpacing.iconSm, 
                            color: isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
                          )
                        : null,
                  ),
                  
                  SizedBox(width: 12.w),
                  
                  // Package info
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          _getPackageTitle(package, isArabic),
                          style: AppTypography.bodyM.copyWith(
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        if (isYearly) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  isDark ? AppColors.successDark : AppColors.successLight,
                                  isDark ? AppColors.successLight : AppColors.successDark,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              isArabic ? 'الأفضل' : 'BEST',
                              style: AppTypography.badge.copyWith(
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
                                colors: [AppColors.gold, AppColors.gold.withValues(alpha: 0.7)],
                              ),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              '∞',
                              style: AppTypography.badge.copyWith(
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
                        style: AppTypography.h4.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? primaryGold : textPrimary,
                        ),
                      ),
                      if (!isLifetime)
                        Text(
                          _getPricePeriod(package, isArabic),
                          style: AppTypography.bodyS.copyWith(
                            color: textSecondary,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    
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
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showAllFeatures ? Icons.expand_less : Icons.expand_more,
                  color: primaryGold,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  _showAllFeatures
                      ? (isArabic ? 'إخفاء المزيد' : 'Show Less')
                      : (isArabic ? '+${moreFeatures.length} ميزة أخرى' : '+${moreFeatures.length} More Features'),
                  style: AppTypography.bodyM.copyWith(
                    fontWeight: FontWeight.w500,
                    color: primaryGold,
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
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: moreFeatures.map((feature) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: primaryGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        feature['icon'] as IconData,
                        size: 16.sp,
                        color: primaryGold,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        (feature['name'] as String).replaceAll(RegExp(r'[🎯☁️📊🏢👤🔄]'), '').trim(),
                        style: AppTypography.bodyS.copyWith(
                          color: textPrimary,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryGold.withValues(alpha: 0.2),
            primaryGold.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: primaryGold, width: 2),
      ),
      child: Column(
        children: [
          Icon(
            Icons.workspace_premium,
            size: 56.sp,
            color: primaryGold,
          ),
          SizedBox(height: 16.h),
          Text(
            '🎉 ${isArabic ? 'عضو مدى الحياة!' : 'Lifetime Member!'}',
            style: AppTypography.h2.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryGold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            isArabic
                ? 'أنت تملك أفضل باقة. استمتع بجميع الميزات إلى الأبد!'
                : 'You have the best plan. Enjoy all features forever!',
            style: AppTypography.bodyM.copyWith(
              color: textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreButton(SubscriptionNotifier notifier, bool isArabic) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    
    return TextButton(
      onPressed: _isProcessing 
          ? null 
          : () => _handleRestorePurchases(notifier, isArabic),
      child: Text(
        isArabic ? 'استعادة المشتريات' : 'Restore purchases',
        style: AppTypography.bodyS.copyWith(
          color: textSecondary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildStickyCTA(SubscriptionNotifier notifier, bool isArabic) {
    if (_selectedPackage == null) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    const primaryGold = AppColors.gold; // Always use gold for buttons

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            bgColor.withValues(alpha: 0),
            bgColor,
            bgColor,
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
                  primaryGold,
                  primaryGold.withValues(alpha: 0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: primaryGold.withValues(alpha: 0.4),
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isArabic ? 'اشترك الآن' : 'Subscribe Now',
                          style: AppTypography.button.copyWith(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                          color: isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
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
          
          if (!mounted) return;
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic ? 'تم الاشتراك بنجاح! 🎉' : 'Subscription successful! 🎉',
                style: AppTypography.bodyM,
              ),
              backgroundColor: isDark ? AppColors.successDark : AppColors.successLight,
            ),
          );

          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) Navigator.pop(context, true);
        } else {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic ? 'تم إلغاء الشراء' : 'Purchase cancelled',
                style: AppTypography.bodyM,
              ),
              backgroundColor: isDark ? AppColors.warningDark : AppColors.warningLight,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Purchase error', source: 'PaywallScreen', error: e, stackTrace: StackTrace.current);
      if (mounted) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic ? 'حدث خطأ أثناء الشراء' : 'An error occurred',
              style: AppTypography.bodyM,
            ),
            backgroundColor: isDark ? AppColors.errorDark : AppColors.errorLight,
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
          
          if (!mounted) return;
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic ? 'تم استعادة المشتريات! ✓' : 'Purchases restored! ✓',
                style: AppTypography.bodyM,
              ),
              backgroundColor: isDark ? AppColors.successDark : AppColors.successLight,
            ),
          );

          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) Navigator.pop(context, true);
        } else {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic ? 'لم يتم العثور على مشتريات' : 'No purchases found',
                style: AppTypography.bodyM,
              ),
              backgroundColor: isDark ? AppColors.warningDark : AppColors.warningLight,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Restore error', source: 'PaywallScreen', error: e, stackTrace: StackTrace.current);
      if (mounted) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic ? 'حدث خطأ أثناء الاستعادة' : 'An error occurred',
              style: AppTypography.bodyM,
            ),
            backgroundColor: isDark ? AppColors.errorDark : AppColors.errorLight,
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
