import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:animate_do/animate_do.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/storage/hive_service.dart';
import '../../../core/debug/app_logger.dart';
import '../exam_screen.dart';
import 'exam_mode.dart';
import 'exam_detail_screen.dart';
import 'paper_exam_config_screen.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';

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
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n?.examMode ?? 'Exam Mode',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
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
                      AppColors.eagleGold.withValues(alpha: 0.3),
                      AppColors.germanRed.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: AppColors.eagleGold,
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
                            decoration: const BoxDecoration(
                              color: AppColors.eagleGold,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              size: 60.sp,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        AutoSizeText(
                          isArabic ? 'ابدأ المحاكاة' : 'Start Simulation',
                          style: GoogleFonts.poppins(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                        ),
                        SizedBox(height: 8.h),
                        AutoSizeText(
                          '33 Questions • 60 Minutes',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Paper Exam Widget
            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: _buildPaperExamWidget(context, l10n, isArabic),
            ),

            SizedBox(height: 24.h),

            // Quick Practice Button
            FadeInUp(
              delay: const Duration(milliseconds: 200),
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
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkSurface,
                    foregroundColor: AppColors.eagleGold,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      side: BorderSide(
                        color: AppColors.eagleGold.withValues(alpha: 0.5),
                        width: 1.w,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // Recent Results Section
            if (_recentResults.isNotEmpty) ...[
              Row(
                children: [
                  AutoSizeText(
                    isArabic ? 'النتائج الأخيرة' : 'Recent Results',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
              SizedBox(height: 16.h),
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
                    color: AppColors.darkSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      side: BorderSide(
                        color: isPassed 
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.red.withValues(alpha: 0.3),
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
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.red.withValues(alpha: 0.2),
                          child: Icon(
                            isPassed ? Icons.check_circle : Icons.cancel,
                            color: isPassed ? Colors.green : Colors.red,
                          ),
                        ),
                        title: AutoSizeText(
                          formattedDate,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                        ),
                        subtitle: AutoSizeText(
                          '$score% • ${mode == 'full' ? (isArabic ? 'امتحان كامل' : 'Full Exam') : (isArabic ? 'اختبار سريع' : 'Quick Practice')}',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.eagleGold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ] else ...[
              Card(
                color: AppColors.darkSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48.sp,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(height: 16.h),
                      AutoSizeText(
                        isArabic ? 'لا توجد نتائج سابقة' : 'No exam results yet',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: Colors.white70,
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

  Widget _buildPaperExamWidget(BuildContext context, AppLocalizations? l10n, bool isArabic) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
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
                  AppColors.darkSurface,
                ]
              : [
                  AppColors.eagleGold.withValues(alpha: 0.1),
                  AppColors.eagleGold.withValues(alpha: 0.05),
                  Colors.white,
                ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.3)
              : AppColors.eagleGold.withValues(alpha: 0.3),
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
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: AppColors.eagleGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.eagleGold,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.print_rounded,
                    color: AppColors.eagleGold,
                    size: 32.sp,
                  ),
                ),
                SizedBox(width: 16.w),
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
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
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
                            onPressed: () => _showPaperExamTutorial(context, l10n, isArabic),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      AutoSizeText(
                        l10n?.paperExamWidgetDescription ?? 
                        (isArabic 
                            ? 'طباعة وممارسة بدون إنترنت' 
                            : 'Print & Practice Offline'),
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                // Arrow
                Icon(
                  Icons.chevron_right,
                  color: AppColors.eagleGold,
                  size: 28.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPaperExamTutorial(BuildContext context, AppLocalizations? l10n, bool isArabic) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.print_rounded,
                  color: AppColors.eagleGold,
                  size: 32.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: AutoSizeText(
                    l10n?.paperExamTutorialTitle ?? 
                    (isArabic ? 'كيفية استخدام الامتحان الورقي' : 'How to Use Paper Exam'),
                    style: GoogleFonts.poppins(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            // Steps
            _buildTutorialStep(
              context,
              l10n,
              isArabic,
              step: 1,
              icon: Icons.create,
              title: l10n?.paperExamTutorialStep1Title ?? 
                     (isArabic ? 'إنشاء PDF' : 'Create PDF'),
              description: l10n?.paperExamTutorialStep1Desc ?? 
                          (isArabic 
                              ? 'اضغط على "امتحان ورقي" واختر الإعدادات (الولاية، خلط الأسئلة، تضمين الحلول) ثم اضغط "إنشاء PDF"' 
                              : 'Tap "Paper Exam", choose settings (state, shuffle, include solutions), then tap "Generate PDF"'),
            ),
            SizedBox(height: 16.h),
            _buildTutorialStep(
              context,
              l10n,
              isArabic,
              step: 2,
              icon: Icons.print,
              title: l10n?.paperExamTutorialStep2Title ?? 
                     (isArabic ? 'طباعة PDF' : 'Print PDF'),
              description: l10n?.paperExamTutorialStep2Desc ?? 
                          (isArabic 
                              ? 'اطبع PDF على ورق. سيكون هناك QR Code في أعلى الصفحة' 
                              : 'Print the PDF on paper. There will be a QR Code at the top of the page'),
            ),
            SizedBox(height: 16.h),
            _buildTutorialStep(
              context,
              l10n,
              isArabic,
              step: 3,
              icon: Icons.edit,
              title: l10n?.paperExamTutorialStep3Title ?? 
                     (isArabic ? 'أجب على الورقة' : 'Answer on Paper'),
              description: l10n?.paperExamTutorialStep3Desc ?? 
                          (isArabic 
                              ? 'أجب على الأسئلة باستخدام القلم والورقة كما في الامتحان الحقيقي' 
                              : 'Answer the questions using pen and paper, just like the real exam'),
            ),
            SizedBox(height: 16.h),
            _buildTutorialStep(
              context,
              l10n,
              isArabic,
              step: 4,
              icon: Icons.qr_code_scanner,
              title: l10n?.paperExamTutorialStep4Title ?? 
                     (isArabic ? 'مسح QR Code' : 'Scan QR Code'),
              description: l10n?.paperExamTutorialStep4Desc ?? 
                          (isArabic 
                              ? 'افتح التطبيق واذهب إلى "امتحان ورقي" ثم اضغط "Scan to Correct" وامسح QR Code من الورقة' 
                              : 'Open the app, go to "Paper Exam", tap "Scan to Correct", and scan the QR Code from the paper'),
            ),
            SizedBox(height: 16.h),
            _buildTutorialStep(
              context,
              l10n,
              isArabic,
              step: 5,
              icon: Icons.check_circle,
              title: l10n?.paperExamTutorialStep5Title ?? 
                     (isArabic ? 'أدخل الإجابات واحصل على النتيجة' : 'Enter Answers & Get Score'),
              description: l10n?.paperExamTutorialStep5Desc ?? 
                          (isArabic 
                              ? 'أدخل إجاباتك من الورقة في التطبيق بسرعة واحصل على النتيجة فوراً' 
                              : 'Quickly enter your answers from the paper into the app and get your score instantly'),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialStep(
    BuildContext context,
    AppLocalizations? l10n,
    bool isArabic,
    {
    required int step,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step number
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: AppColors.eagleGold.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: AppColors.eagleGold,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              '$step',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.eagleGold,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Icon
        Icon(
          icon,
          color: AppColors.eagleGold,
          size: 24.sp,
        ),
        SizedBox(width: 12.w),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
              ),
              SizedBox(height: 4.h),
              AutoSizeText(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: Colors.white70,
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

