import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/timetable.dart';

import 'event.dart';

abstract class EventProvider<E extends Event> {
  const EventProvider();

  factory EventProvider.list(List<E> events) = ListEventProvider<E>;

  void onVisibleDatesChanged(DateInterval visibleRange) {}

  Stream<Iterable<E>> getPartDayEventsIntersecting(LocalDate date);

  void dispose() {}
}

/// An [EventProvider] accepting a single fixed list of events.
class ListEventProvider<E extends Event> extends EventProvider<E> {
  ListEventProvider(List<E> events)
      : assert(events != null),
        _events = events;

  final List<E> _events;

  @override
  Stream<Iterable<E>> getPartDayEventsIntersecting(LocalDate date) {
    final events = _events.partDayEvents.intersectingDate(date);
    return Stream.value(events);
  }
}

mixin VisibleDatesStreamEventProviderMixin<E extends Event>
    on EventProvider<E> {
  final _visibleDates = BehaviorSubject<DateInterval>();
  ValueStream<DateInterval> get visibleDates => _visibleDates.stream;

  @mustCallSuper
  @override
  void onVisibleDatesChanged(DateInterval visibleRange) {
    _visibleDates.add(visibleRange);
  }

  @mustCallSuper
  @override
  void dispose() {
    _visibleDates.close();
  }
}

typedef StreamedEventGetter<E extends Event> = Stream<Iterable<E>> Function(
    DateInterval dates);

class StreamEventProvider<E extends Event> extends EventProvider<E>
    with VisibleDatesStreamEventProviderMixin<E> {
  StreamEventProvider({@required this.eventGetter})
      : assert(eventGetter != null) {
    _events = visibleDates.switchMap(eventGetter).publishValue();
  }

  final StreamedEventGetter<E> eventGetter;
  ValueStream<Iterable<E>> _events;

  @override
  Stream<Iterable<E>> getPartDayEventsIntersecting(LocalDate date) {
    return _events.map((events) => events.partDayEvents.intersectingDate(date));
  }
}
