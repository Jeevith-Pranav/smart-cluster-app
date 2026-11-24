import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/vehicle_model.dart';
import '../../providers/vehicle_provider.dart';
import '../../utils/status_style.dart';
import '../../widgets/cards/navigation_card.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/section_title.dart';
import '../../widgets/common/status_chip.dart';

/// Navigation tab: the turn card, route controls, and cluster link status.
///
/// Transparent like every tab: the gradient and bottom bar come from the
/// app shell.
class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

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
            child: Selector<
                VehicleProvider,
                ({
                  NavigationInstruction instruction,
                  ConnectionStatus status,
                  bool isDemoRunning,
                })>(
              selector: (_, provider) => (
                instruction: provider.vehicle.navigation,
                status: provider.vehicle.connectionStatus,
                isDemoRunning: provider.isNavigationDemoRunning,
              ),
              builder: (context, data, _) {
                // Read once; the callbacks do not need to trigger rebuilds.
                final provider = context.read<VehicleProvider>();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Screen title -------------------------------------
                    Semantics(
                      header: true,
                      child: Text('Navigation', style: textTheme.headlineMedium),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Turn-by-turn guidance',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // --- Turn card ----------------------------------------
                    NavigationCard(instruction: data.instruction),
                    const SizedBox(height: AppSpacing.xxl),

                    // --- Route controls -----------------------------------
                    const SectionTitle(
                      title: 'Route Controls',
                      subtitle: 'Dummy route for testing',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _RouteControls(
                      isDemoRunning: data.isDemoRunning,
                      onNext: provider.advanceNavigation,
                      onRestart: provider.restartNavigation,
                      onDemoChanged: (enabled) {
                        if (enabled) {
                          provider.startNavigationDemo();
                        } else {
                          provider.stopNavigationDemo();
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // --- Cluster link -------------------------------------
                    const SectionTitle(title: 'Cluster Display'),
                    const SizedBox(height: AppSpacing.md),
                    _ClusterLinkCard(status: data.status),
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

/// Next turn and Restart buttons, plus the auto-demo switch.
class _RouteControls extends StatelessWidget {
  const _RouteControls({
    required this.isDemoRunning,
    required this.onNext,
    required this.onRestart,
    required this.onDemoChanged,
  });

  final bool isDemoRunning;
  final VoidCallback onNext;
  final VoidCallback onRestart;
  final ValueChanged<bool> onDemoChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onNext,
                  icon: const Icon(Icons.skip_next_rounded, size: 20),
                  label: const Text('Next turn'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.restart_alt_rounded, size: 20),
                  label: const Text('Restart'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.glassBorder),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          // SwitchListTile gives correct switch semantics and a full-row
          // tap target without extra code.
          SwitchListTile(
            value: isDemoRunning,
            onChanged: onDemoChanged,
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Auto demo',
              style: textTheme.titleSmall?.copyWith(fontSize: 16),
            ),
            subtitle: Text(
              'Advances the route every 6 seconds',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Explains whether instructions currently reach the cluster.
class _ClusterLinkCard extends StatelessWidget {
  const _ClusterLinkCard({required this.status});

  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isConnected = status == ConnectionStatus.connected;

    return GlassCard(
      semanticLabel: isConnected
          ? 'Instructions are being sent to the cluster'
          : 'Cluster is ${status.label}. Instructions are not being sent.',
      child: Row(
        children: [
          Expanded(
            child: ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isConnected
                        ? 'Instructions are mirrored on the cluster.'
                        : 'Connect to the cluster to mirror instructions.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Every new turn is sent to the Raspberry Pi display.',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          StatusChip(
            label: isConnected ? 'Streaming' : status.label,
            icon: isConnected ? Icons.cast_connected_rounded : status.icon,
            color: status.color,
          ),
        ],
      ),
    );
  }
}