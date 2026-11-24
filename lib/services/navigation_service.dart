import 'dart:async';

import '../models/vehicle_model.dart';

/// Provides turn-by-turn navigation instructions.
///
/// **Current state:** dummy data only. A fixed route is stepped through on
/// demand with [advance]. No GPS, maps, or network calls are involved.
///
/// **Future implementation notes:**
///  * Replace [_route] with steps produced by a routing provider.
///  * Drive [_publish] from live location updates instead of [advance].
///  * Keep the public API ([currentInstruction], [instructionStream],
///    [start], [stop], [advance]) unchanged so callers need no edits.
class NavigationService {
  NavigationService({List<NavigationInstruction>? route})
      : _route = route ?? _dummyRoute;

  // -------------------------------------------------------------------------
  // Dummy route
  // -------------------------------------------------------------------------

  /// A short Chennai route. The first step matches the spec dummy data
  /// ("Turn Left, 250 m").
  static const List<NavigationInstruction> _dummyRoute = [
    NavigationInstruction(
      direction: TurnDirection.left,
      distanceMeters: 250,
      roadName: 'Anna Salai',
      etaMinutes: 18,
      remainingKm: 7.4,
    ),
    NavigationInstruction(
      direction: TurnDirection.right,
      distanceMeters: 800,
      roadName: 'Mount Road',
      etaMinutes: 15,
      remainingKm: 6.1,
    ),
    NavigationInstruction(
      direction: TurnDirection.straight,
      distanceMeters: 1800,
      roadName: 'Cathedral Road',
      etaMinutes: 11,
      remainingKm: 4.2,
    ),
    NavigationInstruction(
      direction: TurnDirection.slightRight,
      distanceMeters: 600,
      roadName: 'TTK Road',
      etaMinutes: 6,
      remainingKm: 2.0,
    ),
    NavigationInstruction(
      direction: TurnDirection.arrive,
      distanceMeters: 120,
      roadName: 'Destination',
      etaMinutes: 1,
      remainingKm: 0.1,
    ),
  ];

  // -------------------------------------------------------------------------
  // State
  // -------------------------------------------------------------------------

  final List<NavigationInstruction> _route;
  int _stepIndex = 0;
  bool _isActive = true;
  bool _isDisposed = false;

  final StreamController<NavigationInstruction> _controller =
      StreamController<NavigationInstruction>.broadcast();

  /// The instruction for the current step of the route.
  NavigationInstruction get currentInstruction => _route[_stepIndex];

  /// Whether guidance is currently running.
  bool get isActive => _isActive;

  /// Zero-based index of the current step.
  int get stepIndex => _stepIndex;

  /// Total number of steps in the route.
  int get stepCount => _route.length;

  /// Whether the current step is the final one.
  bool get isLastStep => _stepIndex == _route.length - 1;

  /// Emits whenever the current instruction changes.
  Stream<NavigationInstruction> get instructionStream => _controller.stream;

  // -------------------------------------------------------------------------
  // Control
  // -------------------------------------------------------------------------

  /// Starts guidance from the first step of the route.
  void start() {
    if (_isDisposed) return;
    _isActive = true;
    _stepIndex = 0;
    _publish();
  }

  /// Stops guidance. The last instruction remains readable through
  /// [currentInstruction], but no further events are emitted by [advance].
  void stop() {
    if (_isDisposed) return;
    _isActive = false;
  }

  /// Moves to the next step. Does nothing on the last step or when
  /// guidance is stopped.
  void advance() {
    if (_isDisposed || !_isActive || isLastStep) return;
    _stepIndex++;
    _publish();
  }

  // -------------------------------------------------------------------------
  // Internals
  // -------------------------------------------------------------------------

  void _publish() {
    if (_isDisposed) return;
    _controller.add(currentInstruction);
  }

  /// Releases the stream controller. Called by the root [Provider].
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _controller.close();
  }
}