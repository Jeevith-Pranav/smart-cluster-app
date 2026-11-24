import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme.dart';
import '../../models/vehicle_model.dart';
import '../../utils/status_style.dart';
import '../common/glass_card.dart';
import '../common/status_chip.dart';

/// Panel of status chips summarising the health of the vehicle systems.
///
/// ```dart
/// const VehicleHealthSection(
///   connectionStatus: ConnectionStatus.connected,
///   batteryHealth: HealthStatus.good,
///   fuelHealth: HealthStatus.good,
/// )
/// ```
class VehicleHealthSection extends StatelessWidget {
  const VehicleHealthSection({
    super.key,
    required this.connectionStatus,
    required this.batteryHealth,
    required this.fuelHealth,
  });

  /// Current BLE link state. Also decides whether the cluster counts as online.
  final ConnectionStatus connectionStatus;

  /// Overall battery health.
  final HealthStatus batteryHealth;

  /// Health of the fuel level sensor and tank.
  final HealthStatus fuelHealth;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final chips = <Widget>[
      _bleChip,
      _batteryChip,
      _fuelChip,
      _clusterChip,
    ];

    return GlassCard(
      semanticLabel: 'Vehicle health',
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (var i = 0; i < chips.length; i++)
              // One-time staggered entrance, skipped for reduced motion.
              if (reduceMotion)
                chips[i]
              else
                chips[i]
                    .animate(delay: (80 * i).ms)
                    .fadeIn(duration: 350.ms, curve: Curves.easeOut)
                    .scale(
                      begin: const Offset(0.92, 0.92),
                      end: const Offset(1, 1),
                      duration: 350.ms,
                      curve: Curves.easeOut,
                    ),
          ],
        ),
      ),
    );
  }

  /// "BLE Connected", "BLE Connecting", or "BLE Disconnected".
  Widget get _bleChip {
    return StatusChip(
      label: 'BLE ${connectionStatus.label}',
      icon: connectionStatus.icon,
      color: connectionStatus.color,
    );
  }

  /// "Battery Healthy", "Battery Low", or "Battery Critical".
  Widget get _batteryChip {
    final label = switch (batteryHealth) {
      HealthStatus.good => 'Battery Healthy',
      HealthStatus.warning => 'Battery Low',
      HealthStatus.critical => 'Battery Critical',
    };
    return StatusChip.health(
      label: label,
      status: batteryHealth,
      icon: Icons.battery_full_rounded,
    );
  }

  /// "Fuel Sensor Active", "Fuel Low", or "Fuel Critical".
  Widget get _fuelChip {
    final label = switch (fuelHealth) {
      HealthStatus.good => 'Fuel Sensor Active',
      HealthStatus.warning => 'Fuel Low',
      HealthStatus.critical => 'Fuel Critical',
    };
    return StatusChip.health(
      label: label,
      status: fuelHealth,
      icon: Icons.sensors_rounded,
    );
  }

  /// "Cluster Online" when linked, "Cluster Pending" while connecting,
  /// otherwise "Cluster Offline".
  Widget get _clusterChip {
    final (label, color) = switch (connectionStatus) {
      ConnectionStatus.connected => ('Cluster Online', AppColors.success),
      ConnectionStatus.connecting => ('Cluster Pending', AppColors.warning),
      ConnectionStatus.disconnected => ('Cluster Offline', AppColors.textMuted),
    };
    return StatusChip(
      label: label,
      icon: Icons.memory_rounded,
      color: color,
    );
  }
}