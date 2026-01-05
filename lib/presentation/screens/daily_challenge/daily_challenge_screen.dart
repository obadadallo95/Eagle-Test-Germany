import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../domain/entities/question.dart';
import '../../providers/daily_challenge_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/question_card.dart';
import '../../widgets/gamification/celebration_overlay.dart';
import '../../widgets/gamification/animated_question_card.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/storage/hive_service.dart';
import '../../providers/exam_readiness_provider.dart';
import '../../providers/points_provider.dart';
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
        _translationLangCode = currentLocale.languageCode == 'ar' ? 'ar' : 'en';
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

    return CelebrationOverlay(
      confettiController: _confettiController,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkCharcoal,
              AppColors.darkCharcoal.withValues(alpha: 0.95),
              AppColors.darkSurface.withValues(alpha: 0.9),
              AppColors.darkSurface,
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
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                if (_isFinished) {
                  Navigator.pop(context);
                } else {
                  _showExitConfirmation();
                }
              },
            ),
            title: Text(
              '🔥 ${l10n?.dailyChallenge ?? 'Daily Challenge'}',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
                    style: GoogleFonts.poppins(color: Colors.white70),
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
                  // Progress Bar & Score
                  _buildHeader(
                    currentIndex: _currentIndex,
                    totalQuestions: _questions!.length,
                    score: _calculateCurrentScore(),
                    isArabic: isArabic,
                  ),

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

                  SizedBox(height: 16.h),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.eagleGold),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 64.sp),
                  SizedBox(height: 16.h),
                  Text(
                    l10n?.errorLoadingQuestions ?? 'Error loading questions',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(dailyChallengeProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.eagleGold,
                    ),
                    child: Text(
                      l10n?.retry ?? 'Retry',
                      style: GoogleFonts.poppins(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required int currentIndex,
    required int totalQuestions,
    required int score,
    required bool isArabic,
  }) {
    final progress = (currentIndex + 1) / totalQuestions;

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkSurface,
            AppColors.darkSurface.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.eagleGold.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress Bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10.h,
                    backgroundColor: Colors.grey[800],
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.eagleGold),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.eagleGold.withValues(alpha: 0.3),
                      AppColors.eagleGold.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.eagleGold,
                    width: 2.w,
                  ),
                ),
                child: Text(
                  '${currentIndex + 1}/$totalQuestions',
                  style: GoogleFonts.poppins(
                    color: AppColors.eagleGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Score Display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.eagleGold.withValues(alpha: 0.3),
                      AppColors.eagleGold.withValues(alpha: 0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.stars, color: AppColors.eagleGold, size: 28.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                '$score',
                style: GoogleFonts.poppins(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.eagleGold,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                'points',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons({
    required bool hasAnswered,
    required bool isCorrect,
    required bool isLastQuestion,
    required bool isArabic,
    AppLocalizations? l10n,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.darkSurface.withValues(alpha: 0.95),
            AppColors.darkSurface,
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
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
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(
                    color: Colors.white30,
                    width: 1.5.w,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
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
                            colors: [Colors.green.shade400, Colors.green.shade600],
                          )
                        : LinearGradient(
                            colors: [AppColors.eagleGold, AppColors.eagleGold.withValues(alpha: 0.8)],
                          ))
                    : null,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: hasAnswered
                    ? [
                        BoxShadow(
                          color: (isCorrect ? Colors.green : AppColors.eagleGold).withValues(alpha: 0.4),
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
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasAnswered
                      ? Colors.transparent
                      : Colors.grey[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
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

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          AppLocalizations.of(context)?.exitChallenge ?? 'Exit Challenge?',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)?.exitChallengeMessage ??
              'Are you sure you want to exit? Your progress will be lost.',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)?.cancel ?? 'Cancel',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit challenge
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              AppLocalizations.of(context)?.exit ?? 'Exit',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }
}
