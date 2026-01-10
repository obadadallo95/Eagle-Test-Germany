import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
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
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isArabic ? 'تفاصيل الامتحان' : 'Exam Details',
          style: AppTypography.h2.copyWith(
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
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
              return _buildQuestionsList(context, questionsMap, questionDetails, isArabic, l10n, isDark, primaryGold, _showTranslation ? currentLocale.languageCode : 'de');
            },
            loading: () => Center(
              child: CircularProgressIndicator(color: primaryGold),
            ),
            error: (_, __) => _buildQuestionsList(context, questionsMap, questionDetails, isArabic, l10n, isDark, primaryGold, _showTranslation ? currentLocale.languageCode : 'de'),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: primaryGold,
          ),
        ),
        error: (e, s) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: AppColors.errorDark),
                const SizedBox(height: AppSpacing.lg),
                AutoSizeText(
                  "Error: $e",
                  style: AppTypography.bodyL.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
              ],
            ),
          );
        },
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
    bool isDark,
    Color primaryGold,
    String languageCode,
  ) {
    final theme = Theme.of(context);
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final dateStr = widget.examResult['date'] as String?;
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
    final formattedDate = date != null 
        ? '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'
        : 'Unknown';
    
    final isPassed = widget.examResult['isPassed'] as bool? ?? false;
    final mode = widget.examResult['mode'] as String? ?? 'full';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Exam Summary Card
          Card(
            color: isPassed 
                ? AppColors.successDark.withValues(alpha: 0.2) 
                : AppColors.errorDark.withValues(alpha: 0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
              side: BorderSide(
                color: isPassed ? AppColors.successDark : AppColors.errorDark,
                width: 2.w,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  Icon(
                    isPassed ? Icons.check_circle : Icons.cancel,
                    size: 64.sp,
                    color: isPassed ? AppColors.successDark : AppColors.errorDark,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AutoSizeText(
                    isPassed 
                        ? (isArabic ? 'نجحت!' : 'Passed!')
                        : (isArabic ? 'لم تنجح' : 'Failed'),
                    style: AppTypography.h2.copyWith(
                      color: isPassed ? AppColors.successDark : AppColors.errorDark,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AutoSizeText(
                    '${widget.examResult['scorePercentage'] ?? 0}%',
                    style: AppTypography.h1.copyWith(
                      fontSize: 48.sp,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        icon: Icons.check_circle,
                        label: isArabic ? 'صحيح' : 'Correct',
                        value: '${widget.examResult['correctCount'] ?? 0}',
                        color: AppColors.successDark,
                        isDark: isDark,
                      ),
                      _buildStatItem(
                        context,
                        icon: Icons.cancel,
                        label: isArabic ? 'خطأ' : 'Wrong',
                        value: '${widget.examResult['wrongCount'] ?? 0}',
                        color: AppColors.errorDark,
                        isDark: isDark,
                      ),
                      _buildStatItem(
                        context,
                        icon: Icons.timer,
                        label: isArabic ? 'الوقت' : 'Time',
                        value: _formatTime(widget.examResult['timeSeconds'] as int? ?? 0),
                        color: primaryGold,
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AutoSizeText(
                    formattedDate,
                    style: AppTypography.bodyM.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    maxLines: 1,
                  ),
                  AutoSizeText(
                    mode == 'full' 
                        ? (isArabic ? 'امتحان كامل' : 'Full Exam')
                        : (isArabic ? 'اختبار سريع' : 'Quick Practice'),
                    style: AppTypography.bodyS.copyWith(
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Filter Toggle and Translation Toggle
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoSizeText(
                    isArabic ? 'الأسئلة والإجابات' : 'Questions & Answers',
                    style: AppTypography.h3.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                  ),
                  Row(
                    children: [
                      AutoSizeText(
                        l10n?.mistakesOnly ?? (isArabic ? 'الأخطاء فقط' : 'Mistakes Only'),
                        style: AppTypography.bodyM.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Switch(
                        value: _showMistakesOnly,
                        onChanged: (value) {
                          setState(() {
                            _showMistakesOnly = value;
                          });
                        },
                        activeThumbColor: primaryGold,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.translate,
                    size: 18.sp,
                    color: _showTranslation ? primaryGold : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AutoSizeText(
                    isArabic ? 'عرض الترجمة' : 'Show Translation',
                    style: AppTypography.bodyM.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Switch(
                    value: _showTranslation,
                    onChanged: (value) {
                      setState(() {
                        _showTranslation = value;
                      });
                    },
                    activeThumbColor: primaryGold,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

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
              color: surfaceColor,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(
                  color: isCorrect 
                      ? AppColors.successDark.withValues(alpha: 0.3)
                      : AppColors.errorDark.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Status Icon
                    Row(
                      children: [
                        // Status Icon
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: isCorrect 
                                ? AppColors.successDark.withValues(alpha: 0.2)
                                : AppColors.errorDark.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            size: 24.sp,
                            color: isCorrect ? AppColors.successDark : AppColors.errorDark,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AutoSizeText(
                            question.getText(languageCode),
                            style: AppTypography.h4.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
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
                          backgroundColor = AppColors.successDark.withValues(alpha: 0.2);
                          textColor = AppColors.successDark;
                          borderColor = AppColors.successDark;
                          icon = Icons.check_circle;
                        } else {
                          backgroundColor = Colors.transparent;
                          textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
                          borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
                        }
                      } else {
                        // إذا كانت الإجابة خاطئة
                        if (isUserAnswer) {
                          // إجابة المستخدم (خطأ) - باللون الأحمر
                          backgroundColor = AppColors.errorDark.withValues(alpha: 0.2);
                          textColor = AppColors.errorDark;
                          borderColor = AppColors.errorDark;
                          icon = Icons.close;
                        } else if (isCorrectAnswer) {
                          // الإجابة الصحيحة - باللون الأخضر
                          backgroundColor = AppColors.successDark.withValues(alpha: 0.2);
                          textColor = AppColors.successDark;
                          borderColor = AppColors.successDark;
                          icon = Icons.check_circle;
                        } else {
                          backgroundColor = Colors.transparent;
                          textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
                          borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
                        }
                      }
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.md),
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
                              const SizedBox(width: AppSpacing.sm),
                            ],
                            Expanded(
                              child: AutoSizeText(
                                '${answer.id}. ${answer.getText(languageCode)}',
                                style: AppTypography.bodyM.copyWith(
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
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showAiExplanation(context, question, isDark, primaryGold),
                          icon: Icon(
                            Icons.auto_awesome,
                            size: 18.sp,
                            color: primaryGold,
                          ),
                          label: AutoSizeText(
                            l10n?.explainWithAi ?? 'Explain with AI',
                            style: AppTypography.bodyS.copyWith(
                              color: primaryGold,
                            ),
                            maxLines: 1,
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: primaryGold.withValues(alpha: 0.5),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                              horizontal: AppSpacing.md,
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

  Future<void> _showAiExplanation(BuildContext context, Question question, bool isDark, Color primaryGold) async {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.read(localeProvider);
    final userLanguage = currentLocale.languageCode;
    final isArabic = userLanguage == 'ar';
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

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
            backgroundColor: surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: Row(
              children: [
                Icon(Icons.auto_awesome, color: primaryGold, size: 28.sp),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l10n?.upgradeToPro ?? 'Upgrade to Pro',
                    style: AppTypography.h3.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: Text(
              l10n?.aiTutorDailyLimitReached ?? 'You have used AI Tutor 3 times today. Subscribe to Pro for unlimited usage.',
              style: AppTypography.bodyM.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n?.cancel ?? 'Cancel',
                  style: AppTypography.button.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                  backgroundColor: primaryGold,
                  foregroundColor: isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
                ),
                child: Text(
                  l10n?.upgrade ?? 'Upgrade',
                  style: AppTypography.button,
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
        isDark: isDark,
        primaryGold: primaryGold,
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
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 24.sp),
        const SizedBox(height: AppSpacing.xs),
        AutoSizeText(
          value,
          style: AppTypography.h2.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
        ),
        AutoSizeText(
          label,
          style: AppTypography.bodyS.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
  final bool isDark;
  final Color primaryGold;

  const _AiExplanationBottomSheet({
    required this.question,
    required this.userLanguage,
    required this.isArabic,
    required this.l10n,
    required this.isDark,
    required this.primaryGold,
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
    final surfaceColor = widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: surfaceColor,
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
                      style: AppTypography.bodyM.copyWith(
                        color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                    Icon(Icons.error_outline, color: AppColors.errorDark, size: 48.sp),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      widget.l10n?.errorLoadingExplanation ?? 'Error loading explanation',
                      style: AppTypography.h4.copyWith(
                        color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      errorMessage.length > 100 
                          ? '${errorMessage.substring(0, 100)}...' 
                          : errorMessage,
                      style: AppTypography.bodyS.copyWith(
                        color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    ElevatedButton.icon(
                      onPressed: _refreshExplanation,
                      icon: Icon(Icons.refresh, size: 18.sp),
                      label: Text(
                        widget.isArabic ? 'إعادة المحاولة' : 'Retry',
                        style: AppTypography.button,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.primaryGold,
                        foregroundColor: widget.isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }

            final explanation = snapshot.data ?? '';

            final surfaceColor = widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
            
            return Container(
              decoration: BoxDecoration(
                color: surfaceColor.withValues(alpha: 0.95),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
                border: Border.all(
                  color: widget.primaryGold.withValues(alpha: 0.3),
                  width: 2.w,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: widget.primaryGold,
                          size: 28.sp,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            widget.l10n?.aiExplanation ?? 'AI Explanation',
                            style: AppTypography.h3.copyWith(
                              color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close, 
                            color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    // Explanation with Markdown
                    Flexible(
                      child: SingleChildScrollView(
                        child: MarkdownBody(
                          data: explanation,
                          styleSheet: MarkdownStyleSheet(
                            p: AppTypography.bodyL.copyWith(
                              height: 1.6,
                              color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            strong: AppTypography.bodyL.copyWith(
                              fontWeight: FontWeight.bold,
                              color: widget.primaryGold,
                            ),
                            h1: AppTypography.h1.copyWith(
                              color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            h2: AppTypography.h2.copyWith(
                              color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            h3: AppTypography.h3.copyWith(
                              color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            listBullet: AppTypography.bodyL.copyWith(
                              color: widget.primaryGold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: widget.primaryGold,
                                  ),
                                )
                              : Icon(
                                  Icons.refresh,
                                  size: 18.sp,
                                  color: widget.primaryGold,
                                ),
                          label: Text(
                            widget.isArabic ? 'تحديث' : 'Refresh',
                            style: AppTypography.button.copyWith(
                              color: widget.primaryGold,
                            ),
                            maxLines: 1,
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: widget.primaryGold.withValues(alpha: 0.5),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: explanation));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    widget.isArabic ? 'تم النسخ!' : 'Copied!',
                                    style: AppTypography.button,
                                  ),
                                  backgroundColor: widget.primaryGold,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.copy,
                              size: 18.sp,
                              color: widget.primaryGold,
                            ),
                            label: Text(
                              widget.isArabic ? 'نسخ' : 'Copy',
                              style: AppTypography.button.copyWith(
                                color: widget.primaryGold,
                              ),
                              maxLines: 1,
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: widget.primaryGold.withValues(alpha: 0.5),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
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
                              color: widget.isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
                            ),
                            label: Text(
                              widget.isArabic ? 'مشاركة' : 'Share',
                              style: AppTypography.button,
                              maxLines: 1,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.primaryGold,
                              foregroundColor: widget.isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
              decoration: BoxDecoration(
                color: widget.primaryGold,
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
