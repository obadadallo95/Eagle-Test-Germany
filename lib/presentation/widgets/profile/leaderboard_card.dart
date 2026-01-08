import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/leaderboard_service.dart';
import '../../../l10n/app_localizations.dart';

/// -----------------------------------------------------------------
/// 🏆 LEADERBOARD CARD / RANGLISTE KARTE / بطاقة لوحة المتصدرين
/// -----------------------------------------------------------------
/// Displays top 5 students based on questions learned.
/// Shows rank, name, avatar, and score.
/// -----------------------------------------------------------------
class LeaderboardCard extends StatefulWidget {
  const LeaderboardCard({super.key});

  @override
  State<LeaderboardCard> createState() => _LeaderboardCardState();
}

class _LeaderboardCardState extends State<LeaderboardCard> {
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
    });

    final leaderboard = await LeaderboardService.getTopStudents();

    if (mounted) {
      setState(() {
        _leaderboard = leaderboard;
        _isLoading = false;
      });
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.eagleGold; // Gold
      case 2:
        return Colors.grey.shade400; // Silver
      case 3:
        return Colors.brown.shade400; // Bronze
      default:
        return Colors.white70;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events; // Trophy
      case 2:
        return Icons.military_tech; // Medal
      case 3:
        return Icons.workspace_premium; // Premium
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 400),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.darkCharcoal,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.eagleGold.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: AppColors.eagleGold,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                AutoSizeText(
                  l10n?.topLearners ?? '🏆 Top Learners',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  minFontSize: 16.sp,
                  stepGranularity: 1.sp,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            // Content
            if (_isLoading)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(24.h),
                  child: const CircularProgressIndicator(
                    color: AppColors.eagleGold,
                  ),
                ),
              )
            else if (_leaderboard.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(24.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.leaderboard_outlined,
                        color: Colors.grey.shade600,
                        size: 48.sp,
                      ),
                      SizedBox(height: 8.h),
                      AutoSizeText(
                        l10n?.noLeaderboardData ?? 'No leaderboard data available',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        minFontSize: 12.sp,
                        stepGranularity: 1.sp,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _leaderboard.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey.shade800,
                ),
                itemBuilder: (context, index) {
                  final student = _leaderboard[index];
                  final rank = student['rank'] as int;
                  final name = student['name'] as String? ?? 'Guest User';
                  final avatarUrl = student['avatar_url'] as String?;
                  final questionsLearned = student['questions_learned'] as int;
                  final isCurrentUser = student['is_current_user'] as bool? ?? false;

                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? AppColors.eagleGold.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        // Rank
                        Container(
                          width: 40.w,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getRankIcon(rank),
                                color: _getRankColor(rank),
                                size: rank <= 3 ? 24.sp : 20.sp,
                              ),
                              SizedBox(height: 4.h),
                              AutoSizeText(
                                '#$rank',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: _getRankColor(rank),
                                ),
                                maxLines: 1,
                                minFontSize: 10.sp,
                                stepGranularity: 1.sp,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        
                        // Avatar
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.eagleGold.withValues(alpha: 0.2),
                            border: Border.all(
                              color: AppColors.eagleGold,
                              width: 1.5,
                            ),
                            image: avatarUrl != null && avatarUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(avatarUrl),
                                    fit: BoxFit.cover,
                                    onError: (exception, stackTrace) {
                                      // Handle network image error
                                    },
                                  )
                                : null,
                          ),
                          child: avatarUrl == null || avatarUrl.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 24.sp,
                                  color: AppColors.eagleGold,
                                )
                              : null,
                        ),
                        SizedBox(width: 12.w),
                        
                        // Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AutoSizeText(
                                name,
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: isCurrentUser
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isCurrentUser
                                      ? AppColors.eagleGold
                                      : Colors.white,
                                ),
                                maxLines: 1,
                                minFontSize: 12.sp,
                                stepGranularity: 1.sp,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isCurrentUser)
                                Padding(
                                  padding: EdgeInsets.only(top: 2.h),
                                  child: AutoSizeText(
                                    l10n?.you ?? 'You',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.sp,
                                      color: AppColors.eagleGold.withValues(alpha: 0.8),
                                    ),
                                    maxLines: 1,
                                    minFontSize: 8.sp,
                                    stepGranularity: 1.sp,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        // Score
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.eagleGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.eagleGold.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AutoSizeText(
                                '$questionsLearned',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.eagleGold,
                                ),
                                maxLines: 1,
                                minFontSize: 14.sp,
                                stepGranularity: 1.sp,
                              ),
                              AutoSizeText(
                                l10n?.statsQuestions ?? 'Questions',
                                style: GoogleFonts.poppins(
                                  fontSize: 8.sp,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                minFontSize: 7.sp,
                                stepGranularity: 1.sp,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

