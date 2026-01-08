import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import '../../../domain/entities/question.dart';
import '../../../core/theme/app_colors.dart';
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

    final questionsAsync = ref.watch(examQuestionsProvider);

    return CelebrationOverlay(
      confettiController: _confettiController,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: AutoSizeText(
            l10n?.voiceExam ?? '🎤 Voice Exam',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
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
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.eagleGold,
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
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          color: Colors.white70,
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
                  Container(
                    padding: EdgeInsets.all(24.w),
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
                                size: 28.sp,
                              ),
                              label: Text(
                                _isPlaying
                                    ? (l10n?.playing ?? 'Playing...')
                                    : (l10n?.playAudio ?? '🔊 Play Audio'),
                                style: GoogleFonts.poppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.eagleGold,
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
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
                                    ? AppColors.eagleGold
                                    : Colors.grey.shade700,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              child: Text(
                                _currentIndex >= _questions!.length - 1
                                    ? (l10n?.finish ?? 'Finish')
                                    : (l10n?.next ?? 'Next'),
                                style: GoogleFonts.poppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: AppColors.eagleGold,
            ),
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
                      color: Colors.red,
                    ),
                    SizedBox(height: 16.h),
                    AutoSizeText(
                      l10n?.errorLoadingQuestions ?? 'Error loading questions',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(examQuestionsProvider);
                      },
                      child: AutoSizeText(
                        l10n?.retry ?? 'Retry',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                        ),
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

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question Text with Translation Toggle
          FadeInDown(
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.eagleGold.withValues(alpha: 0.3),
                  width: 2.w,
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
                          color: AppColors.eagleGold,
                          size: 24.sp,
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
                  SizedBox(height: 8.h),
                  // Question Text
                  Directionality(
                    textDirection: _showGerman ? TextDirection.ltr : (isRtl ? TextDirection.rtl : TextDirection.ltr),
                    child: AutoSizeText(
                      _showGerman 
                        ? question.getText('de')
                        : question.getText(userLanguage),
                      style: GoogleFonts.poppins(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      minFontSize: 16.sp,
                      stepGranularity: 1.sp,
                      maxLines: 10,
                    ),
                  ),
                  // AI Tutor Button (Pro only)
                  if (isPro) ...[
                    SizedBox(height: 16.h),
                    ElevatedButton.icon(
                      onPressed: () => _showAiExplanation(question, userLanguage, l10n),
                      icon: Icon(Icons.auto_awesome, size: 20.sp),
                      label: Text(
                        l10n?.explainWithAi ?? 'Explain Question',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.eagleGold.withValues(alpha: 0.2),
                        foregroundColor: AppColors.eagleGold,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(color: AppColors.eagleGold, width: 1.w),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(height: 32.h),

          // Answers
          Expanded(
            child: ListView.builder(
              itemCount: question.answers.length,
              itemBuilder: (context, index) {
                final answer = question.answers[index];
                final isSelected = userAnswer == answer.id;
                final isCorrect = answer.id == question.correctAnswerId;

                return FadeInUp(
                  delay: Duration(milliseconds: 100 * index),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: InkWell(
                      onTap: () => _selectAnswer(answer.id),
                      borderRadius: BorderRadius.circular(16.r),
                      child: Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isCorrect
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.red.withValues(alpha: 0.2))
                              : AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected
                                ? (isCorrect ? Colors.green : Colors.red)
                                : AppColors.eagleGold.withValues(alpha: 0.3),
                            width: isSelected ? 2.w : 1.w,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Radio Button
                            Container(
                              width: 24.w,
                              height: 24.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? (isCorrect ? Colors.green : Colors.red)
                                      : AppColors.eagleGold,
                                  width: 2.w,
                                ),
                                color: isSelected
                                    ? (isCorrect ? Colors.green : Colors.red)
                                    : Colors.transparent,
                              ),
                              child: isSelected
                                  ? Icon(
                                      isCorrect ? Icons.check : Icons.close,
                                      size: 16.sp,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            SizedBox(width: 16.w),
                            // Answer Text
                            Expanded(
                              child: Directionality(
                                textDirection: _showGerman ? TextDirection.ltr : (isRtl ? TextDirection.rtl : TextDirection.ltr),
                                child: AutoSizeText(
                                  _showGerman 
                                    ? answer.getText('de')
                                    : answer.getText(userLanguage),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18.sp,
                                    color: Colors.white,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                  minFontSize: 14.sp,
                                  stepGranularity: 1.sp,
                                  maxLines: 3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.eagleGold, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    widget.l10n?.explainWithAi ?? 'Question Explanation',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.1)),
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
                        const CircularProgressIndicator(color: AppColors.eagleGold),
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
                        SizedBox(height: 24.h),
                        ElevatedButton.icon(
                          onPressed: _refreshExplanation,
                          icon: Icon(Icons.refresh, size: 20.sp),
                          label: Text(
                            widget.l10n?.retry ?? 'Retry',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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
                return SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: Text(
                    explanation,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: Colors.white,
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

