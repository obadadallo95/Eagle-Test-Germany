import 'package:flutter/material.dart';

/// Eagle Test Germany - Design System Colors v3.0
/// Supports both Dark and Light themes
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIMARY BRAND COLORS (Shared between themes)
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Primary Gold - Main brand color
  static const Color gold = Color(0xFFD4AF37);
  
  /// Gold Light - Hover states in dark mode
  static const Color goldLight = Color(0xFFE5C158);
  
  /// Gold Dark - Text/Icons in light mode (better contrast)
  static const Color goldDark = Color(0xFFB59020);
  
  /// Gold Darker - High contrast text on white
  static const Color goldDarker = Color(0xFF8B7355);

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  
  // Success (Correct answers)
  static const Color successDark = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF2E7D32);
  static const Color successBgDark = Color(0x334CAF50);  // 20% opacity
  static const Color successBgLight = Color(0x264CAF50); // 15% opacity
  
  // Error (Wrong answers)
  static const Color errorDark = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFD32F2F);
  static const Color errorBgDark = Color(0x33F44336);
  static const Color errorBgLight = Color(0x26F44336);
  
  // Warning (Hints, pending)
  static const Color warningDark = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFED6C02);
  static const Color warningBgDark = Color(0x33FF9800);
  static const Color warningBgLight = Color(0x26FF9800);
  
  // Info (Links, information)
  static const Color infoDark = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF0288D1);
  static const Color infoBgDark = Color(0x332196F3);
  static const Color infoBgLight = Color(0x262196F3);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🌙 DARK MODE COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Dark mode background
  static const Color darkBg = Color(0xFF0D0D12);
  
  /// Dark mode surface (cards, panels)
  static const Color darkSurface = Color(0xFF1A1A24);
  
  /// Dark mode elevated surface (hover states)
  static const Color darkElevated = Color(0xFF252530);
  
  /// Dark mode surface variant
  static const Color darkSurfaceVariant = Color(0xFF2A2A36);
  
  // Dark mode text colors
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static Color darkTextSecondary = Colors.white.withValues(alpha: 0.6);
  static Color darkTextTertiary = Colors.white.withValues(alpha: 0.4);
  static Color darkTextDisabled = Colors.white.withValues(alpha: 0.2);
  
  // Dark mode borders
  static Color darkBorder = Colors.white.withValues(alpha: 0.1);
  static Color darkBorderHover = Colors.white.withValues(alpha: 0.2);
  static Color darkBorderFocus = gold;
  static Color darkDivider = Colors.white.withValues(alpha: 0.05);

  // ═══════════════════════════════════════════════════════════════════════════
  // ☀️ LIGHT MODE COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Light mode background
  static const Color lightBg = Color(0xFFFFFFFF);
  
  /// Light mode surface (cards, panels)
  static const Color lightSurface = Color(0xFFF5F5F7);
  
  /// Light mode elevated surface
  static const Color lightElevated = Color(0xFFFFFFFF);
  
  /// Light mode surface variant
  static const Color lightSurfaceVariant = Color(0xFFEBEBED);
  
  // Light mode text colors
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightTextTertiary = Color(0xFF999999);
  static const Color lightTextDisabled = Color(0xFFCCCCCC);
  
  // Light mode borders
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightBorderHover = Color(0xFFCCCCCC);
  static const Color lightBorderFocus = gold;
  static const Color lightDivider = Color(0xFFE0E0E0);
  
  // Light mode shadows
  static Color lightShadow = Colors.black.withValues(alpha: 0.08);

  // ═══════════════════════════════════════════════════════════════════════════
  // LEGACY COLORS (للتوافق مع الكود القديم)
  // ═══════════════════════════════════════════════════════════════════════════
  
  @Deprecated('Use AppColors.gold instead')
  static const Color primaryGold = gold;
  
  @Deprecated('Use AppColors.gold instead')
  static const Color eagleGold = gold;
  
  @Deprecated('Use AppColors.errorDark instead')
  static const Color primaryRed = Color(0xFFDD0000);
  
  @Deprecated('Use AppColors.errorDark instead')
  static const Color germanRed = Color(0xFFFF0000);
  
  @Deprecated('Use AppColors.darkBg instead')
  static const Color primaryBlack = Color(0xFF000000);
  
  @Deprecated('Use AppColors.darkBg instead')
  static const Color deepBlack = Color(0xFF121212);
  
  @Deprecated('Use AppColors.darkSurface instead')
  static const Color darkCharcoal = Color(0xFF1E1E2C);
  
  @Deprecated('Use AppColors.successDark instead')
  static const Color correctGreen = Color(0xFF4CAF50);
  
  @Deprecated('Use AppColors.errorDark instead')
  static const Color wrongRed = Color(0xFFE53935);

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Get semantic color based on brightness
  static Color success(Brightness brightness) =>
      brightness == Brightness.dark ? successDark : successLight;
  
  static Color error(Brightness brightness) =>
      brightness == Brightness.dark ? errorDark : errorLight;
  
  static Color warning(Brightness brightness) =>
      brightness == Brightness.dark ? warningDark : warningLight;
  
  static Color info(Brightness brightness) =>
      brightness == Brightness.dark ? infoDark : infoLight;
  
  /// Get background color based on brightness
  static Color background(Brightness brightness) =>
      brightness == Brightness.dark ? darkBg : lightBg;
  
  /// Get surface color based on brightness
  static Color surface(Brightness brightness) =>
      brightness == Brightness.dark ? darkSurface : lightSurface;
  
  /// Get primary text color based on brightness
  static Color textPrimary(Brightness brightness) =>
      brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;
  
  /// Get secondary text color based on brightness
  static Color textSecondary(Brightness brightness) =>
      brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;
  
  /// Get border color based on brightness
  static Color border(Brightness brightness) =>
      brightness == Brightness.dark ? darkBorder : lightBorder;
  
  /// Get gold color for text (darker in light mode for contrast)
  static Color goldText(Brightness brightness) =>
      brightness == Brightness.dark ? gold : goldDark;
}
