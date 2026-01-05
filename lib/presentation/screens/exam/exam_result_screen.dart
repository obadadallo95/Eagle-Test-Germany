import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../domain/entities/question.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/storage/hive_service.dart';
import '../../../core/services/ai_tutor_service.dart';
import '../../../core/debug/app_logger.dart';
import '../../providers/locale_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/points_provider.dart';
import '../subscription/paywall_screen.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';
import 'exam_mode.dart';
import 'exam_detail_screen.dart';
import '../main_screen.dart';

/// شاشة النتائج بعد انتهاء الامتحان
class ExamResultScreen extends ConsumerStatefulWidget {
  final List<Question> questions;
  final Map<int, String> userAnswers; // questionId -> selectedAnswerId
  final int totalTimeSeconds;
  final ExamMode mode;

  const ExamResultScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.totalTimeSeconds,
    required this.mode,
  });

  @override
  ConsumerState<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends ConsumerState<ExamResultScreen> {
  bool _isSaved = false;
  bool _showTranslation = false;

  @override
  void initState() {
    super.initState();
    _saveExamResult();
  }

  Future<void> _saveExamResult() async {
    if (_isSaved) {
      AppLogger.warn('Exam result already saved, skipping...', source: 'ExamResultScreen');
      return;
    }

    try {
      AppLogger.functionStart('_saveExamResult', source: 'ExamResultScreen');
      AppLogger.info('Starting save: ${widget.questions.length} questions, ${widget.userAnswers.length} answers, mode: ${widget.mode}', source: 'ExamResultScreen');

      // حساب النتيجة وإعداد تفاصيل الأسئلة
      int correctCount = 0;
      int wrongCount = 0;
      final List<Map<String, dynamic>> questionDetails = [];

      for (final question in widget.questions) {
        final userAnswer = widget.userAnswers[question.id];
        final isCorrect = userAnswer != null && userAnswer == question.correctAnswerId;
        
        if (isCorrect) {
          correctCount++;
        } else if (userAnswer != null) {
          wrongCount++;
        }

        // حفظ تفاصيل السؤال
        questionDetails.add({
          'questionId': question.id,
          'userAnswer': userAnswer ?? '',
          'correctAnswer': question.correctAnswerId,
          'isCorrect': isCorrect,
        });

        // حفظ الإجابة (صحيحة أو خاطئة) لتحديث SRS والتقدم
        try {
          await HiveService.saveQuestionAnswer(
            question.id,
            userAnswer ?? question.correctAnswerId,
            isCorrect,
          );
          AppLogger.event('Answer saved', source: 'ExamResultScreen', data: {
            'questionId': question.id,
            'isCorrect': isCorrect,
            'mode': widget.mode.toString(),
          });
        } catch (e, stackTrace) {
          AppLogger.error('Failed to save answer', source: 'ExamResultScreen', error: e, stackTrace: stackTrace);
        }
      }

      final totalQuestions = widget.questions.length;
      final scorePercentage = totalQuestions > 0 
          ? (correctCount / totalQuestions * 100).round() 
          : 0;
      final isPassed = scorePercentage >= 50;

      AppLogger.info('Exam calculated: score=$scorePercentage%, correct=$correctCount, wrong=$wrongCount, total=$totalQuestions, isPassed=$isPassed', source: 'ExamResultScreen');

      // حفظ النتيجة مع تفاصيل الأسئلة
      try {
        await HiveService.saveExamResult(
          scorePercentage: scorePercentage,
          correctCount: correctCount,
          wrongCount: wrongCount,
          totalQuestions: totalQuestions,
          timeSeconds: widget.totalTimeSeconds,
          mode: widget.mode == ExamMode.full ? 'full' : 'quick',
          isPassed: isPassed,
          questionDetails: questionDetails,
        );
        
        // إضافة النقاط للامتحان
        // نقاط الامتحان = (النسبة المئوية / 10) × عدد الأسئلة الصحيحة
        // مثال: 80% مع 8 أسئلة صحيحة = (80/10) × 8 = 64 نقطة
        final examPoints = ((scorePercentage / 10) * correctCount).round();
        if (examPoints > 0) {
          await ref.read(totalPointsProvider.notifier).addPoints(
            points: examPoints,
            source: 'exam',
            details: {
              'mode': widget.mode == ExamMode.full ? 'full' : 'quick',
              'scorePercentage': scorePercentage,
              'correctCount': correctCount,
              'totalQuestions': totalQuestions,
              'isPassed': isPassed,
              'timeSeconds': widget.totalTimeSeconds,
            },
          );
        }
        
        AppLogger.event('Exam result saved', source: 'ExamResultScreen', data: {
          'mode': widget.mode == ExamMode.full ? 'full' : 'quick',
          'score': scorePercentage,
          'time': widget.totalTimeSeconds,
          'points': examPoints,
        });
        
        // Verify it was saved
        final savedHistory = HiveService.getExamHistory();
        AppLogger.info('Verification: ${savedHistory.length} exams in history', source: 'ExamResultScreen');
        if (savedHistory.isNotEmpty) {
          final lastExam = savedHistory.first;
          AppLogger.log('Last exam: score=${lastExam['scorePercentage']}%, mode=${lastExam['mode']}', source: 'ExamResultScreen');
        }
      } catch (e, stackTrace) {
        AppLogger.error('Failed to save exam result', source: 'ExamResultScreen', error: e, stackTrace: stackTrace);
      }

      _isSaved = true;
      AppLogger.functionEnd('_saveExamResult', source: 'ExamResultScreen');
    } catch (e, stackTrace) {
      AppLogger.error('FATAL ERROR in _saveExamResult', source: 'ExamResultScreen', error: e, stackTrace: stackTrace);
      _isSaved = true; // Prevent infinite retries
    }
  }

  Future<void> _showAiExplanation(BuildContext context, Question question) async {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.read(localeProvider);
    final userLanguage = currentLocale.languageCode;
    final isArabic = userLanguage == 'ar';

    // Check if user is Pro
    final subscriptionState = ref.read(subscriptionProvider);
    final isPro = subscriptionState.isPro;
    
    // التحقق من عدد الاستخدامات اليومية للمستخدمين المجانيين
    if (!isPro) {
      final canUse = HiveService.canUseAiTutor(isPro: false);
      final remainingUses = HiveService.getRemainingAiTutorUsesToday(isPro: false);
      
      if (!canUse) {
        // تم تجاوز الحد اليومي (3 مرات)
        showDialog(
          context: context,
          builder: (context) {
            final theme = Theme.of(context);
            return AlertDialog(
              backgroundColor: theme.cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.eagleGold, size: 28.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      l10n.upgradeToPro,
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            content: Text(
              l10n.aiTutorDailyLimitReached,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: GoogleFonts.poppins(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaywallScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.eagleGold,
                    foregroundColor: Colors.black,
                  ),
                  child: Text(
                    l10n.upgrade,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
        return;
      }
      
      // التحقق من الاستخدامات المتبقية قبل الاستخدام
      if (remainingUses <= 0) {
        return;
      }
    }

    // Show loading bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AiExplanationBottomSheet(
        question: question,
        userLanguage: userLanguage,
        isArabic: isArabic,
        l10n: l10n,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.read(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar';

    // حساب النتيجة
    int correctCount = 0;
    int wrongCount = 0;
    final List<Question> wrongQuestions = [];

    for (final question in widget.questions) {
      final userAnswer = widget.userAnswers[question.id];
      if (userAnswer != null && userAnswer == question.correctAnswerId) {
        correctCount++;
      } else {
        if (userAnswer != null) {
          wrongCount++;
          wrongQuestions.add(question);
        }
      }
    }

    final totalQuestions = widget.questions.length;
    final scorePercentage = (correctCount / totalQuestions * 100).round();
    final isPassed = scorePercentage >= 50; // 50% للنجاح

    // تنسيق الوقت
    final minutes = widget.totalTimeSeconds ~/ 60;
    final seconds = widget.totalTimeSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isArabic ? 'نتيجة الامتحان' : 'Exam Results',
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Result Card
            Card(
              color: isPassed ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: BorderSide(
                  color: isPassed ? Colors.green : Colors.red,
                  width: 2.w,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    Icon(
                      isPassed ? Icons.check_circle : Icons.cancel,
                      size: 80.sp,
                      color: isPassed ? Colors.green : Colors.red,
                    ),
                    SizedBox(height: 16.h),
                    AutoSizeText(
                      isPassed 
                          ? (isArabic ? 'نجحت!' : 'Passed!')
                          : (isArabic ? 'لم تنجح' : 'Failed'),
                      style: GoogleFonts.poppins(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: isPassed ? Colors.green : Colors.red,
                      ),
                      maxLines: 1,
                    ),
                    SizedBox(height: 8.h),
                    AutoSizeText(
                      '$scorePercentage%',
                      style: GoogleFonts.poppins(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          icon: Icons.check_circle,
                          label: isArabic ? 'صحيح' : 'Correct',
                          value: '$correctCount',
                          color: Colors.green,
                        ),
                        _buildStatItem(
                          context,
                          icon: Icons.cancel,
                          label: isArabic ? 'خطأ' : 'Wrong',
                          value: '$wrongCount',
                          color: Colors.red,
                        ),
                        _buildStatItem(
                          context,
                          icon: Icons.timer,
                          label: isArabic ? 'الوقت' : 'Time',
                          value: timeString,
                          color: AppColors.eagleGold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Translation Toggle
            if (wrongQuestions.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.translate,
                    size: 18.sp,
                    color: _showTranslation ? AppColors.eagleGold : Colors.white54,
                  ),
                  SizedBox(width: 8.w),
                  AutoSizeText(
                    isArabic ? 'عرض الترجمة' : 'Show Translation',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                  ),
                  SizedBox(width: 8.w),
                  Switch(
                    value: _showTranslation,
                    onChanged: (value) {
                      setState(() {
                        _showTranslation = value;
                      });
                    },
                    activeThumbColor: AppColors.eagleGold,
                    activeTrackColor: AppColors.eagleGold.withValues(alpha: 0.5),
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
            ],

            // Wrong Answers Section
            if (wrongQuestions.isNotEmpty) ...[
              AutoSizeText(
                isArabic ? 'الأجوبة الخاطئة' : 'Wrong Answers',
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
              ),
              SizedBox(height: 16.h),
              ...wrongQuestions.map((question) {
                final userAnswer = widget.userAnswers[question.id];
                return Card(
                  color: AppColors.darkSurface,
                  margin: EdgeInsets.only(bottom: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(
                      color: Colors.red.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            question.getText(_showTranslation ? currentLocale.languageCode : 'de'),
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 3,
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Icon(Icons.close, size: 16.sp, color: Colors.red),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: AutoSizeText(
                                  '${isArabic ? 'إجابتك' : 'Your answer'}: ${userAnswer != null ? question.answers.firstWhere((a) => a.id == userAnswer, orElse: () => question.answers.first).getText(_showTranslation ? currentLocale.languageCode : 'de') : 'N/A'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: Colors.red.shade300,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(Icons.check, size: 16.sp, color: Colors.green),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: AutoSizeText(
                                  '${isArabic ? 'الإجابة الصحيحة' : 'Correct answer'}: ${question.answers.firstWhere((a) => a.id == question.correctAnswerId).getText(_showTranslation ? currentLocale.languageCode : 'de')}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: Colors.green.shade300,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          // AI Explain Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _showAiExplanation(context, question),
                              icon: Icon(
                                Icons.auto_awesome,
                                size: 18.sp,
                                color: AppColors.eagleGold,
                              ),
                              label: AutoSizeText(
                                l10n.explainWithAi,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: AppColors.eagleGold,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppColors.eagleGold.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 8.h,
                                  horizontal: 12.w,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ),
                );
              }),
            ],

            SizedBox(height: 24.h),

            // Review Answers Button
            ElevatedButton.icon(
              onPressed: () {
                // إنشاء examResult map من البيانات الحالية
                final examResultMap = {
                  'id': DateTime.now().millisecondsSinceEpoch,
                  'date': DateTime.now().toIso8601String(),
                  'scorePercentage': scorePercentage,
                  'correctCount': correctCount,
                  'wrongCount': wrongCount,
                  'totalQuestions': totalQuestions,
                  'timeSeconds': widget.totalTimeSeconds,
                  'mode': widget.mode == ExamMode.full ? 'full' : 'quick',
                  'isPassed': isPassed,
                  'questionDetails': widget.questions.map((question) {
                    final userAnswer = widget.userAnswers[question.id];
                    final isCorrect = userAnswer != null && userAnswer == question.correctAnswerId;
                    return {
                      'questionId': question.id,
                      'userAnswer': userAnswer ?? '',
                      'correctAnswer': question.correctAnswerId,
                      'isCorrect': isCorrect,
                    };
                  }).toList(),
                };
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExamDetailScreen(examResult: examResultMap),
                  ),
                );
              },
              icon: Icon(
                Icons.rate_review,
                size: 24.sp,
                color: Colors.black,
              ),
              label: AutoSizeText(
                l10n.reviewAnswers,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.eagleGold,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Back to Home Button
            OutlinedButton(
              onPressed: () {
                // العودة مباشرة للصفحة الرئيسية
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.eagleGold.withValues(alpha: 0.5),
                  width: 1,
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: AutoSizeText(
                isArabic ? 'العودة للرئيسية' : 'Back to Home',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.eagleGold,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.sp),
        SizedBox(height: 4.h),
        AutoSizeText(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
        ),
        AutoSizeText(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.white70,
          ),
          maxLines: 1,
        ),
      ],
    );
  }
}

/// StatefulWidget منفصل لحفظ الشرح ومنع إعادة الاستدعاء
class _AiExplanationBottomSheet extends StatefulWidget {
  final Question question;
  final String userLanguage;
  final bool isArabic;
  final AppLocalizations? l10n;

  const _AiExplanationBottomSheet({
    required this.question,
    required this.userLanguage,
    required this.isArabic,
    required this.l10n,
  });

  @override
  State<_AiExplanationBottomSheet> createState() => _AiExplanationBottomSheetState();
}

class _AiExplanationBottomSheetState extends State<_AiExplanationBottomSheet> {
  Future<String>? _explanationFuture;
  String? _cachedExplanation;

  @override
  void initState() {
    super.initState();
    // تحميل الشرح الأول مرة واحدة فقط
    _explanationFuture = _loadExplanation();
  }

  Future<String> _loadExplanation() async {
    if (_cachedExplanation != null) {
      return _cachedExplanation!;
    }
    
    final explanation = await AiTutorService.explainQuestion(
      question: widget.question,
      userLanguage: widget.userLanguage,
    );
    
    if (mounted) {
      setState(() {
        _cachedExplanation = explanation;
      });
    }
    
    return explanation;
  }

  Future<void> _refreshExplanation() async {
    setState(() {
      _cachedExplanation = null; // مسح الـ cache
    });

    final newExplanation = await AiTutorService.explainQuestion(
      question: widget.question,
      userLanguage: widget.userLanguage,
    );

    if (mounted) {
      setState(() {
        _cachedExplanation = newExplanation;
        _explanationFuture = Future.value(newExplanation);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: FutureBuilder<String>(
        future: _explanationFuture,
        builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Typing Indicator Animation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTypingDot(0),
                        SizedBox(width: 8.w),
                        _buildTypingDot(1),
                        SizedBox(width: 8.w),
                        _buildTypingDot(2),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      widget.l10n?.aiThinking ?? 'AI is thinking...',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              final error = snapshot.error;
              final errorMessage = error?.toString() ?? 'Unknown error';
              
              AppLogger.error('AI explanation error in UI', source: 'ExamResultScreen', error: error);
              
              return Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
                    SizedBox(height: 16.h),
                    Text(
                      widget.l10n?.errorLoadingExplanation ?? 'Error loading explanation',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      errorMessage.length > 100 
                          ? '${errorMessage.substring(0, 100)}...' 
                          : errorMessage,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12.sp,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: _refreshExplanation,
                      icon: Icon(Icons.refresh, size: 18.sp),
                      label: Text(
                        widget.isArabic ? 'إعادة المحاولة' : 'Retry',
                        style: GoogleFonts.poppins(fontSize: 14.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.eagleGold,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            }

            final explanation = snapshot.data ?? '';

            return Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
                border: Border.all(
                  color: AppColors.eagleGold.withValues(alpha: 0.3),
                  width: 2.w,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: AppColors.eagleGold,
                          size: 28.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            widget.l10n?.aiExplanation ?? 'AI Explanation',
                            style: GoogleFonts.poppins(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white70),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    // Explanation with Markdown
                    Flexible(
                      child: SingleChildScrollView(
                        child: MarkdownBody(
                          data: explanation,
                          styleSheet: MarkdownStyleSheet(
                            p: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              color: Colors.white,
                              height: 1.6,
                            ),
                            strong: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.eagleGold,
                            ),
                            h1: GoogleFonts.poppins(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            h2: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            h3: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            listBullet: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              color: AppColors.eagleGold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Action Buttons (Copy & Share)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: explanation));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    widget.isArabic ? 'تم النسخ!' : 'Copied!',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  backgroundColor: AppColors.eagleGold,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.copy,
                              size: 18.sp,
                              color: AppColors.eagleGold,
                            ),
                            label: Text(
                              widget.isArabic ? 'نسخ' : 'Copy',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: AppColors.eagleGold,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.eagleGold.withValues(alpha: 0.5),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Share.share(
                                explanation,
                                subject: widget.isArabic
                                    ? 'شرح من Eagle AI Tutor'
                                    : 'Explanation from Eagle AI Tutor',
                              );
                            },
                            icon: Icon(
                              Icons.share,
                              size: 18.sp,
                              color: Colors.black,
                            ),
                            label: Text(
                              widget.isArabic ? 'مشاركة' : 'Share',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.eagleGold,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
    );
  }

  /// بناء Typing Indicator Dot مع Animation
  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animatedValue = ((value + delay) % 1.0);
        final opacity = (animatedValue < 0.5)
            ? animatedValue * 2
            : 2 - (animatedValue * 2);
        final scale = 0.8 + (opacity * 0.4);

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: const BoxDecoration(
                color: AppColors.eagleGold,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
      onEnd: () {
        // إعادة تشغيل Animation
        if (mounted) {
          setState(() {});
        }
      },
    );
  }
}


