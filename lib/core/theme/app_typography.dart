import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Eagle Test Germany - Typography System v3.0
/// Poppins for headings, Inter for body text
class AppTypography {
  AppTypography._();

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADINGS - Poppins (Geometric, friendly, modern)
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// H1 - Page titles, exam results
  /// 28px, Bold (700), Line height: 36px
  static TextStyle h1 = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.29, // 36px
    letterSpacing: -0.5,
  );
  
  /// H2 - Screen headers, section titles
  /// 24px, SemiBold (600), Line height: 32px
  static TextStyle h2 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33, // 32px
    letterSpacing: -0.3,
  );
  
  /// H3 - Card titles, modal headers
  /// 20px, SemiBold (600), Line height: 28px
  static TextStyle h3 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4, // 28px
    letterSpacing: -0.2,
  );
  
  /// H4 - Subheadings, labels
  /// 16px, Medium (500), Line height: 24px
  static TextStyle h4 = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5, // 24px
    letterSpacing: 0,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BODY TEXT - Inter (Clean, highly readable)
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Body Large - Questions, descriptions
  /// 16px, Regular (400), Line height: 24px
  static TextStyle bodyL = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5, // 24px
    letterSpacing: 0,
  );
  
  /// Body Medium - Standard UI text
  /// 14px, Regular (400), Line height: 22px
  static TextStyle bodyM = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.57, // 22px
    letterSpacing: 0,
  );
  
  /// Body Small - Captions, metadata
  /// 12px, Regular (400), Line height: 18px
  static TextStyle bodyS = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5, // 18px
    letterSpacing: 0,
  );
  
  /// Caption - Tiny text, credits
  /// 11px, Regular (400), Line height: 16px
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.45, // 16px
    letterSpacing: 0,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BUTTONS - Poppins
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Button - All buttons
  /// 14px, SemiBold (600), Line height: 20px
  static TextStyle button = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43, // 20px
    letterSpacing: 0.5,
  );
  
  /// Button Small - Small buttons
  /// 12px, SemiBold (600), Line height: 16px
  static TextStyle buttonSmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33, // 16px
    letterSpacing: 0.3,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BADGES & LABELS - Poppins
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Badge - Tags, status indicators
  /// 12px, Medium (500), Line height: 16px
  static TextStyle badge = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33, // 16px
    letterSpacing: 0,
  );
  
  /// Label - Form labels
  /// 14px, Medium (500), Line height: 20px
  static TextStyle label = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43, // 20px
    letterSpacing: 0,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SPECIAL STYLES
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Number Display - Large numbers (exam results, statistics)
  /// 32px, Bold (700)
  static TextStyle numberLarge = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  /// Percentage - Progress indicators
  /// 40px, Bold (700)
  static TextStyle percentage = GoogleFonts.poppins(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -1,
  );
  
  /// Monospace - For code or numbers that need alignment
  static TextStyle mono = GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Apply color to a text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// Make a style bold
  static TextStyle bold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w700);
  }
  
  /// Make a style semibold
  static TextStyle semiBold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w600);
  }
  
  /// Make a style medium
  static TextStyle medium(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w500);
  }
}

