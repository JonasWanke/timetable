import 'package:flutter/material.dart';

import 'components/date_indicator.dart';
import 'components/multi_date_event_header.dart';
import 'components/week_indicator.dart';
import 'localization.dart';
import 'utils.dart';

typedef DateBasedStyleProvider<T> = T Function(DateTime date);
typedef WeekBasedStyleProvider<T> = T Function(WeekInfo week);

@immutable
class TimetableThemeData {
  factory TimetableThemeData({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required TimetableLocalizations localizations,
    DateBasedStyleProvider<DateIndicatorStyle>? dateIndicatorStyleProvider,
    MultiDateEventHeaderStyle? multiDateEventHeaderStyle,
    WeekBasedStyleProvider<WeekIndicatorStyle>? weekIndicatorStyleProvider,
  }) {
    return TimetableThemeData.raw(
      dateIndicatorStyleProvider: dateIndicatorStyleProvider ??
          (date) => DateIndicatorStyle(
                date: date,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
      multiDateEventHeaderStyle:
          multiDateEventHeaderStyle ?? MultiDateEventHeaderStyle(),
      weekIndicatorStyleProvider: weekIndicatorStyleProvider ??
          (week) => WeekIndicatorStyle(
                week: week,
                colorScheme: colorScheme,
                textTheme: textTheme,
                localizations: localizations,
              ),
    );
  }

  const TimetableThemeData.raw({
    required this.dateIndicatorStyleProvider,
    required this.multiDateEventHeaderStyle,
    required this.weekIndicatorStyleProvider,
  });

  final DateBasedStyleProvider<DateIndicatorStyle> dateIndicatorStyleProvider;
  final MultiDateEventHeaderStyle multiDateEventHeaderStyle;
  final WeekBasedStyleProvider<WeekIndicatorStyle> weekIndicatorStyleProvider;

  @override
  int get hashCode => hashValues(
        dateIndicatorStyleProvider,
        multiDateEventHeaderStyle,
        weekIndicatorStyleProvider,
      );
  @override
  bool operator ==(Object other) {
    return other is TimetableThemeData &&
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
