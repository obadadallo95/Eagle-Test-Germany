import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../../core/theme/app_colors.dart';

/// -----------------------------------------------------------------
/// 🎉 CELEBRATION OVERLAY / FEIER-OVERLAY / طبقة الاحتفال
/// -----------------------------------------------------------------
/// Reusable confetti celebration overlay widget
/// يمكن استخدامه كـ Wrapper لأي شاشة لعرض الاحتفال
/// -----------------------------------------------------------------
class CelebrationOverlay extends StatefulWidget {
  final Widget child;
  final ConfettiController? confettiController;
  final bool autoPlay;
  final Duration duration;
  final List<Color>? colors;

  const CelebrationOverlay({
    super.key,
    required this.child,
    this.confettiController,
    this.autoPlay = false,
    this.duration = const Duration(seconds: 3),
    this.colors,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = widget.confettiController ?? ConfettiController(duration: widget.duration);
    
    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.play();
      });
    }
  }

  @override
  void dispose() {
    // Only dispose if we created it (not provided from outside)
    if (widget.confettiController == null) {
      _confettiController.dispose();
    }
    super.dispose();
  }

  /// Play confetti animation
  void play() {
    _confettiController.play();
  }

  /// Stop confetti animation
  void stop() {
    _confettiController.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Confetti Layer
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: widget.colors ?? const [
              AppColors.eagleGold,
              Colors.orange,
              Colors.red,
              Colors.pink,
              Colors.purple,
              Colors.blue,
              Colors.green,
              Colors.yellow,
            ],
            createParticlePath: (size) {
              final path = Path();
              path.addOval(Rect.fromCircle(center: Offset.zero, radius: size.width / 2));
              return path;
            },
          ),
        ),
      ],
    );
  }
}


