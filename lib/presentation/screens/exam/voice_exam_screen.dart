import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import '../../../domain/entities/question.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/debug/app_logger.dart';
import '../../providers/exam_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';
import '../../widgets/gamification/celebration_overlay.dart';
import 'exam_result_screen.dart';
import 'exam_mode.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/points_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../../core/services/ai_tutor_service.dart';
import '../../../core/storage/hive_service.dart';
import '../subscription/paywall_screen.dart';
import 'package:confetti/confetti.dart';

/// -----------------------------------------------------------------
/// 🎤 VOICE EXAM SCREEN / SPRACHPRÜFUNG / شاشة الامتحان الصوتي
/// -----------------------------------------------------------------
/// Premium feature: Full exam mode with voice narration
/// Reads questions and answers in German using Text-to-Speech
/// User selects answers by touch
/// -----------------------------------------------------------------
class VoiceExamScreen extends ConsumerStatefulWidget {
  const VoiceExamScreen({super.key});

  @override
  ConsumerState<VoiceExamScreen> createState() => _VoiceExamScreenState();
}

class _VoiceExamScreenState extends ConsumerState<VoiceExamScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  int _currentIndex = 0;
  final Map<int, String> _userAnswers = {}; // questionId -> selectedAnswerId
  List<Question>? _questions;
  bool _isPlaying = false;
  bool _isFinished = false;
  DateTime? _startTime;
  final PageController _pageController = PageController();
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  bool _showGerman = true; // عرض الألمانية افتراضياً

  @override
  void initState() {
    super.initState();
    _initTts();
    _startTime = DateTime.now();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("de-DE");
    await _flutterTts.setPitch(1.0);
    
    final prefs = await SharedPreferences.getInstance();
    final savedSpeed = prefs.getDouble('tts_speed') ?? 1.0;
    await _flutterTts.setSpeechRate(savedSpeed);

    // استماع لانتهاء الكلام
    _flutterTts.setCompletionHandler(() {
      _onSpeechComplete();
    });
  }

  void _onSpeechComplete() {
    // بعد انتهاء قراءة السؤال، نقرأ الخيارات
    if (_questions != null && _currentIndex < _questions!.length) {
      _readAnswers();
    }
  }

  Future<void> _readQuestion() async {
    if (_questions == null || _currentIndex >= _questions!.length) return;

    final question = _questions![_currentIndex];
    final prefs = await SharedPreferences.getInstance();
    final savedSpeed = prefs.getDouble('tts_speed') ?? 1.0;
    await _flutterTts.setSpeechRate(savedSpeed);

    setState(() {
      _isPlaying = true;
    });

    // قراءة السؤال
    await _flutterTts.speak('Frage ${_currentIndex + 1}: ${question.getText('de')}');
  }

  Future<void> _readAnswers() async {
    if (_questions == null || _currentIndex >= _questions!.length) return;

    final question = _questions![_currentIndex];
    final prefs = await SharedPreferences.getInstance();
    final savedSpeed = prefs.getDouble('tts_speed') ?? 1.0;
    await _flutterTts.setSpeechRate(savedSpeed);

    // قراءة الخيارات
    for (int i = 0; i < question.answers.length; i++) {
      final answer = question.answers[i];
      await _flutterTts.speak('Antwort ${i + 1}: ${answer.getText('de')}');
    }
  }

  void _selectAnswer(String answerId) {
    if (_isFinished) return;

    setState(() {
      if (_questions != null && _currentIndex < _questions!.length) {
        _userAnswers[_questions![_currentIndex].id] = answerId;
      }
    });
  }

  Future<void> _nextQuestion() async {
    if (_questions == null || _currentIndex >= _questions!.length - 1) {
      await _finishExam();
      return;
    }

    setState(() {
      _currentIndex++;
    });

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // قراءة السؤال التالي تلقائياً
    await Future.delayed(const Duration(milliseconds: 500));
    await _readQuestion();
  }

  Future<void> _finishExam() async {
    if (_questions == null || _isFinished) return;

    await _flutterTts.stop();
    
    setState(() {
      _isFinished = true;
    });

    // حساب النتيجة
    int correctCount = 0;
    for (var question in _questions!) {
      final userAnswer = _userAnswers[question.id];
      if (userAnswer == question.correctAnswerId) {
        correctCount++;
      }
    }

    final totalQuestions = _questions!.length;
    final scorePercentage = (correctCount / totalQuestions * 100).round();
    final isPassed = scorePercentage >= 50;

    // حساب المدة
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime!);

    // إضافة النقاط
    final points = (scorePercentage / 10).round() * correctCount;
    await ref.read(totalPointsProvider.notifier).addPoints(
      points: points,
      source: 'voice_exam',
      details: {'score': scorePercentage, 'correctCount': correctCount},
    );

    // عرض الاحتفال إذا نجح
    if (isPassed) {
      _confettiController.play();
    }

    // الانتقال إلى شاشة النتيجة
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ExamResultScreen(
            questions: _questions!,
            userAnswers: _userAnswers,
            totalTimeSeconds: duration.inSeconds,
            mode: ExamMode.full,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;

    final questionsAsync = ref.watch(examQuestionsProvider);

    return CelebrationOverlay(
      confettiController: _confettiController,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: AutoSizeText(
            l10n?.voiceExam ?? '🎤 Voice Exam',
            style: AppTypography.h2.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
          ),
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
          actions: [
            if (_questions != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Center(
                  child: AutoSizeText(
                    '${_currentIndex + 1}/${_questions!.length}',
                    style: AppTypography.bodyL.copyWith(
                      fontWeight: FontWeight.w600,
                      color: primaryGold,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
          ],
        ),
        body: questionsAsync.when(
          data: (questions) {
            if (questions.isEmpty) {
              return AdaptivePageWrapper(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: Colors.red,
                      ),
                      SizedBox(height: 16.h),
                      AutoSizeText(
                        l10n?.noQuestionsAvailable ?? 'No questions available',
                        style: AppTypography.bodyL.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            // حفظ الأسئلة عند أول تحميل
            if (_questions == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _questions = questions;
                });
                _readQuestion();
              });
            }

            if (_questions == null || _currentIndex >= _questions!.length) {
              return const Center(child: CircularProgressIndicator());
            }

            final question = _questions![_currentIndex];
            final userAnswer = _userAnswers[question.id];
            final userLanguage = currentLocale.languageCode;

            return SafeArea(
              child: Column(
                children: [
                  // Question Card
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _questions!.length,
                      itemBuilder: (context, index) {
                        if (index != _currentIndex) {
                          return const SizedBox.shrink();
                        }
                        return _buildQuestionCard(question, theme, userLanguage, l10n);
                      },
                    ),
                  ),

                  // Controls
                  Builder(
                    builder: (context) {
                      final theme = Theme.of(context);
                      final isDark = theme.brightness == Brightness.dark;
                      final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
                      final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
                      
                      return Container(
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Play Audio Button
                            FadeInUp(
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isPlaying ? null : _readQuestion,
                                  icon: Icon(
                                    _isPlaying ? Icons.volume_up : Icons.play_circle_outline,
                                    size: AppSpacing.iconLg,
                                  ),
                                  label: Text(
                                    _isPlaying
                                        ? (l10n?.playing ?? 'Playing...')
                                        : (l10n?.playAudio ?? '🔊 Play Audio'),
                                    style: AppTypography.button,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.gold,
                                    foregroundColor: isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
                                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Next Button
                            FadeInUp(
                              delay: const Duration(milliseconds: 100),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: userAnswer == null ? null : _nextQuestion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: userAnswer != null
                                        ? primaryGold
                                        : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightTextDisabled),
                                    foregroundColor: userAnswer != null
                                        ? (isDark ? AppColors.darkBg : AppColors.lightTextPrimary)
                                        : (isDark ? AppColors.darkTextDisabled : AppColors.lightTextTertiary),
                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                    ),
                                  ),
                                  child: Text(
                                    _currentIndex >= _questions!.length - 1
                                        ? (l10n?.finish ?? 'Finish')
                                        : (l10n?.next ?? 'Next'),
                                    style: AppTypography.button,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
          loading: () => Builder(
            builder: (context) {
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
              return Center(
                child: CircularProgressIndicator(
                  color: primaryGold,
                ),
              );
            },
          ),
          error: (error, stack) {
            AppLogger.error('Failed to load questions', source: 'VoiceExamScreen', error: error, stackTrace: stack);
            return AdaptivePageWrapper(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: AppColors.errorDark,
                    ),
                    SizedBox(height: 16.h),
                    AutoSizeText(
                      l10n?.errorLoadingQuestions ?? 'Error loading questions',
                      style: AppTypography.bodyL.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(examQuestionsProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
                      ),
                      child: AutoSizeText(
                        l10n?.retry ?? 'Retry',
                        style: AppTypography.button,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Question question, ThemeData theme, String userLanguage, AppLocalizations? l10n) {
    final userAnswer = _userAnswers[question.id];
    final subscriptionState = ref.watch(subscriptionProvider);
    final isPro = subscriptionState.isPro;
    final isRtl = userLanguage == 'ar';
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question Text with Translation Toggle
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Translation Toggle Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          _showGerman ? Icons.translate : Icons.language,
                          color: primaryGold,
                          size: AppSpacing.iconLg,
                        ),
                        onPressed: () {
                          setState(() {
                            _showGerman = !_showGerman;
                          });
                        },
                        tooltip: _showGerman 
                          ? (l10n?.showArabic ?? 'Show Translation')
                          : (l10n?.hideArabic ?? 'Show German'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Question Text
                  Directionality(
                    textDirection: _showGerman ? TextDirection.ltr : (isRtl ? TextDirection.rtl : TextDirection.ltr),
                    child: AutoSizeText(
                      _showGerman 
                        ? question.getText('de')
                        : question.getText(userLanguage),
                      style: AppTypography.h3.copyWith(
                        color: textPrimary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                      minFontSize: 14.sp,
                      stepGranularity: 1.sp,
                      maxLines: 4,
                    ),
                  ),
                  // AI Tutor Button (Pro only)
                  if (isPro) ...[
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton.icon(
                      onPressed: () => _showAiExplanation(question, userLanguage, l10n),
                      icon: const Icon(Icons.auto_awesome, size: AppSpacing.iconMd),
                      label: Text(
                        l10n?.explainWithAi ?? 'Explain Question',
                        style: AppTypography.bodyS.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark 
                            ? AppColors.successBgDark 
                            : AppColors.successBgLight,
                        foregroundColor: isDark ? AppColors.successDark : AppColors.successLight,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          side: BorderSide(
                            color: isDark ? AppColors.successDark : AppColors.successLight, 
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Answers - All visible without scrolling
          Expanded(
            child: Column(
              children: List.generate(
                question.answers.length,
                (index) {
                  final answer = question.answers[index];
                  final isSelected = userAnswer == answer.id;
                  final isCorrect = answer.id == question.correctAnswerId;

                  return Expanded(
                    child: FadeInUp(
                      delay: Duration(milliseconds: 100 * index),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: InkWell(
                          onTap: () => _selectAnswer(answer.id),
                          borderRadius: const BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isCorrect
                                      ? (isDark ? AppColors.successBgDark : AppColors.successBgLight)
                                      : (isDark ? AppColors.errorBgDark : AppColors.errorBgLight))
                                  : surfaceColor,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              border: Border.all(
                                color: isSelected
                                    ? (isCorrect 
                                        ? (isDark ? AppColors.successDark : AppColors.successLight)
                                        : (isDark ? AppColors.errorDark : AppColors.errorLight))
                                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Radio Button
                                Container(
                                  width: 20.w,
                                  height: 20.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? (isCorrect 
                                              ? (isDark ? AppColors.successDark : AppColors.successLight)
                                              : (isDark ? AppColors.errorDark : AppColors.errorLight))
                                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? (isCorrect 
                                            ? (isDark ? AppColors.successDark : AppColors.successLight)
                                            : (isDark ? AppColors.errorDark : AppColors.errorLight))
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          isCorrect ? Icons.check : Icons.close,
                                          size: 14.sp,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                // Answer Text
                                Expanded(
                                  child: Directionality(
                                    textDirection: _showGerman ? TextDirection.ltr : (isRtl ? TextDirection.rtl : TextDirection.ltr),
                                    child: AutoSizeText(
                                      _showGerman 
                                        ? answer.getText('de')
                                        : answer.getText(userLanguage),
                                      style: AppTypography.bodyM.copyWith(
                                        color: textPrimary,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                      minFontSize: 12.sp,
                                      stepGranularity: 1.sp,
                                      maxLines: 2,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// عرض شرح السؤال بالمساعد الذكي (Pro فقط)
  Future<void> _showAiExplanation(Question question, String userLanguage, AppLocalizations? l10n) async {

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
          final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
          final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
          
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
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      l10n?.upgradeToPro ?? 'Upgrade to Pro',
                      style: AppTypography.h3.copyWith(
                        color: textPrimary,
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
                  color: textSecondary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n?.cancel ?? 'Cancel',
                    style: AppTypography.bodyM.copyWith(
                      color: textSecondary,
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
                    backgroundColor: AppColors.gold,
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
        builder: (context) => _AiExplanationBottomSheet(
          question: question,
          userLanguage: userLanguage,
          l10n: l10n,
        ),
      );
    }
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
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    
      return Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: AppSpacing.bottomSheetRadius,
        ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: primaryGold, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    widget.l10n?.explainWithAi ?? 'Question Explanation',
                    style: AppTypography.h3.copyWith(
                      color: textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
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
                        SizedBox(height: 24.h),
                        Text(
                          widget.l10n?.aiThinking ?? 'AI is thinking...',
                          style: AppTypography.bodyM.copyWith(
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: AppColors.errorDark, size: 48.sp),
                        SizedBox(height: 16.h),
                        Text(
                          widget.l10n?.errorLoadingExplanation ?? 'Error loading explanation',
                          style: AppTypography.bodyL.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton.icon(
                          onPressed: _refreshExplanation,
                          icon: Icon(Icons.refresh, size: 20.sp),
                          label: Text(
                            widget.l10n?.retry ?? 'Retry',
                            style: AppTypography.button,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final explanation = snapshot.data ?? '';
                return SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: Text(
                    explanation,
                    style: AppTypography.bodyL.copyWith(
                      color: textPrimary,
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

