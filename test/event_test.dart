import 'package:chrono/chrono.dart';
import 'package:test/test.dart';
import 'package:timetable/src/event/event.dart';
import 'package:timetable/src/utils.dart';

void main() {
  group('TimetableEvent', () {
    final start = const Year(2020).firstDay.atMidnight;

    final events = [
      _TestEvent(start, start),
      _TestEvent(start, start + const Days(1)),
      _TestEvent(start, start + const Days(2)),
      _TestEvent(start + 10.hours, start + 12.hours),
      _TestEvent(
        start + const Hours(10),
        start + const Days(1) + const Hours(12),
      ),
      _TestEvent(
        start + const Hours(10),
        start + const Days(2) + const Hours(12),
      ),
    ];

    test('intersectsInterval', () {
      final intervals = [
        {
          Interval(start - const Days(1), start - const Days(1)): false,
          Interval(start, start): true,
          Interval(start, start + const Days(1)): true,
          Interval(start + const Days(1), start + const Days(1)): false,
        },
        {
          Interval(start - const Days(1), start - const Days(1)): false,
          Interval(start, start): true,
          Interval(start, start + const Days(1)): true,
          Interval(start + const Days(1), start + const Days(1)): false,
        },
        {
          Interval(start - const Days(1), start - const Days(1)): false,
          Interval(start, start): true,
          Interval(start, start + const Days(1)): true,
          Interval(start + const Days(1), start + const Days(1)): true,
        },
        {
          Interval(start - const Days(1), start - const Days(1)): false,
          Interval(start, start): false,
          Interval(start, start + const Days(1)): true,
          Interval(start + const Days(1), start + const Days(1)): false,
        },
        {
          Interval(start - const Days(1), start - const Days(1)): false,
          Interval(start, start): false,
          Interval(start, start + const Days(1)): true,
          Interval(start + const Days(1), start + const Days(1)): true,
        },
        {
          Interval(start - const Days(1), start - const Days(1)): false,
          Interval(start, start): false,
          Interval(start, start + const Days(1)): true,
          Interval(start + const Days(1), start + const Days(1)): true,
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
