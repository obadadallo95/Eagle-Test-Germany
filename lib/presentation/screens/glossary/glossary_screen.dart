import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flip_card/flip_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../providers/glossary_provider.dart';
import '../../providers/question_provider.dart';
import '../../providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';
import '../../../domain/entities/term.dart';
import '../../../domain/entities/question.dart';

/// -----------------------------------------------------------------
/// 📖 GLOSSARY SCREEN / WÖRTERBUCH / شاشة القاموس
/// -----------------------------------------------------------------
/// Premium Flashcard Mode for learning political/legal terms with TTS.
/// -----------------------------------------------------------------
class GlossaryScreen extends ConsumerStatefulWidget {
  const GlossaryScreen({super.key});

  @override
  ConsumerState<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends ConsumerState<GlossaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  String _searchQuery = '';
  String? _selectedCategory; // القسم المختار
  int _currentIndex = 0;
  bool _isFlashcardMode = true; // Default to flashcard mode
  final FlutterTts _flutterTts = FlutterTts();
  final Map<int, GlobalKey<FlipCardState>> _flipCardKeys = {};
  bool _hasInitializedRandom = false; // لتتبع ما إذا تم اختيار كلمة عشوائية

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

  Future<void> _speakTerm(String term) async {
    // تحديث سرعة الصوت قبل التحدث (في حالة تغييرها في الإعدادات)
    final prefs = await SharedPreferences.getInstance();
    final savedSpeed = prefs.getDouble('tts_speed') ?? 1.0;
    await _flutterTts.setSpeechRate(savedSpeed);
    await _flutterTts.speak(term);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _nextCard() {
    if (_currentIndex < _getFilteredTerms().length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<Term> _getFilteredTerms() {
    final glossaryAsync = ref.watch(glossarySearchProvider(_searchQuery));
    return glossaryAsync.when(
      data: (terms) {
        final sorted = List<Term>.from(terms)..sort((a, b) => a.term.compareTo(b.term));
        return sorted;
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final langCode = currentLocale.languageCode;
    final isArabic = langCode == 'ar';

    final glossaryAsync = ref.watch(glossarySearchProvider(_searchQuery));

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          l10n?.glossary ?? 'Glossary',
          style: AppTypography.h2.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isFlashcardMode ? Icons.list : Icons.style),
            tooltip: _isFlashcardMode
                ? (l10n?.glossaryListView ?? 'List View')
                : (l10n?.glossaryFlashcards ?? 'Flashcards'),
            onPressed: () {
              setState(() {
                _isFlashcardMode = !_isFlashcardMode;
                _currentIndex = 0;
              });
            },
          ),
        ],
      ),
      body: AdaptivePageWrapper(
        padding: EdgeInsets.zero,
        enableScroll: false, // Column مع PageView يملأ الشاشة
        child: Column(
          children: [
            // Search Bar
            Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: TextField(
              controller: _searchController,
              style: AppTypography.bodyL.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: l10n?.glossarySearchPlaceholder ?? 'Search glossary...',
                hintStyle: AppTypography.bodyL.copyWith(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
                prefixIcon: Icon(
                  Icons.search, 
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, 
                  size: 20.sp,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear, 
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, 
                          size: 20.sp,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: primaryGold.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: primaryGold.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: primaryGold),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _currentIndex = 0;
                  _hasInitializedRandom = false; // إعادة تعيين عند البحث
                });
              },
            ),
          ),
          
          // Category Filter Chips
          _buildCategoryFilter(context, isDark, primaryGold, surfaceColor, isArabic),

          // Content
          Expanded(
            child: _isFlashcardMode
                ? _buildFlashcardMode(context, glossaryAsync, langCode, isArabic)
                : _buildListMode(context, glossaryAsync, langCode, isArabic),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildFlashcardMode(
    BuildContext context,
    AsyncValue<List<Term>> glossaryAsync,
    String langCode,
    bool isArabic,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final l10n = AppLocalizations.of(context);
    
    // استخدام المصطلحات المفلترة
    final filteredTerms = _getFilteredTerms();
    
    return filteredTerms.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _selectedCategory != null ? Icons.filter_alt_off : Icons.search_off,
                  size: 64.sp,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
                const SizedBox(height: AppSpacing.lg),
                AutoSizeText(
                  _selectedCategory != null
                      ? (isArabic
                          ? 'لا توجد مصطلحات في هذا القسم'
                          : 'No terms in this category')
                      : (_searchQuery.isEmpty
                          ? (l10n?.glossaryNoTermsAvailable ?? 'No terms available')
                          : (l10n?.glossaryNoTermsFound ?? 'No terms found')),
                  style: AppTypography.bodyL.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          )
        : _buildFlashcardContent(filteredTerms, langCode, isArabic, isDark, primaryGold, surfaceColor, l10n);
  }

  Widget _buildFlashcardContent(
    List<Term> terms,
    String langCode,
    bool isArabic,
    bool isDark,
    Color primaryGold,
    Color surfaceColor,
    AppLocalizations? l10n,
  ) {
        if (terms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off, 
                  size: 64.sp, 
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
                const SizedBox(height: AppSpacing.lg),
                AutoSizeText(
                  _searchQuery.isEmpty
                      ? (l10n?.glossaryNoTermsAvailable ?? 'No terms available')
                      : (l10n?.glossaryNoTermsFound ?? 'No terms found'),
                  style: AppTypography.bodyL.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final sortedTerms = List<Term>.from(terms)..sort((a, b) => a.term.compareTo(b.term));
        
        // Initialize flip card keys
        for (int i = 0; i < sortedTerms.length; i++) {
          _flipCardKeys[i] ??= GlobalKey<FlipCardState>();
        }

        // اختيار كلمة عشوائية عند أول تحميل أو عند تغيير الفلتر
        if (!_hasInitializedRandom && sortedTerms.isNotEmpty && _searchQuery.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final random = Random();
            final randomIndex = random.nextInt(sortedTerms.length);
            setState(() {
              _currentIndex = randomIndex;
              _hasInitializedRandom = true;
            });
            // الانتقال إلى الصفحة العشوائية
            if (_pageController.hasClients) {
              _pageController.jumpToPage(randomIndex);
            }
          });
        }

        return Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoSizeText(
                    isArabic
                        ? '${_currentIndex + 1} / ${sortedTerms.length}'
                        : '${_currentIndex + 1} / ${sortedTerms.length}',
                    style: AppTypography.bodyM.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  if (sortedTerms[_currentIndex].category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: primaryGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: primaryGold.withValues(alpha: 0.5),
                          width: 1.w,
                        ),
                      ),
                      child: AutoSizeText(
                        sortedTerms[_currentIndex].category ?? '',
                        style: AppTypography.bodyS.copyWith(
                          color: primaryGold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Flashcard
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: sortedTerms.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final term = sortedTerms[index];
                  return Padding(
                    padding: EdgeInsets.all(16.w),
                    child: _buildFlashcard(term, langCode, isArabic, index),
                  );
                },
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: _currentIndex > 0 ? _previousCard : null,
                      icon: Icon(isArabic ? Icons.arrow_forward : Icons.arrow_back, size: 18.sp),
                      label: Text(
                        l10n?.glossaryPrevious ?? 'Previous',
                        style: AppTypography.button.copyWith(fontSize: 12.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: surfaceColor,
                        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        minimumSize: Size(0, 48.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final term = sortedTerms[_currentIndex];
                        _speakTerm(term.term);
                      },
                      icon: Icon(Icons.volume_up, size: 18.sp),
                      label: Text(
                        l10n?.glossaryPronounce ?? 'Pronounce',
                        style: AppTypography.button.copyWith(fontSize: 12.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGold,
                        foregroundColor: isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        minimumSize: Size(0, 48.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: _currentIndex < sortedTerms.length - 1 ? _nextCard : null,
                      icon: Icon(isArabic ? Icons.arrow_back : Icons.arrow_forward, size: 18.sp),
                      label: Text(
                        l10n?.glossaryNext ?? 'Next',
                        style: AppTypography.button.copyWith(fontSize: 12.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: surfaceColor,
                        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        minimumSize: Size(0, 48.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
  }

  Widget _buildFlashcard(Term term, String langCode, bool isArabic, int index) {
    final l10n = AppLocalizations.of(context);
    final flipKey = _flipCardKeys[index] ??= GlobalKey<FlipCardState>();

    return FlipCard(
      key: flipKey,
      flipOnTouch: true,
      direction: FlipDirection.HORIZONTAL,
      front: _buildCardFront(context, term, langCode, isArabic, l10n),
      back: _buildCardBack(context, term, langCode, isArabic, l10n),
    );
  }

  Widget _buildCardFront(BuildContext context, Term term, String langCode, bool isArabic, AppLocalizations? l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  primaryGold.withValues(alpha: 0.2),
                  surfaceColor.withValues(alpha: 0.8),
                ]
              : [
                  primaryGold.withValues(alpha: 0.1),
                  surfaceColor,
                ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: primaryGold.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? AppColors.darkBg.withValues(alpha: 0.3)
                : AppColors.lightBg.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.volume_up, size: 48.sp, color: primaryGold),
              onPressed: () => _speakTerm(term.term),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AutoSizeText(
              term.term,
              style: AppTypography.h1.copyWith(
                fontSize: 48.sp,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.lg),
            AutoSizeText(
              l10n?.glossaryTapToFlip ?? 'Tap to flip',
              style: AppTypography.bodyM.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(BuildContext context, Term term, String langCode, bool isArabic, AppLocalizations? l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final questionsAsync = ref.watch(questionsProvider);
    final relatedQuestionIds = term.getAllRelatedQuestionIds();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  surfaceColor.withValues(alpha: 0.9),
                  surfaceColor.withValues(alpha: 0.7),
                ]
              : [
                  surfaceColor,
                  surfaceColor.withValues(alpha: 0.95),
                ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: primaryGold.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? AppColors.darkBg.withValues(alpha: 0.3)
                : AppColors.lightBg.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Term
            AutoSizeText(
              term.term,
              style: AppTypography.h1.copyWith(
                fontSize: 32.sp,
                color: primaryGold,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Definition
            AutoSizeText(
              l10n?.glossaryDefinition ?? 'Definition:',
              style: AppTypography.h4.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AutoSizeText(
              term.getDefinition(langCode),
              style: AppTypography.bodyL.copyWith(
                fontSize: 18.sp,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              maxLines: 10,
            ),

            // Example
            if (term.getExample(langCode).isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxl),
              AutoSizeText(
                l10n?.glossaryExample ?? 'Example:',
                style: AppTypography.h4.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: primaryGold.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: AutoSizeText(
                  term.getExample(langCode),
                  style: AppTypography.bodyL.copyWith(
                    fontSize: 16.sp,
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  maxLines: 5,
                ),
              ),
            ],

            // Related Questions Button
            if (relatedQuestionIds.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxl),
              questionsAsync.when(
                data: (allQuestions) {
                  final relatedQuestions = allQuestions
                      .where((q) => relatedQuestionIds.contains(q.id))
                      .toList();

                  if (relatedQuestions.isEmpty) return const SizedBox.shrink();

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showRelatedQuestions(context, term, relatedQuestions, langCode, isArabic);
                      },
                      icon: const Icon(Icons.quiz),
                      label: Text(
                        '${l10n?.glossaryShowInQuestionContext ?? 'Show in Question Context'} (${relatedQuestions.length})',
                        style: AppTypography.button,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGold,
                        foregroundColor: isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                          horizontal: AppSpacing.md,
                        ),
                        minimumSize: Size(double.infinity, 52.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),
            AutoSizeText(
              l10n?.glossaryTapToFlip ?? 'Tap to flip',
              style: AppTypography.bodyM.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showRelatedQuestions(
    BuildContext context,
    Term term,
    List<Question> questions,
    String langCode,
    bool isArabic,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightSurface;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              '${l10n?.glossaryRelatedQuestions ?? 'Questions related to'} "${term.term}"',
              style: AppTypography.h3.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...questions.map((question) => Card(
                  color: bgColor,
                  child: ListTile(
                    title: AutoSizeText(
                      question.getText(langCode),
                      style: AppTypography.bodyL.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      maxLines: 2,
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: primaryGold),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to question detail
                      // You can implement navigation to ExamDetailScreen here
                    },
                  ),
                )),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildListMode(
    BuildContext context,
    AsyncValue<List<Term>> glossaryAsync,
    String langCode,
    bool isArabic,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final l10n = AppLocalizations.of(context);
    
    // استخدام المصطلحات المفلترة
    final filteredTerms = _getFilteredTerms();
    
    if (filteredTerms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedCategory != null ? Icons.filter_alt_off : Icons.search_off,
              size: 64.sp,
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            AutoSizeText(
              _selectedCategory != null
                  ? (isArabic
                      ? 'لا توجد مصطلحات في هذا القسم'
                      : 'No terms in this category')
                  : (_searchQuery.isEmpty
                      ? (l10n?.glossaryNoTermsAvailable ?? 'No terms available')
                      : (l10n?.glossaryNoTermsFound ?? 'No terms found')),
              style: AppTypography.bodyL.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final sortedTerms = List<Term>.from(filteredTerms)..sort((a, b) => a.term.compareTo(b.term));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: sortedTerms.length,
          itemBuilder: (context, index) {
            final term = sortedTerms[index];
            return Card(
              color: surfaceColor,
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryGold.withValues(alpha: 0.2),
                  child: Text(
                    term.term[0].toUpperCase(),
                    style: AppTypography.bodyL.copyWith(
                      color: primaryGold,
                    ),
                  ),
                ),
                title: Text(
                  term.term,
                  style: AppTypography.h4.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                subtitle: Text(
                  term.getDefinitionSnippet(langCode, maxLength: 80),
                  style: AppTypography.bodyM.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(Icons.chevron_right, color: primaryGold),
                onTap: () {
                  setState(() {
                    _isFlashcardMode = true;
                    _currentIndex = index;
                  });
                },
              ),
            );
          },
        );
  }

  /// بناء فلاتر الأقسام
  Widget _buildCategoryFilter(
    BuildContext context,
    bool isDark,
    Color primaryGold,
    Color surfaceColor,
    bool isArabic,
  ) {
    final categoriesAsync = ref.watch(glossaryCategoriesProvider);
    
    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) return const SizedBox.shrink();
        
        return Container(
          height: 60.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // زر "الكل" / "All"
              _buildCategoryChip(
                context: context,
                label: isArabic ? 'الكل' : 'All',
                isSelected: _selectedCategory == null,
                isDark: isDark,
                primaryGold: primaryGold,
                surfaceColor: surfaceColor,
                onTap: () {
                  setState(() {
                    _selectedCategory = null;
                    _searchQuery = '';
                    _searchController.clear();
                    _hasInitializedRandom = false; // إعادة تعيين لاختيار كلمة عشوائية جديدة
                  });
                  // اختيار كلمة عشوائية من جميع الكلمات فوراً
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final filteredTerms = _getFilteredTerms();
                    if (filteredTerms.isNotEmpty) {
                      final random = Random();
                      final randomIndex = random.nextInt(filteredTerms.length);
                      setState(() {
                        _currentIndex = randomIndex;
                        _hasInitializedRandom = true;
                      });
                      if (_pageController.hasClients) {
                        _pageController.jumpToPage(randomIndex);
                      }
                    }
                  });
                },
              ),
              SizedBox(width: 8.w),
              // أقسام أخرى
              ...categories.map((category) {
                final categoryLabel = _getCategoryLabel(category, isArabic);
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: _buildCategoryChip(
                    context: context,
                    label: categoryLabel,
                    isSelected: _selectedCategory == category,
                    isDark: isDark,
                    primaryGold: primaryGold,
                    surfaceColor: surfaceColor,
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                        _searchQuery = '';
                        _searchController.clear();
                        _hasInitializedRandom = false; // إعادة تعيين لاختيار كلمة عشوائية جديدة
                      });
                      // اختيار كلمة عشوائية من القسم المحدد فوراً
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final filteredTerms = _getFilteredTerms();
                        if (filteredTerms.isNotEmpty) {
                          final random = Random();
                          final randomIndex = random.nextInt(filteredTerms.length);
                          setState(() {
                            _currentIndex = randomIndex;
                            _hasInitializedRandom = true;
                          });
                          if (_pageController.hasClients) {
                            _pageController.jumpToPage(randomIndex);
                          }
                        }
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// بناء شريحة القسم
  Widget _buildCategoryChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required bool isDark,
    required Color primaryGold,
    required Color surfaceColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryGold.withValues(alpha: isDark ? 0.3 : 0.25),
                      primaryGold.withValues(alpha: isDark ? 0.2 : 0.15),
                    ],
                  )
                : null,
            color: isSelected ? null : surfaceColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected
                  ? primaryGold
                  : primaryGold.withValues(alpha: isDark ? 0.2 : 0.15),
              width: isSelected ? 2.w : 1.w,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryGold.withValues(alpha: isDark ? 0.3 : 0.2),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.bodyM.copyWith(
                color: isSelected
                    ? primaryGold
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// الحصول على اسم القسم باللغة المناسبة
  String _getCategoryLabel(String category, bool isArabic) {
    final categoryLabels = {
      'System': isArabic ? 'النظام' : 'System',
      'Rights': isArabic ? 'الحقوق' : 'Rights',
      'Society': isArabic ? 'المجتمع' : 'Society',
      'Welfare': isArabic ? 'الرفاهية' : 'Welfare',
      'History': isArabic ? 'التاريخ' : 'History',
    };
    return categoryLabels[category] ?? category;
  }
}
