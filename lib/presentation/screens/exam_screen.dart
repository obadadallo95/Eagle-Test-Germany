import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import 'dart:async';
import '../../domain/entities/question.dart';
import '../providers/exam_provider.dart';
import '../providers/quick_practice_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/question_card.dart';
import '../widgets/time_tracker.dart';
import '../widgets/gamification/celebration_overlay.dart';
import '../widgets/gamification/animated_question_card.dart';
import '../widgets/core/adaptive_page_wrapper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/debug/app_logger.dart';
import '../../core/services/ai_tutor_service.dart';
import '../../core/storage/hive_service.dart';
import 'subscription/paywall_screen.dart';
import 'exam/exam_mode.dart';
import 'exam/exam_result_screen.dart';

/// -----------------------------------------------------------------
/// 📝 EXAM SCREEN / PRÜFUNGSBILDSCHIRM / شاشة الامتحان
/// -----------------------------------------------------------------
/// Supports multiple exam modes:
/// - Full Exam: 33 questions (30 general + 3 state-specific), 60 minutes
/// - Quick Practice: 15 random questions, 15 minutes
/// Features Text-to-Speech support, Arabic translation toggle, and answer tracking.
/// -----------------------------------------------------------------
/// **Deutsch:** Unterstützt mehrere Prüfungsmodi.
/// -----------------------------------------------------------------
/// **العربية:** يدعم أوضاع امتحان متعددة.
/// -----------------------------------------------------------------
class ExamScreen extends ConsumerStatefulWidget {
  final ExamMode mode;
  
  const ExamScreen({
    super.key,
    this.mode = ExamMode.full,
  });

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> {
  int _currentIndex = 0;
  String? _selectedAnswerId;
  bool _showArabic = false;
  final FlutterTts _flutterTts = FlutterTts();
  
  // Timer
  Timer? _timer;
  int _remainingSeconds = 0;
  final Map<int, String> _userAnswers = {}; // questionId -> selectedAnswerId
  DateTime? _startTime;
  List<Question>? _questions; // Store questions for timer finish
  
  // Gamification
  final PageController _pageController = PageController();
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();
    _initTts();
    final timerMinutes = widget.mode == ExamMode.quick ? 15 : 60;
    _remainingSeconds = timerMinutes * 60;
    _startTime = DateTime.now();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flutterTts.stop();
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer?.cancel();
            if (_questions != null) {
              _finishExam(_questions!);
            }
          }
        });
      }
    });
  }

  void _finishExam(List<Question> questions) {
    _timer?.cancel();
    final totalTimeSeconds = _startTime != null 
        ? DateTime.now().difference(_startTime!).inSeconds 
        : 0;
    
    // إطلاق Confetti عند إنهاء الامتحان
    _confettiController.play();
    
    // Navigate to results screen after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ExamResultScreen(
              questions: questions,
              userAnswers: _userAnswers,
              totalTimeSeconds: totalTimeSeconds,
              mode: widget.mode,
            ),
          ),
        );
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("de-DE");
    await _flutterTts.setPitch(1.0);
    
    // جلب سرعة TTS المحفوظة من الإعدادات
    final prefs = await SharedPreferences.getInstance();
    final savedSpeed = prefs.getDouble('tts_speed') ?? 1.0;
    await _flutterTts.setSpeechRate(savedSpeed);
  }

  Future<void> _playQuestion(String text) async {
    // تحديث سرعة الصوت قبل التحدث (في حالة تغييرها في الإعدادات)
    final prefs = await SharedPreferences.getInstance();
    final savedSpeed = prefs.getDouble('tts_speed') ?? 1.0;
    await _flutterTts.setSpeechRate(savedSpeed);
    await _flutterTts.speak(text);
  }

  /// عرض شرح السؤال بالمساعد الذكي (Pro فقط)
  Future<void> _showAiExplanation(Question question) async {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.read(localeProvider);
    final userLanguage = currentLocale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    // Check if user is Pro
    final subscriptionState = ref.read(subscriptionProvider);
    final isPro = subscriptionState.isPro;
    
    // التحقق من عدد الاستخدامات اليومية للمستخدمين المجانيين
    if (!isPro) {
      final canUse = HiveService.canUseAiTutor(isPro: false);
      
      if (!canUse) {
        // تم تجاوز الحد اليومي (3 مرات)
        if (mounted) {
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
                    foregroundColor: Colors.black,
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
        builder: (context) => _AiExplanationBottomSheet(
          question: question,
          userLanguage: userLanguage,
          l10n: l10n,
        ),
      );
    }
  }

  void _nextQuestion() {
    if (_questions == null || _currentIndex >= _questions!.length - 1) {
      if (_questions != null) {
        _finishExam(_questions!);
      }
      return;
    }

    setState(() {
      _currentIndex++;
      _selectedAnswerId = _userAnswers[_questions![_currentIndex].id];
      _showArabic = false; // Reset for next question
    });

    // Slide animation
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Select provider based on mode
    final questionsAsync = widget.mode == ExamMode.quick
        ? ref.watch(quickPracticeQuestionsProvider)
        : ref.watch(examQuestionsProvider);

    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final modeTitle = widget.mode == ExamMode.quick
        ? (l10n?.quickPractice ?? 'Quick Practice')
        : (l10n?.examMode ?? 'Exam Mode');
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        // التحقق من وجود تقدم في الامتحان
        // نتحقق من: وجود إجابات محفوظة، أو تقدم في الأسئلة، أو إجابة محددة حالياً
        final hasProgress = _userAnswers.isNotEmpty || _currentIndex > 0 || _selectedAnswerId != null;
        
        if (hasProgress) {
          // عرض حوار التأكيد
          final shouldQuit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: surfaceColor,
              title: Text(
                l10n?.quitExam ?? 'Quit Exam?',
                style: AppTypography.h3.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              content: Text(
                l10n?.quitExamMessage ?? 'Your progress will be lost.',
                style: AppTypography.bodyM.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    l10n?.stay ?? 'Stay',
                    style: AppTypography.button.copyWith(color: primaryGold),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.errorDark,
                  ),
                  child: Text(
                    l10n?.quit ?? 'Quit',
                    style: AppTypography.button.copyWith(
                      color: AppColors.errorDark,
                    ),
                  ),
                ),
              ],
            ),
          );
          
          if (shouldQuit == true && mounted && context.mounted) {
            Navigator.pop(context);
          }
        } else {
          // لا يوجد تقدم، الخروج مباشرة
          if (mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: CelebrationOverlay(
        confettiController: _confettiController,
        child: TimeTracker(
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
                title: Text(
                  modeTitle,
                  style: AppTypography.h2.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(
                  color: theme.colorScheme.onSurface,
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(4),
                  child: questionsAsync.when(
                    data: (q) => LinearProgressIndicator(
                      value: (q.isEmpty) ? 0 : (_currentIndex + 1) / q.length,
                      backgroundColor: AppColors.errorDark.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation(primaryGold),
                    ),
                    loading: () => const LinearProgressIndicator(value: 0),
                    error: (_, __) => const LinearProgressIndicator(value: 0),
                  ),
                ),
              ),
              body: AdaptivePageWrapper(
                padding: EdgeInsets.zero,
                enableScroll: false, // Column مع Expanded يملأ الشاشة
                child: questionsAsync.when(
                  data: (questions) {
                    // Store questions for timer finish
                    _questions = questions;
                    
                    if (questions.isEmpty) {
                      return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.quiz_outlined, 
                            size: 64.sp, 
                            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AutoSizeText(
                            l10n?.noQuestions ?? 'No questions loaded.',
                            style: AppTypography.bodyL.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Top Timer and Info
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [
                                    surfaceColor.withValues(alpha: 0.8),
                                    surfaceColor.withValues(alpha: 0.6),
                                  ]
                                : [
                                    surfaceColor,
                                    surfaceColor.withValues(alpha: 0.8),
                                  ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: AutoSizeText(
                                l10n?.questionLabel(_currentIndex + 1, questions.length) ?? 
                                'Question ${_currentIndex + 1}/${questions.length}',
                                style: AppTypography.h4.copyWith(
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md, 
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryGold.withValues(alpha: 0.3),
                                    primaryGold.withValues(alpha: 0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: primaryGold.withValues(alpha: 0.5),
                                  width: 1.5.w,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.timer, size: 16.sp, color: primaryGold),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    _formatTime(_remainingSeconds),
                                    style: AppTypography.bodyM.copyWith(
                                      color: _remainingSeconds < 300 
                                          ? AppColors.errorDark 
                                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                      fontWeight: _remainingSeconds < 300 ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Question Card with Slide Animation
                      Expanded(
                        child: AnimatedQuestionView(
                          itemCount: questions.length,
                          pageController: _pageController,
                          itemBuilder: (context, index) {
                            final question = questions[index];
                            return QuestionCard(
                              question: question,
                              selectedAnswerId: _userAnswers[question.id],
                              translationLangCode: _showArabic ? currentLocale.languageCode : null,
                              isAnswerChecked: false,
                              onAnswerSelected: (id) {
                                setState(() {
                                  _selectedAnswerId = id;
                                  _userAnswers[question.id] = id;
                                });
                              },
                              onToggleTranslation: () {
                                setState(() {
                                  _showArabic = !_showArabic;
                                });
                              },
                              onPlayAudio: () => _playQuestion(question.getText('de')),
                              onShowAiExplanation: () => _showAiExplanation(question),
                            );
                          },
                        ),
                      ),

                      // Next Button
                      Container(
                        margin: const EdgeInsets.all(AppSpacing.lg),
                        child: SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: _selectedAnswerId != null
                                  ? LinearGradient(
                                      colors: [
                                        primaryGold,
                                        primaryGold.withValues(alpha: 0.8),
                                      ],
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: _selectedAnswerId != null
                                  ? [
                                      BoxShadow(
                                        color: primaryGold.withValues(alpha: isDark ? 0.4 : 0.25),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 6),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: ElevatedButton(
                              onPressed: _selectedAnswerId == null 
                                ? null 
                                : _nextQuestion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedAnswerId == null 
                                    ? (isDark ? Colors.grey.shade700 : Colors.grey.shade300)
                                    : Colors.transparent,
                                foregroundColor: _selectedAnswerId == null 
                                    ? (isDark ? Colors.grey.shade400 : Colors.grey.shade600)
                                    : Colors.black,
                                padding: EdgeInsets.symmetric(vertical: 18.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                elevation: _selectedAnswerId != null ? 5 : 0,
                              ),
                              child: AutoSizeText(
                                _currentIndex < questions.length - 1
                                    ? (l10n?.nextQuestion ?? 'Next Question')
                                    : (l10n?.finishExam ?? 'Finish Exam'),
                                style: AppTypography.button.copyWith(
                                  fontSize: 18.sp,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: primaryGold,
                  ),
                ),
                    error: (e, s) {
                      AppLogger.error('Exam Error', source: 'ExamScreen', error: e, stackTrace: s);
                      return Center(
                        child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 64.sp, color: AppColors.errorDark),
                          const SizedBox(height: AppSpacing.lg),
                          AutoSizeText(
                            "${l10n?.errorLoadingExam ?? 'Error loading exam'}: $e",
                            style: AppTypography.bodyL.copyWith(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 5,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGold,
                              foregroundColor: Colors.black,
                            ),
                            child: Text(l10n?.goBack ?? 'Go Back'),
                          ),
                        ],
                      ),
                    ),
                  );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// StatefulWidget منفصل لحفظ الشرح ومنع إعادة الاستدعاء
class _AiExplanationBottomSheet extends StatefulWidget {
  final Question question;
  final String userLanguage;
  final AppLocalizations? l10n;

  const _AiExplanationBottomSheet({
    required this.question,
    required this.userLanguage,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    
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
                Icon(Icons.auto_awesome, color: primaryGold, size: 24.sp),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    widget.l10n?.explainWithAi ?? 'Question Explanation',
                    style: AppTypography.h3.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close, 
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.1) 
                : Colors.black.withValues(alpha: 0.1),
          ),
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
                        CircularProgressIndicator(color: primaryGold),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          widget.l10n?.aiThinking ?? 'AI is thinking...',
                          style: AppTypography.bodyM.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
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
                            backgroundColor: primaryGold,
                            foregroundColor: Colors.black,
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
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      height: 1.6,
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
