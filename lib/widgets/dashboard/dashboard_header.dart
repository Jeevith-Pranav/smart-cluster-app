import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme.dart';
import '../../models/vehicle_model.dart';
import '../../utils/status_style.dart';
import '../common/animated_dot.dart';
import '../common/live_clock.dart';

/// Header of the dashboard: brand, vehicle name, clock, and info pills.
///
/// ```dart
/// const DashboardHeader(
///   vehicleName: 'Hyundai i20 Prototype',
///   connectionStatus: ConnectionStatus.connected,
///   temperatureCelsius: 32,
///   weatherCondition: 'Sunny',
///   location: 'Chennai',
/// )
/// ```
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.vehicleName,
    required this.connectionStatus,
    required this.temperatureCelsius,
    required this.weatherCondition,
    required this.location,
  });

  /// Display name of the vehicle.
  final String vehicleName;

  /// Current BLE link state.
  final ConnectionStatus connectionStatus;

  /// Outside temperature in degrees Celsius (dummy weather).
  final int temperatureCelsius;

  /// Short weather description (dummy weather), for example "Sunny".
  final String weatherCondition;

  /// City or area name.
  final String location;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final weather = _weatherStyle(weatherCondition);

    Widget header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand line with a small accent bar.
                  Row(
                    children: [
                      ExcludeSemantics(
                        child: Container(
                          width: 4,
                          height: 14,
                          decoration: BoxDecoration(
                            gradient: AppGradients.primary,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          'SMART CLUSTER',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            color: AppColors.primaryGlow,
                            letterSpacing: 3,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Semantics(
                    header: true,
                    child: Text(
                      vehicleName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.headlineSmall?.copyWith(
                        fontSize: 26,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            // Live time and date, aligned to the right edge.
            const LiveClock(),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _InfoPill(
              semanticLabel: connectionStatus.label,
              color: connectionStatus.color,
              label: connectionStatus.label,
              leading: AnimatedDot(
                color: connectionStatus.color,
                size: 8,
                isPulsing: connectionStatus.shouldPulse,
              ),
            ),
            _InfoPill(
              semanticLabel:
                  '$weatherCondition, $temperatureCelsius degrees Celsius',
              color: weather.color,
              label: '$temperatureCelsius°C · $weatherCondition',
              leading: Icon(weather.icon, size: 16, color: weather.color),
            ),
            _InfoPill(
              semanticLabel: 'Location $location',
              color: AppColors.primaryGlow,
              label: location,
              leading: const Icon(
                Icons.location_on_rounded,
                size: 16,
                color: AppColors.primaryGlow,
              ),
            ),
          ],
        ),
      ],
    );

    // One-time entrance animation, skipped when the user asks for less motion.
    if (!reduceMotion) {
      header = header
          .animate()
          .fadeIn(duration: 500.ms, curve: Curves.easeOut)
          .slideY(begin: -0.08, end: 0, duration: 500.ms, curve: Curves.easeOut);
    }

    return header;
  }
}

/// Icon and colour for a weather description. Dummy-data helper: it matches
/// on keywords so a future weather API can reuse it unchanged.
({IconData icon, Color color}) _weatherStyle(String condition) {
  final text = condition.toLowerCase();
  if (text.contains('storm')) {
    return (icon: Icons.thunderstorm_rounded, color: AppColors.warning);
  }
  if (text.contains('rain') || text.contains('shower')) {
    return (icon: Icons.water_drop_rounded, color: AppColors.primaryGlow);
  }
  if (text.contains('cloud')) {
    return (icon: Icons.cloud_rounded, color: AppColors.textSecondary);
  }
  if (text.contains('sun') || text.contains('clear')) {
    return (icon: Icons.wb_sunny_rounded, color: AppColors.warning);
  }
  return (icon: Icons.wb_cloudy_rounded, color: AppColors.textSecondary);
}

/// A small rounded pill with a leading widget and a label.
///
/// Lighter than a [GlassCard] (no blur), so several can sit in the header
/// without extra GPU cost.
class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.leading,
    required this.label,
    required this.color,
    required this.semanticLabel,
  });

  /// Icon or dot drawn before the label.
  final Widget leading;

  /// Text shown in the pill.
  final String label;

  /// Accent colour for the border tint and the leading widget.
  final Color color;

  /// What screen readers announce for the whole pill.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: semanticLabel,
      container: true,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm - 1,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                leading,
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}