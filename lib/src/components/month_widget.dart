import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:chrono/chrono.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

import '../config.dart';
import '../theme.dart';
import '../utils.dart';
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
    this.yearMonth, {
    super.key,
    DateWidgetBuilder? weekDayBuilder,
    YearWeekWidgetBuilder? weekBuilder,
    DateWidgetBuilder? dateBuilder,
    this.style,
  })  : weekDayBuilder =
            weekDayBuilder ?? ((context, date) => WeekdayIndicator(date)),
        weekBuilder = weekBuilder ??
            ((context, week) {
              final timetableTheme = TimetableTheme.orDefaultOf(context);
              return WeekIndicator(
                week,
                style: (style ??
                            timetableTheme.monthWidgetStyleProvider(yearMonth))
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
              final timetableTheme = TimetableTheme.orDefaultOf(context);
              DateIndicatorStyle? dateStyle;
              if (date.yearMonth != yearMonth &&
                  (style ?? timetableTheme.monthWidgetStyleProvider(yearMonth))
                      .showDatesFromOtherMonthsAsDisabled) {
                final original =
                    timetableTheme.dateIndicatorStyleProvider(date);
                dateStyle = original.copyWith(
                  textStyle: original.textStyle.copyWith(
                    color: context.theme.colorScheme.surface.disabledOnColor,
                  ),
                );
              }
              return DateIndicator(date, style: dateStyle);
            });

  final YearMonth yearMonth;

  final DateWidgetBuilder weekDayBuilder;
  final YearWeekWidgetBuilder weekBuilder;
  final DateWidgetBuilder dateBuilder;

  final MonthWidgetStyle? style;

  @override
  Widget build(BuildContext context) {
    final style = this.style ??
        TimetableTheme.orDefaultOf(context).monthWidgetStyleProvider(yearMonth);

    final firstDay = yearMonth.firstDay.previousOrSame(style.startOfWeek);
    final minDayCount = yearMonth.length;
    final weekCount = minDayCount.roundToWeeks(rounding: Rounding.up).inWeeks;

    final today = Date.todayInLocalZone();

    Widget buildDate(int week, Weekday weekday) {
      final date = firstDay + Weeks(week) + Days(weekday.index);
      if (!style.showDatesFromOtherMonths && date.yearMonth != yearMonth) {
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
        ...repeat(Days.perWeek, [1.fr]),
      ],
      rowSizes: [
        auto,
        ...repeat(weekCount, [auto]),
      ],
      children: [
        // By using today as the base, highlighting for the current day is
        // applied automatically.
        // FIXME(JonasWanke): support startOfWeek
        for (final day in today.yearWeek.days)
          GridPlacement(
            columnStart: day.weekday.number,
            rowStart: 0,
            child: Center(child: weekDayBuilder(context, day.asDate)),
          ),
        GridPlacement(
          columnStart: 0,
          rowStart: 1,
          rowSpan: weekCount,
          child: _buildWeeks(context, style, firstDay, weekCount),
        ),
        for (final week in 0.rangeTo(weekCount - 1))
          // FIXME(JonasWanke): support startOfWeek
          for (final weekday in Weekday.values)
            GridPlacement(
              columnStart: weekday.number,
              rowStart: week + 1,
              child: buildDate(week, weekday),
            ),
      ],
    );
  }

  Widget _buildWeeks(
    BuildContext context,
    MonthWidgetStyle style,
    Date firstDay,
    int weekCount,
  ) {
    return DecoratedBox(
      decoration: style.weeksDecoration,
      child: Padding(
        padding: style.weeksPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final index in 0.rangeTo(weekCount - 1))
              weekBuilder(context, (firstDay + Weeks(index)).yearWeek),
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
    // To allow future updates to use the `yearMonth` and align the parameters
    // to other style constructors.
    // FIXME
    // ignore: avoid_unused_constructor_parameters
    YearMonth yearMonth, {
    Weekday? startOfWeek,
    Decoration? weeksDecoration,
    EdgeInsetsGeometry? weeksPadding,
    bool? removeIndividualWeekDecorations,
    EdgeInsetsGeometry? datePadding,
    bool? showDatesFromOtherMonths,
    bool? showDatesFromOtherMonthsAsDisabled,
  }) {
    final theme = context.theme;
    removeIndividualWeekDecorations ??= true;
    return MonthWidgetStyle.raw(
      startOfWeek: startOfWeek ?? Weekday.monday,
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

  final Weekday startOfWeek;
  final Decoration weeksDecoration;
  final EdgeInsetsGeometry weeksPadding;
  final bool removeIndividualWeekDecorations;
  final EdgeInsetsGeometry datePadding;

  /// Whether dates from adjacent months are displayed to fill the grid.
  final bool showDatesFromOtherMonths;

  /// Whether dates from adjacent months are displayed with lower text opacity.
  final bool showDatesFromOtherMonthsAsDisabled;

  MonthWidgetStyle copyWith({
    Weekday? startOfWeek,
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
