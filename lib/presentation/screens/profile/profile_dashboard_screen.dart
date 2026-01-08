import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
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
    
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.vpn_key, color: AppColors.eagleGold, size: 28.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: AutoSizeText(
                l10n.activateLicense,
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.white70,
              ),
              maxLines: 2,
              minFontSize: 12.sp,
              stepGranularity: 1.sp,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: licenseKeyController,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: l10n.licenseKey,
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white38,
                ),
                filled: true,
                fillColor: AppColors.darkCharcoal,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.eagleGold),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.eagleGold, width: 2),
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
              style: GoogleFonts.poppins(
                color: Colors.white70,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // TODO: Call activate_license RPC in Supabase
              // For now, show a message
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.setupComplete,
                    ),
                    backgroundColor: AppColors.eagleGold,
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.eagleGold,
              foregroundColor: AppColors.darkSurface,
            ),
            child: Text(
              l10n.activateLicense,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
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
          
          SizedBox(height: 24.h),
          
          // KPI Section
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 100),
            child: _buildKpiSection(context, readinessAsync, l10n),
          ),
          
          SizedBox(height: 24.h),
          
          // Action Section (Only for Free users)
          if (!isPro)
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 200),
              child: _buildActionSection(context, l10n),
            ),
          
          if (!isPro) SizedBox(height: 24.h),
          
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
          
          SizedBox(height: 24.h),
          
          // Leaderboard Section
          const LeaderboardCard(),
          
          SizedBox(height: 24.h), // Bottom padding
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isArabic 
                ? 'يمكنك تغيير الاسم مرة واحدة فقط في الخطة المجانية. ترقية إلى Pro لتغيير الاسم بدون حدود.'
                : 'You can only change your name once in the free plan. Upgrade to Pro for unlimited name changes.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: isArabic ? 'ترقية' : 'Upgrade',
                textColor: Colors.white,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(name.isEmpty 
            ? l10n.nameRemoved
            : l10n.nameSaved),
          backgroundColor: Colors.green,
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
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.eagleGold.withValues(alpha: 0.2),
            AppColors.eagleGold.withValues(alpha: 0.1),
            AppColors.darkCharcoal,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.eagleGold.withValues(alpha: 0.3),
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
                        color: AppColors.eagleGold.withValues(alpha: 0.2),
                        border: Border.all(
                          color: AppColors.eagleGold,
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
                            color: AppColors.eagleGold,
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
                          color: AppColors.eagleGold,
                          border: Border.all(color: AppColors.darkSurface, width: 2),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 14.sp,
                          color: AppColors.darkSurface,
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
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.enterYourName,
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: Colors.white70,
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
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: Colors.white70,
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
                            padding: EdgeInsets.only(top: 4.h),
                            child: AutoSizeText(
                              isArabic 
                                ? 'تم تغيير الاسم مرة واحدة (الخطة المجانية)'
                                : 'Name changed once (Free plan)',
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                color: Colors.orange,
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
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isPro
                        ? AppColors.eagleGold
                        : Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isPro ? '🥇' : '⚪',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: AutoSizeText(
                          isPro ? l10n.proMember : l10n.freePlan,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: isPro ? AppColors.darkSurface : Colors.white,
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
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        minFontSize: 9.sp,
                        stepGranularity: 1.sp,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
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
                      activeThumbColor: AppColors.eagleGold,
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
            iconColor: Colors.blue,
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
        
        SizedBox(width: 12.w),
        
        // Card 2: Streak
        Expanded(
          child: _buildKpiCard(
            context,
            icon: Icons.local_fire_department,
            iconColor: Colors.orange,
            title: l10n.streak,
            value: _isLoadingStats ? '...' : '$_streak',
            subtitle: 'Days',
            showProgress: false,
          ),
        ),
        
        SizedBox(width: 12.w),
        
        // Card 3: Mastery
        Expanded(
          child: _buildKpiCard(
            context,
            icon: Icons.check_circle,
            iconColor: Colors.green,
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
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.darkCharcoal,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.shade800,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 32.sp),
          SizedBox(height: 12.h),
          if (showProgress && progress != null)
            CircularPercentIndicator(
              radius: 30.r,
              lineWidth: 4.w,
              percent: progress.clamp(0.0, 1.0),
              center: AutoSizeText(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                minFontSize: 14.sp,
                stepGranularity: 1.sp,
              ),
              progressColor: iconColor,
              backgroundColor: Colors.grey.shade800,
            )
          else
            AutoSizeText(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              minFontSize: 18.sp,
              stepGranularity: 1.sp,
            ),
          SizedBox(height: 8.h),
          AutoSizeText(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.white70,
            ),
            maxLines: 1,
            minFontSize: 10.sp,
            stepGranularity: 1.sp,
          ),
          AutoSizeText(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              color: Colors.white54,
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
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.eagleGold.withValues(alpha: 0.2),
            AppColors.eagleGold.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.eagleGold,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          AutoSizeText(
            l10n.upgradeAccount,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            minFontSize: 16.sp,
            stepGranularity: 1.sp,
          ),
          SizedBox(height: 12.h),
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
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.eagleGold,
              foregroundColor: AppColors.darkSurface,
              padding: EdgeInsets.symmetric(
                horizontal: 32.w,
                vertical: 16.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: _showLicenseActivationDialog,
            child: Text(
              l10n.orActivateLicense,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: AppColors.eagleGold,
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
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: AutoSizeText(
            l10n.settings,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            minFontSize: 16.sp,
            stepGranularity: 1.sp,
          ),
        ),
        Card(
          color: AppColors.darkCharcoal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              // Language
              ListTile(
                leading: const Icon(Icons.language, color: AppColors.eagleGold),
                title: Text(
                  l10n.language,
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                subtitle: Text(
                  _getLanguageName(locale.languageCode, isArabic),
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
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
              Divider(height: 1, color: Colors.grey.shade800),
              
              // Federal State
              ListTile(
                leading: const Icon(Icons.location_on, color: AppColors.eagleGold),
                title: Text(
                  l10n.federalState,
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                subtitle: FutureBuilder<String?>(
                  future: UserPreferencesService.getSelectedState(),
                  builder: (context, snapshot) {
                    final state = snapshot.data ?? (isArabic ? 'غير محدد' : 'Not Set');
                    return Text(
                      state,
                      style: GoogleFonts.poppins(color: Colors.white70),
                    );
                  },
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
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
              Divider(height: 1, color: Colors.grey.shade800),
              
              // Dark Mode
              ListTile(
                leading: const Icon(Icons.dark_mode, color: AppColors.eagleGold),
                title: Text(
                  l10n.darkMode,
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                  activeThumbColor: AppColors.eagleGold,
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade800),
              
              // Speaking Speed (TTS)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.speed, color: AppColors.eagleGold, size: 24.sp),
                            SizedBox(width: 12.w),
                            Text(
                              l10n.speakingSpeed,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_ttsSpeed.toStringAsFixed(1)}x',
                          style: GoogleFonts.poppins(
                            color: AppColors.eagleGold,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Slider(
                      value: _ttsSpeed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      label: '${_ttsSpeed.toStringAsFixed(1)}x',
                      activeColor: AppColors.eagleGold,
                      inactiveColor: Colors.grey.shade700,
                      onChanged: (value) {
                        _saveTtsSpeed(value);
                      },
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade800),
              
              // Daily Reminder
              ListTile(
                leading: const Icon(Icons.notifications, color: AppColors.eagleGold),
                title: Text(
                  l10n.dailyReminder,
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                subtitle: _isReminderEnabled
                    ? Text(
                        '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.poppins(color: Colors.white70),
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
                  activeThumbColor: AppColors.eagleGold,
                ),
                onTap: _isReminderEnabled
                    ? () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: _reminderTime,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.eagleGold,
                                  onPrimary: AppColors.darkSurface,
                                  surface: AppColors.darkCharcoal,
                                  onSurface: Colors.white,
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
              Divider(height: 1, color: Colors.grey.shade800),
              
              // Privacy Policy
              ListTile(
                leading: const Icon(Icons.privacy_tip, color: AppColors.eagleGold),
                title: Text(
                  l10n.privacyPolicy,
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LegalScreen(),
                    ),
                  );
                },
              ),
              Divider(height: 1, color: Colors.grey.shade800),
              
              // About App
              ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.eagleGold),
                title: Text(
                  l10n.about,
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
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

