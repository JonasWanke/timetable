import 'package:time_machine/time_machine.dart';
import 'package:timetable/timetable.dart';

import 'event.dart';

abstract class EventProvider<E extends Event> {
  const EventProvider();

  const factory EventProvider.simple(List<E> events) = SimpleEventProvider<E>;

  Iterable<Event> getPartDayEventsIntersecting(LocalDate date);
}

/// An [EventProvider] accepting a single fixed list of events.
class SimpleEventProvider<E extends Event> extends EventProvider<E> {
  const SimpleEventProvider(List<E> events)
      : assert(events != null),
        _events = events;

  final List<E> _events;

  @override
  Iterable<Event> getPartDayEventsIntersecting(LocalDate date) {
    return _events
        .where((e) => e.isPartDay)
        .where((e) => e.intersectsDate(date));
  }
}
