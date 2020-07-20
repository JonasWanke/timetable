import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';

import 'timetable.dart';

/// Defines visual properties for [Timetable] and related widgets.
class TimetableThemeData {
  const TimetableThemeData({
    this.primaryColor,
    this.weekIndicatorDecoration,
    this.weekIndicatorTextStyle,
    this.totalDateIndicatorHeight,
    this.weekDayIndicatorPattern,
    this.weekDayIndicatorDecoration,
    this.weekDayIndicatorTextStyle,
    this.dateIndicatorPattern,
    this.dateIndicatorDecoration,
    this.dateIndicatorTextStyle,
    this.allDayEventHeight,
    this.hourTextStyle,
    this.hourColumnWidth,
    this.formatHour,
    this.timeIndicatorColor,
    this.dividerColor,
    this.minimumHourHeight,
    this.maximumHourHeight,
    this.partDayEventMinimumDuration,
    this.partDayEventMinimumHeight,
    this.partDayEventSpacing,
    this.enablePartDayEventStacking,
    this.partDayEventMinimumDeltaForStacking,
    this.partDayStackedEventSpacing,
  })  : assert(allDayEventHeight == null || allDayEventHeight > 0),
        assert(minimumHourHeight == null || minimumHourHeight > 0),
        assert(maximumHourHeight == null || maximumHourHeight > 0),
        assert(minimumHourHeight == null ||
            maximumHourHeight == null ||
            minimumHourHeight <= maximumHourHeight);

  /// Used by default for indicating the current date.
  ///
  /// The default value is [ThemeData.primaryColor].
  final Color primaryColor;

  // Header:

  /// [Decoration] to show around the week indicator.
  final Decoration weekIndicatorDecoration;

  /// [TextStyle] used to display the current week number.
  final TextStyle weekIndicatorTextStyle;

  /// Total (combined) height of both the day-of-week- and
  /// date-of-month-indicators.
  ///
  /// > **Note:** This will soon be determined automatically based on the actual
  /// > height.
  @experimental
  final double totalDateIndicatorHeight;

  /// [LocalDatePattern] for formatting the day-of-week.
  ///
  /// See also:
  /// - [dateIndicatorTextStyle] for a list of possible states.
  final MaterialStateProperty<LocalDatePattern> weekDayIndicatorPattern;

  /// [Decoration] to show around the day-of-week-indicator.
  ///
  /// See also:
  /// - [dateIndicatorTextStyle] for a list of possible states.
  final MaterialStateProperty<Decoration> weekDayIndicatorDecoration;

  /// [TextStyle] used to display the day of week.
  ///
  /// See also:
  /// - [dateIndicatorTextStyle] for a list of possible states.
  final MaterialStateProperty<TextStyle> weekDayIndicatorTextStyle;

  /// [LocalDatePattern] for formatting the date (of month).
  ///
  /// See also:
  /// - [dateIndicatorTextStyle] for a list of possible states.
  final MaterialStateProperty<LocalDatePattern> dateIndicatorPattern;

  /// [Decoration] to show around the date (of month) indicator.
  ///
  /// See also:
  /// - [dateIndicatorTextStyle] for a list of possible states.
  final MaterialStateProperty<Decoration> dateIndicatorDecoration;

  /// [TextStyle] used to display the date (of month).
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

  // Content:

  /// [TextStyle] used to display the hours of the day.
  final TextStyle hourTextStyle;

  /// Width of hour of day column
  ///
  /// Default to 48
  final double hourColumnWidth;

  /// [HourFormatter] used to format the hours of the day string.
  final HourFormatter formatHour;

  /// [Color] for painting the current time indicator.
  final Color timeIndicatorColor;

  /// [Color] for painting hour and day dividers in the part-day event area.
  final Color dividerColor;

  /// Minimum height of a single hour when zooming in.
  ///
  /// Defaults to 16.
  final double minimumHourHeight;

  /// Maximum height of a single hour when zooming in.
  ///
  /// [double.infinity] is supported!
  ///
  /// Defaults to 64.
  final double maximumHourHeight;

  /// Minimum [Period] to size a part-day event.
  ///
  /// Can be used together with [partDayEventMinimumHeight].
  final Period partDayEventMinimumDuration;

  /// Minimum height to size a part-day event.
  ///
  /// Can be used together with [partDayEventMinimumDuration].
  final double partDayEventMinimumHeight;

  /// Horizontal space between two parallel events shown next to each other.
  final double partDayEventSpacing;

  /// Controls whether overlapping events may be stacked on top of each other.
  ///
  /// If set to `true`, intersecting events may be stacked if their start values
  /// differ by at least [partDayEventMinimumDeltaForStacking]. If set to
  /// `false`, intersecting events will always be shown next to each other and
  /// not overlap.
  ///
  /// Defaults to `true`.
  final bool enablePartDayEventStacking;

  /// When the start values of two events differ by at least this value, they
  /// may be stacked on top of each other.
  ///
  /// If the difference is less, they will be shown next to each other.
  ///
  /// Defaults to 15 min.
  ///
  /// See also:
  /// - [enablePartDayEventStacking], which can disable the stacking behavior
  ///   completely.
  final Period partDayEventMinimumDeltaForStacking;

  /// Horizontal space between two parallel events stacked on top of each other.
  final double partDayStackedEventSpacing;

  @override
  int get hashCode {
    return hashList([
      primaryColor,
      weekIndicatorDecoration,
      weekIndicatorTextStyle,
      totalDateIndicatorHeight,
      weekDayIndicatorPattern,
      weekDayIndicatorDecoration,
      weekDayIndicatorTextStyle,
      dateIndicatorPattern,
      dateIndicatorDecoration,
      dateIndicatorTextStyle,
      allDayEventHeight,
      hourTextStyle,
      hourColumnWidth,
      formatHour,
      timeIndicatorColor,
      dividerColor,
      minimumHourHeight,
      maximumHourHeight,
      partDayEventMinimumDuration,
      partDayEventMinimumHeight,
      partDayEventSpacing,
      enablePartDayEventStacking,
      partDayEventMinimumDeltaForStacking,
      partDayStackedEventSpacing,
    ]);
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
        other.totalDateIndicatorHeight == totalDateIndicatorHeight &&
        other.weekDayIndicatorPattern == weekDayIndicatorPattern &&
        other.weekDayIndicatorDecoration == weekDayIndicatorDecoration &&
        other.weekDayIndicatorTextStyle == weekDayIndicatorTextStyle &&
        other.dateIndicatorPattern == dateIndicatorPattern &&
        other.dateIndicatorDecoration == dateIndicatorDecoration &&
        other.dateIndicatorTextStyle == dateIndicatorTextStyle &&
        other.allDayEventHeight == allDayEventHeight &&
        other.hourTextStyle == hourTextStyle &&
        other.timeIndicatorColor == timeIndicatorColor &&
        other.dividerColor == dividerColor &&
        other.minimumHourHeight == minimumHourHeight &&
        other.maximumHourHeight == maximumHourHeight &&
        other.partDayEventMinimumDuration == partDayEventMinimumDuration &&
        other.partDayEventMinimumHeight == partDayEventMinimumHeight &&
        other.partDayEventSpacing == partDayEventSpacing &&
        other.enablePartDayEventStacking == enablePartDayEventStacking &&
        other.partDayEventMinimumDeltaForStacking ==
            partDayEventMinimumDeltaForStacking &&
        other.partDayStackedEventSpacing == partDayStackedEventSpacing;
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

typedef HourFormatter = String Function(LocalTime time);
