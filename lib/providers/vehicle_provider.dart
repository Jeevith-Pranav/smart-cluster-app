import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/vehicle_model.dart';
import '../services/ble_service.dart';
import '../services/navigation_service.dart';

/// Holds the live [VehicleModel] and the quick-control state for the UI.
///
/// Data flow:
///   BleService / NavigationService  ->  VehicleProvider  ->  widgets
///
/// Navigation instructions flow the other way too: every instruction from
/// [NavigationService] is forwarded to [BleService] so the cluster can
/// display it.
class VehicleProvider extends ChangeNotifier {
  VehicleProvider({
    required BleService bleService,
    required NavigationService navigationService,
  })  : _bleService = bleService,
        _navigationService = navigationService {
    // Build the first snapshot from the services' current values.
    _vehicle = VehicleModel.dummy.copyWith(
      connectionStatus: _bleService.connectionStatus,
      batteryPercent: _bleService.batteryLevel,
      fuelPercent: _bleService.fuelLevel,
      rangeKm: _rangeForFuel(_bleService.fuelLevel),
      batteryHealth: _batteryHealthFor(_bleService.batteryLevel),
      fuelHealth: _fuelHealthFor(_bleService.fuelLevel),
      navigation: _navigationService.currentInstruction,
    );
    _listenToServices();
  }

  final BleService _bleService;
  final NavigationService _navigationService;

  late VehicleModel _vehicle;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  bool _isDisposed = false;

  // -------------------------------------------------------------------------
  // Public state
  // -------------------------------------------------------------------------

  /// Latest snapshot of the vehicle.
  VehicleModel get vehicle => _vehicle;

  /// Hazard lights state (toggle).
  bool get isHazardOn => _isHazardOn;
  bool _isHazardOn = false;

  /// Headlights state (toggle).
  bool get isHeadlightsOn => _isHeadlightsOn;
  bool _isHeadlightsOn = false;

  /// True briefly after [honkHorn] so the UI can animate the button.
  bool get isHornActive => _isHornActive;
  bool _isHornActive = false;

  /// True briefly after [locateVehicle] so the UI can animate the button.
  bool get isLocating => _isLocating;
  bool _isLocating = false;

  /// Whether the navigation demo timer is currently running.
  bool get isNavigationDemoRunning => _demoTimer != null;

  Timer? _hornTimer;
  Timer? _locateTimer;
  Timer? _demoTimer;

  // -------------------------------------------------------------------------
  // Dummy conversion rules
  // -------------------------------------------------------------------------

  /// Kilometres of range per percent of fuel. Derived from the spec dummy
  /// values (74% fuel is 420 km), so the dummy range stays consistent.
  static const double _kmPerFuelPercent = 420 / 74;

  static int _rangeForFuel(int fuelPercent) =>
      (fuelPercent * _kmPerFuelPercent).round();

  static HealthStatus _batteryHealthFor(int percent) {
    if (percent < 10) return HealthStatus.critical;
    if (percent < 20) return HealthStatus.warning;
    return HealthStatus.good;
  }

  static HealthStatus _fuelHealthFor(int percent) {
    if (percent < 8) return HealthStatus.critical;
    if (percent < 15) return HealthStatus.warning;
    return HealthStatus.good;
  }

  // -------------------------------------------------------------------------
  // Service subscriptions
  // -------------------------------------------------------------------------

  void _listenToServices() {
    _subscriptions.addAll([
      _bleService.connectionStream.listen((status) {
        _update(_vehicle.copyWith(connectionStatus: status));
      }),
      _bleService.batteryLevelStream.listen((level) {
        _update(
          _vehicle.copyWith(
            batteryPercent: level,
            batteryHealth: _batteryHealthFor(level),
          ),
        );
      }),
      _bleService.fuelLevelStream.listen((level) {
        _update(
          _vehicle.copyWith(
            fuelPercent: level,
            rangeKm: _rangeForFuel(level),
            fuelHealth: _fuelHealthFor(level),
          ),
        );
      }),
      // Instructions arriving from the BLE side (for example the cluster
      // echoing back) update the UI directly.
      _bleService.navigationInstructionStream.listen((instruction) {
        _update(_vehicle.copyWith(navigation: instruction));
      }),
      // Instructions from the navigation source update the UI and are
      // forwarded to the cluster.
      _navigationService.instructionStream.listen((instruction) {
        _update(_vehicle.copyWith(navigation: instruction));
        _bleService.sendNavigationInstruction(instruction);
      }),
    ]);
  }

  /// Replaces the snapshot and notifies listeners, unless the provider is
  /// already disposed.
  void _update(VehicleModel next) {
    if (_isDisposed) return;
    _vehicle = next;
    notifyListeners();
  }

  // -------------------------------------------------------------------------
  // Connection
  // -------------------------------------------------------------------------

  /// Connects to the cluster.
  Future<void> connect() => _bleService.connect();

  /// Disconnects from the cluster.
  Future<void> disconnect() => _bleService.disconnect();

  // -------------------------------------------------------------------------
  // Navigation
  // -------------------------------------------------------------------------

  /// Moves to the next navigation step (dummy route).
  void advanceNavigation() => _navigationService.advance();

  /// Restarts the dummy route from the first step.
  void restartNavigation() => _navigationService.start();

  /// Starts a demo that advances the route every [interval].
  ///
  /// Useful when showing the project to mentors. Not called by default.
  /// Notifies listeners so the "Auto demo" switch reflects the new state.
  void startNavigationDemo({
    Duration interval = const Duration(seconds: 6),
  }) {
    if (_isDisposed) return;
    _demoTimer?.cancel();
    _demoTimer = Timer.periodic(interval, (timer) {
      if (_navigationService.isLastStep) {
        _navigationService.start();
      } else {
        _navigationService.advance();
      }
    });
    notifyListeners();
  }

  /// Stops the navigation demo started by [startNavigationDemo].
  /// Notifies listeners so the "Auto demo" switch reflects the new state.
  void stopNavigationDemo() {
    if (_isDisposed) return;
    _demoTimer?.cancel();
    _demoTimer = null;
    notifyListeners();
  }

  // -------------------------------------------------------------------------
  // Quick controls (dummy behaviour; will become BLE writes later)
  // -------------------------------------------------------------------------

  /// Sounds the horn. Momentary: [isHornActive] resets after a short delay.
  void honkHorn() {
    _hornTimer?.cancel();
    _isHornActive = true;
    notifyListeners();
    _hornTimer = Timer(const Duration(milliseconds: 600), () {
      if (_isDisposed) return;
      _isHornActive = false;
      notifyListeners();
    });
  }

  /// Toggles the hazard lights.
  void toggleHazard() {
    _isHazardOn = !_isHazardOn;
    notifyListeners();
  }

  /// Toggles the headlights.
  void toggleHeadlights() {
    _isHeadlightsOn = !_isHeadlightsOn;
    notifyListeners();
  }

  /// Flashes the lights and beeps so the owner can find the vehicle.
  /// Momentary: [isLocating] resets after a short delay.
  void locateVehicle() {
    _locateTimer?.cancel();
    _isLocating = true;
    notifyListeners();
    _locateTimer = Timer(const Duration(seconds: 3), () {
      if (_isDisposed) return;
      _isLocating = false;
      notifyListeners();
    });
  }

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  @override
  void dispose() {
    _isDisposed = true;
    _hornTimer?.cancel();
    _locateTimer?.cancel();
    _demoTimer?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}