import 'package:dartx/dartx.dart';
import 'package:test/test.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/src/visible_range.dart';

void main() {
  VisibleRange visibleRange;

  group('VisibleRange.days', () {
    setUp(() => visibleRange = VisibleRange.days(3));

    test('getTargetPageForFocus', () {
      // Monday of week 2020-01
      final startDate = LocalDate(2019, 12, 30);

      expect(
        0.rangeTo(2).map((offset) {
          return visibleRange.getTargetPageForFocusDate(
            startDate + Period(days: offset),
            DayOfWeek.monday,
          );
        }),
        equals(0.rangeTo(2).map((offset) => startDate.epochDay + offset)),
      );
    });

    test('getTargetPageForCurrent', () {
      // Monday of week 2020-01
      final startPage = LocalDate(2019, 12, 30).epochDay.toDouble();

      final values = {
        startPage: startPage,
        startPage - 0.4: startPage,
        startPage + 0.4: startPage,
        startPage + 1: startPage + 1,
      };
      expect(
        values.keys.map((current) {
          return visibleRange.getTargetPageForCurrent(
            current,
            DayOfWeek.monday,
          );
        }),
        equals(values.values),
      );
    });
  });

  group('VisibleRange.week', () {
    setUp(() => visibleRange = VisibleRange.week());

    group('getTargetPageForFocus', () {
      LocalDate getTargetDate(LocalDate focusDate) {
        final targetPage =
            visibleRange.getTargetPageForFocusDate(focusDate, DayOfWeek.monday);
        return LocalDate.fromEpochDay(targetPage.toInt());
      }

      Iterable<LocalDate> getTargetDates(int weekNumber) {
        return [
          DayOfWeek.monday,
          DayOfWeek.tuesday,
          DayOfWeek.wednesday,
          DayOfWeek.thursday,
          DayOfWeek.friday,
          DayOfWeek.saturday,
          DayOfWeek.sunday,
        ]
            .map((d) => WeekYearRules.iso
                .getLocalDate(2020, weekNumber, d, CalendarSystem.iso))
            .map(getTargetDate);
      }

      test('week 2020-1', () {
        expect(
          getTargetDates(1),
          everyElement(equals(LocalDate(2019, 12, 30))),
        );
      });
      test('week 2020-18', () {
        expect(
          getTargetDates(18),
          everyElement(equals(LocalDate(2020, 4, 27))),
        );
      });
    });

    test('getTargetPageForCurrent', () {
      // Monday of week 2020-01
      final startPage = LocalDate(2019, 12, 30).epochDay.toDouble();

      expect(
        (-3).rangeTo(3).map((offset) {
          return visibleRange.getTargetPageForCurrent(
            startPage + offset,
            DayOfWeek.monday,
          );
        }),
        everyElement(equals(startPage)),
      );
    });
  });
}
