import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../models/vehicle_model.dart';
import '../../utils/status_style.dart';
import '../common/animated_dot.dart';
import '../common/card_header.dart';
import '../common/glass_card.dart';
import '../common/metric_tile.dart';

/// Dashboard card summarising the vehicle: name, link state, speed, location.
///
/// ```dart
/// const VehicleCard(
///   name: 'Hyundai i20 Prototype',
///   connectionStatus: ConnectionStatus.connected,
///   speedKmh: 42,
///   location: 'Chennai',
///   temperatureCelsius: 32,
/// )
/// ```
class VehicleCard extends StatelessWidget {
  const VehicleCard({
    super.key,
    required this.name,
    required this.connectionStatus,
    required this.speedKmh,
    required this.location,
    required this.temperatureCelsius,
    this.onTap,
  });

  /// Display name of the vehicle.
  final String name;

  /// Current BLE link state.
  final ConnectionStatus connectionStatus;

  /// Current speed in km/h.
  final int speedKmh;

  /// City or area name.
  final String location;

  /// Outside temperature in degrees Celsius.
  final int temperatureCelsius;

  /// Optional tap handler, for example to open the Vehicle tab.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return GlassCard(
      onTap: onTap,
      semanticLabel: '$name, ${connectionStatus.label}, '
          'speed $speedKmh kilometres per hour, $location, '
          '$temperatureCelsius degrees Celsius',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CardHeader(
            title: 'VEHICLE',
            icon: Icons.directions_car_rounded,
            color: AppColors.primaryGlow,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Name and connection state.
          ExcludeSemantics(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleLarge?.copyWith(fontSize: 22),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _ConnectionBadge(status: connectionStatus),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Speed readout. The number counts from the previously shown value
          // to the new one.
          ExcludeSemantics(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: speedKmh.toDouble()),
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value.round().toString(),
                      style: textTheme.displayMedium?.copyWith(
                        fontSize: 56,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'km/h',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 18,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: 'LOCATION',
                  value: location,
                  icon: Icons.location_on_rounded,
                ),
              ),
              Expanded(
                child: MetricTile(
                  label: 'OUTSIDE',
                  value: '$temperatureCelsius',
                  unit: '°C',
                  icon: Icons.thermostat_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pulsing dot plus connection label, coloured by link state.
class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({required this.status});

  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedDot(
          color: status.color,
          size: 8,
          isPulsing: status.shouldPulse,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          status.label,
          style: textTheme.labelMedium?.copyWith(
            color: status.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}