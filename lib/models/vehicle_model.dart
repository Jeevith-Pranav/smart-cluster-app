/// Domain models for the Smart Cluster Companion App.
///
/// Everything here is immutable and free of Flutter imports, so it can be
/// unit-tested and reused by both the dummy data source and the future
/// BLE implementation.
library;

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// State of the BLE link between the phone and the Raspberry Pi cluster.
enum ConnectionStatus {
  disconnected('Disconnected'),
  connecting('Connecting'),
  connected('Connected');

  const ConnectionStatus(this.label);

  /// Human readable label shown in the UI.
  final String label;
}

/// Generic health level used for battery, fuel sensor, and cluster checks.
enum HealthStatus {
  good('Good'),
  warning('Warning'),
  critical('Critical');

  const HealthStatus(this.label);

  /// Human readable label shown in the UI.
  final String label;
}

/// Maneuver shown on the navigation card and sent to the cluster.
enum TurnDirection {
  straight('Continue Straight'),
  slightLeft('Slight Left'),
  left('Turn Left'),
  slightRight('Slight Right'),
  right('Turn Right'),
  uTurn('Make a U-Turn'),
  arrive('Arrive at Destination');

  const TurnDirection(this.instruction);

  /// Spoken-style instruction text, e.g. "Turn Left".
  final String instruction;
}

// ---------------------------------------------------------------------------
// Navigation
// ---------------------------------------------------------------------------

/// A single turn-by-turn instruction received from the navigation source.
class NavigationInstruction {
  const NavigationInstruction({
    required this.direction,
    required this.distanceMeters,
    required this.roadName,
    required this.etaMinutes,
    required this.remainingKm,
  });

  /// The upcoming maneuver.
  final TurnDirection direction;

  /// Distance to the maneuver in metres.
  final int distanceMeters;

  /// Name of the road to turn onto.
  final String roadName;

  /// Estimated minutes until arrival at the destination.
  final int etaMinutes;

  /// Remaining trip distance in kilometres.
  final double remainingKm;

  /// Distance formatted for display: "250 m" below 1 km, otherwise "1.4 km".
  String get formattedDistance {
    if (distanceMeters < 1000) return '$distanceMeters m';
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }

  /// ETA formatted for display: "12 min" or "1 h 5 min".
  String get formattedEta {
    if (etaMinutes < 60) return '$etaMinutes min';
    final hours = etaMinutes ~/ 60;
    final minutes = etaMinutes % 60;
    return minutes == 0 ? '$hours h' : '$hours h $minutes min';
  }

  /// Returns a copy with the given fields replaced.
  NavigationInstruction copyWith({
    TurnDirection? direction,
    int? distanceMeters,
    String? roadName,
    int? etaMinutes,
    double? remainingKm,
  }) {
    return NavigationInstruction(
      direction: direction ?? this.direction,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      roadName: roadName ?? this.roadName,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      remainingKm: remainingKm ?? this.remainingKm,
    );
  }

  /// Dummy instruction used until real navigation data is available.
  static const NavigationInstruction dummy = NavigationInstruction(
    direction: TurnDirection.left,
    distanceMeters: 250,
    roadName: 'Anna Salai',
    etaMinutes: 18,
    remainingKm: 7.4,
  );
}

// ---------------------------------------------------------------------------
// Vehicle
// ---------------------------------------------------------------------------

/// Snapshot of everything the dashboard displays about the vehicle.
class VehicleModel {
  const VehicleModel({
    required this.name,
    required this.connectionStatus,
    required this.batteryPercent,
    required this.batteryVoltage,
    required this.batteryHealth,
    required this.isCharging,
    required this.fuelPercent,
    required this.rangeKm,
    required this.fuelHealth,
    required this.speedKmh,
    required this.temperatureCelsius,
    required this.weatherCondition,
    required this.location,
    required this.navigation,
  });

  /// Display name, e.g. "Hyundai i20 Prototype".
  final String name;

  /// Current BLE link state.
  final ConnectionStatus connectionStatus;

  /// Battery state of charge, 0 to 100.
  final int batteryPercent;

  /// Battery voltage in volts.
  final double batteryVoltage;

  /// Overall battery health.
  final HealthStatus batteryHealth;

  /// Whether the battery is currently charging.
  final bool isCharging;

  /// Fuel tank level, 0 to 100.
  final int fuelPercent;

  /// Estimated remaining range in kilometres.
  final int rangeKm;

  /// Health of the fuel level sensor and tank.
  final HealthStatus fuelHealth;

  /// Current speed in km/h.
  final int speedKmh;

  /// Outside temperature in degrees Celsius (dummy weather).
  final int temperatureCelsius;

  /// Short weather description (dummy weather).
  final String weatherCondition;

  /// City or area name.
  final String location;

  /// Active navigation instruction.
  final NavigationInstruction navigation;

  /// Whether the phone is currently linked to the cluster.
  bool get isConnected => connectionStatus == ConnectionStatus.connected;

  /// Battery fraction 0.0 to 1.0, convenient for gauges.
  double get batteryFraction => batteryPercent / 100;

  /// Fuel fraction 0.0 to 1.0, convenient for gauges.
  double get fuelFraction => fuelPercent / 100;

  /// Returns a copy with the given fields replaced.
  VehicleModel copyWith({
    String? name,
    ConnectionStatus? connectionStatus,
    int? batteryPercent,
    double? batteryVoltage,
    HealthStatus? batteryHealth,
    bool? isCharging,
    int? fuelPercent,
    int? rangeKm,
    HealthStatus? fuelHealth,
    int? speedKmh,
    int? temperatureCelsius,
    String? weatherCondition,
    String? location,
    NavigationInstruction? navigation,
  }) {
    return VehicleModel(
      name: name ?? this.name,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      batteryHealth: batteryHealth ?? this.batteryHealth,
      isCharging: isCharging ?? this.isCharging,
      fuelPercent: fuelPercent ?? this.fuelPercent,
      rangeKm: rangeKm ?? this.rangeKm,
      fuelHealth: fuelHealth ?? this.fuelHealth,
      speedKmh: speedKmh ?? this.speedKmh,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      location: location ?? this.location,
      navigation: navigation ?? this.navigation,
    );
  }

  /// Dummy vehicle used until the BLE service delivers real values.
  static const VehicleModel dummy = VehicleModel(
    name: 'Hyundai i20 Prototype',
    connectionStatus: ConnectionStatus.connected,
    batteryPercent: 92,
    batteryVoltage: 12.6,
    batteryHealth: HealthStatus.good,
    isCharging: false,
    fuelPercent: 74,
    rangeKm: 420,
    fuelHealth: HealthStatus.good,
    speedKmh: 42,
    temperatureCelsius: 32,
    weatherCondition: 'Sunny',
    location: 'Chennai',
    navigation: NavigationInstruction.dummy,
  );
}