import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:animate_do/animate_do.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/storage/hive_service.dart';
import '../../../core/debug/app_logger.dart';
import '../exam_screen.dart';
import 'exam_mode.dart';
import 'exam_detail_screen.dart';
import 'paper_exam_config_screen.dart';
import 'voice_exam_screen.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';
import '../../widgets/paywall_guard.dart';

/// -----------------------------------------------------------------
/// 📝 EXAM LANDING SCREEN / PRÜFUNG / شاشة الامتحان
/// -----------------------------------------------------------------
/// Landing screen for exam mode with large "Start Simulation" button
/// and recent exam results history.
/// -----------------------------------------------------------------
class ExamLandingScreen extends ConsumerStatefulWidget {
  const ExamLandingScreen({super.key});

  @override
  ConsumerState<ExamLandingScreen> createState() => _ExamLandingScreenState();
}

class _ExamLandingScreenState extends ConsumerState<ExamLandingScreen> {
  List<Map<String, dynamic>> _recentResults = [];

  @override
  void initState() {
    super.initState();
    _loadRecentResults();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload results when returning to this screen
    _loadRecentResults();
  }

  Future<void> _loadRecentResults() async {
    AppLogger.functionStart('_loadRecentResults', source: 'ExamLandingScreen');
    final examHistory = HiveService.getExamHistory();
    AppLogger.info('Total exams in history: ${examHistory.length}', source: 'ExamLandingScreen');
    
    // Get last 3 results
    final recent = examHistory.take(3).toList();
    AppLogger.log('Displaying ${recent.length} recent exams', source: 'ExamLandingScreen');
    
    setState(() {
      _recentResults = recent;
    });
    AppLogger.functionEnd('_loadRecentResults', source: 'ExamLandingScreen');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n?.examMode ?? 'Exam Mode',
          style: AppTypography.h2.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: AdaptivePageWrapper(
        child: Column(
          children: [
            // Large Start Simulation Button
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Container(
                width: double.infinity,
                height: 200.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryGold.withValues(alpha: 0.3),
                      AppColors.errorDark.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: primaryGold,
                    width: 2.w,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ExamScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(24.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Pulse(
                          infinite: true,
                          duration: const Duration(seconds: 2),
                          child: Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: primaryGold,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              size: 60.sp,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AutoSizeText(
                          isArabic ? 'ابدأ المحاكاة' : 'Start Simulation',
                          style: AppTypography.h1.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightBg,
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AutoSizeText(
                          '33 Questions • 60 Minutes',
                          style: AppTypography.bodyM.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Paper Exam Widget
            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: _buildPaperExamWidget(context, l10n, isArabic, isDark, primaryGold, surfaceColor),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Voice Exam Button (Pro Feature)
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: PaywallGuard(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VoiceExamScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.mic, size: 24.sp),
                    label: AutoSizeText(
                      l10n?.voiceExam ?? '🎤 Voice Exam (Pro)',
                      style: AppTypography.button,
                      maxLines: 1,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Quick Practice Button
            FadeInUp(
              delay: const Duration(milliseconds: 250),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExamScreen(mode: ExamMode.quick),
                      ),
                    );
                  },
                  icon: Icon(Icons.flash_on, size: 24.sp),
                  label: AutoSizeText(
                    l10n?.quickPractice ?? 'Quick Practice',
                    style: AppTypography.button,
                    maxLines: 1,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: surfaceColor,
                    foregroundColor: primaryGold,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      side: BorderSide(
                        color: primaryGold.withValues(alpha: 0.5),
                        width: 1.w,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Recent Results Section
            if (_recentResults.isNotEmpty) ...[
              Row(
                children: [
                  AutoSizeText(
                    isArabic ? 'النتائج الأخيرة' : 'Recent Results',
                    style: AppTypography.h3.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              ..._recentResults.map((result) {
                final dateStr = result['date'] as String?;
                final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
                final formattedDate = date != null 
                    ? '${date.day}/${date.month}/${date.year}'
                    : 'Unknown';
                final score = result['scorePercentage'] as int? ?? 0;
                final isPassed = result['isPassed'] as bool? ?? false;
                final mode = result['mode'] as String? ?? 'full';
                
                return FadeInUp(
                  child: Card(
                    color: surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      side: BorderSide(
                        color: isPassed 
                            ? AppColors.successDark.withValues(alpha: 0.3)
                            : AppColors.errorDark.withValues(alpha: 0.3),
                        width: 1.w,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExamDetailScreen(examResult: result),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16.r),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPassed 
                              ? AppColors.successDark.withValues(alpha: 0.2)
                              : AppColors.errorDark.withValues(alpha: 0.2),
                          child: Icon(
                            isPassed ? Icons.check_circle : Icons.cancel,
                            color: isPassed ? AppColors.successDark : AppColors.errorDark,
                          ),
                        ),
                        title: AutoSizeText(
                          formattedDate,
                          style: AppTypography.h4.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                        ),
                        subtitle: AutoSizeText(
                          '$score% • ${mode == 'full' ? (isArabic ? 'امتحان كامل' : 'Full Exam') : (isArabic ? 'اختبار سريع' : 'Quick Practice')}',
                          style: AppTypography.bodyS.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: primaryGold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ] else ...[
              Card(
                color: surfaceColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48.sp,
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AutoSizeText(
                        isArabic ? 'لا توجد نتائج سابقة' : 'No exam results yet',
                        style: AppTypography.bodyL.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaperExamWidget(
    BuildContext context, 
    AppLocalizations? l10n, 
    bool isArabic,
    bool isDark,
    Color primaryGold,
    Color surfaceColor,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                  surfaceColor,
                ]
              : [
                  primaryGold.withValues(alpha: 0.1),
                  primaryGold.withValues(alpha: 0.05),
                  surfaceColor,
                ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.3)
              : primaryGold.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PaperExamConfigScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: primaryGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: primaryGold,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.print_rounded,
                    color: primaryGold,
                    size: 32.sp,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              l10n?.paperExam ?? (isArabic ? 'امتحان ورقي' : 'Paper Exam'),
                              style: AppTypography.h3.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          // Info button
                          IconButton(
                            icon: Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              size: 20.sp,
                            ),
                            onPressed: () => _showPaperExamTutorial(context, l10n, isArabic, isDark, primaryGold, surfaceColor),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AutoSizeText(
                        l10n?.paperExamWidgetDescription ?? 
                        (isArabic 
                            ? 'طباعة وممارسة بدون إنترنت' 
                            : 'Print & Practice Offline'),
                        style: AppTypography.bodyS.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Arrow
                Icon(
                  Icons.chevron_right,
                  color: primaryGold,
                  size: 28.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPaperExamTutorial(
    BuildContext context, 
    AppLocalizations? l10n, 
    bool isArabic,
    bool isDark,
    Color primaryGold,
    Color surfaceColor,
  ) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.print_rounded,
                  color: primaryGold,
                  size: 32.sp,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AutoSizeText(
                    l10n?.paperExamTutorialTitle ?? 
                    (isArabic ? 'كيفية استخدام الامتحان الورقي' : 'How to Use Paper Exam'),
                    style: AppTypography.h2.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close, 
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            // Steps
            _buildTutorialStep(
              context,
              l10n,
              isArabic,
              isDark,
              primaryGold,
              step: 1,
              icon: Icons.create,
              title: l10n?.paperExamTutorialStep1Title ?? 
                     (isArabic ? 'إنشاء PDF' : 'Create PDF'),
              description: l10n?.paperExamTutorialStep1Desc ?? 
                          (isArabic 
                              ? 'اضغط على "امتحان ورقي" واختر الإعدادات (الولاية، خلط الأسئلة، تضمين الحلول) ثم اضغط "إنشاء PDF"' 
                              : 'Tap "Paper Exam", choose settings (state, shuffle, include solutions), then tap "Generate PDF"'),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildTutorialStep(
              context,
              l10n,
              isArabic,
              isDark,
              primaryGold,
              step: 2,
              icon: Icons.print,
              title: l10n?.paperExamTutorialStep2Title ?? 
                     (isArabic ? 'طباعة PDF' : 'Print PDF'),
              description: l10n?.paperExamTutorialStep2Desc ?? 
                          (isArabic 
                              ? 'اطبع PDF على ورق. سيكون هناك QR Code في أعلى الصفحة' 
                              : 'Print the PDF on paper. There will be a QR Code at the top of the page'),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildTutorialStep(
              context,
              l10n,
              isArabic,
              isDark,
              primaryGold,
              step: 3,
              icon: Icons.edit,
              title: l10n?.paperExamTutorialStep3Title ?? 
                     (isArabic ? 'أجب على الورقة' : 'Answer on Paper'),
              description: l10n?.paperExamTutorialStep3Desc ?? 
                          (isArabic 
                              ? 'أجب على الأسئلة باستخدام القلم والورقة كما في الامتحان الحقيقي' 
                              : 'Answer the questions using pen and paper, just like the real exam'),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildTutorialStep(
              context,
              l10n,
              isArabic,
              isDark,
              primaryGold,
              step: 4,
              icon: Icons.qr_code_scanner,
              title: l10n?.paperExamTutorialStep4Title ?? 
                     (isArabic ? 'مسح QR Code' : 'Scan QR Code'),
              description: l10n?.paperExamTutorialStep4Desc ?? 
                          (isArabic 
                              ? 'افتح التطبيق واذهب إلى "امتحان ورقي" ثم اضغط "Scan to Correct" وامسح QR Code من الورقة' 
                              : 'Open the app, go to "Paper Exam", tap "Scan to Correct", and scan the QR Code from the paper'),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildTutorialStep(
              context,
              l10n,
              isArabic,
              isDark,
              primaryGold,
              step: 5,
              icon: Icons.check_circle,
              title: l10n?.paperExamTutorialStep5Title ?? 
                     (isArabic ? 'أدخل الإجابات واحصل على النتيجة' : 'Enter Answers & Get Score'),
              description: l10n?.paperExamTutorialStep5Desc ?? 
                          (isArabic 
                              ? 'أدخل إجاباتك من الورقة في التطبيق بسرعة واحصل على النتيجة فوراً' 
                              : 'Quickly enter your answers from the paper into the app and get your score instantly'),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialStep(
    BuildContext context,
    AppLocalizations? l10n,
    bool isArabic,
    bool isDark,
    Color primaryGold,
    {
    required int step,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step number
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: primaryGold.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: primaryGold,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              '$step',
              style: AppTypography.badge.copyWith(
                color: primaryGold,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Icon
        Icon(
          icon,
          color: primaryGold,
          size: 24.sp,
        ),
        const SizedBox(width: AppSpacing.md),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                title,
                style: AppTypography.h4.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: AppSpacing.xs),
              AutoSizeText(
                description,
                style: AppTypography.bodyS.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
