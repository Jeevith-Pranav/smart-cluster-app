import 'dart:ui';

import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

/// A frosted-glass container.
///
/// Layers, from back to front:
///  1. soft drop shadow (outside the clip, so it is not cut off),
///  2. backdrop blur of whatever is behind the card,
///  3. translucent tint plus a diagonal sheen,
///  4. a hairline border,
///  5. optional ink ripple when [onTap] is set.
///
/// Usage:
/// ```dart
/// GlassCard(
///   padding: const EdgeInsets.all(20),
///   child: Text('Hello'),
/// )
/// ```
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.borderRadius = AppRadius.lg,
    this.blurSigma = 18,
    this.tint,
    this.gradient = AppGradients.glassSheen,
    this.borderColor = AppColors.glassBorder,
    this.onTap,
    this.semanticLabel,
  });

  /// Content shown inside the card.
  final Widget child;

  /// Space between the card edge and [child].
  final EdgeInsetsGeometry padding;

  /// Corner radius in logical pixels.
  final double borderRadius;

  /// Strength of the backdrop blur. Lower it on screens with many cards if
  /// performance matters on low-end devices.
  final double blurSigma;

  /// Fill colour. Defaults to [AppColors.glassFill]. Pass a tinted colour
  /// (for example a translucent blue) to emphasise a card.
  final Color? tint;

  /// Gradient laid over the fill. Pass `null` for a flat tint.
  final Gradient? gradient;

  /// Border colour.
  final Color borderColor;

  /// Called when the card is tapped. When null, the card is not interactive
  /// and shows no ripple.
  final VoidCallback? onTap;

  /// Optional accessibility label read by screen readers.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    Widget card = DecoratedBox(
      // The shadow lives outside the ClipRRect so the clip does not cut it.
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tint ?? AppColors.glassFill,
              gradient: gradient,
              borderRadius: radius,
              border: Border.all(color: borderColor),
            ),
            // Material provides the surface the ink ripple paints on.
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                borderRadius: radius,
                child: Padding(padding: padding, child: child),
              ),
            ),
          ),
        ),
      ),
    );

    if (semanticLabel != null) {
      card = Semantics(
        label: semanticLabel,
        button: onTap != null,
        container: true,
        child: card,
      );
    }

    return card;
  }
}