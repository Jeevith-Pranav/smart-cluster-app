import 'dart:async';

import '../models/vehicle_model.dart';

/// Bluetooth Low Energy gateway between the phone and the Raspberry Pi cluster.
///
/// **Current state:** architecture only. Every value is dummy data and no
/// radio is touched. The public surface (getters, streams, [connect],
/// [disconnect]) is the contract the rest of the app depends on, so the real
/// GATT implementation can replace the internals without changing any caller.
///
/// **Future implementation notes:**
///  * [connect] will scan for the cluster, open a GATT connection, discover
///    services, and subscribe to notifications.
///  * Characteristic notifications will feed the stream controllers below.
///  * Navigation instructions will be written to the cluster through a
///    writable characteristic.
class BleService {
  BleService({
    ConnectionStatus initialStatus = ConnectionStatus.connected,
    int initialBatteryLevel = 92,
    int initialFuelLevel = 74,
    NavigationInstruction initialNavigation = NavigationInstruction.dummy,
  })  : _connectionStatus = initialStatus,
        _batteryLevel = initialBatteryLevel,
        _fuelLevel = initialFuelLevel,
        _navigationInstruction = initialNavigation;

  // -------------------------------------------------------------------------
  // Current values (dummy for now)
  // -------------------------------------------------------------------------

  ConnectionStatus _connectionStatus;
  int _batteryLevel;
  int _fuelLevel;
  NavigationInstruction _navigationInstruction;

  /// Whether [dispose] has been called. Prevents events after teardown.
  bool _isDisposed = false;

  /// Current state of the link to the cluster.
  ConnectionStatus get connectionStatus => _connectionStatus;

  /// Latest battery level, 0 to 100.
  int get batteryLevel => _batteryLevel;

  /// Latest fuel level, 0 to 100.
  int get fuelLevel => _fuelLevel;

  /// Latest navigation instruction.
  NavigationInstruction get navigationInstruction => _navigationInstruction;

  // -------------------------------------------------------------------------
  // Streams (one controller per characteristic, broadcast so that several
  // listeners can subscribe)
  // -------------------------------------------------------------------------

  final StreamController<ConnectionStatus> _connectionController =
      StreamController<ConnectionStatus>.broadcast();
  final StreamController<int> _batteryController =
      StreamController<int>.broadcast();
  final StreamController<int> _fuelController =
      StreamController<int>.broadcast();
  final StreamController<NavigationInstruction> _navigationController =
      StreamController<NavigationInstruction>.broadcast();

  /// Emits whenever the connection state changes.
  Stream<ConnectionStatus> get connectionStream => _connectionController.stream;

  /// Emits whenever a new battery level is received.
  Stream<int> get batteryLevelStream => _batteryController.stream;

  /// Emits whenever a new fuel level is received.
  Stream<int> get fuelLevelStream => _fuelController.stream;

  /// Emits whenever a new navigation instruction is available.
  Stream<NavigationInstruction> get navigationInstructionStream =>
      _navigationController.stream;

  // -------------------------------------------------------------------------
  // Connection lifecycle
  // -------------------------------------------------------------------------

  /// Connects to the cluster.
  ///
  /// Dummy behaviour: simulates a short connection delay, then reports
  /// [ConnectionStatus.connected]. Does nothing if already connected or
  /// connecting.
  Future<void> connect() async {
    if (_isDisposed) return;
    if (_connectionStatus != ConnectionStatus.disconnected) return;

    _setConnectionStatus(ConnectionStatus.connecting);

    // Simulated handshake time. Replace with scan, connect, and discovery.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    _setConnectionStatus(ConnectionStatus.connected);
  }

  /// Disconnects from the cluster.
  ///
  /// Dummy behaviour: immediately reports [ConnectionStatus.disconnected].
  Future<void> disconnect() async {
    if (_isDisposed) return;
    if (_connectionStatus == ConnectionStatus.disconnected) return;

    // Replace with cancelling subscriptions and closing the GATT connection.
    _setConnectionStatus(ConnectionStatus.disconnected);
  }

  // -------------------------------------------------------------------------
  // Outgoing data (phone to cluster)
  // -------------------------------------------------------------------------

  /// Sends a navigation instruction to the cluster.
  ///
  /// Dummy behaviour: stores the instruction and re-emits it on
  /// [navigationInstructionStream]. The real version will write it to the
  /// navigation GATT characteristic.
  Future<void> sendNavigationInstruction(
    NavigationInstruction instruction,
  ) async {
    if (_isDisposed) return;
    _navigationInstruction = instruction;
    _navigationController.add(instruction);
  }

  // -------------------------------------------------------------------------
  // Internals
  // -------------------------------------------------------------------------

  void _setConnectionStatus(ConnectionStatus status) {
    if (_isDisposed) return;
    _connectionStatus = status;
    _connectionController.add(status);
  }

  /// Releases all stream controllers. Called by the root [Provider].
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _connectionController.close();
    _batteryController.close();
    _fuelController.close();
    _navigationController.close();
  }
}