import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/vehicle_model.dart';
import '../../providers/app_navigation_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/cards/battery_card.dart';
import '../../widgets/cards/fuel_card.dart';
import '../../widgets/cards/navigation_card.dart';
import '../../widgets/cards/vehicle_card.dart';
import '../../widgets/common/section_title.dart';
import '../../widgets/dashboard/dashboard_header.dart';
import '../../widgets/dashboard/quick_controls.dart';
import '../../widgets/dashboard/vehicle_health_section.dart';

/// Main dashboard: header, navigation, battery, fuel, vehicle, quick
/// controls, and vehicle health.
///
/// This screen is transparent: the gradient and the bottom bar come from the
/// app shell. It scrolls underneath the frosted bottom bar.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  /// Content never grows wider than this, so tablets stay readable.
  static const double _maxContentWidth = 1100;

  /// Width from which battery and fuel sit side by side.
  static const double _twoColumnBreakpoint = 460;

  /// Width from which navigation and vehicle sit side by side.
  static const double _wideBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    // Height of the system inset plus the bottom bar (the shell extends the
    // body behind it), so the last section can scroll fully into view.
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final navigation = context.read<AppNavigationProvider>();

    return SafeArea(
      // The bottom is handled manually so content can scroll under the bar.
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Header -------------------------------------------------
                Selector<
                    VehicleProvider,
                    ({
                      String name,
                      ConnectionStatus status,
                      int temperature,
                      String weather,
                      String location,
                    })>(
                  selector: (_, provider) {
                    final vehicle = provider.vehicle;
                    return (
                      name: vehicle.name,
                      status: vehicle.connectionStatus,
                      temperature: vehicle.temperatureCelsius,
                      weather: vehicle.weatherCondition,
                      location: vehicle.location,
                    );
                  },
                  builder: (context, data, _) {
                    return DashboardHeader(
                      vehicleName: data.name,
                      connectionStatus: data.status,
                      temperatureCelsius: data.temperature,
                      weatherCondition: data.weather,
                      location: data.location,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),

                // --- Navigation and vehicle ---------------------------------
                _AdaptivePair(
                  minWidthForRow: _wideBreakpoint,
                  first: _Reveal(
                    index: 0,
                    child: Selector<VehicleProvider, NavigationInstruction>(
                      selector: (_, provider) => provider.vehicle.navigation,
                      builder: (context, instruction, _) {
                        return NavigationCard(
                          instruction: instruction,
                          onTap: () => navigation.selectTab(AppTab.navigation),
                        );
                      },
                    ),
                  ),
                  second: _Reveal(
                    index: 1,
                    child: Selector<
                        VehicleProvider,
                        ({
                          String name,
                          ConnectionStatus status,
                          int speed,
                          String location,
                          int temperature,
                        })>(
                      selector: (_, provider) {
                        final vehicle = provider.vehicle;
                        return (
                          name: vehicle.name,
                          status: vehicle.connectionStatus,
                          speed: vehicle.speedKmh,
                          location: vehicle.location,
                          temperature: vehicle.temperatureCelsius,
                        );
                      },
                      builder: (context, data, _) {
                        return VehicleCard(
                          name: data.name,
                          connectionStatus: data.status,
                          speedKmh: data.speed,
                          location: data.location,
                          temperatureCelsius: data.temperature,
                          onTap: () => navigation.selectTab(AppTab.vehicle),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // --- Battery and fuel ---------------------------------------
                _AdaptivePair(
                  minWidthForRow: _twoColumnBreakpoint,
                  first: _Reveal(
                    index: 2,
                    child: Selector<
                        VehicleProvider,
                        ({
                          int percent,
                          double voltage,
                          HealthStatus health,
                          bool isCharging,
                        })>(
                      selector: (_, provider) {
                        final vehicle = provider.vehicle;
                        return (
                          percent: vehicle.batteryPercent,
                          voltage: vehicle.batteryVoltage,
                          health: vehicle.batteryHealth,
                          isCharging: vehicle.isCharging,
                        );
                      },
                      builder: (context, data, _) {
                        return BatteryCard(
                          percent: data.percent,
                          voltage: data.voltage,
                          health: data.health,
                          isCharging: data.isCharging,
                          onTap: () => navigation.selectTab(AppTab.vehicle),
                        );
                      },
                    ),
                  ),
                  second: _Reveal(
                    index: 3,
                    child: Selector<
                        VehicleProvider,
                        ({int percent, int rangeKm, HealthStatus health})>(
                      selector: (_, provider) {
                        final vehicle = provider.vehicle;
                        return (
                          percent: vehicle.fuelPercent,
                          rangeKm: vehicle.rangeKm,
                          health: vehicle.fuelHealth,
                        );
                      },
                      builder: (context, data, _) {
                        return FuelCard(
                          percent: data.percent,
                          rangeKm: data.rangeKm,
                          health: data.health,
                          onTap: () => navigation.selectTab(AppTab.vehicle),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // --- Quick controls -----------------------------------------
                const SectionTitle(title: 'Quick Controls'),
                const SizedBox(height: AppSpacing.md),
                _Reveal(
                  index: 4,
                  child: Selector<
                      VehicleProvider,
                      ({
                        bool horn,
                        bool hazard,
                        bool headlights,
                        bool locating,
                      })>(
                    selector: (_, provider) => (
                      horn: provider.isHornActive,
                      hazard: provider.isHazardOn,
                      headlights: provider.isHeadlightsOn,
                      locating: provider.isLocating,
                    ),
                    builder: (context, data, _) {
                      // Read once; callbacks do not need to trigger rebuilds.
                      final provider = context.read<VehicleProvider>();
                      return QuickControls(
                        isHornActive: data.horn,
                        isHazardOn: data.hazard,
                        isHeadlightsOn: data.headlights,
                        isLocating: data.locating,
                        onHorn: provider.honkHorn,
                        onHazard: provider.toggleHazard,
                        onHeadlights: provider.toggleHeadlights,
                        onLocate: provider.locateVehicle,
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // --- Vehicle health -----------------------------------------
                const SectionTitle(title: 'Vehicle Health'),
                const SizedBox(height: AppSpacing.md),
                _Reveal(
                  index: 5,
                  child: Selector<
                      VehicleProvider,
                      ({
                        ConnectionStatus status,
                        HealthStatus battery,
                        HealthStatus fuel,
                      })>(
                    selector: (_, provider) {
                      final vehicle = provider.vehicle;
                      return (
                        status: vehicle.connectionStatus,
                        battery: vehicle.batteryHealth,
                        fuel: vehicle.fuelHealth,
                      );
                    },
                    builder: (context, data, _) {
                      return VehicleHealthSection(
                        connectionStatus: data.status,
                        batteryHealth: data.battery,
                        fuelHealth: data.fuel,
                      );
                    },
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

/// Lays two children side by side when there is enough width, otherwise
/// stacks them vertically with the same gap.
class _AdaptivePair extends StatelessWidget {
  const _AdaptivePair({
    required this.first,
    required this.second,
    required this.minWidthForRow,
  });

  final Widget first;
  final Widget second;

  /// Available width from which the two children share a row.
  final double minWidthForRow;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= minWidthForRow) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: second),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            first,
            const SizedBox(height: AppSpacing.lg),
            second,
          ],
        );
      },
    );
  }
}

/// One-time staggered entrance (fade and slight rise) for a dashboard block.
///
/// [index] sets the delay so blocks appear in reading order. Skipped when
/// the system asks for reduced motion.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    return child
        .animate(delay: (90 * index).ms)
        .fadeIn(duration: 450.ms, curve: Curves.easeOut)
        .slideY(begin: 0.06, end: 0, duration: 450.ms, curve: Curves.easeOut);
  }
}