import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/storage/hive_service.dart';
import '../../../domain/entities/question.dart';
import '../../providers/question_provider.dart';
import '../../widgets/question_card.dart';
import '../../widgets/time_tracker.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';
import '../../providers/locale_provider.dart';
import '../../../core/debug/app_logger.dart';

/// -----------------------------------------------------------------
/// ⭐ FAVORITES SCREEN / FAVORITEN / شاشة المفضلة
/// -----------------------------------------------------------------
/// Displays all favorite questions for review.
/// -----------------------------------------------------------------
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  int _currentIndex = 0;
  String? _selectedAnswerId;
  bool _showArabic = false;
  bool _isAnswerChecked = false;
  final PageController _pageController = PageController();
  List<Question> _favoriteQuestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    AppLogger.functionStart('_loadFavorites', source: 'FavoritesScreen');
    setState(() {
      _isLoading = true;
    });

    try {
      final favoriteIds = HiveService.getFavorites();
      AppLogger.info('Found ${favoriteIds.length} favorite questions', source: 'FavoritesScreen');

      if (favoriteIds.isEmpty) {
        setState(() {
          _favoriteQuestions = [];
          _isLoading = false;
        });
        AppLogger.functionEnd('_loadFavorites', source: 'FavoritesScreen');
        return;
      }

      // Load all questions and filter by favorites
      final allQuestionsAsync = ref.read(generalQuestionsProvider);
      final allQuestions = allQuestionsAsync.when(
        data: (questions) => questions,
        loading: () => <Question>[],
        error: (_, __) => <Question>[],
      );

      final favorites = allQuestions.where((q) => favoriteIds.contains(q.id)).toList();
      
      AppLogger.event('Favorites loaded', source: 'FavoritesScreen', data: {
        'count': favorites.length,
      });

      setState(() {
        _favoriteQuestions = favorites;
        _isLoading = false;
      });
      
      AppLogger.functionEnd('_loadFavorites', source: 'FavoritesScreen');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load favorites', source: 'FavoritesScreen', error: e, stackTrace: stackTrace);
      setState(() {
        _favoriteQuestions = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAnswer(String answerId, Question question) async {
    if (_isAnswerChecked) return;

    setState(() {
      _selectedAnswerId = answerId;
      _isAnswerChecked = true;
    });

    final isCorrect = answerId == question.correctAnswerId;
    await HiveService.saveQuestionAnswer(question.id, answerId, isCorrect);
  }

  void _nextQuestion() {
    if (_currentIndex < _favoriteQuestions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswerId = null;
        _isAnswerChecked = false;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _selectedAnswerId = null;
        _isAnswerChecked = false;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        // التحقق من وجود تقدم في المفضلة
        final hasProgress = _currentIndex > 0 || _selectedAnswerId != null || _isAnswerChecked;
        
        if (hasProgress) {
          // عرض حوار التأكيد
          final shouldQuit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.darkSurface,
              title: Text(
                isArabic ? 'الخروج من المفضلة؟' : 'Quit Favorites?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              content: Text(
                isArabic ? 'سيتم فقدان التقدم الحالي.' : 'Your progress will be lost.',
                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    isArabic ? 'البقاء' : 'Stay',
                    style: const TextStyle(color: AppColors.eagleGold),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.germanRed,
                  ),
                  child: Text(
                    isArabic ? 'الخروج' : 'Quit',
                    style: TextStyle(
                      color: AppColors.germanRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
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
      child: TimeTracker(
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              appBar: AppBar(
                title: Text(
                  isArabic ? 'المفضلة' : 'Favorites',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                backgroundColor: theme.appBarTheme.backgroundColor,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(Icons.refresh, size: 24.sp),
                    onPressed: _loadFavorites,
                    tooltip: isArabic ? 'تحديث' : 'Refresh',
                  ),
                ],
              ),
              body: AdaptivePageWrapper(
                padding: EdgeInsets.zero,
                enableScroll: false, // PageView يملأ الشاشة
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.eagleGold),
                      )
                    : _favoriteQuestions.isEmpty
                        ? _buildEmptyState(isArabic)
                        : _buildQuestionsView(l10n, isArabic),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isArabic) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 24.h),
            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                return Column(
                  children: [
                    AutoSizeText(
                      isArabic ? 'لا توجد أسئلة مفضلة' : 'No favorite questions',
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    AutoSizeText(
                      isArabic
                          ? 'اضغط على أيقونة القلب في أي سؤال لإضافته إلى المفضلة'
                          : 'Tap the heart icon on any question to add it to favorites',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
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

  Widget _buildQuestionsView(AppLocalizations? l10n, bool isArabic) {
    return Column(
      children: [
        // Progress indicator
        Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              color: theme.cardTheme.color,
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / _favoriteQuestions.length,
                      backgroundColor: theme.brightness == Brightness.dark 
                          ? Colors.grey.shade800 
                          : Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.eagleGold),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    '${_currentIndex + 1}/${_favoriteQuestions.length}',
                    style: GoogleFonts.poppins(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Questions
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _favoriteQuestions.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _selectedAnswerId = null;
                _isAnswerChecked = false;
              });
            },
            itemBuilder: (context, index) {
              final question = _favoriteQuestions[index];
              return _buildQuestionView(question, l10n, isArabic);
            },
          ),
        ),

        // Navigation buttons
        Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return Container(
              padding: EdgeInsets.all(16.w),
              color: theme.cardTheme.color,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _currentIndex > 0 ? _previousQuestion : null,
                    icon: Icon(Icons.arrow_back, size: 20.sp),
                    label: Text(isArabic ? 'السابق' : 'Previous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.brightness == Brightness.dark 
                          ? AppColors.darkCharcoal 
                          : Colors.grey.shade200,
                      foregroundColor: theme.colorScheme.onSurface,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _currentIndex < _favoriteQuestions.length - 1
                        ? _nextQuestion
                        : null,
                    icon: Icon(Icons.arrow_forward, size: 20.sp),
                    label: Text(isArabic ? 'التالي' : 'Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.eagleGold,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuestionView(Question question, AppLocalizations? l10n, bool isArabic) {
    final currentLocale = ref.watch(localeProvider);
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          QuestionCard(
            key: ValueKey('favorite_${question.id}_${HiveService.isFavorite(question.id)}'),
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
            onPlayAudio: () {
              // TTS can be added here if needed
            },
          ),
        ],
      ),
    );
  }
}

