import 'dart:math' as math;
import 'package:flutter/foundation.dart' show listEquals;
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

/// An animated 270-degree circular gauge.
///
/// The arc opens at the bottom, like an automotive dial: it starts at the
/// lower left, sweeps clockwise over the top, and ends at the lower right.
///
/// ```dart
/// CircularGauge(
///   value: 0.92,
///   gradientColors: const [AppColors.primary, AppColors.primaryGlow],
///   child: const Text('92%'),
/// )
/// ```
class CircularGauge extends StatelessWidget {
  const CircularGauge({
    super.key,
    required this.value,
    required this.gradientColors,
    this.child,
    this.size = 160,
    this.strokeWidth = 14,
    this.trackColor = AppColors.glassBorder,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutCubic,
    this.semanticLabel,
  }) : assert(gradientColors.length >= 2, 'Provide at least two colours.');

  /// Fill level from 0.0 (empty) to 1.0 (full). Values outside the range
  /// are clamped.
  final double value;

  /// Colours of the progress arc, from the start of the dial to the end.
  /// At least two colours are required.
  final List<Color> gradientColors;

  /// Widget drawn in the centre of the dial.
  final Widget? child;

  /// Width and height of the gauge in logical pixels.
  final double size;

  /// Thickness of the arc.
  final double strokeWidth;

  /// Colour of the unfilled track behind the progress arc.
  final Color trackColor;

  /// Duration of the fill animation.
  final Duration duration;

  /// Easing of the fill animation.
  final Curve curve;

  /// Accessibility description, for example "Battery 92 percent".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final target = value.clamp(0.0, 1.0);

    // Honour the platform "remove animations" accessibility setting.
    final animationDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : duration;

    return Semantics(
      label: semanticLabel,
      container: true,
      child: SizedBox.square(
        dimension: size,
        child: TweenAnimationBuilder<double>(
          // `begin` is used on the first build only. Afterwards the tween
          // animates from the currently shown value to the new target.
          tween: Tween<double>(begin: 0, end: target),
          duration: animationDuration,
          curve: curve,
          builder: (context, animatedValue, child) {
            return CustomPaint(
              painter: _GaugePainter(
                progress: animatedValue,
                gradientColors: gradientColors,
                trackColor: trackColor,
                strokeWidth: strokeWidth,
              ),
              child: child,
            );
          },
          // The centre widget does not depend on the animation value, so it
          // is passed as `child` and built only once per rebuild.
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Paints the track, the gradient progress arc, its glow, and the end knob.
class _GaugePainter extends CustomPainter {
  const _GaugePainter({
    required this.progress,
    required this.gradientColors,
    required this.trackColor,
    required this.strokeWidth,
  });

  /// Current animated fill, 0.0 to 1.0.
  final double progress;
  final List<Color> gradientColors;
  final Color trackColor;
  final double strokeWidth;

  /// Arc starts at the lower left (135 degrees, measured clockwise from the
  /// 3 o'clock position in Flutter's coordinate system).
  static const double _startAngle = 3 * math.pi / 4;

  /// Total sweep of the dial: 270 degrees.
  static const double _sweepAngle = 3 * math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Track: the full empty dial.
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawArc(rect, _startAngle, _sweepAngle, false, trackPaint);

    if (progress <= 0) return;

    final progressSweep = _sweepAngle * progress;

    // The gradient spans the whole dial, so the colour at any point on the
    // arc is stable while the arc grows.
    final shader = SweepGradient(
      startAngle: 0,
      endAngle: _sweepAngle,
      colors: gradientColors,
      transform: const GradientRotation(_startAngle),
    ).createShader(rect);

    // 2. Glow: the same arc, blurred and translucent, drawn underneath.
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4
      ..strokeCap = StrokeCap.round
      ..shader = shader
      ..color = Colors.white.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawArc(rect, _startAngle, progressSweep, false, glowPaint);

    // 3. Progress arc.
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = shader;
    canvas.drawArc(rect, _startAngle, progressSweep, false, progressPaint);

    // 4. Knob at the tip of the arc.
    final tipAngle = _startAngle + progressSweep;
    final tip = Offset(
      center.dx + radius * math.cos(tipAngle),
      center.dy + radius * math.sin(tipAngle),
    );
    final knobPaint = Paint()..color = Colors.white;
    canvas.drawCircle(tip, strokeWidth * 0.26, knobPaint);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor ||
        !listEquals(oldDelegate.gradientColors, gradientColors);
  }
}