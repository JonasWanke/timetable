import 'package:test/test.dart';
import 'package:time_machine/time_machine.dart';
import 'package:dartx/dartx.dart';
import 'package:timetable/src/event.dart';

void main() {
  group('TimetableEvent', () {
    final startDate = LocalDate(2020, 1, 1);
    final start = startDate.atMidnight();
    final day = Period(days: 1);

    final events = [
      _TestEvent(start, start),
      _TestEvent(start, start + day),
      _TestEvent(start, start + Period(days: 2)),
      _TestEvent(start.addHours(10), start.addHours(12)),
      _TestEvent(
        start + Period(hours: 10),
        start + Period(days: 1, hours: 12),
      ),
      _TestEvent(
        start + Period(hours: 10),
        start + Period(days: 2, hours: 12),
      ),
    ];

    test('intersectsInterval', () {
      final intervals = [
        {
          DateInterval(startDate - day, startDate - day): false,
          DateInterval(startDate, startDate): true,
          DateInterval(startDate, startDate + day): true,
          DateInterval(startDate + day, startDate + day): false,
        },
        {
          DateInterval(startDate - day, startDate - day): false,
          DateInterval(startDate, startDate): true,
          DateInterval(startDate, startDate + day): true,
          DateInterval(startDate + day, startDate + day): false,
        },
        {
          DateInterval(startDate - day, startDate - day): false,
          DateInterval(startDate, startDate): true,
          DateInterval(startDate, startDate + day): true,
          DateInterval(startDate + day, startDate + day): true,
        },
        {
          DateInterval(startDate - day, startDate - day): false,
          DateInterval(startDate, startDate): true,
          DateInterval(startDate, startDate + day): true,
          DateInterval(startDate + day, startDate + day): false,
        },
        {
          DateInterval(startDate - day, startDate - day): false,
          DateInterval(startDate, startDate): true,
          DateInterval(startDate, startDate + day): true,
          DateInterval(startDate + day, startDate + day): true,
        },
        {
          DateInterval(startDate - day, startDate - day): false,
          DateInterval(startDate, startDate): true,
          DateInterval(startDate, startDate + day): true,
          DateInterval(startDate + day, startDate + day): true,
        },
      ];

      for (final index in events.indices) {
        final event = events[index];
        final ints = intervals[index];
        expect(
          ints.keys.map(event.intersectsInterval),
          ints.values,
          reason: 'index: $index',
        );
      }
    });

    test('endDateInclusive', () {
      expect(events.map((e) => e.endDateInclusive), [
        startDate,
        startDate,
        startDate + day,
        startDate,
        startDate + day,
        startDate + Period(days: 2),
      ]);
    });

    test('intersectingDates', () {
      expect(events.map((e) => e.intersectingDates), [
        DateInterval(startDate, startDate),
        DateInterval(startDate, startDate),
        DateInterval(startDate, startDate + day),
        DateInterval(startDate, startDate),
        DateInterval(startDate, startDate + day),
        DateInterval(startDate, startDate + Period(days: 2)),
      ]);
    });
  });
}

class _TestEvent extends Event {
  const _TestEvent(
    LocalDateTime start,
    LocalDateTime end,
  ) : super(id: '', start: start, end: end);
}
