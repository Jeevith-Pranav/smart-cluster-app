import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../models/vehicle_model.dart';
import '../../utils/status_style.dart';
import '../common/card_header.dart';
import '../common/glass_card.dart';
import '../common/metric_tile.dart';
import '../common/status_chip.dart';
import '../gauges/circular_gauge.dart';

/// Dashboard card showing fuel level, estimated range, and fuel health.
///
/// ```dart
/// const FuelCard(
///   percent: 74,
///   rangeKm: 420,
///   health: HealthStatus.good,
/// )
/// ```
class FuelCard extends StatelessWidget {
  const FuelCard({
    super.key,
    required this.percent,
    required this.rangeKm,
    required this.health,
    this.onTap,
  });

  /// Fuel tank level, 0 to 100.
  final int percent;

  /// Estimated remaining range in kilometres.
  final int rangeKm;

  /// Health of the fuel level sensor and tank.
  final HealthStatus health;

  /// Optional tap handler, for example to open the Vehicle tab.
  final VoidCallback? onTap;

  /// Largest gauge diameter, so the dial does not grow too big on tablets.
  static const double _maxGaugeSize = 180;

  @override
  Widget build(BuildContext context) {
    final fraction = (percent / 100).clamp(0.0, 1.0);

    // Blue normally, orange below 20%, red below 10%.
    final gradient = GaugeGradients.forLevel(
      fraction,
      normal: GaugeGradients.primary,
    );
    final accent = gradient.last;

    return GlassCard(
      onTap: onTap,
      semanticLabel: 'Fuel $percent percent, estimated range $rangeKm kilometres',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CardHeader(
            title: 'FUEL',
            icon: Icons.local_gas_station_rounded,
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
                  semanticLabel: 'Fuel level $percent percent',
                  child: _GaugeCenter(
                    percent: percent,
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
                  label: 'RANGE',
                  value: '$rangeKm',
                  unit: 'km',
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
          _statusChip,
        ],
      ),
    );
  }

  /// "Sensor active" when healthy, otherwise a low-fuel warning.
  Widget get _statusChip {
    if (health == HealthStatus.good) {
      return const StatusChip(
        label: 'Sensor active',
        icon: Icons.sensors_rounded,
        color: AppColors.success,
      );
    }
    return StatusChip.health(
      label: 'Low fuel',
      status: health,
    );
  }
}

/// Percentage readout and caption drawn in the middle of the gauge.
class _GaugeCenter extends StatelessWidget {
  const _GaugeCenter({
    required this.percent,
    required this.gaugeSize,
  });

  final int percent;
  final double gaugeSize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
          Text(
            'FUEL LEVEL',
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              fontSize: math.max(9, gaugeSize * 0.065),
            ),
          ),
        ],
      ),
    );
  }
}