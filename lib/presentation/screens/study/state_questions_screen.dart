import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/ai_tutor_service.dart';
import '../../providers/question_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/question_card.dart';
import '../../../core/storage/srs_service.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';
import '../../../core/storage/hive_service.dart';
import '../../../core/storage/user_preferences_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/question.dart';
import '../subscription/paywall_screen.dart';

/// -----------------------------------------------------------------
/// 🏛️ STATE QUESTIONS SCREEN / LANDESFRAGEN / شاشة أسئلة الولاية
/// -----------------------------------------------------------------
/// Displays state-specific questions (up to 10 questions) for the selected state.
/// -----------------------------------------------------------------
class StateQuestionsScreen extends ConsumerStatefulWidget {
  const StateQuestionsScreen({super.key});

  @override
  ConsumerState<StateQuestionsScreen> createState() => _StateQuestionsScreenState();
}

class _StateQuestionsScreenState extends ConsumerState<StateQuestionsScreen> {
  int _currentIndex = 0;
  String? _selectedAnswerId;
  bool _showTranslation = false;
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
    if (_isAnswerChecked) return;

    setState(() {
      _selectedAnswerId = answerId;
      _isAnswerChecked = true;
    });

    final isCorrect = answerId == question.correctAnswerId;
    
    // Save answer
    await HiveService.saveQuestionAnswer(question.id, answerId, isCorrect);
    
    // Update SRS
    await SrsService.updateSrsAfterAnswer(question.id, isCorrect);
    
    // جدولة إشعارات SRS إذا لزم الأمر
    final isReminderEnabled = await UserPreferencesService.getReminderEnabled();
    if (isReminderEnabled) {
      await NotificationService.scheduleSrsReminder();
      await NotificationService.scheduleStreakReminder();
    }
  }

  void _nextQuestion() {
    final questions = _getQuestions();
    if (_currentIndex < questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // All questions reviewed
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(localeProvider).languageCode == 'ar'
                ? 'رائع! تمت مراجعة جميع أسئلة الولاية. 🎉'
                : 'Great job! All state questions reviewed. 🎉',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  List<Question> _getQuestions() {
    final selectedStateAsync = ref.watch(_selectedStateProvider);
    final selectedState = selectedStateAsync.value;
    
    if (selectedState == null || selectedState.isEmpty) {
      return [];
    }

    final asyncValue = ref.watch(stateQuestionsProvider(selectedState));
    return asyncValue.when(
      data: (questions) {
        // Take up to 10 questions
        return questions.take(10).toList();
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar';
    final selectedStateAsync = ref.watch(_selectedStateProvider);
    
    final questionsAsync = selectedStateAsync.when(
      data: (selectedState) {
        if (selectedState == null || selectedState.isEmpty) {
          return const AsyncValue<List<Question>>.data([]);
        }
        return ref.watch(stateQuestionsProvider(selectedState));
      },
      loading: () => const AsyncValue<List<Question>>.loading(),
      error: (_, __) => const AsyncValue<List<Question>>.data([]),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final hasProgress = _selectedAnswerId != null || _currentIndex > 0;
        
        if (hasProgress) {
          final shouldQuit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(isArabic ? 'الخروج من المراجعة؟' : 'Exit Review?'),
              content: Text(
                isArabic
                    ? 'هل أنت متأكد من الخروج؟ سيتم فقدان التقدم الحالي.'
                    : 'Are you sure you want to exit? Your current progress will be lost.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    isArabic ? 'خروج' : 'Exit',
                    style: TextStyle(color: Colors.red, fontSize: 14.sp),
                  ),
                ),
              ],
            ),
          );
          
          if (shouldQuit == true && mounted && context.mounted) {
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                isArabic ? 'أسئلة الولاية' : 'State Questions',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              backgroundColor: theme.appBarTheme.backgroundColor,
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: questionsAsync.when(
                  data: (questions) => LinearProgressIndicator(
                    value: questions.isEmpty ? 0 : (_currentIndex + 1) / questions.length,
                    backgroundColor: AppColors.germanRed.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation(AppColors.eagleGold),
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
                  final selectedState = selectedStateAsync.value;
                  if (selectedState == null || selectedState.isEmpty) {
                    return _buildNoStateSelected(context, isArabic);
                  }

                  if (questions.isEmpty) {
                    return _buildEmptyState(context, isArabic);
                  }

                  return PageView.builder(
                    controller: _pageController,
                    itemCount: questions.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                        _selectedAnswerId = null;
                        _showTranslation = false;
                        _isAnswerChecked = false;
                      });
                    },
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      return _buildQuestionView(context, question, l10n, currentLocale.languageCode);
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.eagleGold),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                      SizedBox(height: 16.h),
                      Builder(
                        builder: (context) {
                          final theme = Theme.of(context);
                          return AutoSizeText(
                            isArabic ? 'خطأ في تحميل الأسئلة' : 'Error loading questions',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );  // إغلاق return Scaffold
        },
      ),
    );
  }

  Widget _buildNoStateSelected(BuildContext context, bool isArabic) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 120.sp,
              color: Colors.grey[600],
            ),
            SizedBox(height: 24.h),
            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                return Column(
                  children: [
                    AutoSizeText(
                      isArabic ? 'لم يتم اختيار ولاية' : 'No State Selected',
                      style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                    ),
                    SizedBox(height: 16.h),
                    AutoSizeText(
                      isArabic
                          ? 'يرجى اختيار ولاية من الإعدادات لعرض أسئلة الولاية.'
                          : 'Please select a state from settings to view state questions.',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isArabic) {
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
            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                return Column(
                  children: [
                    AutoSizeText(
                      isArabic ? 'لا توجد أسئلة' : 'No Questions Available',
                      style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                    ),
                    SizedBox(height: 16.h),
                    AutoSizeText(
                      isArabic
                          ? 'لا توجد أسئلة خاصة بالولاية المختارة حالياً.'
                          : 'No state-specific questions available for the selected state.',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionView(
    BuildContext context,
    Question question,
    AppLocalizations? l10n,
    String languageCode,
  ) {
    final questions = _getQuestions();
    final isArabic = languageCode == 'ar';

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Question Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText(
                isArabic
                    ? 'سؤال ${_currentIndex + 1}/${questions.length}'
                    : 'Question ${_currentIndex + 1}/${questions.length}',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.germanRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flag, size: 16.sp, color: AppColors.germanRed),
                    SizedBox(width: 4.w),
                    AutoSizeText(
                      isArabic ? 'ولاية' : 'State',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: AppColors.germanRed,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Question Card
          QuestionCard(
            question: question,
            selectedAnswerId: _selectedAnswerId,
            translationLangCode: _showTranslation ? languageCode : null,
            isAnswerChecked: _isAnswerChecked,
            onAnswerSelected: (id) => _handleAnswer(id, question),
            onToggleTranslation: () {
              setState(() {
                _showTranslation = !_showTranslation;
              });
            },
            onPlayAudio: () => _playQuestion(question.getText('de')),
            onShowAiExplanation: () => _showAiExplanation(context, question, languageCode),
          ),

          SizedBox(height: 32.h),

          // Next Button (only show after answer is checked)
          if (_isAnswerChecked)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.eagleGold,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: AutoSizeText(
                  _currentIndex < questions.length - 1
                      ? (isArabic ? 'التالي' : 'Next')
                      : (isArabic ? 'إنهاء' : 'Finish'),
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showAiExplanation(BuildContext context, Question question, String languageCode) async {
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
      builder: (context) => _StateAiExplanationBottomSheet(
        question: question,
        userLanguage: userLanguage,
        isArabic: isArabic,
        l10n: l10n,
      ),
    );
  }
}

/// StatefulWidget منفصل لحفظ الشرح ومنع إعادة الاستدعاء
class _StateAiExplanationBottomSheet extends StatefulWidget {
  final Question question;
  final String userLanguage;
  final bool isArabic;
  final AppLocalizations? l10n;

  const _StateAiExplanationBottomSheet({
    required this.question,
    required this.userLanguage,
    required this.isArabic,
    required this.l10n,
  });

  @override
  State<_StateAiExplanationBottomSheet> createState() => _StateAiExplanationBottomSheetState();
}

class _StateAiExplanationBottomSheetState extends State<_StateAiExplanationBottomSheet> {
  Future<String>? _explanationFuture;
  String? _cachedExplanation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
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
      _cachedExplanation = null;
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
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
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
                  child: AutoSizeText(
                    explanation,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: theme.colorScheme.onSurface,
                      height: 1.6,
                    ),
                  ),
                );
              },
            ),
          ),
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

/// Provider to get selected state
final _selectedStateProvider = FutureProvider<String?>((ref) async {
  return await UserPreferencesService.getSelectedState();
});

