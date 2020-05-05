import 'package:test/test.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/src/visible_range.dart';

void main() {
  group('WeekVisibleRange', () {
    WeekVisibleRange visibleRange;
    setUp(() => visibleRange = WeekVisibleRange());

    group('getTargetPage w/o velocity', () {
      LocalDate getTargetDate(LocalDate focusDate) {
        final targetPage =
            visibleRange.getTargetPageForDate(focusDate, DayOfWeek.monday);
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
  });
}
