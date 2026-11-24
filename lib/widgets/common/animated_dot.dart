import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme.dart';

/// A small status dot with an optional looping "radar pulse".
///
/// Typical use: green and pulsing when connected, orange while connecting,
/// grey and still when disconnected.
///
/// ```dart
/// const AnimatedDot()                                    // green, pulsing
/// const AnimatedDot(color: AppColors.warning)            // orange, pulsing
/// const AnimatedDot(color: AppColors.textMuted, isPulsing: false)
/// ```
class AnimatedDot extends StatelessWidget {
  const AnimatedDot({
    super.key,
    this.color = AppColors.success,
    this.size = 10,
    this.isPulsing = true,
  });

  /// Colour of the dot, its glow, and the pulse ring.
  final Color color;

  /// Diameter of the solid core in logical pixels.
  final double size;

  /// Whether the pulse ring animates. The core dot is always drawn.
  final bool isPulsing;

  /// Duration of one pulse cycle.
  static const Duration _pulseDuration = Duration(milliseconds: 1600);

  /// How far the ring expands, as a multiple of [size].
  static const double _pulseScale = 2.6;

  @override
  Widget build(BuildContext context) {
    // Honour the platform "remove animations" accessibility setting.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final shouldPulse = isPulsing && !reduceMotion;

    // The dot is purely decorative. The status text next to it carries the
    // meaning for screen readers.
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          // The ring grows beyond the layout box without taking up space.
          clipBehavior: Clip.none,
          children: [
            if (shouldPulse)
              SizedBox.square(
                dimension: size,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.45),
                  ),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scaleXY(
                    begin: 1,
                    end: _pulseScale,
                    duration: _pulseDuration,
                    curve: Curves.easeOut,
                  )
                  .fadeOut(
                    duration: _pulseDuration,
                    curve: Curves.easeOut,
                  ),
            // Solid core with a soft glow.
            SizedBox.square(
              dimension: size,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.6),
                      blurRadius: size * 0.9,
                      spreadRadius: size * 0.05,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}