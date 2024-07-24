import 'package:flutter/material.dart';

import 'components/date_dividers.dart';
import 'components/date_events.dart';
import 'components/date_header.dart';
import 'components/date_indicator.dart';
import 'components/hour_dividers.dart';
import 'components/month_indicator.dart';
import 'components/month_widget.dart';
import 'components/multi_date_event_header.dart';
import 'components/now_indicator.dart';
import 'components/time_indicator.dart';
import 'components/week_indicator.dart';
import 'components/weekday_indicator.dart';
import 'layouts/multi_date.dart';
import 'utils.dart';
import 'week.dart';

typedef MonthBasedStyleProvider<T> = T Function(DateTime month);
typedef WeekBasedStyleProvider<T> = T Function(Week week);
typedef DateBasedStyleProvider<T> = T Function(DateTime date);
typedef TimeBasedStyleProvider<T> = T Function(Duration time);

/// Bundles styles for all Timetable widgets.
///
/// See also:
///
/// * [TimetableTheme], which makes the theme data available to nested widgets.
@immutable
class TimetableThemeData {
  factory TimetableThemeData(
    BuildContext context, {
    int? startOfWeek,
    DateDividersStyle? dateDividersStyle,
    DateBasedStyleProvider<DateEventsStyle>? dateEventsStyleProvider,
    DateBasedStyleProvider<DateHeaderStyle>? dateHeaderStyleProvider,
    DateBasedStyleProvider<DateIndicatorStyle>? dateIndicatorStyleProvider,
    HourDividersStyle? hourDividersStyle,
    MonthBasedStyleProvider<MonthIndicatorStyle>? monthIndicatorStyleProvider,
    MonthBasedStyleProvider<MonthWidgetStyle>? monthWidgetStyleProvider,
    MultiDateEventHeaderStyle? multiDateEventHeaderStyle,
    MultiDateTimetableStyle? multiDateTimetableStyle,
    NowIndicatorStyle? nowIndicatorStyle,
    TimeBasedStyleProvider<TimeIndicatorStyle>? timeIndicatorStyleProvider,
    DateBasedStyleProvider<WeekdayIndicatorStyle>?
        weekdayIndicatorStyleProvider,
    WeekBasedStyleProvider<WeekIndicatorStyle>? weekIndicatorStyleProvider,
  }) {
    return TimetableThemeData.raw(
      startOfWeek: startOfWeek ?? DateTime.monday,
      dateDividersStyle: dateDividersStyle ?? DateDividersStyle(context),
      dateEventsStyleProvider:
          dateEventsStyleProvider ?? (date) => DateEventsStyle(context, date),
      dateHeaderStyleProvider:
          dateHeaderStyleProvider ?? (date) => DateHeaderStyle(context, date),
      dateIndicatorStyleProvider: dateIndicatorStyleProvider ??
          (date) => DateIndicatorStyle(context, date),
      hourDividersStyle: hourDividersStyle ?? HourDividersStyle(context),
      monthIndicatorStyleProvider: monthIndicatorStyleProvider ??
          (month) => MonthIndicatorStyle(context, month),
      monthWidgetStyleProvider: monthWidgetStyleProvider ??
          (month) => MonthWidgetStyle(context, month, startOfWeek: startOfWeek),
      multiDateEventHeaderStyle:
          multiDateEventHeaderStyle ?? MultiDateEventHeaderStyle(context),
      multiDateTimetableStyle:
          multiDateTimetableStyle ?? MultiDateTimetableStyle(context),
      nowIndicatorStyle: nowIndicatorStyle ?? NowIndicatorStyle(context),
      timeIndicatorStyleProvider: timeIndicatorStyleProvider ??
          (time) => TimeIndicatorStyle(context, time),
      weekdayIndicatorStyleProvider: weekdayIndicatorStyleProvider ??
          (date) => WeekdayIndicatorStyle(context, date),
      weekIndicatorStyleProvider: weekIndicatorStyleProvider ??
          (week) => WeekIndicatorStyle(context, week),
    );
  }

  TimetableThemeData.raw({
    required this.startOfWeek,
    required this.dateDividersStyle,
    required this.dateEventsStyleProvider,
    required this.dateHeaderStyleProvider,
    required this.dateIndicatorStyleProvider,
    required this.hourDividersStyle,
    required this.monthIndicatorStyleProvider,
    required this.monthWidgetStyleProvider,
    required this.multiDateEventHeaderStyle,
    required this.multiDateTimetableStyle,
    required this.nowIndicatorStyle,
    required this.timeIndicatorStyleProvider,
    required this.weekdayIndicatorStyleProvider,
    required this.weekIndicatorStyleProvider,
  }) : assert(startOfWeek.debugCheckIsValidTimetableDayOfWeek());

  final int startOfWeek;
  final DateDividersStyle dateDividersStyle;
  final DateBasedStyleProvider<DateEventsStyle> dateEventsStyleProvider;
  final DateBasedStyleProvider<DateHeaderStyle> dateHeaderStyleProvider;
  final DateBasedStyleProvider<DateIndicatorStyle> dateIndicatorStyleProvider;
  final HourDividersStyle hourDividersStyle;
  final MonthBasedStyleProvider<MonthIndicatorStyle>
      monthIndicatorStyleProvider;
  final MonthBasedStyleProvider<MonthWidgetStyle> monthWidgetStyleProvider;
  final MultiDateEventHeaderStyle multiDateEventHeaderStyle;
  final MultiDateTimetableStyle multiDateTimetableStyle;
  final NowIndicatorStyle nowIndicatorStyle;
  final TimeBasedStyleProvider<TimeIndicatorStyle> timeIndicatorStyleProvider;
  final DateBasedStyleProvider<WeekdayIndicatorStyle>
      weekdayIndicatorStyleProvider;
  final WeekBasedStyleProvider<WeekIndicatorStyle> weekIndicatorStyleProvider;

  TimetableThemeData copyWith({
    int? startOfWeek,
    DateDividersStyle? dateDividersStyle,
    DateBasedStyleProvider<DateEventsStyle>? dateEventsStyleProvider,
    DateBasedStyleProvider<DateHeaderStyle>? dateHeaderStyleProvider,
    DateBasedStyleProvider<DateIndicatorStyle>? dateIndicatorStyleProvider,
    HourDividersStyle? hourDividersStyle,
    MonthBasedStyleProvider<MonthIndicatorStyle>? monthIndicatorStyleProvider,
    MonthBasedStyleProvider<MonthWidgetStyle>? monthWidgetStyleProvider,
    MultiDateEventHeaderStyle? multiDateEventHeaderStyle,
    MultiDateTimetableStyle? multiDateTimetableStyle,
    NowIndicatorStyle? nowIndicatorStyle,
    TimeBasedStyleProvider<TimeIndicatorStyle>? timeIndicatorStyleProvider,
    DateBasedStyleProvider<WeekdayIndicatorStyle>?
        weekdayIndicatorStyleProvider,
    WeekBasedStyleProvider<WeekIndicatorStyle>? weekIndicatorStyleProvider,
  }) {
    return TimetableThemeData.raw(
      startOfWeek: startOfWeek ?? this.startOfWeek,
      dateDividersStyle: dateDividersStyle ?? this.dateDividersStyle,
      dateEventsStyleProvider:
          dateEventsStyleProvider ?? this.dateEventsStyleProvider,
      dateHeaderStyleProvider:
          dateHeaderStyleProvider ?? this.dateHeaderStyleProvider,
      dateIndicatorStyleProvider:
          dateIndicatorStyleProvider ?? this.dateIndicatorStyleProvider,
      hourDividersStyle: hourDividersStyle ?? this.hourDividersStyle,
      monthIndicatorStyleProvider:
          monthIndicatorStyleProvider ?? this.monthIndicatorStyleProvider,
      monthWidgetStyleProvider:
          monthWidgetStyleProvider ?? this.monthWidgetStyleProvider,
      multiDateEventHeaderStyle:
          multiDateEventHeaderStyle ?? this.multiDateEventHeaderStyle,
      multiDateTimetableStyle:
          multiDateTimetableStyle ?? this.multiDateTimetableStyle,
      nowIndicatorStyle: nowIndicatorStyle ?? this.nowIndicatorStyle,
      timeIndicatorStyleProvider:
          timeIndicatorStyleProvider ?? this.timeIndicatorStyleProvider,
      weekdayIndicatorStyleProvider:
          weekdayIndicatorStyleProvider ?? this.weekdayIndicatorStyleProvider,
      weekIndicatorStyleProvider:
          weekIndicatorStyleProvider ?? this.weekIndicatorStyleProvider,
    );
  }

  @override
  int get hashCode {
    return Object.hash(
      startOfWeek,
      dateDividersStyle,
      dateEventsStyleProvider,
      dateHeaderStyleProvider,
      dateIndicatorStyleProvider,
      hourDividersStyle,
      monthIndicatorStyleProvider,
      monthWidgetStyleProvider,
      multiDateEventHeaderStyle,
      multiDateTimetableStyle,
      nowIndicatorStyle,
      timeIndicatorStyleProvider,
      weekdayIndicatorStyleProvider,
      weekIndicatorStyleProvider,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TimetableThemeData &&
        startOfWeek == other.startOfWeek &&
        dateDividersStyle == other.dateDividersStyle &&
        dateEventsStyleProvider == other.dateEventsStyleProvider &&
        dateHeaderStyleProvider == other.dateHeaderStyleProvider &&
        dateIndicatorStyleProvider == other.dateIndicatorStyleProvider &&
        hourDividersStyle == other.hourDividersStyle &&
        monthIndicatorStyleProvider == other.monthIndicatorStyleProvider &&
        monthWidgetStyleProvider == other.monthWidgetStyleProvider &&
        multiDateEventHeaderStyle == other.multiDateEventHeaderStyle &&
        multiDateTimetableStyle == other.multiDateTimetableStyle &&
        nowIndicatorStyle == other.nowIndicatorStyle &&
        timeIndicatorStyleProvider == other.timeIndicatorStyleProvider &&
        weekdayIndicatorStyleProvider == other.weekdayIndicatorStyleProvider &&
        weekIndicatorStyleProvider == other.weekIndicatorStyleProvider;
  }
}

/// Provides styles for nested Timetable widgets.
///
/// See also:
///
/// * [TimetableThemeData], which bundles the actual styles.
class TimetableTheme extends InheritedWidget {
  const TimetableTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final TimetableThemeData data;

  @override
  bool updateShouldNotify(TimetableTheme oldWidget) => data != oldWidget.data;

  static TimetableThemeData? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TimetableTheme>()?.data;
  static TimetableThemeData orDefaultOf(BuildContext context) =>
      of(context) ?? TimetableThemeData(context);
}
