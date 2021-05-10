import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

import '../date/date_page_view.dart';
import '../styling.dart';
import '../utils.dart';
import 'date_indicator.dart';
import 'week_indicator.dart';
import 'weekday_indicator.dart';

class MonthWidget extends StatelessWidget {
  MonthWidget(
    this.month, {
    this.startOfWeek = DateTime.monday,
    DateWidgetBuilder? dateBuilder,
  })  : assert(month.isValidTimetableMonth),
        assert(startOfWeek.isValidTimetableDayOfWeek),
        dateBuilder = dateBuilder ?? _defaultDateBuilder(month);

  final DateTime month;
  final int startOfWeek;

  final DateWidgetBuilder dateBuilder;
  static DateWidgetBuilder _defaultDateBuilder(DateTime month) {
    assert(month.isValidTimetableMonth);
    return (context, date) {
      assert(date.isValidTimetableDate);
      return Padding(
        padding: EdgeInsets.all(4),
        child: DateIndicator(
          date,
          // textStyle: date.firstDayOfMonth != month
          //     ? TextStyle(color: context.theme.disabledOnBackground)
          //     : null,
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = month.previousOrSame(startOfWeek);
    final weekCount = (month.lastDayOfMonth.difference(firstDay).inDays /
            DateTime.daysPerWeek)
        .ceil();

    final today = DateTimeTimetable.today();

    return LayoutGrid(
      columnSizes: [
        auto,
        ...repeat(DateTime.daysPerWeek, [1.fr]),
      ],
      rowSizes: [
        auto,
        ...repeat(weekCount, [auto]),
      ],
      children: [
        // By using today as the base, highlighting for the current day is
        // applied automatically.
        for (final day in 1.rangeTo(DateTime.daysPerWeek))
          GridPlacement(
            columnStart: day,
            rowStart: 0,
            child: Center(
              child: WeekdayIndicator(today + (day - today.weekday).days),
            ),
          ),
        GridPlacement(
          columnStart: 0,
          rowStart: 1,
          rowSpan: weekCount,
          child: _buildWeeks(context, firstDay, weekCount),
        ),
        for (final week in 0.until(weekCount))
          for (final weekday in 0.until(DateTime.daysPerWeek))
            GridPlacement(
              columnStart: 1 + weekday,
              rowStart: 1 + week,
              child: Center(
                child: dateBuilder(
                  context,
                  firstDay + (DateTime.daysPerWeek * week + weekday).days,
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildWeeks(BuildContext context, DateTime firstDay, int weekCount) {
    assert(firstDay.isValidTimetableDate);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final index in 0.until(weekCount))
            WeekIndicator.forDate(
              firstDay + (index * DateTime.daysPerWeek).days,
              // style: WeekIndicatorStyle(
              //   decoration: TemporalStateProperty.all(BoxDecoration()),
              // ),
              alwaysUseNarrowestVariant: true,
            ),
        ],
      ),
    );
  }
}
