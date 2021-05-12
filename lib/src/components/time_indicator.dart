import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:black_hole_flutter/black_hole_flutter.dart';

import '../localization.dart';
import '../theme.dart';
import '../utils.dart';

class TimeIndicator extends StatelessWidget {
  TimeIndicator({
    Key? key,
    required this.time,
    this.style,
  })  : assert(time.isValidTimetableTimeOfDay),
        super(key: key);

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
    assert(time.isValidTimetableTimeOfDay);
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
@immutable
class TimeIndicatorStyle {
  factory TimeIndicatorStyle(
    BuildContext context,
    Duration time, {
    TextStyle? textStyle,
    String? label,
  }) {
    assert(time.isValidTimetableTimeOfDay);

    final theme = context.theme;
    return TimeIndicatorStyle.raw(
      textStyle: textStyle ??
          theme.textTheme.caption!
              .copyWith(color: theme.colorScheme.background.disabledOnColor),
      label: label ??
          () {
            context.dependOnTimetableLocalizations();
            return TimeIndicator.formatHour(time);
          }(),
    );
  }

  const TimeIndicatorStyle.raw({
    required this.textStyle,
    required this.label,
  });

  final TextStyle textStyle;
  final String label;

  TimeIndicatorStyle copyWith({
    TextStyle? textStyle,
    String? label,
  }) {
    return TimeIndicatorStyle.raw(
      textStyle: textStyle ?? this.textStyle,
      label: label ?? this.label,
    );
  }

  @override
  int get hashCode => hashValues(textStyle, label);
  @override
  bool operator ==(Object other) {
    return other is TimeIndicatorStyle &&
        textStyle == other.textStyle &&
        label == other.label;
  }
}
