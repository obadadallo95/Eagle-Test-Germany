import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flip_card/flip_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../providers/glossary_provider.dart';
import '../../providers/question_provider.dart';
import '../../providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
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
  int _currentIndex = 0;
  bool _isFlashcardMode = true; // Default to flashcard mode
  final FlutterTts _flutterTts = FlutterTts();
  final Map<int, GlobalKey<FlipCardState>> _flipCardKeys = {};

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

    return Scaffold(
      backgroundColor: AppColors.darkCharcoal,
      appBar: AppBar(
        title: Text(
          l10n?.glossary ?? 'Glossary',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.darkSurface,
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
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: l10n?.glossarySearchPlaceholder ?? 'Search glossary...',
                hintStyle: GoogleFonts.poppins(color: Colors.white54),
                prefixIcon: Icon(Icons.search, color: Colors.white70, size: 20.sp),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.white70, size: 20.sp),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.darkSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.eagleGold.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.eagleGold.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.eagleGold),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _currentIndex = 0;
                });
              },
            ),
          ),

          // Content
          Expanded(
            child: _isFlashcardMode
                ? _buildFlashcardMode(glossaryAsync, langCode, isArabic)
                : _buildListMode(glossaryAsync, langCode, isArabic),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildFlashcardMode(
    AsyncValue<List<Term>> glossaryAsync,
    String langCode,
    bool isArabic,
  ) {
    final l10n = AppLocalizations.of(context);
    return glossaryAsync.when(
      data: (terms) {
        if (terms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64.sp, color: Colors.grey[600]),
                SizedBox(height: 16.h),
                AutoSizeText(
                  _searchQuery.isEmpty
                      ? (l10n?.glossaryNoTermsAvailable ?? 'No terms available')
                      : (l10n?.glossaryNoTermsFound ?? 'No terms found'),
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.white70,
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

        return Column(
          children: [
            // Progress indicator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoSizeText(
                    isArabic
                        ? '${_currentIndex + 1} / ${sortedTerms.length}'
                        : '${_currentIndex + 1} / ${sortedTerms.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.white70,
                    ),
                  ),
                  if (sortedTerms[_currentIndex].category != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.eagleGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.eagleGold.withValues(alpha: 0.5),
                          width: 1.w,
                        ),
                      ),
                      child: AutoSizeText(
                        sortedTerms[_currentIndex].category ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: AppColors.eagleGold,
                          fontWeight: FontWeight.w600,
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
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _currentIndex > 0 ? _previousCard : null,
                    icon: Icon(isArabic ? Icons.arrow_forward : Icons.arrow_back),
                    label: Text(l10n?.glossaryPrevious ?? 'Previous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkSurface,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      final term = sortedTerms[_currentIndex];
                      _speakTerm(term.term);
                    },
                    icon: Icon(Icons.volume_up, size: 20.sp),
                    label: Text(l10n?.glossaryPronounce ?? 'Pronounce'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.eagleGold,
                      foregroundColor: Colors.black,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _currentIndex < sortedTerms.length - 1 ? _nextCard : null,
                    icon: Icon(isArabic ? Icons.arrow_back : Icons.arrow_forward),
                    label: Text(l10n?.glossaryNext ?? 'Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkSurface,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
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
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
            SizedBox(height: 16.h),
            AutoSizeText(
              'Error: $error',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcard(Term term, String langCode, bool isArabic, int index) {
    final l10n = AppLocalizations.of(context);
    final flipKey = _flipCardKeys[index] ??= GlobalKey<FlipCardState>();

    return FlipCard(
      key: flipKey,
      flipOnTouch: true,
      direction: FlipDirection.HORIZONTAL,
      front: _buildCardFront(term, langCode, isArabic, l10n),
      back: _buildCardBack(term, langCode, isArabic, l10n),
    );
  }

  Widget _buildCardFront(Term term, String langCode, bool isArabic, AppLocalizations? l10n) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.eagleGold.withValues(alpha: 0.2),
            AppColors.darkSurface.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColors.eagleGold.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
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
              icon: Icon(Icons.volume_up, size: 48.sp, color: AppColors.eagleGold),
              onPressed: () => _speakTerm(term.term),
            ),
            SizedBox(height: 24.h),
            AutoSizeText(
              term.term,
              style: GoogleFonts.poppins(
                fontSize: 48.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            SizedBox(height: 16.h),
            AutoSizeText(
              l10n?.glossaryTapToFlip ?? 'Tap to flip',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(Term term, String langCode, bool isArabic, AppLocalizations? l10n) {
    final questionsAsync = ref.watch(questionsProvider);
    final relatedQuestionIds = term.getAllRelatedQuestionIds();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkSurface.withValues(alpha: 0.9),
            AppColors.darkSurface.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColors.eagleGold.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Term
            AutoSizeText(
              term.term,
              style: GoogleFonts.poppins(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.eagleGold,
              ),
              maxLines: 2,
            ),
            SizedBox(height: 16.h),

            // Definition
            AutoSizeText(
              l10n?.glossaryDefinition ?? 'Definition:',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 8.h),
            AutoSizeText(
              term.getDefinition(langCode),
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                color: Colors.white,
              ),
              maxLines: 10,
            ),

            // Example
            if (term.getExample(langCode).isNotEmpty) ...[
              SizedBox(height: 24.h),
              AutoSizeText(
                l10n?.glossaryExample ?? 'Example:',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.eagleGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.eagleGold.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: AutoSizeText(
                  term.getExample(langCode),
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 5,
                ),
              ),
            ],

            // Related Questions Button
            if (relatedQuestionIds.isNotEmpty) ...[
              SizedBox(height: 24.h),
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
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.eagleGold,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
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

            SizedBox(height: 16.h),
            AutoSizeText(
              l10n?.glossaryTapToFlip ?? 'Tap to flip',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.white54,
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
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              '${l10n?.glossaryRelatedQuestions ?? 'Questions related to'} "${term.term}"',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            ...questions.map((question) => Card(
                  color: AppColors.darkCharcoal,
                  child: ListTile(
                    title: AutoSizeText(
                      question.getText(langCode),
                      style: GoogleFonts.poppins(color: Colors.white),
                      maxLines: 2,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.eagleGold),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to question detail
                      // You can implement navigation to ExamDetailScreen here
                    },
                  ),
                )),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildListMode(
    AsyncValue<List<Term>> glossaryAsync,
    String langCode,
    bool isArabic,
  ) {
    final l10n = AppLocalizations.of(context);
    return glossaryAsync.when(
      data: (terms) {
        if (terms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64.sp, color: Colors.grey[600]),
                SizedBox(height: 16.h),
                AutoSizeText(
                  _searchQuery.isEmpty
                      ? (l10n?.glossaryNoTermsAvailable ?? 'No terms available')
                      : (l10n?.glossaryNoTermsFound ?? 'No terms found'),
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          );
        }

        final sortedTerms = List<Term>.from(terms)..sort((a, b) => a.term.compareTo(b.term));

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: sortedTerms.length,
          itemBuilder: (context, index) {
            final term = sortedTerms[index];
            return Card(
              color: AppColors.darkSurface,
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.eagleGold.withValues(alpha: 0.2),
                  child: Text(
                    term.term[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: AppColors.eagleGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  term.term,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  term.getDefinitionSnippet(langCode, maxLength: 80),
                  style: GoogleFonts.poppins(color: Colors.white70),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.eagleGold),
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
            AutoSizeText(
              'Error: $error',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
