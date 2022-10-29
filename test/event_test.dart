import 'package:test/test.dart';
import 'package:timetable/src/event/event.dart';
import 'package:timetable/src/utils.dart';

void main() {
  group('TimetableEvent', () {
    final start = DateTime.utc(2020, 1, 1);

    final events = [
      _TestEvent(start, start),
      _TestEvent(start, start + 1.days),
      _TestEvent(start, start + 2.days),
      _TestEvent(start + 10.hours, start + 12.hours),
      _TestEvent(
        start + const Duration(hours: 10),
        start + const Duration(days: 1, hours: 12),
      ),
      _TestEvent(
        start + const Duration(hours: 10),
        start + const Duration(days: 2, hours: 12),
      ),
    ];

    test('intersectsInterval', () {
      final intervals = [
        {
          Interval(start - 1.days, start - 1.days): false,
          Interval(start, start): true,
          Interval(start, start + 1.days): true,
          Interval(start + 1.days, start + 1.days): false,
        },
        {
          Interval(start - 1.days, start - 1.days): false,
          Interval(start, start): true,
          Interval(start, start + 1.days): true,
          Interval(start + 1.days, start + 1.days): false,
        },
        {
          Interval(start - 1.days, start - 1.days): false,
          Interval(start, start): true,
          Interval(start, start + 1.days): true,
          Interval(start + 1.days, start + 1.days): true,
        },
        {
          Interval(start - 1.days, start - 1.days): false,
          Interval(start, start): false,
          Interval(start, start + 1.days): true,
          Interval(start + 1.days, start + 1.days): false,
        },
        {
          Interval(start - 1.days, start - 1.days): false,
          Interval(start, start): false,
          Interval(start, start + 1.days): true,
          Interval(start + 1.days, start + 1.days): true,
        },
        {
          Interval(start - 1.days, start - 1.days): false,
          Interval(start, start): false,
          Interval(start, start + 1.days): true,
          Interval(start + 1.days, start + 1.days): true,
        },
      ];

      for (var index = 0; index < events.length; index++) {
        final event = events[index];
        final ints = intervals[index];
        expect(
          ints.keys.map(event.interval.intersects),
          ints.values,
          reason: 'index: $index',
        );
      }
    });
  });
}

class _TestEvent extends Event {
  const _TestEvent(DateTime start, DateTime end)
      : super(start: start, end: end);
}
