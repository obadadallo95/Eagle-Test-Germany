import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:animate_do/animate_do.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/pdf_exam_service.dart';
import '../../../core/storage/user_preferences_service.dart';
import '../../widgets/paywall_guard.dart';
import 'scan_exam_screen.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';

/// -----------------------------------------------------------------
/// 📄 PAPER EXAM CONFIG SCREEN / PAPIERPRÜFUNG / شاشة إعداد امتحان الورقي
/// -----------------------------------------------------------------
/// Configuration screen for generating PDF exam papers
/// -----------------------------------------------------------------
class PaperExamConfigScreen extends ConsumerStatefulWidget {
  const PaperExamConfigScreen({super.key});

  @override
  ConsumerState<PaperExamConfigScreen> createState() => _PaperExamConfigScreenState();
}

class _PaperExamConfigScreenState extends ConsumerState<PaperExamConfigScreen> {
  bool _includeSolutions = false;
  bool _shuffleQuestions = false;
  String? _selectedState;
  List<String> _availableStates = [];
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final selectedState = await UserPreferencesService.getSelectedState();
    setState(() {
      _selectedState = selectedState;
    });

    // Load available states
    final states = [
      'BW', 'BY', 'BE', 'BB', 'HB', 'HH', 'HE', 'MV',
      'NI', 'NW', 'RP', 'SL', 'SN', 'ST', 'SH', 'TH',
    ];
    setState(() {
      _availableStates = states;
    });
  }

  String _getStateName(String code) {
    final stateMap = {
      'BW': 'Baden-Württemberg',
      'BY': 'Bayern',
      'BE': 'Berlin',
      'BB': 'Brandenburg',
      'HB': 'Bremen',
      'HH': 'Hamburg',
      'HE': 'Hessen',
      'MV': 'Mecklenburg-Vorpommern',
      'NI': 'Niedersachsen',
      'NW': 'Nordrhein-Westfalen',
      'RP': 'Rheinland-Pfalz',
      'SL': 'Saarland',
      'SN': 'Sachsen',
      'ST': 'Sachsen-Anhalt',
      'SH': 'Schleswig-Holstein',
      'TH': 'Thüringen',
    };
    return stateMap[code] ?? code;
  }

  Future<void> _generatePdf() async {
    setState(() => _isGenerating = true);

    try {
      // Generate PDF
      final doc = await PdfExamService.generateExamPdf(
        includeSolutions: _includeSolutions,
        shuffleQuestions: _shuffleQuestions,
        stateCode: _selectedState,
      );

      // Show options dialog
      if (!mounted) return;
      
      final l10n = AppLocalizations.of(context);
      
      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (context) => Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n?.paperExamPdfGenerated ?? 'PDF Generated Successfully!',
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await PdfExamService.printPdf(doc);
                    },
                    icon: Icon(Icons.print, size: 24.sp),
                    label: Text(l10n?.paperExamPrint ?? 'Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.eagleGold,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final filePath = await PdfExamService.savePdfToFile(doc);
                      await PdfExamService.sharePdf(filePath);
                    },
                    icon: Icon(Icons.share, size: 24.sp),
                    label: Text(l10n?.paperExamShare ?? 'Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.eagleGold,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              // Scan QR Code button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ScanExamScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.qr_code_scanner, size: 24.sp),
                label: Text(l10n?.paperExamScan ?? 'Scan to Correct'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkSurface,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n?.paperExam ?? (isArabic ? 'امتحان ورقي' : 'Paper Exam'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            FadeInDown(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.eagleGold.withValues(alpha: 0.2),
                      AppColors.eagleGold.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.eagleGold.withValues(alpha: 0.3),
                    width: 1.w,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.description,
                      size: 48.sp,
                      color: AppColors.eagleGold,
                    ),
                    SizedBox(height: 12.h),
                    AutoSizeText(
                      l10n?.paperExamSimulation ?? (isArabic ? 'محاكاة امتحان ورقي' : 'Paper Exam Simulation'),
                      style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                    ),
                    SizedBox(height: 8.h),
                    AutoSizeText(
                      l10n?.paperExamDescription ?? (isArabic
                          ? 'قم بإنشاء امتحان PDF واقعي للطباعة'
                          : 'Generate a realistic PDF exam for printing'),
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Configuration Card
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Card(
                color: AppColors.darkSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.paperExamConfiguration ?? (isArabic ? 'الإعدادات' : 'Configuration'),
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // State Selection
                      Text(
                        l10n?.paperExamState ?? (isArabic ? 'الولاية / Bundesland' : 'State / Bundesland'),
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedState,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.darkCharcoal,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: AppColors.eagleGold.withValues(alpha: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: AppColors.eagleGold.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(color: AppColors.eagleGold),
                          ),
                        ),
                        dropdownColor: AppColors.darkSurface,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14.sp),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(l10n?.paperExamGeneral ?? (isArabic ? 'عام (بدون ولاية)' : 'General (No State)')),
                          ),
                          ..._availableStates.map((state) {
                            return DropdownMenuItem<String>(
                              value: state,
                              child: Text(_getStateName(state)),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedState = value);
                        },
                        isExpanded: true,
                      ),
                      SizedBox(height: 20.h),

                      // Include Solutions Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n?.paperExamIncludeSolutions ?? (isArabic ? 'تضمين الحلول' : 'Include Answer Key'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  l10n?.paperExamIncludeSolutionsDesc ?? 'Lösungsschlüssel beifügen',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _includeSolutions,
                            onChanged: (value) {
                              setState(() => _includeSolutions = value);
                            },
                            activeThumbColor: AppColors.eagleGold,
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Shuffle Questions Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n?.paperExamShuffle ?? (isArabic ? 'خلط الأسئلة' : 'Shuffle Questions'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  l10n?.paperExamShuffleDesc ?? 'Fragen mischen',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _shuffleQuestions,
                            onChanged: (value) {
                              setState(() => _shuffleQuestions = value);
                            },
                            activeThumbColor: AppColors.eagleGold,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Generate Button (Protected by Paywall)
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: PaywallGuard(
                child: SizedBox(
                  width: double.infinity,
                  height: 60.h,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generatePdf,
                    icon: _isGenerating
                        ? SizedBox(
                            width: 20.sp,
                            height: 20.sp,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : Icon(Icons.description, size: 24.sp),
                    label: Text(
                      _isGenerating
                          ? (l10n?.paperExamGenerating ?? (isArabic ? 'جاري الإنشاء...' : 'Generating...'))
                          : (l10n?.paperExamGenerate ?? (isArabic ? 'إنشاء PDF 📄' : 'Generate PDF 📄')),
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.eagleGold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

