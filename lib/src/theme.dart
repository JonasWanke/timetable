import 'package:flutter/material.dart';

import 'timetable.dart';

/// Defines visual properties for [Timetable] and related widgets.
class TimetableThemeData {
  const TimetableThemeData({
    this.primaryColor,
    this.weekIndicatorDecoration,
    this.weekIndicatorTextStyle,
    this.weekDayIndicatorDecoration,
    this.weekDayIndicatorTextStyle,
    this.dateIndicatorDecoration,
    this.dateIndicatorTextStyle,
    this.allDayEventHeight,
  });

  /// Used by default for indicating the current date.
  ///
  /// The default value is [ThemeData.primaryColor].
  final Color primaryColor;

  // Header:

  /// [Decoration] to show around the week indicator.
  final Decoration weekIndicatorDecoration;

  /// [TextStyle] to display the current week number.
  final TextStyle weekIndicatorTextStyle;

  /// [Decoration] to show around the day-of-week-indicator.
  ///
  /// See also:
  /// - [dateIndicatorTextStyle] for a list of possible states.
  final MaterialStateProperty<Decoration> weekDayIndicatorDecoration;

  /// [TextStyle] to display the day of week.
  ///
  /// See also:
  /// - [dateIndicatorTextStyle] for a list of possible states.
  final MaterialStateProperty<TextStyle> weekDayIndicatorTextStyle;

  /// [Decoration] to show around the date (of month) indicator.
  ///
  /// See also:
  /// - [dateIndicatorTextStyle] for a list of possible states.
  final MaterialStateProperty<Decoration> dateIndicatorDecoration;

  /// [TextStyle] to display the date (of month).
  ///
  /// States:
  /// - past days: [MaterialState.disabled]
  /// - today: [MaterialState.selected]
  /// - future days: none
  final MaterialStateProperty<TextStyle> dateIndicatorTextStyle;

  /// Height of a single all-day event.
  ///
  /// Defaults to 24.
  final double allDayEventHeight;

  @override
  int get hashCode {
    return hashValues(
      primaryColor,
      weekIndicatorDecoration,
      weekIndicatorTextStyle,
      weekDayIndicatorDecoration,
      weekDayIndicatorTextStyle,
      dateIndicatorDecoration,
      dateIndicatorTextStyle,
      allDayEventHeight,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is TimetableThemeData &&
        other.primaryColor == primaryColor &&
        other.weekIndicatorDecoration == weekIndicatorDecoration &&
        other.weekIndicatorTextStyle == weekIndicatorTextStyle &&
        other.weekDayIndicatorDecoration == weekDayIndicatorDecoration &&
        other.weekDayIndicatorTextStyle == weekDayIndicatorTextStyle &&
        other.dateIndicatorDecoration == dateIndicatorDecoration &&
        other.dateIndicatorTextStyle == dateIndicatorTextStyle &&
        other.allDayEventHeight == allDayEventHeight;
  }
}

/// An inherited widget that defines visual properties for [Timetable]s and
/// related widgets in this widget's subtree.
class TimetableTheme extends InheritedTheme {
  /// Creates a timetable theme that controls the [TimetableThemeData]
  /// properties for a [Timetable].
  ///
  /// [data] must not be null.
  const TimetableTheme({
    Key key,
    @required this.data,
    @required Widget child,
  })  : assert(data != null),
        super(key: key, child: child);

  final TimetableThemeData data;

  /// The closest instance of this class that encloses the given context.
  ///
  /// If there is no enclosing [TimetableTheme] widget, `null` is returned.
  ///
  /// It's recommended to use the extension property on [BuildContext]:
  ///
  /// ```dart
  /// TimetableThemeData theme = context.timetableTheme;
  /// ```
  static TimetableThemeData of(BuildContext context) {
    final timetableTheme =
        context.dependOnInheritedWidgetOfExactType<TimetableTheme>();
    return timetableTheme?.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    final ancestorTheme =
        context.findAncestorWidgetOfExactType<TimetableTheme>();
    return identical(this, ancestorTheme)
        ? child
        : TimetableTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(TimetableTheme oldWidget) => data != oldWidget.data;
}

extension TimetableThemeBuildContext on BuildContext {
  /// Shortcut for `TimetableTheme.of(context)`.
  TimetableThemeData get timetableTheme => TimetableTheme.of(this);
}
