import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:chrono/chrono.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config.dart';
import '../localization.dart';
import '../theme.dart';

/// A widget that displays the weekday for the given date.
///
/// See also:
///
/// * [WeekdayIndicatorStyle], which defines visual properties for this widget.
/// * [TimetableTheme] (and [TimetableConfig]), which provide styles to
///   descendant Timetable widgets.
class WeekdayIndicator extends StatelessWidget {
  const WeekdayIndicator(
    this.date, {
    super.key,
    this.style,
  });

  final Date date;
  final WeekdayIndicatorStyle? style;

  @override
  Widget build(BuildContext context) {
    final style = this.style ??
        TimetableTheme.orDefaultOf(context).weekdayIndicatorStyleProvider(date);

    return DecoratedBox(
      decoration: style.decoration,
      child: Padding(
        padding: style.padding,
        child: Text(style.label, style: style.textStyle),
      ),
    );
  }
}

/// Defines visual properties for [WeekdayIndicator].
///
/// See also:
///
/// * [TimetableThemeData], which bundles the styles for all Timetable widgets.
@immutable
class WeekdayIndicatorStyle {
  factory WeekdayIndicatorStyle(
    BuildContext context,
    Date date, {
    Decoration? decoration,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    String? label,
  }) {
    final theme = context.theme;
    return WeekdayIndicatorStyle.raw(
      decoration: decoration ?? const BoxDecoration(),
      padding: padding ?? EdgeInsets.zero,
      textStyle: textStyle ??
          theme.textTheme.bodySmall!.copyWith(
            color: date.isTodayInLocalZone()
                ? theme.colorScheme.primary
                : theme.colorScheme.surface.mediumEmphasisOnColor,
          ),
      label: label ??
          () {
            context.dependOnTimetableLocalizations();
            return DateFormat('EEE').format(
              date.atMidnight.asCoreDateTimeInLocalZone,
            );
          }(),
    );
  }

  const WeekdayIndicatorStyle.raw({
    required this.decoration,
    required this.padding,
    required this.textStyle,
    required this.label,
  });

  final Decoration decoration;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  final String label;

  WeekdayIndicatorStyle copyWith({
    Decoration? decoration,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    String? label,
  }) {
    return WeekdayIndicatorStyle.raw(
      decoration: decoration ?? this.decoration,
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      label: label ?? this.label,
    );
  }

  @override
  int get hashCode => Object.hash(decoration, padding, textStyle, label);
  @override
  bool operator ==(Object other) {
    return other is WeekdayIndicatorStyle &&
        decoration == other.decoration &&
        padding == other.padding &&
        textStyle == other.textStyle &&
        label == other.label;
  }
}
