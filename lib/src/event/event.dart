import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' hide Interval;
import 'package:meta/meta.dart';

import '../utils.dart';
import 'basic.dart';

/// The base class of all events.
///
/// See also:
/// - [BasicEvent], which provides a basic implementation to get you started.
abstract class Event with Diagnosticable {
  const Event({
    this.showOnTop = false,
    required this.start,
    required this.end,
  }) : assert(start <= end);

  final bool showOnTop;

  /// Start of the event; inclusive.
  final DateTime start;

  /// End of the event; exclusive.
  final DateTime end;

  @nonVirtual
  Interval get interval =>
      Interval(start, start == end ? end : end - 1.milliseconds);

  bool get isAllDay => end.difference(start).inDays >= 1;
  @nonVirtual
  bool get isPartDay => !isAllDay;

  @override
  bool operator ==(dynamic other) {
    return runtimeType == other.runtimeType &&
        showOnTop == other.showOnTop &&
        start == other.start &&
        end == other.end;
  }

  @override
  int get hashCode => hashList([runtimeType, showOnTop, start, end]);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty(
      'showOnTop',
      value: showOnTop,
      ifTrue: 'show on top of other events',
    ));
    properties.add(DiagnosticsProperty('start', start));
    properties.add(DiagnosticsProperty('end', end));
  }
}

extension EventExtension on Event {
  Duration get duration => end.difference(start);
}

extension TimetableEventIterable<E extends Event> on Iterable<E> {
  List<E> sortedByOnTopStartLength() {
    int comparator(E a, E b) {
      if (!a.showOnTop && b.showOnTop) {
        return -1;
      } else if (a.showOnTop && !b.showOnTop) {
        return 1;
      }

      final result = a.start.compareTo(b.start);
      if (result != 0) return result;
      return a.end.compareTo(b.end);
    }

    return sorted(comparator);
  }
}
