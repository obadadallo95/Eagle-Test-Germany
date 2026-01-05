import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/ai_tutor_service.dart';
import '../../../core/storage/user_preferences_service.dart';
import '../../providers/review_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/points_provider.dart';
import '../../widgets/question_card.dart';
import '../../../core/storage/srs_service.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';
import '../../../core/storage/hive_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/question.dart';
import '../main_screen.dart';
import '../subscription/paywall_screen.dart';

/// -----------------------------------------------------------------
/// 🔄 REVIEW SCREEN / WIEDERHOLUNGSBILDSCHIRM / شاشة المراجعة
/// -----------------------------------------------------------------
/// Displays questions due for review based on SRS algorithm.
/// Shows immediate feedback and updates SRS data after each answer.
/// -----------------------------------------------------------------
/// **Deutsch:** Zeigt Fragen an, die zur Wiederholung fällig sind.
/// -----------------------------------------------------------------
/// **العربية:** يعرض الأسئلة المستحقة للمراجعة بناءً على خوارزمية SRS.
/// -----------------------------------------------------------------
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  int _currentIndex = 0;
  String? _selectedAnswerId;
  bool _showArabic = false;
  bool _isAnswerChecked = false;
  final FlutterTts _flutterTts = FlutterTts();
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _initTts();
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

  @override
  void dispose() {
    _flutterTts.stop();
    _pageController.dispose();
    super.dispose();
  }

  void _handleAnswer(String answerId, Question question) async {
    if (_isAnswerChecked) return; // Already checked

    setState(() {
      _selectedAnswerId = answerId;
      _isAnswerChecked = true;
    });

    final isCorrect = answerId == question.correctAnswerId;
    
    // Save answer
    await HiveService.saveQuestionAnswer(question.id, answerId, isCorrect);
    
    // إضافة النقاط للمراجعة (5 نقاط لكل إجابة صحيحة)
    if (isCorrect) {
      await ref.read(totalPointsProvider.notifier).addPoints(
        points: 5,
        source: 'review',
        details: {
          'questionId': question.id,
        },
      );
    }
    
    // Update SRS with quality rating
    // quality: 0=Again, 1=Hard, 2=Good, 3=Easy
    await SrsService.updateSrsAfterAnswer(question.id, isCorrect);
    
    // جدولة إشعارات SRS إذا لزم الأمر
    final isReminderEnabled = await UserPreferencesService.getReminderEnabled();
    if (isReminderEnabled) {
      await NotificationService.scheduleSrsReminder();
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _getQuestions().length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // All questions reviewed
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Great job! All questions reviewed. 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  List<Question> _getQuestions() {
    final asyncValue = ref.watch(reviewQuestionsProvider);
    return asyncValue.when(
      data: (questions) => questions,
      loading: () => [],
      error: (_, __) => [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final questionsAsync = ref.watch(reviewQuestionsProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        // التحقق من وجود تقدم في المراجعة
        final hasProgress = _currentIndex > 0 || _selectedAnswerId != null || _isAnswerChecked;
        
        if (hasProgress) {
          // عرض حوار التأكيد
          final shouldQuit = await showDialog<bool>(
            context: context,
            builder: (context) {
              final theme = Theme.of(context);
              return AlertDialog(
                backgroundColor: theme.cardTheme.color,
                title: Text(
                  l10n?.quitExam ?? 'Quit Review?',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                content: Text(
                  l10n?.quitExamMessage ?? 'Your progress will be lost.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 14.sp,
                  ),
                ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    l10n?.stay ?? 'Stay',
                    style: const TextStyle(color: AppColors.eagleGold),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.germanRed,
                  ),
                  child: Text(
                    l10n?.quit ?? 'Quit',
                    style: TextStyle(
                      color: AppColors.germanRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            );
            },
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
      child: Scaffold(
        appBar: AppBar(
        title: Text(l10n?.reviewMistakes ?? 'Review Due'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: questionsAsync.when(
            data: (questions) => LinearProgressIndicator(
              value: questions.isEmpty ? 0 : (_currentIndex + 1) / questions.length,
              backgroundColor: AppColors.primaryRed.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryGold),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
      ),
      body: AdaptivePageWrapper(
        padding: EdgeInsets.zero,
        enableScroll: false, // PageView يملأ الشاشة
        child: questionsAsync.when(
          data: (questions) {
            if (questions.isEmpty) {
              return _buildEmptyState(context);
            }

            return PageView.builder(
            controller: _pageController,
            itemCount: questions.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _selectedAnswerId = null;
                _showArabic = false;
                _isAnswerChecked = false;
              });
            },
            itemBuilder: (context, index) {
              final question = questions[index];
              return _buildQuestionView(context, question, l10n);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
              SizedBox(height: 16.h),
              Text('Error: $error'),
            ],
          ),
        ),
        ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 120.sp,
              color: Colors.green[300],
            ),
            SizedBox(height: 24.h),
            Text(
              'All Caught Up! 🎉',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You have no questions due for review.\nKeep up the great work!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // العودة مباشرة للصفحة الرئيسية
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionView(BuildContext context, Question question, AppLocalizations? l10n) {
    final currentLocale = ref.watch(localeProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Question Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.questionLabel(_currentIndex + 1, _getQuestions().length) ?? 
                'Question ${_currentIndex + 1}/${_getQuestions().length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Chip(
                avatar: const Icon(Icons.refresh, size: 16),
                label: const Text('Review Mode'),
                backgroundColor: Colors.orange[100],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Question Card
          QuestionCard(
            question: question,
            selectedAnswerId: _selectedAnswerId,
            translationLangCode: _showArabic ? currentLocale.languageCode : null,
            isAnswerChecked: _isAnswerChecked,
            onAnswerSelected: (id) => _handleAnswer(id, question),
            onToggleTranslation: () {
              setState(() {
                _showArabic = !_showArabic;
              });
            },
            onPlayAudio: () => _playQuestion(question.getText('de')),
            onShowAiExplanation: () => _showAiExplanation(context, question),
          ),

          const SizedBox(height: 32),

          // Next Button (only show after answer is checked)
          if (_isAnswerChecked)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _nextQuestion,
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  _currentIndex < _getQuestions().length - 1
                      ? l10n?.nextQuestion ?? 'Next Question'
                      : l10n?.finishExam ?? 'Finish Review',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
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
                      l10n?.upgradeToPro ?? 'Upgrade to Pro',
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
                l10n?.aiTutorDailyLimitReached ?? 'You have used AI Tutor 3 times today. Subscribe to Pro for unlimited usage.',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n?.cancel ?? 'Cancel',
                    style: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
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
    final theme = Theme.of(context);
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.eagleGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: AppColors.eagleGold,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        widget.isArabic
                            ? 'شرح من Eagle AI Tutor'
                            : 'Explanation from Eagle AI Tutor',
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                      ),
                      SizedBox(height: 4.h),
                      AutoSizeText(
                        widget.isArabic
                            ? 'شرح مفصل للسؤال والإجابة الصحيحة'
                            : 'Detailed explanation of the question and correct answer',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          Divider(height: 1.h),
          
          // Content
          Flexible(
            child: FutureBuilder<String>(
              future: _explanationFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: EdgeInsets.all(40.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: AppColors.eagleGold),
                        SizedBox(height: 16.h),
                        AutoSizeText(
                          widget.isArabic ? 'جاري تحميل الشرح...' : 'Loading explanation...',
                          style: GoogleFonts.poppins(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                if (snapshot.hasError) {
                  return Padding(
                    padding: EdgeInsets.all(40.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
                        SizedBox(height: 16.h),
                        AutoSizeText(
                          widget.isArabic
                              ? 'حدث خطأ أثناء تحميل الشرح'
                              : 'Error loading explanation',
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                
                final explanation = snapshot.data ?? '';
                
                return SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Explanation text (Markdown support can be added here)
                      AutoSizeText(
                        explanation,
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: theme.colorScheme.onSurface,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Actions
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isRefreshing ? null : _refreshExplanation,
                    icon: _isRefreshing
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.eagleGold,
                            ),
                          )
                        : Icon(Icons.refresh, size: 20.sp),
                    label: Text(
                      widget.isArabic ? 'تحديث' : 'Refresh',
                      style: GoogleFonts.poppins(),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.eagleGold),
                      foregroundColor: AppColors.eagleGold,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.eagleGold,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(
                      widget.isArabic ? 'إغلاق' : 'Close',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

