import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Eagle Gold Design System Colors
  static const Color _darkCharcoal = Color(0xFF1E1E2C);
  static const Color _eagleGold = Color(0xFFFFD700);
  static const Color _germanRed = Color(0xFFFF0000);
  static const Color _darkSurface = Color(0xFF2A2A3A);

  static ThemeData get lightTheme {
    // Light theme with Eagle Gold accents
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      visualDensity: VisualDensity.compact, // Compact UI density
      colorScheme: ColorScheme.fromSeed(
        seedColor: _eagleGold,
        brightness: Brightness.light,
        primary: _eagleGold,
        secondary: _germanRed,
        surface: Colors.grey.shade50,
        onPrimary: Colors.black,
        onSurface: Colors.black87,
      ),
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.light().textTheme.copyWith(
          headlineLarge: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24, // Reduced from default
          ),
          headlineMedium: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20, // Reduced from default
          ),
          titleLarge: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18, // Reduced from 20
          ),
          bodyLarge: GoogleFonts.poppins(
            color: Colors.black54,
            fontSize: 14, // Reduced from 16
          ),
          bodyMedium: GoogleFonts.poppins(
            color: Colors.black54,
            fontSize: 13, // Reduced from 14
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 18, // Reduced from 20
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _eagleGold,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Reduced padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2, // Flatter look
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Tighter margins
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Slightly smaller radius
          side: BorderSide(
            color: _eagleGold.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true, // Compact input fields
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced padding
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  static ThemeData get darkTheme {
    // Eagle Gold Dark Theme
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      visualDensity: VisualDensity.compact, // Compact UI density
      colorScheme: ColorScheme.fromSeed(
        seedColor: _eagleGold,
        brightness: Brightness.dark,
        primary: _eagleGold,
        secondary: _germanRed,
        surface: _darkSurface,
        onPrimary: Colors.black,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: _darkCharcoal,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme.copyWith(
          headlineLarge: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24, // Reduced from default
          ),
          headlineMedium: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20, // Reduced from default
          ),
          titleLarge: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18, // Reduced from 20
          ),
          bodyLarge: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 14, // Reduced from 16
          ),
          bodyMedium: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 13, // Reduced from 14
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18, // Reduced from 20
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _eagleGold,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Reduced padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 2, // Flatter look (reduced from 4)
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Tighter margins
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Slightly smaller radius
          side: BorderSide(
            color: _eagleGold.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true, // Compact input fields
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced padding
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: _darkSurface,
      ),
    );
  }
}
