import 'package:supercharged/supercharged.dart';
import 'package:test/test.dart';
import 'package:timetable/src/old/visible_range.dart';
import 'package:timetable/src/utils.dart';

void main() {
  late VisibleRange visibleRange;

  group('VisibleRange.days', () {
    setUp(() => visibleRange = VisibleRange.days(3));

    test('getTargetPageForFocus', () {
      // Monday of week 2020-01
      final startDate = DateTime.utc(2019, 12, 30);

      expect(
        0.until(2).map((offset) {
          return visibleRange.getTargetPageForFocusDate(
            startDate + offset.days,
            DateTime.monday,
          );
        }),
        equals(0.until(2).map((offset) => startDate.page + offset)),
      );
    });

    test('getTargetPageForCurrent', () {
      // Monday of week 2020-01
      final startPage = DateTime.utc(2019, 12, 30).page;

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
            DateTime.monday,
          );
        }),
        equals(values.values),
      );
    });
  });

  group('VisibleRange.week', () {
    setUp(() => visibleRange = VisibleRange.week());

    group('getTargetPageForFocus', () {
      DateTime getTargetDate(DateTime focusDate) {
        final targetPage =
            visibleRange.getTargetPageForFocusDate(focusDate, DateTime.monday);
        return DateTimeTimetable.dateFromPage(targetPage.toInt());
      }

      Iterable<DateTime> getTargetDates(DateTime weekStart) {
        return [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
          DateTime.saturday,
          DateTime.sunday,
        ].map((d) => weekStart + (d - 1).days).map(getTargetDate);
      }

      test('week 2020-W01', () {
        expect(
          getTargetDates(DateTime.utc(2019, 12, 30)),
          everyElement(equals(DateTime.utc(2019, 12, 30))),
        );
      });
      test('week 2020-W18', () {
        expect(
          getTargetDates(DateTime.utc(2020, 04, 27)),
          everyElement(equals(DateTime.utc(2020, 4, 27))),
        );
      });
    });

    test('getTargetPageForCurrent', () {
      // Monday of week 2020-W01
      final startPage = DateTime.utc(2019, 12, 30).page;

      expect(
        (-3).until(3).map((offset) {
          return visibleRange.getTargetPageForCurrent(
            startPage + offset,
            DateTime.monday,
          );
        }),
        everyElement(equals(startPage)),
      );
    });
  });
}
