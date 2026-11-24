import 'package:material_ui/material_ui.dart';

import '../app/theme.dart';
import '../models/vehicle_model.dart';

// ---------------------------------------------------------------------------
// HealthStatus
// ---------------------------------------------------------------------------

/// Colour and icon for each [HealthStatus].
extension HealthStatusStyle on HealthStatus {
  /// Accent colour: green when good, orange for warning, red when critical.
  Color get color => switch (this) {
        HealthStatus.good => AppColors.success,
        HealthStatus.warning => AppColors.warning,
        HealthStatus.critical => AppColors.danger,
      };

  /// Icon that reinforces the colour (so meaning is not colour-only).
  IconData get icon => switch (this) {
        HealthStatus.good => Icons.check_circle_rounded,
        HealthStatus.warning => Icons.warning_amber_rounded,
        HealthStatus.critical => Icons.error_rounded,
      };
}

// ---------------------------------------------------------------------------
// ConnectionStatus
// ---------------------------------------------------------------------------

/// Colour and icon for each [ConnectionStatus].
extension ConnectionStatusStyle on ConnectionStatus {
  /// Green when connected, orange while connecting, grey when disconnected.
  Color get color => switch (this) {
        ConnectionStatus.connected => AppColors.success,
        ConnectionStatus.connecting => AppColors.warning,
        ConnectionStatus.disconnected => AppColors.textMuted,
      };

  /// Bluetooth icon matching the link state.
  IconData get icon => switch (this) {
        ConnectionStatus.connected => Icons.bluetooth_connected_rounded,
        ConnectionStatus.connecting => Icons.bluetooth_searching_rounded,
        ConnectionStatus.disconnected => Icons.bluetooth_disabled_rounded,
      };

  /// Whether the status dot should pulse (alive states only).
  bool get shouldPulse => this != ConnectionStatus.disconnected;
}

// ---------------------------------------------------------------------------
// TurnDirection
// ---------------------------------------------------------------------------

/// Icon for each [TurnDirection], used by the navigation card and screen.
extension TurnDirectionStyle on TurnDirection {
  IconData get icon => switch (this) {
        TurnDirection.straight => Icons.straight_rounded,
        TurnDirection.slightLeft => Icons.turn_slight_left_rounded,
        TurnDirection.left => Icons.turn_left_rounded,
        TurnDirection.slightRight => Icons.turn_slight_right_rounded,
        TurnDirection.right => Icons.turn_right_rounded,
        TurnDirection.uTurn => Icons.u_turn_left_rounded,
        TurnDirection.arrive => Icons.flag_rounded,
      };
}

// ---------------------------------------------------------------------------
// Gauge colours
// ---------------------------------------------------------------------------

/// Gradient presets for [CircularGauge] and the logic that picks one from
/// the current level.
abstract final class GaugeGradients {
  /// Healthy green (battery default).
  static const List<Color> success = [Color(0xFF1B9E5A), AppColors.success];

  /// Brand blue (fuel default).
  static const List<Color> primary = [AppColors.primary, AppColors.primaryGlow];

  /// Low-level orange.
  static const List<Color> warning = [Color(0xFFFF8A00), AppColors.warning];

  /// Very-low-level red.
  static const List<Color> danger = [Color(0xFFD93636), AppColors.danger];

  /// Chooses a gradient for [fraction] (0.0 to 1.0).
  ///
  /// * at or above [warningBelow]: the [normal] gradient,
  /// * below [warningBelow]: orange,
  /// * below [dangerBelow]: red.
  static List<Color> forLevel(
    double fraction, {
    required List<Color> normal,
    double warningBelow = 0.20,
    double dangerBelow = 0.10,
  }) {
    if (fraction < dangerBelow) return danger;
    if (fraction < warningBelow) return warning;
    return normal;
  }
}