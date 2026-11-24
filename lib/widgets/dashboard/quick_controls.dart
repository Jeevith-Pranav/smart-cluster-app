import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme.dart';
import '../common/glass_card.dart';

/// Panel with the four vehicle quick controls.
///
/// * Horn and Locate are momentary: they light up while [isHornActive] or
///   [isLocating] is true.
/// * Hazard and Headlights are toggles: they stay lit while on.
///
/// ```dart
/// QuickControls(
///   isHornActive: false,
///   isHazardOn: false,
///   isHeadlightsOn: true,
///   isLocating: false,
///   onHorn: () {},
///   onHazard: () {},
///   onHeadlights: () {},
///   onLocate: () {},
/// )
/// ```
class QuickControls extends StatelessWidget {
  const QuickControls({
    super.key,
    required this.isHornActive,
    required this.isHazardOn,
    required this.isHeadlightsOn,
    required this.isLocating,
    required this.onHorn,
    required this.onHazard,
    required this.onHeadlights,
    required this.onLocate,
  });

  /// True briefly after the horn is pressed.
  final bool isHornActive;

  /// Whether the hazard lights are on.
  final bool isHazardOn;

  /// Whether the headlights are on.
  final bool isHeadlightsOn;

  /// True while the locate-vehicle signal is running.
  final bool isLocating;

  /// Called when Horn is tapped.
  final VoidCallback onHorn;

  /// Called when Hazard is tapped.
  final VoidCallback onHazard;

  /// Called when Headlights is tapped.
  final VoidCallback onHeadlights;

  /// Called when Locate Vehicle is tapped.
  final VoidCallback onLocate;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      _ControlButton(
        label: 'Horn',
        icon: Icons.campaign_rounded,
        activeColor: AppColors.primaryGlow,
        isActive: isHornActive,
        onTap: onHorn,
      ),
      _ControlButton(
        label: 'Hazard',
        icon: Icons.warning_rounded,
        activeColor: AppColors.warning,
        isActive: isHazardOn,
        isToggle: true,
        pulseWhenActive: true,
        onTap: onHazard,
      ),
      _ControlButton(
        label: 'Headlights',
        icon: Icons.highlight_rounded,
        activeColor: AppColors.primary,
        isActive: isHeadlightsOn,
        isToggle: true,
        onTap: onHeadlights,
      ),
      _ControlButton(
        label: 'Locate',
        icon: Icons.my_location_rounded,
        activeColor: AppColors.success,
        isActive: isLocating,
        pulseWhenActive: true,
        onTap: onLocate,
        semanticLabel: 'Locate vehicle',
      ),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(child: buttons[i]),
          ],
        ],
      ),
    );
  }
}

/// One square-ish control button with an icon and a label.
///
/// Lighter than a [GlassCard] (no blur), because four of them sit inside a
/// card that already blurs the background.
class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.label,
    required this.icon,
    required this.activeColor,
    required this.isActive,
    required this.onTap,
    this.isToggle = false,
    this.pulseWhenActive = false,
    this.semanticLabel,
  });

  /// Text under the icon.
  final String label;

  /// Icon shown above the label.
  final IconData icon;

  /// Accent colour while active.
  final Color activeColor;

  /// Whether the control is currently lit.
  final bool isActive;

  /// Called on tap, after a light haptic tick.
  final VoidCallback onTap;

  /// True for on/off controls. Exposes on/off state to screen readers.
  final bool isToggle;

  /// Whether the icon breathes while active (hazard, locate).
  final bool pulseWhenActive;

  /// Overrides [label] for screen readers when it is too short to be clear.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final radius = BorderRadius.circular(AppRadius.md);
    final color = isActive ? activeColor : AppColors.textSecondary;

    Widget iconWidget = Icon(icon, size: 26, color: color);
    if (isActive && pulseWhenActive && !reduceMotion) {
      iconWidget = iconWidget
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .fade(begin: 0.4, end: 1, duration: 600.ms);
    }

    void handleTap() {
      HapticFeedback.lightImpact();
      onTap();
    }

    return Semantics(
      button: true,
      // Null for momentary controls, so they are not announced as switches.
      toggled: isToggle ? isActive : null,
      label: semanticLabel ?? label,
      onTap: handleTap,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.18)
                : AppColors.glassFill,
            borderRadius: radius,
            border: Border.all(
              color: isActive
                  ? activeColor.withValues(alpha: 0.55)
                  : AppColors.glassBorder,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.30),
                      blurRadius: 16,
                    ),
                  ]
                : const [],
          ),
          // Material sits inside the decorated box, so the ripple paints
          // above the background colour.
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: handleTap,
              borderRadius: radius,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.lg,
                  horizontal: AppSpacing.xs,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    iconWidget,
                    const SizedBox(height: AppSpacing.sm),
                    // Shrinks long labels such as "Headlights" on narrow
                    // phones instead of overflowing.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: textTheme.labelMedium?.copyWith(
                          color: isActive
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}