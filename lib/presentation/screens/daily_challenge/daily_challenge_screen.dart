import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../domain/entities/question.dart';
import '../../providers/daily_challenge_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/question_card.dart';
import '../../widgets/gamification/celebration_overlay.dart';
import '../../widgets/gamification/animated_question_card.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/storage/hive_service.dart';
import '../../../core/services/ai_tutor_service.dart';
import '../../providers/exam_readiness_provider.dart';
import '../../providers/points_provider.dart';
import '../subscription/paywall_screen.dart';
import 'daily_challenge_result_dialog.dart';

/// -----------------------------------------------------------------
/// 🎮 DAILY CHALLENGE SCREEN / TÄGLICHE HERAUSFORDERUNG / شاشة التحدي اليومي
/// -----------------------------------------------------------------
/// Gamified daily challenge with 10 random questions
/// نظام التحدي اليومي مع 10 أسئلة عشوائية
/// -----------------------------------------------------------------
class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  int _currentIndex = 0;
  String? _selectedAnswerId;
  String? _translationLangCode; // null = hide, 'ar' = show Arabic
  final FlutterTts _flutterTts = FlutterTts();
  final Map<int, String> _userAnswers = {}; // questionId -> selectedAnswerId
  DateTime? _startTime;
  List<Question>? _questions;
  bool _isFinished = false;
  final PageController _pageController = PageController();
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initTts();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _initTts() async {
    await _flutterTts.setLanguage('de-DE');
    await _flutterTts.setSpeechRate(0.5);
  }

  void _toggleTranslation() {
    setState(() {
      if (_translationLangCode == null) {
        final currentLocale = ref.read(localeProvider);
        _translationLangCode = currentLocale.languageCode; // استخدام اللغة المختارة مباشرة
      } else {
        _translationLangCode = null;
      }
    });
  }

  void _playAudio() {
    if (_questions != null && _currentIndex < _questions!.length) {
      final question = _questions![_currentIndex];
      _flutterTts.speak(question.getText('de'));
    }
  }

  /// عرض شرح السؤال بالمساعد الذكي (Pro فقط)
  Future<void> _showAiExplanation(Question question) async {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.read(localeProvider);
    final userLanguage = currentLocale.languageCode;

    // Check if user is Pro
    final subscriptionState = ref.read(subscriptionProvider);
    final isPro = subscriptionState.isPro;
    
    // التحقق من عدد الاستخدامات اليومية للمستخدمين المجانيين
    if (!isPro) {
      final canUse = HiveService.canUseAiTutor(isPro: false);
      
      if (!canUse) {
        // تم تجاوز الحد اليومي (3 مرات)
        if (mounted) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
          final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
          
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
        }
        return;
      }
      
      // تسجيل الاستخدام
      await HiveService.recordAiTutorUsage();
    }

    // Show loading bottom sheet
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
          return _AiExplanationBottomSheet(
            question: question,
            userLanguage: userLanguage,
            l10n: l10n,
            isDark: isDark,
            primaryGold: primaryGold,
          );
        },
      );
    }
  }

  void _selectAnswer(String answerId) {
    if (_isFinished) return;
    
    setState(() {
      _selectedAnswerId = answerId;
      if (_questions != null && _currentIndex < _questions!.length) {
        _userAnswers[_questions![_currentIndex].id] = answerId;
      }
    });
  }

  void _nextQuestion() {
    if (_questions == null || _currentIndex >= _questions!.length - 1) {
      _finishChallenge();
      return;
    }

    setState(() {
      _currentIndex++;
      _selectedAnswerId = _userAnswers[_questions![_currentIndex].id];
    });

    // Slide animation
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _selectedAnswerId = _userAnswers[_questions![_currentIndex].id];
      });

      // Slide animation
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _finishChallenge() async {
    if (_questions == null || _isFinished) return;
    
    setState(() {
      _isFinished = true;
    });

    // حساب النتيجة وحفظ الإجابات الصحيحة
    int correctCount = 0;
    int totalPoints = 0;

    for (final question in _questions!) {
      final userAnswer = _userAnswers[question.id];
      final isCorrect = userAnswer == question.correctAnswerId;
      
      if (isCorrect) {
        correctCount++;
        totalPoints += 10; // 10 نقاط لكل إجابة صحيحة
        
        // حفظ الإجابة الصحيحة في نظام التقدم
        // هذا يجعل السؤال يُحسب في totalLearned
        await HiveService.saveQuestionAnswer(
          question.id,
          userAnswer!,
          true, // isCorrect
        );
      } else if (userAnswer != null) {
        // حفظ الإجابة الخاطئة أيضاً لتتبع الأخطاء
        await HiveService.saveQuestionAnswer(
          question.id,
          userAnswer,
          false, // isCorrect
        );
      }
    }

    final timeSeconds = _startTime != null
        ? DateTime.now().difference(_startTime!).inSeconds
        : 0;

    // حفظ النتيجة
    ref.read(dailyChallengeResultProvider.notifier).saveResult(
      score: totalPoints,
      correctAnswers: correctCount,
      totalQuestions: _questions!.length,
      timeSeconds: timeSeconds,
    );

    // إضافة النقاط للتحدي اليومي (10 نقاط لكل إجابة صحيحة)
    if (totalPoints > 0) {
      await ref.read(totalPointsProvider.notifier).addPoints(
        points: totalPoints,
        source: 'daily_challenge',
        details: {
          'correctAnswers': correctCount,
          'totalQuestions': _questions!.length,
          'timeSeconds': timeSeconds,
        },
      );
    }

    // تحديث Exam Readiness Provider بعد حفظ الإجابات
    // هذا يضمن أن جاهزية الامتحان تُحسب بناءً على الإجابات الجديدة
    ref.invalidate(examReadinessProvider);

    // إطلاق Confetti
    _confettiController.play();

    // عرض Dialog النتيجة بعد تأخير قصير
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showResultDialog(
          score: totalPoints,
          correctCount: correctCount,
          totalQuestions: _questions!.length,
          timeSeconds: timeSeconds,
        );
      }
    });
  }

  void _showResultDialog({
    required int score,
    required int correctCount,
    required int totalQuestions,
    required int timeSeconds,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DailyChallengeResultDialog(
        score: score,
        correctCount: correctCount,
        totalQuestions: totalQuestions,
        timeSeconds: timeSeconds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar';
    final questionsAsync = ref.watch(dailyChallengeProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    
    return CelebrationOverlay(
      confettiController: _confettiController,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    bgColor,
                    bgColor.withValues(alpha: 0.95),
                    surfaceColor.withValues(alpha: 0.9),
                    surfaceColor,
                  ]
                : [
                    bgColor,
                    bgColor,
                    surfaceColor.withValues(alpha: 0.5),
                    surfaceColor,
                  ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.close, 
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              onPressed: () {
                if (_isFinished) {
                  Navigator.pop(context);
                } else {
                  _showExitConfirmation(isDark);
                }
              },
            ),
            title: Builder(
              builder: (context) {
                if (_questions == null || _questions!.isEmpty) {
                  return Text(
                    '🔥 ${l10n?.dailyChallenge ?? 'Daily Challenge'}',
                    style: AppTypography.h2.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  );
                }
                return _buildAppBarHeader(
                  currentIndex: _currentIndex,
                  totalQuestions: _questions!.length,
                  score: _calculateCurrentScore(),
                  isArabic: isArabic,
                );
              },
            ),
            centerTitle: true,
          ),
          body: AdaptivePageWrapper(
            padding: EdgeInsets.zero,
            enableScroll: false, // Column مع Expanded يملأ الشاشة
            child: questionsAsync.when(
              data: (questions) {
                if (questions.isEmpty) {
                  return Center(
                  child: Text(
                    l10n?.noQuestionsAvailable ?? 'No questions available',
                    style: AppTypography.bodyL.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                );
              }

              // حفظ الأسئلة في state
              if (_questions == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _questions = questions;
                    _selectedAnswerId = _userAnswers[questions[0].id];
                  });
                });
              }

              if (_questions == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final currentQuestion = _questions![_currentIndex];
              final isCorrect = _selectedAnswerId != null &&
                  _selectedAnswerId == currentQuestion.correctAnswerId;
              final hasAnswered = _selectedAnswerId != null;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Question Card with Slide Animation
                  Expanded(
                    child: AnimatedQuestionView(
                      itemCount: _questions!.length,
                      pageController: _pageController,
                      itemBuilder: (context, index) {
                        final question = _questions![index];
                        return QuestionCard(
                          question: question,
                          selectedAnswerId: _userAnswers[question.id],
                          translationLangCode: _translationLangCode,
                          isAnswerChecked: false,
                          onAnswerSelected: _selectAnswer,
                          onToggleTranslation: _toggleTranslation,
                          onPlayAudio: _playAudio,
                          onShowAiExplanation: () => _showAiExplanation(question),
                        );
                      },
                    ),
                  ),

                  // Navigation Buttons
                  _buildNavigationButtons(
                    hasAnswered: hasAnswered,
                    isCorrect: isCorrect,
                    isLastQuestion: _currentIndex == _questions!.length - 1,
                    isArabic: isArabic,
                    l10n: l10n,
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(color: isDark ? AppColors.gold : AppColors.goldDark),
            ),
            error: (error, stack) {
              final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: AppColors.errorDark, size: 64.sp),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n?.errorLoadingQuestions ?? 'Error loading questions',
                      style: AppTypography.bodyL.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(dailyChallengeProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGold,
                      ),
                      child: Text(
                        l10n?.retry ?? 'Retry',
                        style: AppTypography.button,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildAppBarHeader({
    required int currentIndex,
    required int totalQuestions,
    required int score,
    required bool isArabic,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final progress = (currentIndex + 1) / totalQuestions;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress indicator
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: primaryGold,
              width: 3.w,
            ),
          ),
          child: Stack(
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3.w,
                  backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryGold),
                ),
              ),
              Center(
                child: Text(
                  '${currentIndex + 1}/$totalQuestions',
                  style: AppTypography.bodyS.copyWith(
                    color: primaryGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        // Score
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.stars, color: primaryGold, size: 20.sp),
            SizedBox(width: 4.w),
            Text(
              '$score',
              style: AppTypography.h4.copyWith(
                color: primaryGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationButtons({
    required bool hasAnswered,
    required bool isCorrect,
    required bool isLastQuestion,
    required bool isArabic,
    AppLocalizations? l10n,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  surfaceColor.withValues(alpha: 0.95),
                  surfaceColor,
                ]
              : [
                  surfaceColor,
                  surfaceColor.withValues(alpha: 0.9),
                ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? AppColors.darkBg.withValues(alpha: 0.4)
                : AppColors.lightBg.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Button
          if (_currentIndex > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousQuestion,
                icon: Icon(
                  isArabic ? Icons.arrow_forward : Icons.arrow_back,
                  size: 20.sp,
                ),
                label: Text(
                  l10n?.previous ?? 'Previous',
                  style: AppTypography.button.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  side: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.5.w,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
          if (_currentIndex > 0) SizedBox(width: 12.w),
          
          // Next/Finish Button
          Expanded(
            flex: _currentIndex > 0 ? 1 : 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: hasAnswered
                    ? (isCorrect
                        ? LinearGradient(
                            colors: [AppColors.successDark, AppColors.successDark.withValues(alpha: 0.8)],
                          )
                        : LinearGradient(
                            colors: [primaryGold, primaryGold.withValues(alpha: 0.8)],
                          ))
                    : null,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: hasAnswered
                    ? [
                        BoxShadow(
                          color: (isCorrect ? AppColors.successDark : primaryGold).withValues(alpha: isDark ? 0.4 : 0.25),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: ElevatedButton.icon(
                onPressed: hasAnswered
                    ? (isLastQuestion ? _finishChallenge : _nextQuestion)
                    : null,
                icon: Icon(
                  isLastQuestion ? Icons.check_circle : (isArabic ? Icons.arrow_back : Icons.arrow_forward),
                  size: 22.sp,
                ),
                label: Text(
                  isLastQuestion
                      ? (l10n?.finish ?? 'Finish')
                      : (l10n?.next ?? 'Next'),
                  style: AppTypography.button,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasAnswered
                      ? Colors.transparent
                      : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                  foregroundColor: hasAnswered 
                      ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: hasAnswered ? 5 : 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateCurrentScore() {
    int score = 0;
    if (_questions != null) {
      for (final question in _questions!) {
        final userAnswer = _userAnswers[question.id];
        if (userAnswer == question.correctAnswerId) {
          score += 10;
        }
      }
    }
    return score;
  }

  void _showExitConfirmation(bool isDark) {
    final l10n = AppLocalizations.of(context);
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          l10n?.exitChallenge ?? 'Exit Challenge?',
          style: AppTypography.h3.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        content: Text(
          l10n?.exitChallengeMessage ??
              'Are you sure you want to exit? Your progress will be lost.',
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
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit challenge
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.errorDark : AppColors.errorLight,
              foregroundColor: Colors.white, // Error buttons always use white text
            ),
            child: Text(
              l10n?.exit ?? 'Exit',
              style: AppTypography.button,
            ),
          ),
        ],
      ),
    );
  }
}

/// StatefulWidget منفصل لحفظ الشرح ومنع إعادة الاستدعاء
class _AiExplanationBottomSheet extends StatefulWidget {
  final Question question;
  final String userLanguage;
  final AppLocalizations? l10n;
  final bool isDark;
  final Color primaryGold;

  const _AiExplanationBottomSheet({
    required this.question,
    required this.userLanguage,
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
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: widget.primaryGold, size: 24.sp),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    widget.l10n?.explainWithAi ?? 'Question Explanation',
                    style: AppTypography.h3.copyWith(
                      color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close, 
                    color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(color: widget.isDark ? AppColors.darkDivider : AppColors.lightDivider),
          // Content
          Expanded(
            child: FutureBuilder<String>(
              future: _explanationFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: widget.primaryGold),
                        const SizedBox(height: AppSpacing.xxl),
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
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
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
                        const SizedBox(height: AppSpacing.xxl),
                        ElevatedButton.icon(
                          onPressed: _refreshExplanation,
                          icon: Icon(Icons.refresh, size: 20.sp),
                          label: Text(
                            widget.l10n?.retry ?? 'Retry',
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
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Text(
                    explanation,
                    style: AppTypography.bodyL.copyWith(
                      height: 1.6,
                      color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
