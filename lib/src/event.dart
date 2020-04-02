import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

abstract class Event {
  Event({
    @required this.id,
    @required this.start,
    @required this.end,
  })  : assert(id != null),
        assert(start != null),
        assert(end != null);

  final Object id;
  final LocalDateTime start;
  final LocalDateTime end;
  bool get isAllDay => start.periodUntil(end).normalize().days >= 1;
  bool get isPartDay => !isAllDay;

  @override
  bool operator ==(dynamic other) {
    return runtimeType == other.runtimeType &&
        id == other.id &&
        start == other.start &&
        end == other.end;
  }

  @override
  int get hashCode => hashList([runtimeType, id, start, end]);
}

extension TimetableEvent on Event {
  bool intersectsDate(LocalDate date) =>
      start <= date.at(LocalTime.maxValue) &&
      end >= date.at(LocalTime.minValue);
}

extension TimetableEventIterable<E extends Event> on Iterable<E> {
  Iterable<E> get partDayEvents => where((e) => e.isPartDay);

  Iterable<E> intersectingDate(LocalDate date) =>
      where((e) => e.intersectsDate(date));
}
