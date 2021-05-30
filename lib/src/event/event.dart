import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' hide Interval;

import '../utils.dart';
import 'basic.dart';

/// The base class of all events.
///
/// See also:
///
/// * [BasicEvent], which provides a basic implementation to get you started.
abstract class Event with Diagnosticable {
  const Event({
    required this.start,
    required this.end,
  }) : assert(start <= end);

  /// Start of the event; inclusive.
  final DateTime start;

  /// End of the event; exclusive.
  final DateTime end;

  bool get isAllDay => end.difference(start).inDays >= 1;

  @override
  bool operator ==(dynamic other) {
    return runtimeType == other.runtimeType &&
        start == other.start &&
        end == other.end;
  }

  @override
  int get hashCode => hashValues(runtimeType, start, end);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('start', start));
    properties.add(DiagnosticsProperty('end', end));
  }
}

extension EventExtension on Event {
  DateTime get endInclusive => start == end ? end : end - 1.milliseconds;
  Interval get interval => Interval(start, endInclusive);
  Duration get duration => end.difference(start);

  bool get isPartDay => !isAllDay;
}

extension TimetableEventIterable<E extends Event> on Iterable<E> {
  List<E> sortedByStartLength() {
    return sorted((a, b) {
      final result = a.start.compareTo(b.start);
      if (result != 0) return result;
      return a.end.compareTo(b.end);
    });
  }
}
