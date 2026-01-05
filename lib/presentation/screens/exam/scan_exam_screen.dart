import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/question.dart';
import '../../../data/datasources/local_datasource.dart';
import 'paper_correction_screen.dart';

/// -----------------------------------------------------------------
/// 📸 SCAN EXAM SCREEN / QR-SCANNER / شاشة مسح QR Code
/// -----------------------------------------------------------------
/// Scans QR code from PDF to load exam questions
/// -----------------------------------------------------------------
class ScanExamScreen extends ConsumerStatefulWidget {
  const ScanExamScreen({super.key});

  @override
  ConsumerState<ScanExamScreen> createState() => _ScanExamScreenState();
}

class _ScanExamScreenState extends ConsumerState<ScanExamScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture barcodeCapture) async {
    if (_isProcessing) return;

    if (barcodeCapture.barcodes.isEmpty) return;
    final barcode = barcodeCapture.barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    try {
      final qrData = barcode.rawValue!;
      
      // Parse QR data: "ids:101,45,22,300..."
      if (!qrData.startsWith('ids:')) {
        _showError('Invalid QR code format');
        setState(() => _isProcessing = false);
        return;
      }

      final idsString = qrData.substring(4); // Remove "ids:" prefix
      final questionIds = idsString
          .split(',')
          .map((id) => int.tryParse(id.trim()))
          .where((id) => id != null)
          .cast<int>()
          .toList();

      if (questionIds.isEmpty) {
        _showError('No question IDs found');
        setState(() => _isProcessing = false);
        return;
      }

      // Load questions from repository
      final localDataSource = LocalDataSourceImpl();
      final allQuestions = await localDataSource.getGeneralQuestions();
      
      // Also try to load state questions
      final stateQuestions = <Question>[];
      for (final stateCode in ['BW', 'BY', 'BE', 'BB', 'HB', 'HH', 'HE', 'MV', 'NI', 'NW', 'RP', 'SL', 'SN', 'ST', 'SH', 'TH']) {
        try {
          final questions = await localDataSource.getStateQuestions(stateCode);
          stateQuestions.addAll(questions);
        } catch (e) {
          // Continue if state file doesn't exist
        }
      }

      // Combine all questions
      final allAvailableQuestions = [...allQuestions, ...stateQuestions];
      
      // Find questions by IDs
      final examQuestions = questionIds
          .map((id) => allAvailableQuestions.firstWhere(
                (q) => q.id == id,
                orElse: () => throw Exception('Question $id not found'),
              ))
          .toList();

      if (examQuestions.length != questionIds.length) {
        _showError('Some questions not found');
        setState(() => _isProcessing = false);
        return;
      }

      // Stop scanner and navigate to correction screen
      await _scannerController.stop();
      
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaperCorrectionScreen(questions: examQuestions),
        ),
      );
    } catch (e) {
      _showError('Error: ${e.toString()}');
      setState(() => _isProcessing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
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
          l10n?.scanExamTitle ?? (isArabic ? 'مسح QR Code' : 'Scan QR Code'),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AdaptivePageWrapper(
        padding: EdgeInsets.zero,
        enableScroll: false, // Stack يملأ الشاشة
        child: Stack(
          children: [
          // Scanner
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcode,
          ),

          // Overlay with instructions
          Positioned(
            top: 20.h,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.darkSurface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.eagleGold.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: AppColors.eagleGold,
                    size: 32.sp,
                  ),
                  SizedBox(height: 8.h),
                  AutoSizeText(
                    l10n?.scanExamInstructions ?? 
                    (isArabic 
                        ? 'ضع QR Code من PDF داخل الإطار' 
                        : 'Position QR Code from PDF within frame'),
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),

          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.eagleGold),
                    ),
                    SizedBox(height: 16.h),
                    AutoSizeText(
                      l10n?.scanExamProcessing ?? 
                      (isArabic ? 'جاري المعالجة...' : 'Processing...'),
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

