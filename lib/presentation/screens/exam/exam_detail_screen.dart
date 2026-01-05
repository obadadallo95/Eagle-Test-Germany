import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_tutor_service.dart';
import '../../../core/storage/hive_service.dart';
import '../../../core/debug/app_logger.dart';
import '../../providers/locale_provider.dart';
import '../../providers/question_provider.dart';
import '../../providers/subscription_provider.dart';
import '../subscription/paywall_screen.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';
import '../../../domain/entities/question.dart';

/// شاشة تفاصيل الامتحان - عرض الأسئلة والإجابات
class ExamDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> examResult;

  const ExamDetailScreen({
    super.key,
    required this.examResult,
  });

  @override
  ConsumerState<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends ConsumerState<ExamDetailScreen> {
  bool _showMistakesOnly = false;
  bool _showTranslation = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar';

    // Load question details
    final questionDetails = widget.examResult['questionDetails'] as List<dynamic>? ?? [];
    
    // Load all questions (general + state) from provider
    final questionsAsync = ref.watch(questionsProvider);

    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isArabic ? 'تفاصيل الامتحان' : 'Exam Details',
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
        enableScroll: false, // ListView يمرر نفسه
        child: questionsAsync.when(
          data: (allQuestions) {
          // Create a map for quick lookup
          final questionsMap = <int, Question>{};
          for (var q in allQuestions) {
            questionsMap[q.id] = q;
          }
          
          // Also try to load from general questions if not found
          final generalQuestionsAsync = ref.watch(generalQuestionsProvider);
          return generalQuestionsAsync.when(
            data: (generalQuestions) {
              for (var q in generalQuestions) {
                if (!questionsMap.containsKey(q.id)) {
                  questionsMap[q.id] = q;
                }
              }
              return _buildQuestionsList(context, questionsMap, questionDetails, isArabic, l10n, _showTranslation ? currentLocale.languageCode : 'de');
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.eagleGold),
            ),
            error: (_, __) => _buildQuestionsList(context, questionsMap, questionDetails, isArabic, l10n, _showTranslation ? currentLocale.languageCode : 'de'),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.eagleGold,
          ),
        ),
        error: (e, s) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
              SizedBox(height: 16.h),
              AutoSizeText(
                "Error: $e",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildQuestionsList(
    BuildContext context,
    Map<int, Question> questionsMap,
    List<dynamic> questionDetails,
    bool isArabic,
    AppLocalizations? l10n,
    String languageCode,
  ) {
    final dateStr = widget.examResult['date'] as String?;
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
    final formattedDate = date != null 
        ? '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'
        : 'Unknown';
    
    final isPassed = widget.examResult['isPassed'] as bool? ?? false;
    final mode = widget.examResult['mode'] as String? ?? 'full';

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Exam Summary Card
          Card(
            color: isPassed 
                ? Colors.green.withValues(alpha: 0.2) 
                : Colors.red.withValues(alpha: 0.2),
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
                    size: 64.sp,
                    color: isPassed ? Colors.green : Colors.red,
                  ),
                  SizedBox(height: 16.h),
                  AutoSizeText(
                    isPassed 
                        ? (isArabic ? 'نجحت!' : 'Passed!')
                        : (isArabic ? 'لم تنجح' : 'Failed'),
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: isPassed ? Colors.green : Colors.red,
                    ),
                    maxLines: 1,
                  ),
                  SizedBox(height: 8.h),
                  AutoSizeText(
                    '${widget.examResult['scorePercentage'] ?? 0}%',
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
                        value: '${widget.examResult['correctCount'] ?? 0}',
                        color: Colors.green,
                      ),
                      _buildStatItem(
                        context,
                        icon: Icons.cancel,
                        label: isArabic ? 'خطأ' : 'Wrong',
                        value: '${widget.examResult['wrongCount'] ?? 0}',
                        color: Colors.red,
                      ),
                      _buildStatItem(
                        context,
                        icon: Icons.timer,
                        label: isArabic ? 'الوقت' : 'Time',
                        value: _formatTime(widget.examResult['timeSeconds'] as int? ?? 0),
                        color: AppColors.eagleGold,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  AutoSizeText(
                    formattedDate,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                  ),
                  AutoSizeText(
                    mode == 'full' 
                        ? (isArabic ? 'امتحان كامل' : 'Full Exam')
                        : (isArabic ? 'اختبار سريع' : 'Quick Practice'),
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.white54,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Filter Toggle and Translation Toggle
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoSizeText(
                    isArabic ? 'الأسئلة والإجابات' : 'Questions & Answers',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                  ),
                  Row(
                    children: [
                      AutoSizeText(
                        l10n?.mistakesOnly ?? (isArabic ? 'الأخطاء فقط' : 'Mistakes Only'),
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                      ),
                      SizedBox(width: 8.w),
                      Switch(
                        value: _showMistakesOnly,
                        onChanged: (value) {
                          setState(() {
                            _showMistakesOnly = value;
                          });
                        },
                        activeThumbColor: AppColors.eagleGold,
                        activeTrackColor: AppColors.eagleGold.withValues(alpha: 0.5),
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.h),
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
            ],
          ),
          SizedBox(height: 16.h),

          ...questionDetails.asMap().entries.where((entry) {
            // Filter: إذا كان _showMistakesOnly = true، نعرض فقط الأخطاء
            if (_showMistakesOnly) {
              final detail = entry.value;
              final isCorrect = detail['isCorrect'] as bool? ?? false;
              return !isCorrect;
            }
            return true;
          }).map((entry) {
            final detail = entry.value;
            final questionId = detail['questionId'] as int?;
            final userAnswer = detail['userAnswer'] as String? ?? '';
            final correctAnswer = detail['correctAnswer'] as String? ?? '';
            final isCorrect = detail['isCorrect'] as bool? ?? false;
            
            final question = questionId != null ? questionsMap[questionId] : null;
            
            if (question == null) return const SizedBox.shrink();

            return Card(
              color: AppColors.darkSurface,
              margin: EdgeInsets.only(bottom: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(
                  color: isCorrect 
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.red.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Status Icon
                    Row(
                      children: [
                        // Status Icon
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: isCorrect 
                                ? AppColors.correctGreen.withValues(alpha: 0.2)
                                : AppColors.wrongRed.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            size: 24.sp,
                            color: isCorrect ? AppColors.correctGreen : AppColors.wrongRed,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: AutoSizeText(
                            question.getText(languageCode),
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    
                    // Answers Display
                    ...question.answers.map((answer) {
                      final isUserAnswer = answer.id == userAnswer && userAnswer.isNotEmpty;
                      final isCorrectAnswer = answer.id == correctAnswer;
                      
                      Color backgroundColor;
                      Color textColor;
                      Color borderColor;
                      IconData? icon;
                      
                      if (isCorrect) {
                        // إذا كانت الإجابة صحيحة: highlight الإجابة المختارة باللون الأخضر
                        if (isUserAnswer && isCorrectAnswer) {
                          backgroundColor = AppColors.correctGreen.withValues(alpha: 0.2);
                          textColor = AppColors.correctGreen;
                          borderColor = AppColors.correctGreen;
                          icon = Icons.check_circle;
                        } else {
                          backgroundColor = Colors.transparent;
                          textColor = Colors.white70;
                          borderColor = Colors.grey.withValues(alpha: 0.3);
                        }
                      } else {
                        // إذا كانت الإجابة خاطئة
                        if (isUserAnswer) {
                          // إجابة المستخدم (خطأ) - باللون الأحمر
                          backgroundColor = AppColors.wrongRed.withValues(alpha: 0.2);
                          textColor = AppColors.wrongRed;
                          borderColor = AppColors.wrongRed;
                          icon = Icons.close;
                        } else if (isCorrectAnswer) {
                          // الإجابة الصحيحة - باللون الأخضر
                          backgroundColor = AppColors.correctGreen.withValues(alpha: 0.2);
                          textColor = AppColors.correctGreen;
                          borderColor = AppColors.correctGreen;
                          icon = Icons.check_circle;
                        } else {
                          backgroundColor = Colors.transparent;
                          textColor = Colors.white70;
                          borderColor = Colors.grey.withValues(alpha: 0.3);
                        }
                      }
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: borderColor,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (icon != null) ...[
                              Icon(
                                icon,
                                size: 20.sp,
                                color: textColor,
                              ),
                              SizedBox(width: 8.w),
                            ],
                            Expanded(
                              child: AutoSizeText(
                                '${answer.id}. ${answer.getText(languageCode)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: isUserAnswer || isCorrectAnswer 
                                      ? FontWeight.w600 
                                      : FontWeight.normal,
                                  color: textColor,
                                ),
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    
                    // AI Explain Button (for wrong answers only)
                    if (!isCorrect) ...[
                      SizedBox(height: 12.h),
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
                            l10n?.explainWithAi ?? 'Explain with AI',
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
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _showAiExplanation(BuildContext context, Question question) async {
    final l10n = AppLocalizations.of(context);
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
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.darkSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.eagleGold, size: 28.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    l10n?.upgradeToPro ?? 'Upgrade to Pro',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: Text(
              l10n?.aiTutorDailyLimitReached ?? 'You have used AI Tutor 3 times today. Subscribe to Pro for unlimited usage.',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.white70,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n?.cancel ?? 'Cancel',
                  style: GoogleFonts.poppins(color: Colors.white54),
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
                  l10n?.upgrade ?? 'Upgrade',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
  bool _isRefreshing = false;

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
      _isRefreshing = true;
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
        _isRefreshing = false;
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
              
              AppLogger.error('AI explanation error in UI', source: 'ExamDetailScreen', error: error);
              
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
                    // Action Buttons (Refresh, Copy & Share)
                    Row(
                      children: [
                        // زر التحديث
                        OutlinedButton.icon(
                          onPressed: _isRefreshing ? null : _refreshExplanation,
                          icon: _isRefreshing
                              ? SizedBox(
                                  width: 18.sp,
                                  height: 18.sp,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.eagleGold,
                                  ),
                                )
                              : Icon(
                                  Icons.refresh,
                                  size: 18.sp,
                                  color: AppColors.eagleGold,
                                ),
                          label: Text(
                            widget.isArabic ? 'تحديث' : 'Refresh',
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
                            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                          ),
                        ),
                        SizedBox(width: 12.w),
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
