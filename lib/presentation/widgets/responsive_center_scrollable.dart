import 'package:flutter/material.dart';

/// -----------------------------------------------------------------
/// 📏 RESPONSIVE CENTER SCROLLABLE / RESPONSIVE ZENTRIERT / قابل للتمرير والمركز
/// -----------------------------------------------------------------
/// A wrapper widget that constrains content width on large screens
/// and centers it, preventing UI from stretching too wide.
/// 
/// Usage:
/// ```dart
/// ResponsiveCenterScrollable(
///   child: Column(
///     children: [...],
///   ),
/// )
/// ```
/// -----------------------------------------------------------------
class ResponsiveCenterScrollable extends StatelessWidget {
  /// The child widget to wrap
  final Widget child;
  
  /// Maximum width constraint (default: 600)
  /// On screens wider than this, content will be centered with this max width
  final double maxWidth;
  
  /// Horizontal padding for the constrained content
  final double horizontalPadding;
  
  /// Whether to enable scrolling (default: true)
  final bool enableScroll;

  const ResponsiveCenterScrollable({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.horizontalPadding = 16,
    this.enableScroll = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );

    if (enableScroll) {
      content = SingleChildScrollView(
        child: content,
      );
    }

    return content;
  }
}

