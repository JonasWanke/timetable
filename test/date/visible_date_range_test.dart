import 'package:glados/glados.dart';
import 'package:timetable/src/utils.dart';
import 'package:timetable/timetable.dart';
import 'package:tuple_glados/tuple_glados.dart';

void main() {
  group('VisibleDateRange.days', () {
    Glados(any.tuple2(any.positiveInt, any.int)).test('getTargetPageForFocus',
        (it) {
      final rangeSize = it.item1;
      final page = it.item2.toDouble();
      expect(
        VisibleDateRange.days(rangeSize).getTargetPageForFocus(page),
        page,
      );
    });

    Glados(any.tuple2(any.positiveInt, any.double))
        .test('getTargetPageForCurrent', (it) {
      final rangeSize = it.item1;
      final page = it.item2;
      expect(
        VisibleDateRange.days(rangeSize).getTargetPageForCurrent(page),
        page.round(),
      );
    });

    Glados(any.tuple2(any.positiveInt, any.positiveInt))
        .test('scrolling with limits without swipe range', (it) {
      final visibleDayCount = it.item1;
      final maxDateOffset = it.item2;

      final minDate = DateTimeTimetable.today();
      final maxDate = minDate + maxDateOffset.days;
      final range = DaysVisibleDateRange(
        visibleDayCount,
        minDate: minDate,
        maxDate: maxDate,
      );
      expect(range.visibleDayCount, visibleDayCount);
      expect(range.minPage, minDate.page);
      expect(
        range.maxPage,
        (maxDate.page - visibleDayCount + 1).coerceAtLeast(minDate.page),
      );
    });
  });

  group('VisibleDateRange.week', () {
    Glados(any.tuple2(any.dayOfWeek, any.int)).test('getTargetPageForFocus',
        (it) {
      final startOfWeek = it.item1;
      final page = it.item2;

      final daysFromWeekStart =
          (DateTimeTimetable.dateFromPage(page).weekday - startOfWeek) %
              DateTime.daysPerWeek;
      expect(
        VisibleDateRange.week(startOfWeek: startOfWeek)
            .getTargetPageForFocus(page.toDouble()),
        page - daysFromWeekStart,
      );
    });

    Glados(any.tuple2(any.dayOfWeek, any.double))
        .test('getTargetPageForCurrent', (it) {
      final startOfWeek = it.item1;
      final page = it.item2;

      final daysFromWeekStart =
          (DateTimeTimetable.dateFromPage(page.floor()).weekday +
                  page % 1 -
                  startOfWeek) %
              DateTime.daysPerWeek;
      var targetPage = page - daysFromWeekStart;
      if (daysFromWeekStart > DateTime.daysPerWeek / 2) {
        targetPage += DateTime.daysPerWeek;
      }

      expect(
        VisibleDateRange.week(startOfWeek: startOfWeek)
            .getTargetPageForCurrent(page.toDouble()),
        targetPage,
      );
    });
  });
}

extension AnyTimetable on Any {
  Generator<DateTime> get date => any.int.map(DateTimeTimetable.dateFromPage);
  Generator<int> get dayOfWeek =>
      any.intInRange(DateTime.monday, DateTime.sunday);
}
