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
    
    Navigator.push(
      context,
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
              AppColors.eagleGold.withValues(alpha: 0.15),
              AppColors.eagleGold.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.eagleGold.withValues(alpha: 0.3),
            width: 2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.eagleGold.withValues(alpha: 0.2),
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
                  color: AppColors.eagleGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.eagleGold,
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
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                    ),
                    SizedBox(height: 4.h),
                    AutoSizeText(
                      l10n?.aiCoachSubtitle ?? 'Your personalized study plan',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.white70,
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
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.eagleGold,
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
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: AppColors.eagleGold,
                ),
              ),
            )
          else if (_hasError)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: AutoSizeText(
                      l10n?.aiCoachError ?? 'Failed to load coaching advice',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.red.shade300,
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
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: AutoSizeText(
                _coachingAdvice!,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.white,
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
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: AutoSizeText(
                l10n?.aiCoachNoData ?? 'Start answering questions to get personalized study advice!',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.white70,
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
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.eagleGold,
                  foregroundColor: Colors.black,
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
                      color: AppColors.eagleGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: AppColors.eagleGold,
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
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                        ),
                        SizedBox(height: 4.h),
                        AutoSizeText(
                          l10n?.aiCoachSubtitle ?? 'Your personalized study plan',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.white70,
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
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: AutoSizeText(
                  'This is a sample coaching advice that would help you improve your weakest topics. Upgrade to Pro to unlock personalized AI coaching!',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.white,
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
                color: Colors.black.withValues(alpha: 0.3),
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
                    color: AppColors.eagleGold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock,
                    color: AppColors.eagleGold,
                    size: 48.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                AutoSizeText(
                  l10n?.unlockAiCoach ?? 'Unlock AI Coach',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                    backgroundColor: AppColors.eagleGold,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: AutoSizeText(
                    l10n?.upgrade ?? 'Upgrade to Pro',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
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

