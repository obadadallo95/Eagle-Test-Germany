import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/services/ai_coaching_service.dart';
import '../../core/storage/hive_service.dart';
import '../../core/storage/user_preferences_service.dart';
import '../../l10n/app_localizations.dart';
import '../providers/subscription_provider.dart';
import '../providers/question_provider.dart';
import '../providers/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../screens/subscription/paywall_screen.dart';
import '../screens/learn/topic_selection_screen.dart';

/// -----------------------------------------------------------------
/// 🎯 AI COACHING CARD / KI-COACHING-KARTE / بطاقة الموجه الذكي
/// -----------------------------------------------------------------
/// Premium feature: Displays AI-powered study coaching advice
/// Shows weakest topics and personalized study plan
/// -----------------------------------------------------------------
class AiCoachingCard extends ConsumerStatefulWidget {
  const AiCoachingCard({super.key});

  @override
  ConsumerState<AiCoachingCard> createState() => _AiCoachingCardState();
}

class _AiCoachingCardState extends ConsumerState<AiCoachingCard> {
  String? _coachingAdvice;
  List<TopicPerformance> _weakestTopics = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadCoachingData();
  }

  Future<void> _loadCoachingData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final allQuestions = await ref.read(questionsProvider.future);
      final weakestTopics = await AiCoachingService.getWeakestTopics(allQuestions);
      
      final currentLocale = ref.read(localeProvider);
      final userLanguage = currentLocale.languageCode;
      
      final progress = HiveService.getUserProgress();
      int overallScore = 0;
      if (progress != null) {
        final answers = progress['answers'] as Map<String, dynamic>?;
        if (answers != null && answers.isNotEmpty) {
          int correct = 0;
          int total = 0;
          answers.forEach((key, value) {
            if (value is Map && value['isCorrect'] == true) {
              correct++;
            }
            total++;
          });
          overallScore = total > 0 ? (correct / total * 100).round() : 0;
        }
      }
      
      final streak = await UserPreferencesService.getCurrentStreak();
      
      final advice = await AiCoachingService.getCoachingAdvice(
        weakestTopics: weakestTopics,
        userLanguage: userLanguage,
        overallScore: overallScore,
        streak: streak,
      );

      if (mounted) {
        setState(() {
          _weakestTopics = weakestTopics;
          _coachingAdvice = advice;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startFocusedPractice() async {
    if (_weakestTopics.isEmpty) return;
    
    // فتح شاشة الأسئلة للموضوع الأول الضعيف
    final allQuestions = await ref.read(questionsProvider.future);
    final firstWeakTopic = _weakestTopics.first.topic;
    final topicQuestions = allQuestions.where((q) => q.topic == firstWeakTopic || q.categoryId == firstWeakTopic).toList();
    
    if (topicQuestions.isEmpty) return;
    if (!context.mounted) return;
    
    final navigatorContext = context;
    Navigator.push(
      navigatorContext,
      MaterialPageRoute(
        builder: (_) => TopicQuestionsScreen(
          topic: firstWeakTopic,
          questions: topicQuestions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final subscriptionState = ref.watch(subscriptionProvider);
    final isPro = subscriptionState.isPro;

    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryGold.withValues(alpha: 0.15),
              primaryGold.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: primaryGold.withValues(alpha: 0.3),
            width: 2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryGold.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: isPro
              ? _buildProContent(context, l10n, isArabic, theme)
              : _buildFreeContent(context, l10n, isArabic, theme),
        ),
      ),
    );
  }

  Widget _buildProContent(BuildContext context, AppLocalizations? l10n, bool isArabic, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: primaryGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: primaryGold,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AutoSizeText(
                      l10n?.aiCoachTitle ?? '🎯 AI Study Coach',
                      style: AppTypography.h3.copyWith(
                        color: textPrimary,
                      ),
                      maxLines: 1,
                    ),
                    SizedBox(height: 4.h),
                    AutoSizeText(
                      l10n?.aiCoachSubtitle ?? 'Your personalized study plan',
                      style: AppTypography.bodyS.copyWith(
                        color: textSecondary,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Weakest Topics
          if (_weakestTopics.isNotEmpty) ...[
            AutoSizeText(
              l10n?.aiCoachWeakTopics ?? 'Weakest Topics:',
              style: AppTypography.bodyM.copyWith(
                fontWeight: FontWeight.w600,
                color: primaryGold,
              ),
              maxLines: 1,
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _weakestTopics.take(3).map((topic) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.5),
                      width: 1.w,
                    ),
                  ),
                  child: AutoSizeText(
                    '${_getTopicName(topic.topic, isArabic ? 'ar' : 'en')} (${topic.accuracy}%)',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.red.shade300,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
          ],

          // AI Advice
          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: primaryGold,
                ),
              ),
            )
          else if (_hasError)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.errorDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.errorDark, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: AutoSizeText(
                      l10n?.aiCoachError ?? 'Failed to load coaching advice',
                      style: AppTypography.bodyS.copyWith(
                        color: AppColors.errorDark,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            )
          else if (_coachingAdvice != null)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: AutoSizeText(
                _coachingAdvice!,
                style: AppTypography.bodyM.copyWith(
                  color: textPrimary,
                  height: 1.5,
                ),
                maxLines: 5,
                minFontSize: 12.sp,
                stepGranularity: 1.sp,
              ),
            )
          else
            // رسالة عندما لا توجد بيانات كافية
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: AutoSizeText(
                l10n?.aiCoachNoData ?? 'Start answering questions to get personalized study advice!',
                style: AppTypography.bodyM.copyWith(
                  color: textSecondary,
                  height: 1.5,
                ),
                maxLines: 3,
                minFontSize: 12.sp,
                stepGranularity: 1.sp,
                textAlign: TextAlign.center,
              ),
            ),

          SizedBox(height: 16.h),

          // Start Focused Practice Button
          if (_weakestTopics.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startFocusedPractice,
                icon: Icon(Icons.school, size: 20.sp),
                label: AutoSizeText(
                  l10n?.startFocusedPractice ?? 'Start Focused Practice',
                  style: AppTypography.button.copyWith(
                    fontSize: 16.sp,
                  ),
                  maxLines: 1,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFreeContent(BuildContext context, AppLocalizations? l10n, bool isArabic, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    
    return Stack(
      children: [
        // Blurred Content
        Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: primaryGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: primaryGold,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AutoSizeText(
                          l10n?.aiCoachTitle ?? '🎯 AI Study Coach',
                          style: AppTypography.h3.copyWith(
                            color: textPrimary,
                          ),
                          maxLines: 1,
                        ),
                        SizedBox(height: 4.h),
                        AutoSizeText(
                          l10n?.aiCoachSubtitle ?? 'Your personalized study plan',
                          style: AppTypography.bodyS.copyWith(
                            color: textSecondary,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: AutoSizeText(
                  'This is a sample coaching advice that would help you improve your weakest topics. Upgrade to Pro to unlock personalized AI coaching!',
                  style: AppTypography.bodyM.copyWith(
                    color: textPrimary,
                    height: 1.5,
                  ),
                  maxLines: 5,
                ),
              ),
            ],
          ),
        ),
        
        // Blur Overlay
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),

        // Lock Icon & Upgrade Button
        Positioned.fill(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: primaryGold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock,
                    color: primaryGold,
                    size: 48.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                AutoSizeText(
                  l10n?.unlockAiCoach ?? 'Unlock AI Coach',
                  style: AppTypography.h3.copyWith(
                    color: textPrimary,
                  ),
                  maxLines: 1,
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaywallScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: AutoSizeText(
                    l10n?.upgrade ?? 'Upgrade to Pro',
                    style: AppTypography.button.copyWith(
                      fontSize: 16.sp,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getTopicName(String topic, String userLanguage) {
    final isArabic = userLanguage == 'ar';
    
    final topicNames = {
      'system': isArabic ? 'النظام السياسي' : 'Political System',
      'rights': isArabic ? 'الحقوق الأساسية' : 'Basic Rights',
      'history': isArabic ? 'التاريخ الألماني' : 'German History',
      'society': isArabic ? 'المجتمع' : 'Society',
      'europe': isArabic ? 'ألمانيا في أوروبا' : 'Germany in Europe',
      'welfare': isArabic ? 'العمل والتعليم' : 'Work & Education',
    };
    
    return topicNames[topic] ?? topic;
  }
}

