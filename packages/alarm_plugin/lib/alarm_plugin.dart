import 'dart:async';

import 'alarm_event.dart';

/// Stub implementation that simply logs scheduled alarms.
class AlarmPlugin {
  static final List<AlarmEvent> _scheduledEvents = [];

  static Future<void> add2Alarm(AlarmEvent event) async {
    _scheduledEvents.add(event);
    // ignore: avoid_print
    print(
        '[AlarmPlugin] Scheduled alarm "${event.title}" at ${event.hour}:${event.minutes} for days ${event.days}');
  }

  static List<AlarmEvent> get scheduledEvents =>
      List.unmodifiable(_scheduledEvents);
}

