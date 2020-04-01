import 'package:flutter/foundation.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/timetable.dart';

import 'event.dart';

abstract class EventProvider<E extends Event> {
  const EventProvider();

  factory EventProvider.simple(List<E> events) = SimpleEventProvider<E>;

  void dispose() {}

  ValueListenable<Iterable<Event>> getPartDayEventsIntersecting(LocalDate date);
}

/// An [EventProvider] accepting a single fixed list of events.
class SimpleEventProvider<E extends Event> extends EventProvider<E> {
  SimpleEventProvider(List<E> events)
      : assert(events != null),
        _events = events;

  final List<E> _events;
  final Map<LocalDate, ValueNotifier<Iterable<Event>>> _eventsPerDate = {};

  @override
  void dispose() {
    for (final valueNotifier in _eventsPerDate.values) {
      valueNotifier.dispose();
    }
    super.dispose();
  }

  @override
  ValueListenable<Iterable<Event>> getPartDayEventsIntersecting(
      LocalDate date) {
    _eventsPerDate[date] ??= ValueNotifier(
      _events.where((e) => e.isPartDay).where((e) => e.intersectsDate(date)),
    );

    return _eventsPerDate[date];
  }
}
