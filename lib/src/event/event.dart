import 'package:chrono/chrono.dart';
import 'package:deranged/deranged.dart';
import 'package:flutter/foundation.dart';

import '../utils.dart';
import 'basic.dart';

/// The base class of all events.
///
/// See also:
///
/// * [BasicEvent], which provides a basic implementation to get you started.
abstract class Event with Diagnosticable {
  Event({required this.range, this.sortKey}) : assert(range.start <= range.end);

  final Range<CDateTime> range;

  /// A key used to sort events with the same start and end time.
  final Comparable<dynamic>? sortKey;

  bool get isAllDay => range.end.timeDifference(range.start) >= Hours.normalDay;
  bool get isPartDay => !isAllDay;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('range', range));
    properties.add(
      FlagProperty(
        'isAllDay',
        value: isAllDay,
        ifTrue: 'all-day',
        ifFalse: 'part-day',
      ),
    );
  }
}

extension EventExtension on Event {
  RangeInclusive<Date> get dateRange =>
      RangeInclusive(range.start.date, (range.end - Nanoseconds(1)).date);
}

extension TimetableEventIterable<E extends Event> on Iterable<E> {
  List<E> sortedByStartLength() {
    return sorted((a, b) {
      var result = a.range.start.compareTo(b.range.start);
      if (result != 0) return result;
      result = a.range.end.compareTo(b.range.end);
      if (result != 0) return result;

      return switch ((a.sortKey, b.sortKey)) {
        (final a?, final b?) => a.compareTo(b),
        (null, null) => 0,
        (null, _) => -1, // a comes before b
        (_, null) => 1, // b comes before a
      };
    });
  }
}
