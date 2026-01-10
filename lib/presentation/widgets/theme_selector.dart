import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/services/theme_service.dart';
import '../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';

/// Theme selector widget for settings screen
/// Allows user to choose between Light, Dark, and System themes
class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme provider to rebuild on theme change
    ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final currentAppTheme = themeNotifier.appThemeMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          _buildOption(
            context,
            ref,
            icon: Icons.light_mode_rounded,
            label: l10n?.themeLight ?? 'Light',
            mode: AppThemeMode.light,
            isSelected: currentAppTheme == AppThemeMode.light,
            isDark: isDark,
          ),
          _buildOption(
            context,
            ref,
            icon: Icons.dark_mode_rounded,
            label: l10n?.themeDark ?? 'Dark',
            mode: AppThemeMode.dark,
            isSelected: currentAppTheme == AppThemeMode.dark,
            isDark: isDark,
          ),
          _buildOption(
            context,
            ref,
            icon: Icons.phone_android_rounded,
            label: l10n?.themeSystem ?? 'System',
            mode: AppThemeMode.system,
            isSelected: currentAppTheme == AppThemeMode.system,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required AppThemeMode mode,
    required bool isSelected,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          await ref.read(themeProvider.notifier).setAppThemeMode(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.darkBg
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.bodyS.copyWith(
                  color: isSelected
                      ? AppColors.darkBg
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact theme selector (icon only) for app bar
class ThemeSelectorCompact extends ConsumerWidget {
  const ThemeSelectorCompact({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final currentAppTheme = themeNotifier.appThemeMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData icon;
    switch (currentAppTheme) {
      case AppThemeMode.light:
        icon = Icons.light_mode_rounded;
        break;
      case AppThemeMode.dark:
        icon = Icons.dark_mode_rounded;
        break;
      case AppThemeMode.system:
        icon = Icons.brightness_auto_rounded;
        break;
    }

    return IconButton(
      icon: Icon(
        icon,
        color: isDark ? AppColors.gold : AppColors.goldDark,
      ),
      onPressed: () async {
        // Cycle through themes
        await themeNotifier.cycleTheme();
      },
      tooltip: ThemeService.getDisplayName(currentAppTheme),
    );
  }
}

/// Theme selector dialog
class ThemeSelectorDialog extends ConsumerWidget {
  const ThemeSelectorDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const ThemeSelectorDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final currentAppTheme = themeNotifier.appThemeMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(
            Icons.palette_rounded,
            color: AppColors.gold,
          ),
          const SizedBox(width: 12),
          Text(l10n?.themeTitle ?? 'Theme'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDialogOption(
            context,
            ref,
            icon: Icons.light_mode_rounded,
            title: l10n?.themeLight ?? 'Light',
            subtitle: l10n?.themeLightDesc ?? 'Bright theme for daytime study',
            mode: AppThemeMode.light,
            isSelected: currentAppTheme == AppThemeMode.light,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildDialogOption(
            context,
            ref,
            icon: Icons.dark_mode_rounded,
            title: l10n?.themeDark ?? 'Dark',
            subtitle: l10n?.themeDarkDesc ?? 'Dark theme for nighttime study',
            mode: AppThemeMode.dark,
            isSelected: currentAppTheme == AppThemeMode.dark,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildDialogOption(
            context,
            ref,
            icon: Icons.phone_android_rounded,
            title: l10n?.themeSystem ?? 'System',
            subtitle: l10n?.themeSystemDesc ?? 'Follow system settings',
            mode: AppThemeMode.system,
            isSelected: currentAppTheme == AppThemeMode.system,
            isDark: isDark,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.close ?? 'Close'),
        ),
      ],
    );
  }

  Widget _buildDialogOption(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required String subtitle,
    required AppThemeMode mode,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () async {
        await ref.read(themeProvider.notifier).setAppThemeMode(mode);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected
                ? AppColors.gold
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.gold
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.h4.copyWith(
                      color: isSelected
                          ? AppColors.gold
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodyS.copyWith(
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.gold,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

