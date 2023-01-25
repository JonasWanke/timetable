import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

import '../config.dart';
import '../theme.dart';
import '../utils.dart';
import '../week.dart';
import 'date_indicator.dart';
import 'week_indicator.dart';
import 'weekday_indicator.dart';

/// A widget that displays the days of the given month in a grid, with weekdays
/// at the top and week numbers at the left.
///
/// See also:
///
/// * [MonthWidgetStyle], which defines visual properties for this widget.
/// * [TimetableTheme] (and [TimetableConfig]), which provide styles to
///   descendant Timetable widgets.
class MonthWidget extends StatelessWidget {
  MonthWidget(
    this.month, {
    DateWidgetBuilder? weekDayBuilder,
    WeekWidgetBuilder? weekBuilder,
    DateWidgetBuilder? dateBuilder,
    this.style,
  })  : assert(month.debugCheckIsValidTimetableMonth()),
        weekDayBuilder =
            weekDayBuilder ?? ((context, date) => WeekdayIndicator(date)),
        weekBuilder = weekBuilder ??
            ((context, week) {
              final timetableTheme = TimetableTheme.orDefaultOf(context);
              return WeekIndicator(
                week,
                style: (style ?? timetableTheme.monthWidgetStyleProvider(month))
                        .removeIndividualWeekDecorations
                    ? timetableTheme
                        .weekIndicatorStyleProvider(week)
                        .copyWith(decoration: const BoxDecoration())
                    : null,
                alwaysUseNarrowestVariant: true,
              );
            }),
        dateBuilder = dateBuilder ??
            ((context, date) {
              assert(date.debugCheckIsValidTimetableDate());

              final timetableTheme = TimetableTheme.orDefaultOf(context);
              DateIndicatorStyle? dateStyle;
              if (date.firstDayOfMonth != month &&
                  (style ?? timetableTheme.monthWidgetStyleProvider(month))
                      .showDatesFromOtherMonthsAsDisabled) {
                final original =
                    timetableTheme.dateIndicatorStyleProvider(date);
                dateStyle = original.copyWith(
                  textStyle: original.textStyle.copyWith(
                    color: context.theme.colorScheme.background.disabledOnColor,
                  ),
                );
              }
              return DateIndicator(date, style: dateStyle);
            });

  final DateTime month;

  final DateWidgetBuilder weekDayBuilder;
  final WeekWidgetBuilder weekBuilder;
  final DateWidgetBuilder dateBuilder;

  final MonthWidgetStyle? style;

  @override
  Widget build(BuildContext context) {
    final style = this.style ??
        TimetableTheme.orDefaultOf(context).monthWidgetStyleProvider(month);

    final firstDay = month.previousOrSame(style.startOfWeek);
    final minDayCount = month.lastDayOfMonth.difference(firstDay).inDays + 1;
    final weekCount = (minDayCount / DateTime.daysPerWeek).ceil();

    final today = DateTimeTimetable.today();

    Widget buildDate(int week, int weekday) {
      final date = firstDay + (DateTime.daysPerWeek * week + weekday).days;
      if (!style.showDatesFromOtherMonths && date.firstDayOfMonth != month) {
        return const SizedBox.shrink();
      }

      return Center(
        child: Padding(
          padding: style.datePadding,
          child: dateBuilder(context, date),
        ),
      );
    }

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
              child:
                  weekDayBuilder(context, today + (day - today.weekday).days),
            ),
          ),
        GridPlacement(
          columnStart: 0,
          rowStart: 1,
          rowSpan: weekCount,
          child: _buildWeeks(context, style, firstDay, weekCount),
        ),
        for (final week in 0.rangeTo(weekCount - 1))
          for (final weekday in 0.rangeTo(DateTime.daysPerWeek - 1))
            GridPlacement(
              columnStart: weekday + 1,
              rowStart: week + 1,
              child: buildDate(week, weekday),
            ),
      ],
    );
  }

  Widget _buildWeeks(
    BuildContext context,
    MonthWidgetStyle style,
    DateTime firstDay,
    int weekCount,
  ) {
    assert(firstDay.debugCheckIsValidTimetableDate());

    return DecoratedBox(
      decoration: style.weeksDecoration,
      child: Padding(
        padding: style.weeksPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final index in 0.rangeTo(weekCount - 1))
              weekBuilder(
                context,
                (firstDay + (index * DateTime.daysPerWeek).days).week,
              ),
          ],
        ),
      ),
    );
  }
}

/// Defines visual properties for [MonthWidget].
///
/// See also:
///
/// * [TimetableThemeData], which bundles the styles for all Timetable widgets.
@immutable
class MonthWidgetStyle {
  factory MonthWidgetStyle(
    BuildContext context,
    DateTime month, {
    int? startOfWeek,
    Decoration? weeksDecoration,
    EdgeInsetsGeometry? weeksPadding,
    bool? removeIndividualWeekDecorations,
    EdgeInsetsGeometry? datePadding,
    bool? showDatesFromOtherMonths,
    bool? showDatesFromOtherMonthsAsDisabled,
  }) {
    assert(startOfWeek.debugCheckIsValidTimetableDayOfWeek());
    assert(month.debugCheckIsValidTimetableMonth());

    final theme = context.theme;
    removeIndividualWeekDecorations ??= true;
    return MonthWidgetStyle.raw(
      startOfWeek: startOfWeek ?? DateTime.monday,
      weeksDecoration: weeksDecoration ??
          (removeIndividualWeekDecorations
              ? BoxDecoration(
                  color: theme.colorScheme.brightness.contrastColor
                      .withOpacity(0.05),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                )
              : const BoxDecoration()),
      weeksPadding: weeksPadding ?? const EdgeInsets.symmetric(vertical: 12),
      removeIndividualWeekDecorations: removeIndividualWeekDecorations,
      datePadding: datePadding ?? const EdgeInsets.all(4),
      showDatesFromOtherMonths: showDatesFromOtherMonths ?? true,
      showDatesFromOtherMonthsAsDisabled:
          showDatesFromOtherMonthsAsDisabled ?? true,
    );
  }

  const MonthWidgetStyle.raw({
    required this.startOfWeek,
    required this.weeksDecoration,
    required this.weeksPadding,
    required this.removeIndividualWeekDecorations,
    required this.datePadding,
    required this.showDatesFromOtherMonths,
    required this.showDatesFromOtherMonthsAsDisabled,
  });

  final int startOfWeek;
  final Decoration weeksDecoration;
  final EdgeInsetsGeometry weeksPadding;
  final bool removeIndividualWeekDecorations;
  final EdgeInsetsGeometry datePadding;

  /// Whether dates from adjacent months are displayed to fill the grid.
  final bool showDatesFromOtherMonths;

  /// Whether dates from adjacent months are displayed with lower text opacity.
  final bool showDatesFromOtherMonthsAsDisabled;

  MonthWidgetStyle copyWith({
    int? startOfWeek,
    Decoration? weeksDecoration,
    EdgeInsetsGeometry? weeksPadding,
    bool? removeIndividualWeekDecorations,
    EdgeInsetsGeometry? datePadding,
    bool? showDatesFromOtherMonths,
    bool? showDatesFromOtherMonthsAsDisabled,
  }) {
    return MonthWidgetStyle.raw(
      startOfWeek: startOfWeek ?? this.startOfWeek,
      weeksDecoration: weeksDecoration ?? this.weeksDecoration,
      weeksPadding: weeksPadding ?? this.weeksPadding,
      removeIndividualWeekDecorations: removeIndividualWeekDecorations ??
          this.removeIndividualWeekDecorations,
      datePadding: datePadding ?? this.datePadding,
      showDatesFromOtherMonths:
          showDatesFromOtherMonths ?? this.showDatesFromOtherMonths,
      showDatesFromOtherMonthsAsDisabled: showDatesFromOtherMonthsAsDisabled ??
          this.showDatesFromOtherMonthsAsDisabled,
    );
  }

  @override
  int get hashCode {
    return Object.hash(
      startOfWeek,
      weeksDecoration,
      weeksPadding,
      removeIndividualWeekDecorations,
      datePadding,
      showDatesFromOtherMonths,
      showDatesFromOtherMonthsAsDisabled,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MonthWidgetStyle &&
        startOfWeek == other.startOfWeek &&
        weeksDecoration == other.weeksDecoration &&
        weeksPadding == other.weeksPadding &&
        removeIndividualWeekDecorations ==
            other.removeIndividualWeekDecorations &&
        datePadding == other.datePadding &&
        showDatesFromOtherMonths == other.showDatesFromOtherMonths &&
        showDatesFromOtherMonthsAsDisabled ==
            other.showDatesFromOtherMonthsAsDisabled;
  }
}
