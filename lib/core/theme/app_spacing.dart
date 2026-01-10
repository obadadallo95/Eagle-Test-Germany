import 'package:flutter/material.dart';

/// Eagle Test Germany - Spacing System v3.0
/// Based on 4px grid for consistency
class AppSpacing {
  AppSpacing._();

  // ═══════════════════════════════════════════════════════════════════════════
  // BASE SPACING (4px Grid)
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// 2px - Micro adjustments
  static const double xxs = 2.0;
  
  /// 4px - Inline element gaps
  static const double xs = 4.0;
  
  /// 8px - Icon margins, small gaps
  static const double sm = 8.0;
  
  /// 12px - Default spacing between elements
  static const double md = 12.0;
  
  /// 16px - Card padding, standard gaps
  static const double lg = 16.0;
  
  /// 20px - Section spacing
  static const double xl = 20.0;
  
  /// 24px - Large gaps
  static const double xxl = 24.0;
  
  /// 32px - Major sections
  static const double xxxl = 32.0;
  
  /// 40px - Screen top/bottom
  static const double xxxxl = 40.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // SCREEN PADDING
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Horizontal screen padding (16px)
  static const double screenHorizontal = 16.0;
  
  /// Vertical screen padding (24px)
  static const double screenVertical = 24.0;
  
  /// Screen padding EdgeInsets
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
    vertical: screenVertical,
  );
  
  /// Horizontal only padding
  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // COMPONENT SPACING
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Card internal padding
  static const double cardPadding = lg;
  
  /// Gap between cards
  static const double cardGap = md;
  
  /// Gap between buttons
  static const double buttonGap = md;
  
  /// Gap between sections
  static const double sectionGap = xxl;
  
  /// Gap between list items
  static const double listItemGap = sm;
  
  /// Icon to text spacing
  static const double iconTextGap = sm;

  // ═══════════════════════════════════════════════════════════════════════════
  // RADIUS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Small radius (8px) - Buttons, inputs
  static const double radiusSm = 8.0;
  
  /// Medium radius (12px) - Cards
  static const double radiusMd = 12.0;
  
  /// Large radius (16px) - Bottom sheets, modals
  static const double radiusLg = 16.0;
  
  /// Extra large radius (20px) - Special elements
  static const double radiusXl = 20.0;
  
  /// Full radius (50%) - Avatars, badges
  static const double radiusFull = 100.0;
  
  /// Default card border radius
  static BorderRadius get cardRadius => BorderRadius.circular(radiusMd);
  
  /// Button border radius
  static BorderRadius get buttonRadius => BorderRadius.circular(radiusSm);
  
  /// Bottom sheet border radius
  static BorderRadius get bottomSheetRadius => const BorderRadius.vertical(
    top: Radius.circular(radiusLg),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // HEIGHTS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Button height - Large (52px)
  static const double buttonHeightLarge = 52.0;
  
  /// Button height - Medium (44px)
  static const double buttonHeightMedium = 44.0;
  
  /// Button height - Small (32px)
  static const double buttonHeightSmall = 32.0;
  
  /// Input field height (44px)
  static const double inputHeight = 44.0;
  
  /// App bar height (56px)
  static const double appBarHeight = 56.0;
  
  /// Bottom navigation height (56px)
  static const double bottomNavHeight = 56.0;
  
  /// Answer option height (56px)
  static const double answerOptionHeight = 56.0;
  
  /// Progress bar height (6px)
  static const double progressBarHeight = 6.0;
  
  /// Settings item height (48px)
  static const double settingsItemHeight = 48.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDTHS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Icon size - Small (16px)
  static const double iconSm = 16.0;
  
  /// Icon size - Medium (20px)
  static const double iconMd = 20.0;
  
  /// Icon size - Large (24px)
  static const double iconLg = 24.0;
  
  /// Icon size - Extra Large (32px)
  static const double iconXl = 32.0;
  
  /// Avatar size - Small (32px)
  static const double avatarSm = 32.0;
  
  /// Avatar size - Medium (48px)
  static const double avatarMd = 48.0;
  
  /// Avatar size - Large (80px)
  static const double avatarLg = 80.0;
  
  /// Progress ring size - Small (60px)
  static const double progressRingSm = 60.0;
  
  /// Progress ring size - Large (120px)
  static const double progressRingLg = 120.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Create EdgeInsets with all sides
  static EdgeInsets all(double value) => EdgeInsets.all(value);
  
  /// Create horizontal EdgeInsets
  static EdgeInsets horizontal(double value) => EdgeInsets.symmetric(horizontal: value);
  
  /// Create vertical EdgeInsets
  static EdgeInsets vertical(double value) => EdgeInsets.symmetric(vertical: value);
  
  /// Create symmetric EdgeInsets
  static EdgeInsets symmetric({double h = 0, double v = 0}) =>
      EdgeInsets.symmetric(horizontal: h, vertical: v);
  
  /// Create only EdgeInsets
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
  
  /// Vertical gap widget
  static SizedBox verticalGap(double height) => SizedBox(height: height);
  
  /// Horizontal gap widget
  static SizedBox horizontalGap(double width) => SizedBox(width: width);
}

// ═══════════════════════════════════════════════════════════════════════════
// EXTENSION FOR QUICK GAPS
// ═══════════════════════════════════════════════════════════════════════════

/// Quick gap widgets
extension GapExtension on num {
  /// Vertical gap
  SizedBox get vGap => SizedBox(height: toDouble());
  
  /// Horizontal gap
  SizedBox get hGap => SizedBox(width: toDouble());
}

