import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/subscription_provider.dart';
import '../../../core/debug/app_logger.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';

/// -----------------------------------------------------------------
/// 💎 PAYWALL SCREEN / PREMIUM / شاشة الاشتراك
/// -----------------------------------------------------------------
/// Screen for displaying subscription options and handling purchases
/// -----------------------------------------------------------------
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final subscriptionState = ref.watch(subscriptionProvider);
    final subscriptionNotifier = ref.read(subscriptionProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: AutoSizeText(
          isArabic ? 'اشتراك Premium' : 'Premium Subscription',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: subscriptionState.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.eagleGold,
              ),
            )
          : AdaptivePageWrapper(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  FadeInDown(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 80.sp,
                          color: AppColors.eagleGold,
                        ),
                        SizedBox(height: 16.h),
                        AutoSizeText(
                          isArabic ? 'افتح Premium' : 'Unlock Premium Features',
                          style: GoogleFonts.poppins(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),

                  // Free vs Premium Comparison
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildComparisonSection(theme, isArabic),
                  ),

                  SizedBox(height: 32.h),

                  // Subscription Options
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: _buildSubscriptionOptions(
                      context,
                      subscriptionState.offerings,
                      subscriptionNotifier,
                      theme,
                      isArabic,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Restore Purchases Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: TextButton(
                      onPressed: _isProcessing
                          ? null
                          : () => _handleRestorePurchases(subscriptionNotifier, isArabic),
                      child: AutoSizeText(
                        isArabic ? 'استعادة المشتريات' : 'Restore Purchases',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildComparisonSection(ThemeData theme, bool isArabic) {
    final l10n = AppLocalizations.of(context);
    return Card(
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: AppColors.eagleGold.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
        child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AutoSizeText(
              l10n?.availableFeatures ?? 'Available Features',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 20.h),
            
            // Free Plan
            _buildPlanRow(
              theme,
              l10n?.freePlan ?? 'Free',
              [
                l10n?.accessToAllQuestions ?? 'Access to all questions',
                l10n?.adsIfAvailable ?? 'Ads (if available)',
                l10n?.oneExamPerDay ?? 'One exam per day',
              ],
              false,
            ),
            
            SizedBox(height: 16.h),
            Divider(color: AppColors.eagleGold.withValues(alpha: 0.3)),
            SizedBox(height: 16.h),
            
            // Premium Plan
            _buildPlanRow(
              theme,
              l10n?.proSubscriptionPremium ?? 'Pro Subscription (Premium)',
              [
                l10n?.unlimitedAiTutor ?? 'Unlimited AI Tutor',
                l10n?.pdfExamGeneration ?? 'PDF Exam Generation',
                l10n?.noAds ?? 'No Ads',
                l10n?.advancedSuccessStatistics ?? 'Advanced Success Statistics',
              ],
              true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanRow(ThemeData theme, String title, List<String> features, bool isPremium) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              isPremium ? Icons.star : Icons.check_circle_outline,
              color: isPremium ? AppColors.eagleGold : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            AutoSizeText(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isPremium ? AppColors.eagleGold : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...features.map((feature) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Icon(
                  Icons.check,
                  color: isPremium ? AppColors.eagleGold : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: AutoSizeText(
                    feature,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubscriptionOptions(
    BuildContext context,
    Offerings? offerings,
    SubscriptionNotifier notifier,
    ThemeData theme,
    bool isArabic,
  ) {
    // Mock Mode: إذا لم تكن هناك عروض، نستخدم Mock data
    final packages = offerings?.current?.availablePackages ?? [];
    
    if (packages.isEmpty) {
      // Mock Mode: إنشاء Mock packages
      return _buildMockPackages(context, notifier, theme, isArabic);
    }

    // ترتيب Packages: Monthly, 3 Months, Lifetime
    packages.sort((a, b) {
      final aPeriod = _getPackagePeriod(a);
      final bPeriod = _getPackagePeriod(b);
      return aPeriod.compareTo(bPeriod);
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: packages.asMap().entries.map((entry) {
        final index = entry.key;
        final package = entry.value;
        final isBestValue = index == 1; // Yearly is "Best Value"

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildPackageCard(
            context,
            package,
            notifier,
            theme,
            isArabic,
            isBestValue,
          ),
        );
      }).toList(),
    );
  }

  /// بناء Mock Packages للاستخدام في Mock Mode
  Widget _buildMockPackages(
    BuildContext context,
    SubscriptionNotifier notifier,
    ThemeData theme,
    bool isArabic,
  ) {
    final l10n = AppLocalizations.of(context);
    
    final mockPackages = [
      {
        'identifier': 'monthly',
        'title': l10n?.monthly ?? 'Monthly',
        'subtitle': l10n?.renewsMonthly ?? 'Renews monthly',
        'price': '\$4.99',
        'packageType': 1,
      },
      {
        'identifier': 'yearly',
        'title': l10n?.yearly ?? 'Yearly',
        'subtitle': l10n?.bestValue ?? 'Best Value',
        'price': '\$29.99',
        'packageType': 2,
      },
      {
        'identifier': 'lifetime',
        'title': l10n?.lifetime ?? 'Lifetime',
        'subtitle': l10n?.oneTimePayment ?? 'One-time payment',
        'price': '\$99.99',
        'packageType': 3,
      },
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: mockPackages.asMap().entries.map((entry) {
        final index = entry.key;
        final mockPackage = entry.value;
        final isBestValue = index == 1; // Yearly is "Best Value"

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildMockPackageCard(
            context,
            mockPackage,
            notifier,
            theme,
            isArabic,
            isBestValue,
          ),
        );
      }).toList(),
    );
  }

  /// بناء بطاقة Mock Package
  Widget _buildMockPackageCard(
    BuildContext context,
    Map<String, dynamic> mockPackage,
    SubscriptionNotifier notifier,
    ThemeData theme,
    bool isArabic,
    bool isBestValue,
  ) {
    return Card(
      color: isBestValue ? AppColors.eagleGold.withValues(alpha: 0.1) : theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: isBestValue ? AppColors.eagleGold : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: _isProcessing
            ? null
            : () {
                // في Mock Mode، لا يمكن إجراء شراء حقيقي
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: AutoSizeText(
                      isArabic
                          ? 'وضع المحاكاة: لا يمكن إجراء شراء حقيقي'
                          : 'Mock Mode: Cannot make real purchase',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isBestValue)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.eagleGold,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: AutoSizeText(
                          AppLocalizations.of(context)?.bestValue ?? 'Best Value',
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    if (isBestValue) SizedBox(height: 8.h),
                    AutoSizeText(
                      mockPackage['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    AutoSizeText(
                      mockPackage['subtitle'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AutoSizeText(
                    mockPackage['price'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.eagleGold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    Package package,
    SubscriptionNotifier notifier,
    ThemeData theme,
    bool isArabic,
    bool isBestValue,
  ) {
    final l10n = AppLocalizations.of(context);
    final identifier = package.identifier.toLowerCase();
    
    // تحديد العنوان والوصف بناءً على المعرف
    String title;
    String subtitle;
    
    if (identifier.contains('monthly') || identifier.contains('month')) {
      title = l10n?.monthly ?? 'Monthly';
      subtitle = l10n?.renewsMonthly ?? 'Renews monthly';
    } else if (identifier.contains('yearly') || identifier.contains('year') || identifier.contains('annual')) {
      title = l10n?.yearly ?? 'Yearly';
      subtitle = l10n?.bestValue ?? 'Best Value';
    } else if (identifier.contains('lifetime') || identifier.contains('forever')) {
      title = l10n?.lifetime ?? 'Lifetime';
      subtitle = l10n?.oneTimePayment ?? 'One-time payment';
    } else {
      title = package.storeProduct.title;
      subtitle = package.storeProduct.description;
    }

    return Card(
      color: isBestValue ? AppColors.eagleGold.withValues(alpha: 0.1) : theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: isBestValue ? AppColors.eagleGold : Colors.transparent,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: _isProcessing ? null : () => _handlePurchase(package, notifier, isArabic),
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isBestValue)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.eagleGold,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: AutoSizeText(
                              AppLocalizations.of(context)?.bestValue ?? 'Best Value',
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        if (isBestValue) SizedBox(height: 8.h),
                        AutoSizeText(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        AutoSizeText(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AutoSizeText(
                        package.storeProduct.priceString,
                        style: GoogleFonts.poppins(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.eagleGold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // CircularProgressIndicator عند _isProcessing
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.eagleGold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  int _getPackagePeriod(Package package) {
    final identifier = package.identifier.toLowerCase();
    if (identifier.contains('lifetime') || identifier.contains('forever')) return 3;
    if (identifier.contains('yearly') || identifier.contains('year') || identifier.contains('annual')) return 2;
    return 1; // Monthly
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
          // نجاح الشراء
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AutoSizeText(
                isArabic ? 'تم الاشتراك بنجاح!' : 'Subscription successful!',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // إغلاق الشاشة بعد تأخير قصير
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          // فشل الشراء (مثل إلغاء المستخدم)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AutoSizeText(
                isArabic ? 'تم إلغاء الشراء' : 'Purchase cancelled',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Purchase error', source: 'PaywallScreen', error: e, stackTrace: StackTrace.current);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AutoSizeText(
              isArabic ? 'حدث خطأ أثناء الشراء' : 'An error occurred during purchase',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AutoSizeText(
                isArabic ? 'تم استعادة المشتريات بنجاح!' : 'Purchases restored successfully!',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AutoSizeText(
                isArabic ? 'لم يتم العثور على مشتريات' : 'No purchases found',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Restore error', source: 'PaywallScreen', error: e, stackTrace: StackTrace.current);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AutoSizeText(
              isArabic ? 'حدث خطأ أثناء الاستعادة' : 'An error occurred during restore',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

