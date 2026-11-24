import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/vehicle_model.dart';
import '../../providers/vehicle_provider.dart';
import '../../utils/status_style.dart';
import '../../widgets/cards/vehicle_card.dart';
import '../../widgets/common/animated_dot.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/section_title.dart';
import '../../widgets/dashboard/vehicle_health_section.dart';

/// Vehicle tab: summary, connection control, diagnostics, and health.
///
/// Transparent like every tab: the gradient and bottom bar come from the
/// app shell.
class VehicleScreen extends StatelessWidget {
  const VehicleScreen({super.key});

  /// Content never grows wider than this, so tablets stay readable.
  static const double _maxContentWidth = 700;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Includes the bottom bar height, because the shell extends the body
    // behind it.
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              bottomInset + AppSpacing.xxl,
            ),
            // The whole screen depends on most vehicle fields, so one
            // Selector on the snapshot is simpler than many small ones.
            child: Selector<VehicleProvider, VehicleModel>(
              selector: (_, provider) => provider.vehicle,
              builder: (context, vehicle, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Screen title -------------------------------------
                    Semantics(
                      header: true,
                      child: Text('Vehicle', style: textTheme.headlineMedium),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Status and diagnostics',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // --- Summary ------------------------------------------
                    VehicleCard(
                      name: vehicle.name,
                      connectionStatus: vehicle.connectionStatus,
                      speedKmh: vehicle.speedKmh,
                      location: vehicle.location,
                      temperatureCelsius: vehicle.temperatureCelsius,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // --- Connection ---------------------------------------
                    const SectionTitle(title: 'Connection'),
                    const SizedBox(height: AppSpacing.md),
                    _ConnectionPanel(status: vehicle.connectionStatus),
                    const SizedBox(height: AppSpacing.xxl),

                    // --- Diagnostics --------------------------------------
                    const SectionTitle(title: 'Diagnostics'),
                    const SizedBox(height: AppSpacing.md),
                    _DiagnosticsPanel(vehicle: vehicle),
                    const SizedBox(height: AppSpacing.xxl),

                    // --- Health -------------------------------------------
                    const SectionTitle(title: 'Vehicle Health'),
                    const SizedBox(height: AppSpacing.md),
                    VehicleHealthSection(
                      connectionStatus: vehicle.connectionStatus,
                      batteryHealth: vehicle.batteryHealth,
                      fuelHealth: vehicle.fuelHealth,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Link state with a Connect or Disconnect button.
///
/// The button is disabled while connecting so it cannot be tapped twice.
class _ConnectionPanel extends StatelessWidget {
  const _ConnectionPanel({required this.status});

  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final provider = context.read<VehicleProvider>();

    final subtitle = switch (status) {
      ConnectionStatus.connected => 'Linked to the cluster over BLE',
      ConnectionStatus.connecting => 'Looking for the cluster…',
      ConnectionStatus.disconnected => 'Not linked to the cluster',
    };

    return GlassCard(
      semanticLabel: 'Cluster connection, ${status.label}',
      child: Row(
        children: [
          ExcludeSemantics(
            child: Icon(status.icon, size: 28, color: status.color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      AnimatedDot(
                        color: status.color,
                        size: 8,
                        isPulsing: status.shouldPulse,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          status.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            color: status.color,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _buildButton(provider),
        ],
      ),
    );
  }

  Widget _buildButton(VehicleProvider provider) {
    switch (status) {
      case ConnectionStatus.connected:
        return OutlinedButton.icon(
          onPressed: provider.disconnect,
          icon: const Icon(Icons.link_off_rounded, size: 18),
          label: const Text('Disconnect'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.glassBorder),
            minimumSize: const Size(0, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      case ConnectionStatus.connecting:
        // A null callback disables the button.
        return FilledButton.icon(
          onPressed: null,
          icon: const SizedBox.square(
            dimension: 16,1111`sxc `
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          label: const Text('Connecting'),
        );
      case ConnectionStatus.disconnected:
        return FilledButton.icon(
          onPressed: provider.connect,
          icon: const Icon(Icons.bluetooth_rounded, size: 18),
          label: const Text('Connect'),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
        );
    }
  }
}

/// Card listing every vehicle reading as a label and value row.
class _DiagnosticsPanel extends StatelessWidget {
  const _DiagnosticsPanel({required this.vehicle});

  final VehicleModel vehicle;

  @override
  Widget build(BuildContext context) {
    final rows = <_DiagnosticRow>[
      _DiagnosticRow(
        icon: vehicle.connectionStatus.icon,
        label: 'BLE link',
        value: vehicle.connectionStatus.label,
        valueColor: vehicle.connectionStatus.color,
      ),
      _DiagnosticRow(
        icon: Icons.battery_full_rounded,
        label: 'Battery level',
        value: '${vehicle.batteryPercent}%',
      ),
      _DiagnosticRow(
        icon: Icons.bolt_rounded,
        label: 'Battery voltage',
        value: '${vehicle.batteryVoltage.toStringAsFixed(1)} V',
      ),
      _DiagnosticRow(
        icon: vehicle.batteryHealth.icon,
        label: 'Battery health',
        value: vehicle.batteryHealth.label,
        valueColor: vehicle.batteryHealth.color,
      ),
      _DiagnosticRow(
        icon: Icons.local_gas_station_rounded,
        label: 'Fuel level',
        value: '${vehicle.fuelPercent}%',
      ),
      _DiagnosticRow(
        icon: Icons.route_rounded,
        label: 'Estimated range',
        value: '${vehicle.rangeKm} km',
      ),
      _DiagnosticRow(
        icon: vehicle.fuelHealth.icon,
        label: 'Fuel sensor',
        value: vehicle.fuelHealth.label,
        valueColor: vehicle.fuelHealth.color,
      ),
      _DiagnosticRow(
        icon: Icons.speed_rounded,
        label: 'Speed',
        value: '${vehicle.speedKmh} km/h',
      ),
    ];

    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(),
            rows[i],
          ],
        ],
      ),
    );
  }
}

/// One diagnostic line: icon, label on the left, value on the right.
class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Colour of the value. Defaults to the primary text colour.
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      label: '$label $value',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}