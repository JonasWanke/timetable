import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' hide Interval;
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';

import 'basic.dart';
import 'utils.dart';

/// The base class of all events.
///
/// See also:
/// - [BasicEvent], which provides a basic implementation to get you started.
abstract class Event with Diagnosticable {
  const Event({
    required this.id,
    required this.start,
    required this.end,
  }) : assert(start <= end);

  /// A unique ID, used, e.g., for animating events.
  final Object id;

  /// Start of the event; inclusive.
  final DateTime start;

  // End of the event; exclusive.
  final DateTime end;

  // @nonVirtual
  // DateTime get endDateInclusive {
  //   if (start < end && end.isAtStartOfDay) return end.previousDay.startOfDay;
  //   return end.startOfDay;
  // }

  @nonVirtual
  Interval get interval =>
      Interval(start, start == end ? end : end - 1.milliseconds);

  // @nonVirtual
  // DateInterval get intersectingDates =>
  //     DateInterval(start.calendarDate, endDateInclusive);

  bool get isAllDay => end.difference(start).inDays >= 1;
  @nonVirtual
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('id', id));
    properties.add(DiagnosticsProperty('start', start));
    properties.add(DiagnosticsProperty('end', end));
  }
}

extension TimetableEventIterable<E extends Event> on Iterable<E> {
  // Iterable<E> get allDayEvents => where((e) => e.isAllDay);
  // Iterable<E> get partDayEvents => where((e) => e.isPartDay);

  // Iterable<E> intersecting(DateTime dateTime) =>
  //     where((e) => e.intersects(dateTime));
  // Iterable<E> intersectingInterval(Interval interval) =>
  //     where((e) => e.intersectsInterval(interval));

  List<E> sortedByStartLength() {
    int comparator(E a, E b) {
      final result = a.start.compareTo(b.start);
      if (result != 0) return result;
      return a.end.compareTo(b.end);
    }

    return sorted(comparator);
  }
}

typedef EventBuilder<E extends Event> = Widget Function(
  BuildContext context,
  E event,
);
