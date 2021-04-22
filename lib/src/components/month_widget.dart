import 'package:flutter/material.dart';
import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

import '../styling.dart';
import '../utils.dart';
import 'date_indicator.dart';
import 'week_indicator.dart';
import 'weekday_indicator.dart';

class MonthWidget extends StatelessWidget {
  MonthWidget(
    this.month, {
    this.startOfWeek = DateTime.monday,
  })  : assert(month.isValidTimetableMonth),
        assert(startOfWeek.isValidTimetableDayOfWeek);

  final DateTime month;
  final int startOfWeek;

  @override
  Widget build(BuildContext context) {
    final firstDay = month.previousOrSame(startOfWeek);
    final weekCount = (month.lastDayOfMonth.difference(firstDay).inDays /
            DateTime.daysPerWeek)
        .ceil();

    return LayoutGrid(
      columnSizes: [
        auto,
        ...repeat(DateTime.daysPerWeek, [1.fr]),
      ],
      rowSizes: [
        auto,
        ...repeat(weekCount, [auto]),
      ],
      columnGap: 8,
      rowGap: 8,
      children: [
        GridPlacement(
          columnStart: 1,
          columnSpan: DateTime.daysPerWeek,
          rowStart: 0,
          child: _buildWeekdays(),
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
                child: _buildDate(
                  context,
                  firstDay + (DateTime.daysPerWeek * week + weekday).days,
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildWeekdays() {
    final today = DateTimeTimetable.today();
    return Row(children: [
      // By using today as the base, highlighting for the current day is
      // applied automatically.
      for (final day in 1.rangeTo(DateTime.daysPerWeek))
        Expanded(
          child: Center(
            child: WeekdayIndicator(today + (day - today.weekday).days),
          ),
        ),
    ]);
  }

  Widget _buildWeeks(BuildContext context, DateTime firstDay, int weekCount) {
    assert(firstDay.isValidTimetableDate);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.theme.brightness.contrastColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final index in 0.until(weekCount))
              WeekIndicator.forDate(
                firstDay + (index * DateTime.daysPerWeek).days,
                style: WeekIndicatorStyle(
                  decoration: TemporalStateProperty.all(BoxDecoration()),
                ),
                alwaysUseNarrowestVariant: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDate(BuildContext context, DateTime date) {
    assert(date.isValidTimetableDate);
    return DateIndicator(
      date,
      textStyle: date.firstDayOfMonth != month
          ? TextStyle(color: context.theme.disabledOnBackground)
          : null,
    );
  }
}
