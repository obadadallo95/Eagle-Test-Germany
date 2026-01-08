import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:animate_do/animate_do.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_logo.dart';
import '../exam/paper_exam_config_screen.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';

/// -----------------------------------------------------------------
/// 💎 ABOUT SCREEN / ÜBER UNS / من نحن
/// -----------------------------------------------------------------
/// Premium showcase screen highlighting app features:
/// - 6-Language Support
/// - High-Quality Translations
/// - AI Smart Assistant
/// -----------------------------------------------------------------
class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  PackageInfo? _packageInfo;
  bool _isLoadingVersion = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = packageInfo;
      _isLoadingVersion = false;
    });
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final version = _packageInfo?.version ?? '1.0.0';

    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.about,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: AdaptivePageWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Header (The Brand)
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Column(
                children: [
                  AppLogo(
                    width: 120.w,
                    height: 120.h,
                  ),
                  SizedBox(height: 16.h),
                  AutoSizeText(
                    'Eagle Test: Germany',
                    style: GoogleFonts.poppins(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                  ),
                  SizedBox(height: 8.h),
                  AutoSizeText(
                    _isLoadingVersion
                        ? l10n.aboutLoadingVersion
                        : 'v$version (Hybrid Edition)',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: AppColors.eagleGold,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // 2. Feature Section (The Core Value)
            // Card A: Multi-language Mastery
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 600),
              child: _buildFeatureCard(
                context,
                icon: '🌍',
                title: l10n.aboutMultiLanguageTitle,
                subtitle: l10n.aboutMultiLanguageSubtitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildLanguageBadge('🇩🇪', 'DE'),
                        _buildLanguageBadge('🇺🇸', 'EN'),
                        _buildLanguageBadge('🇸🇾', 'AR'),
                        _buildLanguageBadge('🇹🇷', 'TR'),
                        _buildLanguageBadge('🇷🇺', 'RU'),
                        _buildLanguageBadge('🇺🇦', 'UA'),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    AutoSizeText(
                      l10n.aboutMultiLanguageDescription,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Card B: Smart Context Translation
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              duration: const Duration(milliseconds: 600),
              child: _buildFeatureCard(
                context,
                icon: '📝',
                title: l10n.aboutTranslationTitle,
                subtitle: l10n.aboutTranslationSubtitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    AutoSizeText(
                      l10n.aboutTranslationDescription,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Card C: Eagle AI Tutor (Highlighted)
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 600),
              child: _buildFeatureCard(
                context,
                icon: '🤖',
                title: l10n.aboutAiTutorTitle,
                subtitle: l10n.aboutAiTutorSubtitle,
                isHighlighted: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    AutoSizeText(
                      l10n.aboutAiTutorDescription,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Card D: Daily Challenge (New Gamified Feature)
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              duration: const Duration(milliseconds: 600),
              child: _buildFeatureCard(
                context,
                icon: '🔥',
                title: l10n.aboutDailyChallengeTitle,
                subtitle: l10n.aboutDailyChallengeSubtitle,
                isHighlighted: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    AutoSizeText(
                      l10n.aboutDailyChallengeDescription,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Card E: Paper Exam (New Premium Feature)
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 600),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaperExamConfigScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20.r),
                child: _buildPaperExamCard(
                  context,
                  l10n,
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // 3. Tech Stack Section
            FadeInUp(
              delay: const Duration(milliseconds: 550),
              duration: const Duration(milliseconds: 600),
              child: _buildTechStackSection(context, l10n),
            ),

            SizedBox(height: 32.h),

            // 4. The Roadmap (Coming Soon)
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 600),
              child: _buildRoadmapSection(context, l10n),
            ),

            SizedBox(height: 32.h),

            // 5. Developer & Socials
            FadeInUp(
              delay: const Duration(milliseconds: 700),
              duration: const Duration(milliseconds: 600),
              child: Column(
                children: [
                  AutoSizeText(
                    l10n.aboutDevelopedWith,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.white54,
                    ),
                    maxLines: 1,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        context,
                        icon: Icons.star,
                        label: l10n.aboutRateUs,
                        onTap: () {
                          // TODO: Replace with actual app store URL
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.aboutRateUs,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 12.w),
                      _buildSocialButton(
                        context,
                        icon: Icons.email,
                        label: l10n.aboutSupport,
                        onTap: () {
                          _launchURL('mailto:support@eagletest.de?subject=Support Request');
                        },
                      ),
                      SizedBox(width: 12.w),
                      _buildSocialButton(
                        context,
                        icon: Icons.language,
                        label: l10n.aboutWebsite,
                        onTap: () {
                          _launchURL('https://eagletest.de');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required Widget child,
    bool isHighlighted = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isHighlighted
              ? [
                  AppColors.eagleGold.withValues(alpha: 0.15),
                  AppColors.darkSurface.withValues(alpha: 0.8),
                ]
              : [
                  AppColors.darkSurface.withValues(alpha: 0.8),
                  AppColors.darkSurface.withValues(alpha: 0.6),
                ],
        ),
        border: Border.all(
          color: isHighlighted
              ? AppColors.eagleGold.withValues(alpha: 0.6)
              : AppColors.eagleGold.withValues(alpha: 0.2),
          width: isHighlighted ? 2.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              icon,
              style: TextStyle(fontSize: 48.sp),
            ),
            SizedBox(height: 12.h),
            AutoSizeText(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            AutoSizeText(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: AppColors.eagleGold,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPaperExamCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.05),
            AppColors.darkSurface.withValues(alpha: 0.8),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.eagleGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.eagleGold,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 14.sp,
                        color: AppColors.eagleGold,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Exclusive',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.eagleGold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                // Icon
                Icon(
                  Icons.print_rounded,
                  size: 48.sp,
                  color: Colors.white,
                ),
                SizedBox(height: 12.h),
                // Title
                AutoSizeText(
                  l10n.aboutPaperExamTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                // Subtitle
                AutoSizeText(
                  l10n.aboutPaperExamSubtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                // Description
                AutoSizeText(
                  l10n.aboutPaperExamDescription,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageBadge(String flag, String code) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.eagleGold.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.eagleGold.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: TextStyle(fontSize: 14.sp)),
          SizedBox(width: 3.w),
          Text(
            code,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.eagleGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.eagleGold.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: AppColors.eagleGold,
                size: 24.sp,
              ),
              SizedBox(height: 4.h),
              AutoSizeText(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.white70,
                ),
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoadmapSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkSurface.withValues(alpha: 0.6),
            AppColors.darkSurface.withValues(alpha: 0.4),
          ],
        ),
        border: Border.all(
          color: AppColors.eagleGold.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Text(
                  '🚀',
                  style: TextStyle(fontSize: 24.sp),
                ),
                SizedBox(width: 8.w),
                AutoSizeText(
                  l10n.aboutRoadmapTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
            SizedBox(height: 20.h),
            // Timeline items
            _buildRoadmapItem(
              context,
              icon: '🎙️',
              title: l10n.aboutRoadmapVoiceCoach,
              description: l10n.aboutRoadmapVoiceCoachDesc,
              isLast: false,
            ),
            _buildRoadmapItem(
              context,
              icon: '⚔️',
              title: l10n.aboutRoadmapLiveBattles,
              description: l10n.aboutRoadmapLiveBattlesDesc,
              isLast: false,
            ),
            _buildRoadmapItem(
              context,
              icon: '📑',
              title: l10n.aboutRoadmapBureaucracyBot,
              description: l10n.aboutRoadmapBureaucracyBotDesc,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadmapItem(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required bool isLast,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline dot
            Container(
              width: 12.w,
              height: 12.h,
              margin: EdgeInsets.only(top: 6.h),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.eagleGold.withValues(alpha: 0.5),
                border: Border.all(
                  color: AppColors.eagleGold.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Icon
            Text(
              icon,
              style: TextStyle(fontSize: 24.sp),
            ),
            SizedBox(width: 12.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7), // Dimmed for future
                    ),
                    maxLines: 1,
                  ),
                  SizedBox(height: 4.h),
                  AutoSizeText(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.white54.withValues(alpha: 0.7), // More dimmed
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          SizedBox(height: 8.h),
          // Timeline line
          Row(
            children: [
              SizedBox(width: 6.w),
              Container(
                width: 2,
                height: 24.h,
                color: AppColors.eagleGold.withValues(alpha: 0.2),
              ),
            ],
          ),
          SizedBox(height: 8.h),
        ],
      ],
    );
  }

  Widget _buildTechStackSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkSurface.withValues(alpha: 0.6),
            AppColors.darkSurface.withValues(alpha: 0.4),
          ],
        ),
        border: Border.all(
          color: AppColors.eagleGold.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Text(
                  '⚙️',
                  style: TextStyle(fontSize: 24.sp),
                ),
                SizedBox(width: 8.w),
                AutoSizeText(
                  'Tech Stack',
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
            SizedBox(height: 20.h),
            // Tech items
            _buildTechItem(
              context,
              icon: '🎯',
              text: 'Built with Flutter & Riverpod',
            ),
            SizedBox(height: 12.h),
            _buildTechItem(
              context,
              icon: '🤖',
              text: 'Powered by Eagle AI & Supabase Cloud',
            ),
            SizedBox(height: 12.h),
            _buildTechItem(
              context,
              icon: '🔐',
              text: 'Privacy-First Offline Architecture',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechItem(
    BuildContext context, {
    required String icon,
    required String text,
  }) {
    return Row(
      children: [
        Text(
          icon,
          style: TextStyle(fontSize: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: AutoSizeText(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.white70,
            ),
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

