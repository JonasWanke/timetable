import 'package:glados/glados.dart';
import 'package:timetable/src/utils.dart';
import 'package:timetable/timetable.dart';

void main() {
  group('VisibleDateRange.days', () {
    Glados2(any.positiveInt, any.int).test(
      'getTargetPageForFocus',
      (rangeSize, page) => expect(
        VisibleDateRange.days(rangeSize).getTargetPageForFocus(page.toDouble()),
        page,
      ),
    );

    Glados2(any.positiveInt, any.double).test(
      'getTargetPageForCurrent',
      (rangeSize, page) => expect(
        VisibleDateRange.days(rangeSize).getTargetPageForCurrent(page),
        page.round(),
      ),
    );

    Glados2(any.positiveInt, any.positiveInt).test(
      'scrolling with limits without swipe range',
      (visibleDayCount, maxDateOffset) {
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
      },
    );
  });

  group('VisibleDateRange.week', () {
    Glados2(any.dayOfWeek, any.int).test(
      'getTargetPageForFocus',
      (startOfWeek, page) {
        final daysFromWeekStart =
            (DateTimeTimetable.dateFromPage(page).weekday - startOfWeek) %
                DateTime.daysPerWeek;
        expect(
          VisibleDateRange.week(startOfWeek: startOfWeek)
              .getTargetPageForFocus(page.toDouble()),
          page - daysFromWeekStart,
        );
      },
    );

    Glados2(any.dayOfWeek, any.double).test(
      'getTargetPageForCurrent',
      (startOfWeek, page) {
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
              .getTargetPageForCurrent(page),
          targetPage,
        );
      },
    );
  });
}

extension on Any {
  Generator<int> get dayOfWeek =>
      any.intInRange(DateTime.monday, DateTime.sunday);
}
