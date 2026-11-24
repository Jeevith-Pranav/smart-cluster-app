import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme.dart';
import '../../models/vehicle_model.dart';
import '../../utils/status_style.dart';
import '../common/card_header.dart';
import '../common/glass_card.dart';
import '../common/metric_tile.dart';
import '../common/status_chip.dart';
import '../gauges/circular_gauge.dart';

/// Dashboard card showing battery charge, voltage, health, and charging state.
///
/// ```dart
/// const BatteryCard(
///   percent: 92,
///   voltage: 12.6,
///   health: HealthStatus.good,
///   isCharging: false,
/// )
/// ```
class BatteryCard extends StatelessWidget {
  const BatteryCard({
    super.key,
    required this.percent,
    required this.voltage,
    required this.health,
    required this.isCharging,
    this.onTap,
  });

  /// Battery state of charge, 0 to 100.
  final int percent;

  /// Battery voltage in volts.
  final double voltage;

  /// Overall battery health.
  final HealthStatus health;

  /// Whether the battery is currently charging.
  final bool isCharging;

  /// Optional tap handler, for example to open the Vehicle tab.
  final VoidCallback? onTap;

  /// Largest gauge diameter, so the dial does not grow too big on tablets.
  static const double _maxGaugeSize = 180;

  @override
  Widget build(BuildContext context) {
    final fraction = (percent / 100).clamp(0.0, 1.0);

    // Charging always shows healthy green. Otherwise the colour follows
    // the level (green, orange below 20%, red below 10%).
    final gradient = isCharging
        ? GaugeGradients.success
        : GaugeGradients.forLevel(fraction, normal: GaugeGradients.success);
    final accent = gradient.last;

    return GlassCard(
      onTap: onTap,
      semanticLabel:
          'Battery $percent percent, ${isCharging ? 'charging' : 'not charging'}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CardHeader(
            title: 'BATTERY',
            icon: _headerIcon,
            color: accent,
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final gaugeSize = math.min(constraints.maxWidth, _maxGaugeSize);
                return CircularGauge(
                  value: fraction,
                  size: gaugeSize,
                  strokeWidth: gaugeSize * 0.085,
                  gradientColors: gradient,
                  semanticLabel: 'Battery level $percent percent',
                  child: _GaugeCenter(
                    percent: percent,
                    isCharging: isCharging,
                    gaugeSize: gaugeSize,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: 'VOLTAGE',
                  value: voltage.toStringAsFixed(1),
                  unit: 'V',
                ),
              ),
              Expanded(
                child: MetricTile(
                  label: 'HEALTH',
                  value: health.label,
                  valueColor: health.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          StatusChip(
            label: isCharging ? 'Charging' : 'Not charging',
            icon: isCharging
                ? Icons.bolt_rounded
                : Icons.power_off_rounded,
            color: isCharging ? AppColors.success : AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  /// Header icon: charging, alert when low, otherwise a full battery.
  IconData get _headerIcon {
    if (isCharging) return Icons.battery_charging_full_rounded;
    if (percent < 20) return Icons.battery_alert_rounded;
    return Icons.battery_full_rounded;
  }
}

/// Percentage readout and caption drawn in the middle of the gauge.
class _GaugeCenter extends StatelessWidget {
  const _GaugeCenter({
    required this.percent,
    required this.isCharging,
    required this.gaugeSize,
  });

  final int percent;
  final bool isCharging;
  final double gaugeSize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    Widget bolt = Icon(
      Icons.bolt_rounded,
      size: gaugeSize * 0.10,
      color: AppColors.success,
    );
    // Gentle breathing glow on the bolt while charging.
    if (!reduceMotion) {
      bolt = bolt
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .fade(begin: 0.35, end: 1, duration: 900.ms);
    }

    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              text: '$percent',
              style: textTheme.displaySmall?.copyWith(
                fontSize: gaugeSize * 0.30,
                height: 1,
              ),
              children: [
                TextSpan(
                  text: '%',
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: gaugeSize * 0.13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: gaugeSize * 0.03),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCharging) bolt,
              Text(
                isCharging ? 'CHARGING' : 'CHARGE',
                style: textTheme.labelSmall?.copyWith(
                  color: isCharging
                      ? AppColors.success
                      : AppColors.textMuted,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  fontSize: math.max(9, gaugeSize * 0.065),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}