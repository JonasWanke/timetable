import 'package:test/test.dart';
import 'package:timetable/src/event.dart';
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
        start + Duration(hours: 10),
        start + Duration(days: 1, hours: 12),
      ),
      _TestEvent(
        start + Duration(hours: 10),
        start + Duration(days: 2, hours: 12),
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

    // test('endDateInclusive', () {
    //   expect(events.map((e) => e.endDateInclusive), [
    //     start,
    //     start,
    //     start + 1.days,
    //     start,
    //     start + 1.days,
    //     start + 2.days,
    //   ]);
    // });

    // test('intersectingDates', () {
    //   expect(events.map((e) => e.intersectingDates), [
    //     DateInterval(start, start),
    //     DateInterval(start, start),
    //     DateInterval(start, start + 1.days),
    //     DateInterval(start, start),
    //     DateInterval(start, start + 1.days),
    //     DateInterval(start, start + 2.days),
    //   ]);
    // });
  });
}

class _TestEvent extends Event {
  const _TestEvent(DateTime start, DateTime end)
      : super(id: '', start: start, end: end);
}
