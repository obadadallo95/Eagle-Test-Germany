import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
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
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Great job! All questions reviewed. 🎉'),
          backgroundColor: isDark ? AppColors.successDark : AppColors.successLight,
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
              final isDark = theme.brightness == Brightness.dark;
              final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
              final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
              
              return AlertDialog(
                backgroundColor: surfaceColor,
                title: Text(
                  l10n?.quitExam ?? 'Quit Review?',
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
                    style: AppTypography.button.copyWith(
                      color: primaryGold,
                    ),
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
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
          
          return Scaffold(
            appBar: AppBar(
              title: Text(
                l10n?.reviewMistakes ?? 'Review Due',
                style: AppTypography.h2.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: questionsAsync.when(
                  data: (questions) => LinearProgressIndicator(
                    value: questions.isEmpty ? 0 : (_currentIndex + 1) / questions.length,
                    backgroundColor: AppColors.errorDark.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation(primaryGold),
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
        loading: () => Center(
          child: CircularProgressIndicator(
            color: isDark ? AppColors.gold : AppColors.goldDark,
          ),
        ),
        error: (error, stack) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: AppColors.errorDark),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Error: $error',
                  style: AppTypography.bodyL.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          );
        },
        ),
        ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 120.sp,
              color: AppColors.successDark,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'All Caught Up! 🎉',
              style: AppTypography.h1.copyWith(
                color: AppColors.successDark,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'You have no questions due for review.\nKeep up the great work!',
              textAlign: TextAlign.center,
              style: AppTypography.bodyL.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
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
              label: Text(
                'Back to Home',
                style: AppTypography.button,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionView(BuildContext context, Question question, AppLocalizations? l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentLocale = ref.watch(localeProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Question Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.questionLabel(_currentIndex + 1, _getQuestions().length) ?? 
                'Question ${_currentIndex + 1}/${_getQuestions().length}',
                style: AppTypography.h4.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Chip(
                avatar: const Icon(Icons.refresh, size: 16),
                label: Text(
                  'Review Mode',
                  style: AppTypography.bodyS,
                ),
                backgroundColor: AppColors.warningDark.withValues(alpha: isDark ? 0.2 : 0.1),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

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

          const SizedBox(height: AppSpacing.xxxl),

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
                  style: AppTypography.button,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.gold : AppColors.goldDark,
                  foregroundColor: isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
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
            final isDark = theme.brightness == Brightness.dark;
            final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
            final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
            
            return AlertDialog(
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
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
        return _AiExplanationBottomSheet(
          question: question,
          userLanguage: userLanguage,
          isArabic: isArabic,
          l10n: l10n,
          isDark: isDark,
          primaryGold: primaryGold,
        );
      },
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
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
            margin: const EdgeInsets.only(top: AppSpacing.md),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: widget.primaryGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: widget.primaryGold,
                    size: 24.sp,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        widget.isArabic
                            ? 'شرح من Eagle AI Tutor'
                            : 'Explanation from Eagle AI Tutor',
                        style: AppTypography.h3.copyWith(
                          fontSize: 18.sp,
                          color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AutoSizeText(
                        widget.isArabic
                            ? 'شرح مفصل للسؤال والإجابة الصحيحة'
                            : 'Detailed explanation of the question and correct answer',
                        style: AppTypography.bodyS.copyWith(
                          fontSize: 12.sp,
                          color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close, 
                    color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          Divider(height: 1.h, color: widget.isDark ? AppColors.darkDivider : AppColors.lightDivider),
          
          // Content
          Flexible(
            child: FutureBuilder<String>(
              future: _explanationFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxxxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: widget.primaryGold),
                        const SizedBox(height: AppSpacing.lg),
                        AutoSizeText(
                          widget.isArabic ? 'جاري تحميل الشرح...' : 'Loading explanation...',
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
                    padding: const EdgeInsets.all(AppSpacing.xxxxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: AppColors.errorDark, size: 48.sp),
                        const SizedBox(height: AppSpacing.lg),
                        AutoSizeText(
                          widget.isArabic
                              ? 'حدث خطأ أثناء تحميل الشرح'
                              : 'Error loading explanation',
                          style: AppTypography.bodyL.copyWith(
                            color: AppColors.errorDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                
                final explanation = snapshot.data ?? '';
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Explanation text (Markdown support can be added here)
                      AutoSizeText(
                        explanation,
                        style: AppTypography.bodyL.copyWith(
                          fontSize: 16.sp,
                          height: 1.6,
                          color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
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
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isRefreshing ? null : _refreshExplanation,
                    icon: _isRefreshing
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: widget.primaryGold,
                            ),
                          )
                        : Icon(Icons.refresh, size: 20.sp),
                    label: Text(
                      widget.isArabic ? 'تحديث' : 'Refresh',
                      style: AppTypography.button,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: widget.primaryGold),
                      foregroundColor: widget.primaryGold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.primaryGold,
                      foregroundColor: widget.isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
                    ),
                    child: Text(
                      widget.isArabic ? 'إغلاق' : 'Close',
                      style: AppTypography.button,
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

