import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:animate_do/animate_do.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/question.dart';
import '../../../core/storage/hive_service.dart';
import 'exam_result_screen.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';
import 'exam_mode.dart';

/// -----------------------------------------------------------------
/// 📝 PAPER CORRECTION SCREEN / PAPIERKORREKTUR / شاشة تصحيح الورقي
/// -----------------------------------------------------------------
/// Quick input screen for paper exam answers
/// -----------------------------------------------------------------
class PaperCorrectionScreen extends ConsumerStatefulWidget {
  final List<Question> questions;

  const PaperCorrectionScreen({
    super.key,
    required this.questions,
  });

  @override
  ConsumerState<PaperCorrectionScreen> createState() => _PaperCorrectionScreenState();
}

class _PaperCorrectionScreenState extends ConsumerState<PaperCorrectionScreen> {
  final Map<int, String> _userAnswers = {}; // questionId -> selectedAnswerId
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each question
    for (final question in widget.questions) {
      _controllers[question.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _selectAnswer(int questionId, String answerId) {
    setState(() {
      _userAnswers[questionId] = answerId;
      // Update text field
      final controller = _controllers[questionId];
      if (controller != null) {
        final answerLetter = String.fromCharCode(65 + widget.questions
            .firstWhere((q) => q.id == questionId)
            .answers
            .indexWhere((a) => a.id == answerId));
        controller.text = answerLetter;
      }
    });
    HapticFeedback.selectionClick();
  }

  void _onTextFieldChanged(int questionId, String value) {
    if (value.isEmpty) {
      setState(() {
        _userAnswers.remove(questionId);
      });
      return;
    }

    final upperValue = value.toUpperCase();
    if (upperValue.length == 1 && ['A', 'B', 'C', 'D'].contains(upperValue)) {
      final question = widget.questions.firstWhere((q) => q.id == questionId);
      final answerIndex = upperValue.codeUnitAt(0) - 65; // A=0, B=1, C=2, D=3
      
      if (answerIndex >= 0 && answerIndex < question.answers.length) {
        final answerId = question.answers[answerIndex].id;
        setState(() {
          _userAnswers[questionId] = answerId;
        });
        HapticFeedback.selectionClick();
      }
    }
  }

  Future<void> _finishAndGrade() async {
    if (_userAnswers.length < widget.questions.length) {
      final l10n = AppLocalizations.of(context);
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      
      if (!mounted) return;
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkSurface,
          title: Text(
            l10n?.paperCorrectionIncompleteTitle ?? 
            (isArabic ? 'إجابات غير مكتملة' : 'Incomplete Answers'),
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          content: Text(
            l10n?.paperCorrectionIncompleteMessage ?? 
            (isArabic 
                ? 'لم تقم بالإجابة على جميع الأسئلة. هل تريد المتابعة؟' 
                : 'You have not answered all questions. Continue anyway?'),
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                l10n?.cancel ?? 'Cancel',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                l10n?.confirm ?? 'Confirm',
                style: GoogleFonts.poppins(color: AppColors.eagleGold),
              ),
            ),
          ],
        ),
      );

      if (shouldContinue != true) return;
    }

    // Calculate score
    int correctCount = 0;
    int wrongCount = 0;

    for (final question in widget.questions) {
      final userAnswer = _userAnswers[question.id];
      if (userAnswer != null) {
        if (userAnswer == question.correctAnswerId) {
          correctCount++;
        } else {
          wrongCount++;
        }

        // Save to Hive for SRS
        try {
          await HiveService.saveQuestionAnswer(
            question.id,
            userAnswer,
            userAnswer == question.correctAnswerId,
          );
        } catch (e) {
          // Continue even if save fails
        }
      }
    }

    final totalQuestions = widget.questions.length;
    final scorePercentage = totalQuestions > 0
        ? (correctCount / totalQuestions * 100).round()
        : 0;
    final isPassed = scorePercentage >= 50;

    // Save exam result
    try {
      final questionDetails = widget.questions.map((question) {
        final userAnswer = _userAnswers[question.id];
        final isCorrect = userAnswer != null && userAnswer == question.correctAnswerId;
        return {
          'questionId': question.id,
          'userAnswer': userAnswer ?? '',
          'correctAnswer': question.correctAnswerId,
          'isCorrect': isCorrect,
        };
      }).toList();

      await HiveService.saveExamResult(
        scorePercentage: scorePercentage,
        correctCount: correctCount,
        wrongCount: wrongCount,
        totalQuestions: totalQuestions,
        timeSeconds: 0, // Paper exam has no timer
        mode: 'paper',
        isPassed: isPassed,
        questionDetails: questionDetails,
      );
    } catch (e) {
      // Continue even if save fails
    }

    // Navigate to result screen
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExamResultScreen(
          questions: widget.questions,
          userAnswers: _userAnswers,
          totalTimeSeconds: 0,
          mode: ExamMode.paper,
        ),
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
          l10n?.paperCorrectionTitle ?? 
          (isArabic ? 'تصحيح الامتحان الورقي' : 'Paper Exam Correction'),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: AdaptivePageWrapper(
        padding: EdgeInsets.zero,
        enableScroll: false, // Column مع ListView يملأ الشاشة
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.eagleGold.withValues(alpha: 0.2),
                  AppColors.darkSurface,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AutoSizeText(
                  l10n?.paperCorrectionInstructions ?? 
                  (isArabic 
                      ? 'أدخل إجاباتك من الورقة' 
                      : 'Enter your answers from the paper'),
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                SizedBox(height: 8.h),
                AutoSizeText(
                  '${_userAnswers.length} / ${widget.questions.length} ${l10n?.paperCorrectionAnswered ?? (isArabic ? 'إجابة' : 'answered')}',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: AppColors.eagleGold,
                  ),
                ),
              ],
            ),
          ),

          // Questions list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: widget.questions.length,
              itemBuilder: (context, index) {
                final question = widget.questions[index];
                final questionNumber = index + 1;
                final selectedAnswer = _userAnswers[question.id];
                final controller = _controllers[question.id]!;

                return FadeInUp(
                  delay: Duration(milliseconds: index * 20),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: selectedAnswer != null
                            ? AppColors.eagleGold.withValues(alpha: 0.5)
                            : AppColors.eagleGold.withValues(alpha: 0.2),
                        width: selectedAnswer != null ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Question number and text input
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 32.w,
                                height: 32.h,
                                decoration: BoxDecoration(
                                  color: AppColors.eagleGold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Center(
                                  child: Text(
                                    'Q$questionNumber',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.eagleGold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              // Text input for quick entry
                              SizedBox(
                                width: 60.w,
                                child: TextField(
                                  controller: controller,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: '?',
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.white30,
                                    ),
                                    counterText: '',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: AppColors.eagleGold.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: AppColors.eagleGold.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: const BorderSide(
                                        color: AppColors.eagleGold,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.darkCharcoal,
                                  ),
                                  onChanged: (value) => _onTextFieldChanged(question.id, value),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Answer buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: question.answers.map((answer) {
                            final letter = String.fromCharCode(65 + question.answers.indexOf(answer));
                            final isSelected = selectedAnswer == answer.id;
                            
                            return GestureDetector(
                              onTap: () => _selectAnswer(question.id, answer.id),
                              child: Container(
                                width: 40.w,
                                height: 40.h,
                                margin: EdgeInsets.symmetric(horizontal: 4.w),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.eagleGold
                                      : AppColors.darkCharcoal,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.eagleGold
                                        : AppColors.eagleGold.withValues(alpha: 0.3),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    letter,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.black : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Finish button
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton.icon(
                onPressed: _finishAndGrade,
                icon: Icon(Icons.check_circle, size: 24.sp),
                label: AutoSizeText(
                  l10n?.paperCorrectionFinish ?? 
                  (isArabic ? 'إنهاء وتصحيح' : 'Finish & Grade'),
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
        ],
        ),
      ),
    );
  }
}

