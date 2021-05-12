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
import 'components/week_indicator.dart';
import 'components/weekday_indicator.dart';
import 'utils.dart';

typedef MonthBasedStyleProvider<T> = T Function(DateTime month);
typedef WeekBasedStyleProvider<T> = T Function(WeekInfo week);
typedef DateBasedStyleProvider<T> = T Function(DateTime date);

@immutable
class TimetableThemeData {
  factory TimetableThemeData(
    BuildContext context, {
    DateDividersStyle? dateDividersStyle,
    DateBasedStyleProvider<DateEventsStyle>? dateEventsStyleProvider,
    DateBasedStyleProvider<DateHeaderStyle>? dateHeaderStyleProvider,
    DateBasedStyleProvider<DateIndicatorStyle>? dateIndicatorStyleProvider,
    HourDividersStyle? hourDividersStyle,
    MonthBasedStyleProvider<MonthIndicatorStyle>? monthIndicatorStyleProvider,
    MonthBasedStyleProvider<MonthWidgetStyle>? monthWidgetStyleProvider,
    MultiDateEventHeaderStyle? multiDateEventHeaderStyle,
    NowIndicatorStyle? nowIndicatorStyle,
    DateBasedStyleProvider<WeekdayIndicatorStyle>?
        weekdayIndicatorStyleProvider,
    WeekBasedStyleProvider<WeekIndicatorStyle>? weekIndicatorStyleProvider,
  }) {
    return TimetableThemeData.raw(
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
          (month) => MonthWidgetStyle(context, month),
      multiDateEventHeaderStyle:
          multiDateEventHeaderStyle ?? MultiDateEventHeaderStyle(context),
      nowIndicatorStyle: nowIndicatorStyle ?? NowIndicatorStyle(context),
      weekdayIndicatorStyleProvider: weekdayIndicatorStyleProvider ??
          (date) => WeekdayIndicatorStyle(context, date),
      weekIndicatorStyleProvider: weekIndicatorStyleProvider ??
          (week) => WeekIndicatorStyle(context, week),
    );
  }

  const TimetableThemeData.raw({
    required this.dateDividersStyle,
    required this.dateEventsStyleProvider,
    required this.dateHeaderStyleProvider,
    required this.dateIndicatorStyleProvider,
    required this.hourDividersStyle,
    required this.monthIndicatorStyleProvider,
    required this.monthWidgetStyleProvider,
    required this.multiDateEventHeaderStyle,
    required this.nowIndicatorStyle,
    required this.weekdayIndicatorStyleProvider,
    required this.weekIndicatorStyleProvider,
  });

  final DateDividersStyle dateDividersStyle;
  final DateBasedStyleProvider<DateEventsStyle> dateEventsStyleProvider;
  final DateBasedStyleProvider<DateHeaderStyle> dateHeaderStyleProvider;
  final DateBasedStyleProvider<DateIndicatorStyle> dateIndicatorStyleProvider;
  final HourDividersStyle hourDividersStyle;
  final MonthBasedStyleProvider<MonthIndicatorStyle>
      monthIndicatorStyleProvider;
  final MonthBasedStyleProvider<MonthWidgetStyle> monthWidgetStyleProvider;
  final MultiDateEventHeaderStyle multiDateEventHeaderStyle;
  final NowIndicatorStyle nowIndicatorStyle;
  final DateBasedStyleProvider<WeekdayIndicatorStyle>
      weekdayIndicatorStyleProvider;
  final WeekBasedStyleProvider<WeekIndicatorStyle> weekIndicatorStyleProvider;

  @override
  int get hashCode => hashValues(
        dateDividersStyle,
        dateEventsStyleProvider,
        dateHeaderStyleProvider,
        dateIndicatorStyleProvider,
        hourDividersStyle,
        monthIndicatorStyleProvider,
        monthWidgetStyleProvider,
        multiDateEventHeaderStyle,
        nowIndicatorStyle,
        weekdayIndicatorStyleProvider,
        weekIndicatorStyleProvider,
      );
  @override
  bool operator ==(Object other) {
    return other is TimetableThemeData &&
        dateDividersStyle == other.dateDividersStyle &&
        dateEventsStyleProvider == other.dateEventsStyleProvider &&
        dateHeaderStyleProvider == other.dateHeaderStyleProvider &&
        dateIndicatorStyleProvider == other.dateIndicatorStyleProvider &&
        hourDividersStyle == other.hourDividersStyle &&
        monthIndicatorStyleProvider == other.monthIndicatorStyleProvider &&
        monthWidgetStyleProvider == other.monthWidgetStyleProvider &&
        multiDateEventHeaderStyle == other.multiDateEventHeaderStyle &&
        nowIndicatorStyle == other.nowIndicatorStyle &&
        weekdayIndicatorStyleProvider == other.weekdayIndicatorStyleProvider &&
        weekIndicatorStyleProvider == other.weekIndicatorStyleProvider;
  }
}

class TimetableTheme extends InheritedWidget {
  const TimetableTheme({
    required this.data,
    required Widget child,
  }) : super(child: child);

  final TimetableThemeData data;

  @override
  bool updateShouldNotify(TimetableTheme oldWidget) => data != oldWidget.data;

  static TimetableThemeData? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TimetableTheme>()?.data;
  static TimetableThemeData orDefaultOf(BuildContext context) =>
      of(context) ?? TimetableThemeData(context);
}
