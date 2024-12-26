import 'package:chrono/chrono.dart';
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
        final minDate = Date.todayInLocalZone();
        final maxDate = minDate + Days(maxDateOffset);
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
    Glados2(any.weekday, any.int).test(
      'getTargetPageForFocus',
      (startOfWeek, page) {
        final daysFromWeekStart = startOfWeek
            .untilNextOrSame(DateTimetable.fromPage(page).weekday)
            .inDays;
        expect(
          VisibleDateRange.week(startOfWeek: startOfWeek)
              .getTargetPageForFocus(page.toDouble()),
          page - daysFromWeekStart,
        );
      },
    );

    Glados2(any.weekday, any.double).test(
      'getTargetPageForCurrent',
      (startOfWeek, page) {
        final daysFromWeekStart = (startOfWeek
                    .untilNextOrSame(
                      DateTimetable.fromPage(page.floor()).weekday,
                    )
                    .inDays +
                page % 1) %
            Days.perWeek;
        var targetPage = page - daysFromWeekStart;
        if (daysFromWeekStart > Days.perWeek / 2) {
          targetPage += Days.perWeek;
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
