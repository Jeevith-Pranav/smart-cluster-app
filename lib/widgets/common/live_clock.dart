import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';

/// Shows the current time and date, updating on every minute change.
///
/// ```dart
/// const LiveClock()                                   // right-aligned
/// const LiveClock(crossAxisAlignment: CrossAxisAlignment.start)
/// ```
///
/// The widget owns a [Timer], so it is stateful. Everything around it can
/// stay stateless.
class LiveClock extends StatefulWidget {
  const LiveClock({
    super.key,
    this.crossAxisAlignment = CrossAxisAlignment.end,
    this.now = DateTime.now,
  });

  /// Horizontal alignment of the time and date lines.
  final CrossAxisAlignment crossAxisAlignment;

  /// Source of the current time. Override in tests to control the clock.
  final DateTime Function() now;

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  /// Locale-aware time, for example "10:42 AM".
  static final DateFormat _timeFormat = DateFormat.jm();

  /// Short date, for example "Sat, 21 Nov".
  static final DateFormat _dateFormat = DateFormat('EEE, d MMM');

  /// Spoken date, for example "Saturday 21 November".
  static final DateFormat _spokenDateFormat = DateFormat('EEEE d MMMM');

  /// Current time truncated to the minute. A [ValueNotifier] only notifies
  /// when the value actually changes, so the text rebuilds once per minute.
  late final ValueNotifier<DateTime> _minute;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _minute = ValueNotifier<DateTime>(_truncateToMinute(widget.now()));
    _scheduleNextTick();
  }

  /// Drops seconds and smaller units.
  DateTime _truncateToMinute(DateTime time) {
    return DateTime(time.year, time.month, time.day, time.hour, time.minute);
  }

  /// Fires once, just after the next minute boundary, then re-arms itself.
  /// Re-arming each time avoids drift that a fixed periodic timer would
  /// accumulate.
  void _scheduleNextTick() {
    final now = widget.now();
    final intoMinute = Duration(
      seconds: now.second,
      milliseconds: now.millisecond,
      microseconds: now.microsecond,
    );
    // A small margin guarantees the timer fires after the boundary.
    final delay =
        const Duration(minutes: 1) - intoMinute + const Duration(milliseconds: 50);

    _timer = Timer(delay, () {
      _minute.value = _truncateToMinute(widget.now());
      _scheduleNextTick();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _minute.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder<DateTime>(
      valueListenable: _minute,
      builder: (context, time, _) {
        final timeText = _timeFormat.format(time);

        return Semantics(
          container: true,
          label: 'Time $timeText, ${_spokenDateFormat.format(time)}',
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: widget.crossAxisAlignment,
              children: [
                Text(
                  timeText,
                  maxLines: 1,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    height: 1.05,
                  ),
                ),
                Text(
                  _dateFormat.format(time),
                  maxLines: 1,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}