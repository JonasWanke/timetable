// TODO(JonasWanke): Remove the import when upgrading Flutter
// ignore: unnecessary_import
import 'dart:ui';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config.dart';
import '../localization.dart';
import '../theme.dart';
import '../utils.dart';
import 'time_indicators.dart';

/// A widget that displays a label at the given time.
///
/// See also:
///
/// * [TimeIndicators], which positions [TimeIndicator] widgets.
/// * [TimeIndicatorStyle], which defines visual properties (including the
///   label) for this widget.
/// * [TimetableTheme] (and [TimetableConfig]), which provide styles to
///   descendant Timetable widgets.
class TimeIndicator extends StatelessWidget {
  TimeIndicator({
    super.key,
    required this.time,
    this.style,
  }) : assert(time.debugCheckIsValidTimetableTimeOfDay());

  static String formatHour(Duration time) => _format(DateFormat.j(), time);
  static String formatHourMinute(Duration time) =>
      _format(DateFormat.jm(), time);
  static String formatHourMinuteSecond(Duration time) =>
      _format(DateFormat.jms(), time);

  static String formatHour24(Duration time) => _format(DateFormat.H(), time);
  static String formatHour24Minute(Duration time) =>
      _format(DateFormat.Hm(), time);
  static String formatHour24MinuteSecond(Duration time) =>
      _format(DateFormat.Hms(), time);

  static String _format(DateFormat format, Duration time) {
    assert(time.debugCheckIsValidTimetableTimeOfDay());
    return format.format(DateTime(0) + time);
  }

  final Duration time;
  final TimeIndicatorStyle? style;

  @override
  Widget build(BuildContext context) {
    final style = this.style ??
        TimetableTheme.orDefaultOf(context).timeIndicatorStyleProvider(time);

    return Text(style.label, style: style.textStyle);
  }
}

/// Defines visual properties for [TimeIndicator].
///
/// See also:
///
/// * [TimetableThemeData], which bundles the styles for all Timetable widgets.
@immutable
class TimeIndicatorStyle {
  factory TimeIndicatorStyle(
    BuildContext context,
    Duration time, {
    TextStyle? textStyle,
    String? label,
    bool alwaysUse24HourFormat = false,
  }) {
    assert(time.debugCheckIsValidTimetableTimeOfDay());

    final theme = context.theme;
    final bodySmall = theme.textTheme.bodySmall!;
    final proportionalFiguresFeature =
        const FontFeature.proportionalFigures().value;
    return TimeIndicatorStyle.raw(
      textStyle: textStyle ??
          bodySmall.copyWith(
            color: theme.colorScheme.surface.disabledOnColor,
            fontFeatures: [
              ...?bodySmall.fontFeatures
                  ?.where((it) => it.value != proportionalFiguresFeature),
              const FontFeature.tabularFigures(),
            ],
          ),
      label: label ??
          () {
            context.dependOnTimetableLocalizations();
            return alwaysUse24HourFormat
                ? TimeIndicator.formatHour24(time)
                : TimeIndicator.formatHour(time);
          }(),
    );
  }

  const TimeIndicatorStyle.raw({
    required this.textStyle,
    required this.label,
  });

  final TextStyle textStyle;
  final String label;

  TimeIndicatorStyle copyWith({TextStyle? textStyle, String? label}) {
    return TimeIndicatorStyle.raw(
      textStyle: textStyle ?? this.textStyle,
      label: label ?? this.label,
    );
  }

  @override
  int get hashCode => Object.hash(textStyle, label);
  @override
  bool operator ==(Object other) {
    return other is TimeIndicatorStyle &&
        textStyle == other.textStyle &&
        label == other.label;
  }
}
