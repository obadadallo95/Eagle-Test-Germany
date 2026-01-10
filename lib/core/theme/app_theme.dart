import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// Eagle Test Germany - Theme System v3.0
/// Supports both Dark and Light themes
class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════════════
  // 🌙 DARK THEME
  // ═══════════════════════════════════════════════════════════════════════════
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      
      // Colors
      scaffoldBackgroundColor: AppColors.darkBg,
      primaryColor: AppColors.gold,
      
      colorScheme: ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.goldLight,
        surface: AppColors.darkSurface,
        error: AppColors.errorDark,
        onPrimary: AppColors.darkBg,
        onSecondary: AppColors.darkBg,
        onSurface: AppColors.darkTextPrimary,
        onError: Colors.white,
        outline: AppColors.darkBorder,
        surfaceContainerHighest: AppColors.darkElevated,
      ),
      
      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.h2.copyWith(color: AppColors.darkTextPrimary),
        iconTheme: const IconThemeData(
          color: AppColors.darkTextPrimary,
          size: AppSpacing.iconLg,
        ),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.cardRadius,
          side: BorderSide(color: AppColors.darkBorder),
        ),
      ),
      
      // Elevated Button (Primary)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.darkBg,
          disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.4),
          disabledForegroundColor: AppColors.darkTextDisabled,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeightLarge),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.buttonRadius),
          textStyle: AppTypography.button,
          elevation: 0,
        ),
      ),
      
      // Outlined Button (Secondary)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeightMedium),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: BorderSide(color: AppColors.darkBorderHover),
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.buttonRadius),
          textStyle: AppTypography.button,
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold,
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface.withValues(alpha: 0.4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.buttonRadius,
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.buttonRadius,
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.buttonRadius,
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.buttonRadius,
          borderSide: const BorderSide(color: AppColors.errorDark, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.buttonRadius,
          borderSide: const BorderSide(color: AppColors.errorDark, width: 2),
        ),
        hintStyle: AppTypography.bodyM.copyWith(color: AppColors.darkTextTertiary),
        labelStyle: AppTypography.label.copyWith(color: AppColors.darkTextSecondary),
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkBg,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.bodyS.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.bodyS,
        elevation: 0,
      ),
      
      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkBg,
        indicatorColor: AppColors.gold.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.gold, size: 24);
          }
          return IconThemeData(color: AppColors.darkTextSecondary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.bodyS.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.bodyS.copyWith(color: AppColors.darkTextSecondary);
        }),
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),
      
      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gold,
        linearTrackColor: Color(0xFF333333),
      ),
      
      // Snack Bar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurface,
        contentTextStyle: AppTypography.bodyM.copyWith(color: AppColors.darkTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.buttonRadius),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.cardRadius),
        titleTextStyle: AppTypography.h3.copyWith(color: AppColors.darkTextPrimary),
        contentTextStyle: AppTypography.bodyM.copyWith(color: AppColors.darkTextSecondary),
      ),
      
      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.bottomSheetRadius),
        modalBackgroundColor: AppColors.darkSurface,
      ),
      
      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.gold;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.darkBg),
        side: BorderSide(color: AppColors.darkBorderHover, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.gold;
          }
          return AppColors.darkTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.gold.withValues(alpha: 0.3);
          }
          return AppColors.darkBorder;
        }),
      ),
      
      // List Tile
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.darkTextSecondary,
        textColor: AppColors.darkTextPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.buttonRadius),
      ),
      
      // Text Theme
      textTheme: _buildTextTheme(Brightness.dark),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ☀️ LIGHT THEME
  // ═══════════════════════════════════════════════════════════════════════════
  
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      
      // Colors
      scaffoldBackgroundColor: AppColors.lightBg,
      primaryColor: AppColors.gold,
      
      colorScheme: const ColorScheme.light(
        primary: AppColors.gold,
        secondary: AppColors.goldDark,
        surface: AppColors.lightSurface,
        error: AppColors.errorLight,
        onPrimary: AppColors.lightTextPrimary,
        onSecondary: AppColors.lightTextPrimary,
        onSurface: AppColors.lightTextPrimary,
        onError: Colors.white,
        outline: AppColors.lightBorder,
        surfaceContainerHighest: AppColors.lightElevated,
      ),
      
      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: AppTypography.h2.copyWith(color: AppColors.lightTextPrimary),
        iconTheme: const IconThemeData(
          color: AppColors.lightTextPrimary,
          size: AppSpacing.iconLg,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      
      // Cards
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.cardRadius,
          side: const BorderSide(color: AppColors.lightBorder),
        ),
        shadowColor: AppColors.lightShadow,
      ),
      
      // Elevated Button (Primary)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.lightTextPrimary,
          disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.4),
          disabledForegroundColor: AppColors.lightTextDisabled,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeightLarge),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.buttonRadius),
          textStyle: AppTypography.button,
          elevation: 0,
        ),
      ),
      
      // Outlined Button (Secondary)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightTextPrimary,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeightMedium),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: const BorderSide(color: AppColors.lightBorder),
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.buttonRadius),
          textStyle: AppTypography.button,
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.goldDark, // Darker for readability
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.buttonRadius,
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.buttonRadius,
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.buttonRadius,
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.buttonRadius,
          borderSide: const BorderSide(color: AppColors.errorLight, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.buttonRadius,
          borderSide: const BorderSide(color: AppColors.errorLight, width: 2),
        ),
        hintStyle: AppTypography.bodyM.copyWith(color: AppColors.lightTextTertiary),
        labelStyle: AppTypography.label.copyWith(color: AppColors.lightTextSecondary),
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightBg,
        selectedItemColor: AppColors.goldDark, // Darker for contrast
        unselectedItemColor: AppColors.lightTextTertiary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.bodyS.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.bodyS,
        elevation: 8,
      ),
      
      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightBg,
        indicatorColor: AppColors.gold.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.goldDark, size: 24);
          }
          return const IconThemeData(color: AppColors.lightTextTertiary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.bodyS.copyWith(
              color: AppColors.goldDark,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.bodyS.copyWith(color: AppColors.lightTextTertiary);
        }),
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),
      
      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gold,
        linearTrackColor: AppColors.lightBorder,
      ),
      
      // Snack Bar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightTextPrimary,
        contentTextStyle: AppTypography.bodyM.copyWith(color: AppColors.lightBg),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.buttonRadius),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightBg,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.cardRadius),
        titleTextStyle: AppTypography.h3.copyWith(color: AppColors.lightTextPrimary),
        contentTextStyle: AppTypography.bodyM.copyWith(color: AppColors.lightTextSecondary),
      ),
      
      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.lightBg,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.bottomSheetRadius),
        modalBackgroundColor: AppColors.lightBg,
      ),
      
      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.gold;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.lightTextPrimary),
        side: const BorderSide(color: AppColors.lightBorderHover, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.gold;
          }
          return AppColors.lightTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.gold.withValues(alpha: 0.3);
          }
          return AppColors.lightBorder;
        }),
      ),
      
      // List Tile
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.lightTextSecondary,
        textColor: AppColors.lightTextPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.buttonRadius),
      ),
      
      // Text Theme
      textTheme: _buildTextTheme(Brightness.light),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT THEME BUILDER
  // ═══════════════════════════════════════════════════════════════════════════
  
  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color primaryColor = brightness == Brightness.dark 
        ? AppColors.darkTextPrimary 
        : AppColors.lightTextPrimary;
    final Color secondaryColor = brightness == Brightness.dark 
        ? AppColors.darkTextSecondary 
        : AppColors.lightTextSecondary;
    
    return TextTheme(
      // Display
      displayLarge: AppTypography.h1.copyWith(color: primaryColor),
      displayMedium: AppTypography.h2.copyWith(color: primaryColor),
      displaySmall: AppTypography.h3.copyWith(color: primaryColor),
      
      // Headlines
      headlineLarge: AppTypography.h1.copyWith(color: primaryColor),
      headlineMedium: AppTypography.h2.copyWith(color: primaryColor),
      headlineSmall: AppTypography.h3.copyWith(color: primaryColor),
      
      // Titles
      titleLarge: AppTypography.h3.copyWith(color: primaryColor),
      titleMedium: AppTypography.h4.copyWith(color: primaryColor),
      titleSmall: AppTypography.label.copyWith(color: primaryColor),
      
      // Body
      bodyLarge: AppTypography.bodyL.copyWith(color: primaryColor),
      bodyMedium: AppTypography.bodyM.copyWith(color: secondaryColor),
      bodySmall: AppTypography.bodyS.copyWith(color: secondaryColor),
      
      // Labels
      labelLarge: AppTypography.button.copyWith(color: primaryColor),
      labelMedium: AppTypography.badge.copyWith(color: secondaryColor),
      labelSmall: AppTypography.caption.copyWith(color: secondaryColor),
    );
  }
}
