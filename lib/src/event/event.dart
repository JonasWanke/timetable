import '../utils.dart';
import 'basic.dart';

/// The base class of all events.
///
/// See also:
///
/// * [BasicEvent], which provides a basic implementation to get you started.
abstract interface class Event {
  /// Start of the event; inclusive.
  DateTime get start;

  /// End of the event; exclusive.
  DateTime get end;

  bool get isAllDay;
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
