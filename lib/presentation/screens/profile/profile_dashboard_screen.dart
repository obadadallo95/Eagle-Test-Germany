import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/storage/hive_service.dart';
import '../../../core/storage/user_preferences_service.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/exam_readiness_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../subscription/paywall_screen.dart';
import '../settings/language_selection_sheet.dart';
import '../settings/legal_screen.dart';
import '../settings/about_screen.dart';
import '../settings/state_selection_sheet.dart';
import '../../../core/services/notification_service.dart';
import '../../widgets/profile/leaderboard_card.dart';
import '../../widgets/responsive_center_scrollable.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/debug/app_logger.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// -----------------------------------------------------------------
/// 👤 PROFILE DASHBOARD SCREEN / PROFIL-DASHBOARD / لوحة الملف الشخصي
/// -----------------------------------------------------------------
/// Professional profile dashboard aggregating:
/// - User Identity & License Status
/// - Progress KPIs (Readiness, Streak, Mastery)
/// - License Activation (for Free users)
/// - App Settings (Language, State, Theme, Privacy, About)
/// -----------------------------------------------------------------
class ProfileDashboardScreen extends ConsumerStatefulWidget {
  const ProfileDashboardScreen({super.key});

  @override
  ConsumerState<ProfileDashboardScreen> createState() => _ProfileDashboardScreenState();
}

class _ProfileDashboardScreenState extends ConsumerState<ProfileDashboardScreen> {
  int _streak = 0;
  int _questionsLearned = 0;
  bool _isLoadingStats = true;
  bool _isReminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  double _ttsSpeed = 1.0; // TTS speed control
  
  // User profile fields
  final TextEditingController _nameController = TextEditingController();
  String? _avatarPath;
  bool _allowNameSync = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadReminderSettings();
    _loadUserProfile();
    _loadTtsSpeed();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final name = await UserPreferencesService.getUserName();
    final avatarPath = await UserPreferencesService.getUserAvatarPath();
    final allowSync = await UserPreferencesService.getAllowNameSync();
    
    if (mounted) {
      setState(() {
        _nameController.text = name ?? '';
        _avatarPath = avatarPath;
        _allowNameSync = allowSync;
      });
    }
  }

  Future<void> _loadReminderSettings() async {
    final isEnabled = await UserPreferencesService.getReminderEnabled();
    final time = await UserPreferencesService.getReminderTime();
    if (mounted) {
      setState(() {
        _isReminderEnabled = isEnabled;
        _reminderTime = time ?? const TimeOfDay(hour: 20, minute: 0);
      });
    }
  }

  Future<void> _loadTtsSpeed() async {
    final prefs = await UserPreferencesService.getSharedPreferences();
    if (mounted) {
      setState(() {
        _ttsSpeed = prefs.getDouble('tts_speed') ?? 1.0;
      });
    }
  }

  Future<void> _saveTtsSpeed(double speed) async {
    final prefs = await UserPreferencesService.getSharedPreferences();
    await prefs.setDouble('tts_speed', speed);
    if (mounted) {
      setState(() {
        _ttsSpeed = speed;
      });
    }
  }

  Future<void> _loadStats() async {
    // Load streak
    final streak = await UserPreferencesService.getCurrentStreak();
    
    // Calculate questions learned
    final progress = HiveService.getUserProgress();
    int questionsLearned = 0;
    if (progress != null) {
      final answers = progress['answers'] as Map<dynamic, dynamic>? ?? {};
      answers.forEach((key, value) {
        if (value is Map) {
          final valueMap = Map<String, dynamic>.from(
              (value).map((k, v) => MapEntry(k.toString(), v)));
          if (valueMap['isCorrect'] == true) {
            questionsLearned++;
          }
        }
      });
    }
    
    if (mounted) {
      setState(() {
        _streak = streak;
        _questionsLearned = questionsLearned;
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _showLicenseActivationDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final licenseKeyController = TextEditingController();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightSurface;
    
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.vpn_key, color: primaryGold, size: 28.sp),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AutoSizeText(
                l10n.activateLicense,
                style: AppTypography.h3.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                maxLines: 2,
                minFontSize: 16.sp,
                stepGranularity: 1.sp,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AutoSizeText(
              l10n.enterLicenseKey,
              style: AppTypography.bodyM.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              maxLines: 2,
              minFontSize: 12.sp,
              stepGranularity: 1.sp,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: licenseKeyController,
              style: AppTypography.bodyL.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: l10n.licenseKey,
                hintStyle: AppTypography.bodyL.copyWith(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
                filled: true,
                fillColor: bgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: primaryGold),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: primaryGold, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: AppTypography.button.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Note: Future enhancement - Call activate_license RPC in Supabase
              // For now, show a message
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.setupComplete,
                      style: AppTypography.button,
                    ),
                    backgroundColor: primaryGold,
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGold,
              foregroundColor: isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
            ),
            child: Text(
              l10n.activateLicense,
              style: AppTypography.button,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subscriptionState = ref.watch(subscriptionProvider);
    final isPro = subscriptionState.isPro;
    final readinessAsync = ref.watch(examReadinessProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return SafeArea(
      child: ResponsiveCenterScrollable(
        enableScroll: true,
        child: Column(
          children: [
          // Header Section
          FadeInDown(
            duration: const Duration(milliseconds: 300),
            child: _buildHeaderSection(context, isPro, l10n),
          ),
          
          const SizedBox(height: AppSpacing.xxl),
          
          // KPI Section
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 100),
            child: _buildKpiSection(context, readinessAsync, l10n),
          ),
          
          const SizedBox(height: AppSpacing.xxl),
          
          // Action Section (Only for Free users)
          if (!isPro)
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 200),
              child: _buildActionSection(context, l10n),
            ),
          
          if (!isPro) const SizedBox(height: AppSpacing.xxl),
          
          // Settings Section
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 300),
            child: _buildSettingsSection(
              context,
              locale,
              themeMode,
              isDark,
              l10n,
            ),
          ),
          
          const SizedBox(height: AppSpacing.xxl),
          
          // Leaderboard Section
          const LeaderboardCard(),
          
          const SizedBox(height: AppSpacing.xxl), // Bottom padding
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _avatarPath = image.path;
        });
        
        // Save avatar path locally
        await UserPreferencesService.saveUserAvatarPath(image.path);
        
        // Upload to Supabase if user allows
        if (_allowNameSync) {
          await _uploadAvatarToSupabase(image.path);
        }
      }
    } catch (e) {
      if (mounted) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: isDark ? AppColors.errorDark : AppColors.errorLight,
          ),
        );
      }
    }
  }

  Future<void> _uploadAvatarToSupabase(String imagePath) async {
    try {
      if (!SyncService.isAvailable) return;
      
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      if (session == null) return;
      
      final userId = session.user.id;
      final file = File(imagePath);
      final fileName = 'avatar_$userId.jpg';
      
      // Upload to Supabase Storage
      await supabase.storage
          .from('avatars')
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
      
      // Get public URL
      final avatarUrl = supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);
      
      // Update user profile
      await supabase
          .from('user_profiles')
          .update({'avatar_url': avatarUrl})
          .eq('user_id', userId);
      
      AppLogger.info('Avatar uploaded successfully', source: 'ProfileDashboardScreen');
    } catch (e) {
      AppLogger.warn('Failed to upload avatar: $e', source: 'ProfileDashboardScreen');
    }
  }

  Future<void> _saveName() async {
    final l10n = AppLocalizations.of(context)!;
    final subscriptionState = ref.read(subscriptionProvider);
    final isPro = subscriptionState.isPro;
    final name = _nameController.text.trim();
    final currentName = await UserPreferencesService.getUserName();
    if (!mounted) return;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    
    // Check if name is actually changing
    if (name == currentName) {
      return; // No change, no need to save
    }
    
    // Check name change limits for free users
    if (!isPro) {
      final nameChangeCount = await UserPreferencesService.getNameChangeCount();
      final originalName = await UserPreferencesService.getOriginalName();
      
      // If this is the first name set, allow it
      if (originalName == null && name.isNotEmpty) {
        await UserPreferencesService.saveOriginalName(name);
        await UserPreferencesService.saveUserName(name);
        await UserPreferencesService.incrementNameChangeCount();
      } else if (nameChangeCount >= 1) {
        // Free users can only change name once
        if (mounted) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isArabic 
                ? 'يمكنك تغيير الاسم مرة واحدة فقط في الخطة المجانية. ترقية إلى Pro لتغيير الاسم بدون حدود.'
                : 'You can only change your name once in the free plan. Upgrade to Pro for unlimited name changes.'),
              backgroundColor: isDark ? AppColors.warningDark : AppColors.warningLight,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: isArabic ? 'ترقية' : 'Upgrade',
                textColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaywallScreen()),
                  );
                },
              ),
            ),
          );
        }
        // Reset to previous name
        _nameController.text = currentName ?? '';
        return;
      } else {
        // First change allowed for free users
        await UserPreferencesService.incrementNameChangeCount();
      }
    }
    
    // Save name
    await UserPreferencesService.saveUserName(name);
    
    // Sync to Supabase if user allows
    if (_allowNameSync && name.isNotEmpty) {
      await _syncNameToSupabase(name);
    }
    
    if (mounted) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(name.isEmpty 
            ? l10n.nameRemoved
            : l10n.nameSaved),
          backgroundColor: isDark ? AppColors.successDark : AppColors.successLight,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _syncNameToSupabase(String name) async {
    try {
      if (!SyncService.isAvailable) return;
      
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      if (session == null) return;
      
      final userId = session.user.id;
      
      await supabase
          .from('user_profiles')
          .update({'name': name, 'updated_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId);
      
      AppLogger.info('Name synced to Supabase', source: 'ProfileDashboardScreen');
    } catch (e) {
      AppLogger.warn('Failed to sync name: $e', source: 'ProfileDashboardScreen');
    }
  }

  Widget _buildHeaderSection(BuildContext context, bool isPro, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  primaryGold.withValues(alpha: 0.2),
                  primaryGold.withValues(alpha: 0.1),
                  bgColor,
                ]
              : [
                  primaryGold.withValues(alpha: 0.1),
                  primaryGold.withValues(alpha: 0.05),
                  surfaceColor,
                ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: primaryGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar and Name Row
          Row(
            children: [
              // Avatar with picker
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 70.w,
                      height: 70.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryGold.withValues(alpha: 0.2),
                        border: Border.all(
                          color: primaryGold,
                          width: 2,
                        ),
                        image: _avatarPath != null
                          ? DecorationImage(
                              image: FileImage(File(_avatarPath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                      ),
                      child: _avatarPath == null
                        ? Icon(
                            Icons.person,
                            size: 40.sp,
                            color: primaryGold,
                          )
                        : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryGold,
                          border: Border.all(color: surfaceColor, width: 2),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 14.sp,
                          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(width: 16.w),
              
              // Name Input
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      style: AppTypography.h3.copyWith(
                        fontSize: 18.sp,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.enterYourName,
                        hintStyle: AppTypography.bodyL.copyWith(
                          fontSize: 16.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        // Auto-save on change (debounced)
                      },
                      onEditingComplete: _saveName,
                    ),
                    if (_nameController.text.isEmpty)
                      AutoSizeText(
                        l10n.guestUser,
                        style: AppTypography.bodyL.copyWith(
                          fontSize: 16.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        minFontSize: 14.sp,
                        stepGranularity: 1.sp,
                      ),
                    // Show name change limit info for free users
                    if (!isPro) FutureBuilder<int>(
                      future: UserPreferencesService.getNameChangeCount(),
                      builder: (context, snapshot) {
                        final changeCount = snapshot.data ?? 0;
                        final isArabic = Localizations.localeOf(context).languageCode == 'ar';
                        if (changeCount >= 1) {
                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: AutoSizeText(
                              isArabic 
                                ? 'تم تغيير الاسم مرة واحدة (الخطة المجانية)'
                                : 'Name changed once (Free plan)',
                              style: AppTypography.bodyS.copyWith(
                                fontSize: 10.sp,
                                color: AppColors.warningDark,
                              ),
                              maxLines: 1,
                              minFontSize: 8.sp,
                              stepGranularity: 1.sp,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Status Badge and Privacy Toggle Row
          Row(
            children: [
              // Status Badge
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isPro
                        ? primaryGold
                        : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isPro ? '🥇' : '⚪',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: AutoSizeText(
                          isPro ? l10n.proMember : l10n.freePlan,
                          style: AppTypography.bodyS.copyWith(
                            fontSize: 12.sp,
                            color: isPro 
                                ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          ),
                          maxLines: 1,
                          minFontSize: 10.sp,
                          stepGranularity: 1.sp,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(width: 8.w),
              
              // Privacy Toggle: Allow name sync to database
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: AutoSizeText(
                        l10n.saveNameToDatabase,
                        style: AppTypography.bodyS.copyWith(
                          fontSize: 11.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        minFontSize: 9.sp,
                        stepGranularity: 1.sp,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Switch(
                      value: _allowNameSync,
                      onChanged: (value) async {
                        setState(() {
                          _allowNameSync = value;
                        });
                        await UserPreferencesService.saveAllowNameSync(value);
                        
                        // If enabled, sync current name
                        if (value && _nameController.text.trim().isNotEmpty) {
                          await _syncNameToSupabase(_nameController.text.trim());
                        }
                      },
                      activeThumbColor: primaryGold,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiSection(
    BuildContext context,
    AsyncValue<dynamic> readinessAsync,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        // Card 1: Readiness
        Expanded(
          child: _buildKpiCard(
            context,
            icon: Icons.trending_up,
            iconColor: AppColors.infoDark,
            title: l10n.readiness,
            value: readinessAsync.when(
              data: (readiness) => '${readiness.overallScore.toStringAsFixed(0)}%',
              loading: () => '...',
              error: (_, __) => '0%',
            ),
            subtitle: 'Score',
            progress: readinessAsync.when(
              data: (readiness) => readiness.overallScore / 100.0,
              loading: () => 0.0,
              error: (_, __) => 0.0,
            ),
          ),
        ),
        
        const SizedBox(width: AppSpacing.md),
        
        // Card 2: Streak
        Expanded(
          child: _buildKpiCard(
            context,
            icon: Icons.local_fire_department,
            iconColor: AppColors.warningDark,
            title: l10n.streak,
            value: _isLoadingStats ? '...' : '$_streak',
            subtitle: 'Days',
            showProgress: false,
          ),
        ),
        
        const SizedBox(width: AppSpacing.md),
        
        // Card 3: Mastery
        Expanded(
          child: _buildKpiCard(
            context,
            icon: Icons.check_circle,
            iconColor: AppColors.successDark,
            title: l10n.mastery,
            value: _isLoadingStats ? '...' : '$_questionsLearned',
            subtitle: 'Questions',
            showProgress: false,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    double? progress,
    bool showProgress = true,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final bgColor = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 32.sp),
          const SizedBox(height: AppSpacing.md),
          if (showProgress && progress != null)
            CircularPercentIndicator(
              radius: 30.r,
              lineWidth: 4.w,
              percent: progress.clamp(0.0, 1.0),
              center: AutoSizeText(
                value,
                style: AppTypography.h2.copyWith(
                  fontSize: 18.sp,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                maxLines: 1,
                minFontSize: 14.sp,
                stepGranularity: 1.sp,
              ),
              progressColor: iconColor,
              backgroundColor: bgColor,
            )
          else
            AutoSizeText(
              value,
              style: AppTypography.h1.copyWith(
                fontSize: 24.sp,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              maxLines: 1,
              minFontSize: 18.sp,
              stepGranularity: 1.sp,
            ),
          const SizedBox(height: AppSpacing.sm),
          AutoSizeText(
            title,
            style: AppTypography.bodyS.copyWith(
              fontSize: 12.sp,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            maxLines: 1,
            minFontSize: 10.sp,
            stepGranularity: 1.sp,
          ),
          AutoSizeText(
            subtitle,
            style: AppTypography.bodyS.copyWith(
              fontSize: 10.sp,
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
            maxLines: 1,
            minFontSize: 8.sp,
            stepGranularity: 1.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.gold : AppColors.goldDark;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryGold.withValues(alpha: 0.2),
            primaryGold.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: primaryGold,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          AutoSizeText(
            l10n.upgradeAccount,
            style: AppTypography.h3.copyWith(
              fontSize: 18.sp,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            minFontSize: 16.sp,
            stepGranularity: 1.sp,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaywallScreen(),
                ),
              );
            },
            icon: Icon(Icons.star, size: 24.sp),
            label: Text(
              l10n.subscribeToPro,
              style: AppTypography.button,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGold,
              foregroundColor: isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxxl,
                vertical: AppSpacing.lg,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: _showLicenseActivationDialog,
            child: Text(
              l10n.orActivateLicense,
              style: AppTypography.bodyM.copyWith(
                color: primaryGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    Locale locale,
    ThemeMode themeMode,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final isArabic = locale.languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.md),
          child: AutoSizeText(
            l10n.settings,
            style: AppTypography.h3.copyWith(
              fontSize: 18.sp,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            maxLines: 1,
            minFontSize: 16.sp,
            stepGranularity: 1.sp,
          ),
        ),
        Card(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              // Language
              ListTile(
                leading: Icon(Icons.language, color: isDark ? AppColors.gold : AppColors.goldDark),
                title: Text(
                  l10n.language,
                  style: AppTypography.bodyL.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                subtitle: Text(
                  _getLanguageName(locale.languageCode, isArabic),
                  style: AppTypography.bodyM.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right, 
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: AppColors.darkSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
                    ),
                    builder: (context) => const LanguageSelectionSheet(),
                  );
                },
              ),
              Divider(
                height: 1, 
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              
              // Federal State
              ListTile(
                leading: Icon(Icons.location_on, color: isDark ? AppColors.gold : AppColors.goldDark),
                title: Text(
                  l10n.federalState,
                  style: AppTypography.bodyL.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                subtitle: FutureBuilder<String?>(
                  future: UserPreferencesService.getSelectedState(),
                  builder: (context, snapshot) {
                    final state = snapshot.data ?? (isArabic ? 'غير محدد' : 'Not Set');
                    return Text(
                      state,
                      style: AppTypography.bodyM.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    );
                  },
                ),
                trailing: Icon(
                  Icons.chevron_right, 
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: AppColors.darkSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
                    ),
                    builder: (context) => const StateSelectionSheet(),
                  );
                },
              ),
              Divider(
                height: 1, 
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              
              // Dark Mode
              ListTile(
                leading: Icon(Icons.dark_mode, color: isDark ? AppColors.gold : AppColors.goldDark),
                title: Text(
                  l10n.darkMode,
                  style: AppTypography.bodyL.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                  activeThumbColor: isDark ? AppColors.gold : AppColors.goldDark,
                ),
              ),
              Divider(
                height: 1, 
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              
              // Speaking Speed (TTS)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.speed, color: isDark ? AppColors.gold : AppColors.goldDark, size: 24.sp),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              l10n.speakingSpeed,
                              style: AppTypography.bodyL.copyWith(
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_ttsSpeed.toStringAsFixed(1)}x',
                          style: AppTypography.bodyL.copyWith(
                            color: isDark ? AppColors.gold : AppColors.goldDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Slider(
                      value: _ttsSpeed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      label: '${_ttsSpeed.toStringAsFixed(1)}x',
                      activeColor: isDark ? AppColors.gold : AppColors.goldDark,
                      inactiveColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                      onChanged: (value) {
                        _saveTtsSpeed(value);
                      },
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1, 
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              
              // Daily Reminder
              ListTile(
                leading: Icon(Icons.notifications, color: isDark ? AppColors.gold : AppColors.goldDark),
                title: Text(
                  l10n.dailyReminder,
                  style: AppTypography.bodyL.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                subtitle: _isReminderEnabled
                    ? Text(
                        '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                        style: AppTypography.bodyM.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      )
                    : null,
                trailing: Switch(
                  value: _isReminderEnabled,
                  onChanged: (value) async {
                    setState(() {
                      _isReminderEnabled = value;
                    });
                    await UserPreferencesService.saveReminderEnabled(value);
                    if (value) {
                      await NotificationService.scheduleDailyNotification(_reminderTime);
                    } else {
                      await NotificationService.cancelNotification(1); // _dailyReminderId
                    }
                  },
                  activeThumbColor: isDark ? AppColors.gold : AppColors.goldDark,
                ),
                onTap: _isReminderEnabled
                    ? () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: _reminderTime,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: isDark ? AppColors.gold : AppColors.goldDark,
                                  onPrimary: isDark ? AppColors.darkBg : AppColors.lightTextPrimary,
                                  surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                                  onSurface: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedTime != null && mounted) {
                          setState(() {
                            _reminderTime = pickedTime;
                          });
                          await UserPreferencesService.saveReminderTime(pickedTime);
                          await NotificationService.scheduleDailyNotification(pickedTime);
                        }
                      }
                    : null,
              ),
              Divider(
                height: 1, 
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              
              // Privacy Policy
              ListTile(
                leading: Icon(Icons.privacy_tip, color: isDark ? AppColors.gold : AppColors.goldDark),
                title: Text(
                  l10n.privacyPolicy,
                  style: AppTypography.bodyL.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right, 
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LegalScreen(),
                    ),
                  );
                },
              ),
              Divider(
                height: 1, 
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              
              // About App
              ListTile(
                leading: Icon(Icons.info_outline, color: isDark ? AppColors.gold : AppColors.goldDark),
                title: Text(
                  l10n.about,
                  style: AppTypography.bodyL.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right, 
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getLanguageName(String code, bool isArabic) {
    final names = {
      'en': isArabic ? 'الإنجليزية' : 'English',
      'de': isArabic ? 'الألمانية' : 'Deutsch',
      'ar': isArabic ? 'العربية' : 'Arabic',
      'tr': isArabic ? 'التركية' : 'Türkçe',
      'uk': isArabic ? 'الأوكرانية' : 'Українська',
      'ru': isArabic ? 'الروسية' : 'Русский',
    };
    return names[code] ?? code;
  }
}

