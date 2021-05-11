import 'package:flutter/material.dart';

import 'components/date_dividers.dart';
import 'components/date_indicator.dart';
import 'components/multi_date_event_header.dart';
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
    MultiDateEventHeaderStyle? multiDateEventHeaderStyle,
    WeekBasedStyleProvider<WeekIndicatorStyle>? weekIndicatorStyleProvider,
  }) {
    return TimetableThemeData.raw(
      dateDividersStyle: dateDividersStyle ?? DateDividersStyle(context),
      dateIndicatorStyleProvider: dateIndicatorStyleProvider ??
          (date) => DateIndicatorStyle(context, date),
      multiDateEventHeaderStyle:
          multiDateEventHeaderStyle ?? MultiDateEventHeaderStyle(context),
      weekIndicatorStyleProvider: weekIndicatorStyleProvider ??
          (week) => WeekIndicatorStyle(context, week),
    );
  }

  const TimetableThemeData.raw({
    required this.dateDividersStyle,
    required this.dateIndicatorStyleProvider,
    required this.multiDateEventHeaderStyle,
    required this.weekIndicatorStyleProvider,
  });

  final DateDividersStyle dateDividersStyle;
  final DateBasedStyleProvider<DateIndicatorStyle> dateIndicatorStyleProvider;
  final MultiDateEventHeaderStyle multiDateEventHeaderStyle;
  final WeekBasedStyleProvider<WeekIndicatorStyle> weekIndicatorStyleProvider;

  @override
  int get hashCode => hashValues(
        dateDividersStyle,
        dateIndicatorStyleProvider,
        multiDateEventHeaderStyle,
        weekIndicatorStyleProvider,
      );
  @override
  bool operator ==(Object other) {
    return other is TimetableThemeData &&
        dateDividersStyle == other.dateDividersStyle &&
        dateIndicatorStyleProvider == other.dateIndicatorStyleProvider &&
        multiDateEventHeaderStyle == other.multiDateEventHeaderStyle &&
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
}
