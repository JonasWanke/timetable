import 'package:flutter/material.dart';

import 'components/date_dividers.dart';
import 'components/date_indicator.dart';
import 'components/hour_dividers.dart';
import 'components/multi_date_event_header.dart';
import 'components/now_indicator_painter.dart';
import 'components/week_indicator.dart';
import 'utils.dart';

typedef DateBasedStyleProvider<T> = T Function(DateTime date);
typedef WeekBasedStyleProvider<T> = T Function(WeekInfo week);

@immutable
class TimetableThemeData {
  factory TimetableThemeData(
    BuildContext context, {
    DateDividersStyle? dateDividersStyle,
    DateBasedStyleProvider<DateIndicatorStyle>? dateIndicatorStyleProvider,
    HourDividersStyle? hourDividersStyle,
    MultiDateEventHeaderStyle? multiDateEventHeaderStyle,
    WeekBasedStyleProvider<WeekIndicatorStyle>? weekIndicatorStyleProvider,
    NowIndicatorStyle? nowIndicatorStyle,
  }) {
    return TimetableThemeData.raw(
      dateDividersStyle: dateDividersStyle ?? DateDividersStyle(context),
      dateIndicatorStyleProvider: dateIndicatorStyleProvider ??
          (date) => DateIndicatorStyle(context, date),
      hourDividersStyle: hourDividersStyle ?? HourDividersStyle(context),
      multiDateEventHeaderStyle:
          multiDateEventHeaderStyle ?? MultiDateEventHeaderStyle(context),
      weekIndicatorStyleProvider: weekIndicatorStyleProvider ??
          (week) => WeekIndicatorStyle(context, week),
      nowIndicatorStyle: nowIndicatorStyle ?? NowIndicatorStyle(context),
    );
  }

  const TimetableThemeData.raw({
    required this.dateDividersStyle,
    required this.dateIndicatorStyleProvider,
    required this.hourDividersStyle,
    required this.multiDateEventHeaderStyle,
    required this.weekIndicatorStyleProvider,
    required this.nowIndicatorStyle,
  });

  final DateDividersStyle dateDividersStyle;
  final DateBasedStyleProvider<DateIndicatorStyle> dateIndicatorStyleProvider;
  final HourDividersStyle hourDividersStyle;
  final MultiDateEventHeaderStyle multiDateEventHeaderStyle;
  final WeekBasedStyleProvider<WeekIndicatorStyle> weekIndicatorStyleProvider;
  final NowIndicatorStyle nowIndicatorStyle;

  @override
  int get hashCode => hashValues(
        dateDividersStyle,
        dateIndicatorStyleProvider,
        hourDividersStyle,
        multiDateEventHeaderStyle,
        weekIndicatorStyleProvider,
        nowIndicatorStyle,
      );
  @override
  bool operator ==(Object other) {
    return other is TimetableThemeData &&
        dateDividersStyle == other.dateDividersStyle &&
        dateIndicatorStyleProvider == other.dateIndicatorStyleProvider &&
        hourDividersStyle == other.hourDividersStyle &&
        multiDateEventHeaderStyle == other.multiDateEventHeaderStyle &&
        weekIndicatorStyleProvider == other.weekIndicatorStyleProvider &&
        nowIndicatorStyle == other.nowIndicatorStyle;
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
}
