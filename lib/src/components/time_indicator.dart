import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:black_hole_flutter/black_hole_flutter.dart';

import '../localization.dart';
import '../utils.dart';

class TimeIndicator extends StatelessWidget {
  TimeIndicator({
    Key? key,
    required this.time,
    ValueGetter<DateFormat>? format,
    this.textStyle,
  })  : assert(time.isValidTimetableTimeOfDay),
        formatter = _formatterFromDateFormat(format ?? formatHour),
        super(key: key);

  const TimeIndicator.custom({
    Key? key,
    required this.time,
    required this.formatter,
    this.textStyle,
  }) : super(key: key);

  // We use getters instead of final fields because `DateFormat`'s constructor
  // captures the locale, hence changing the app's locale doesn't affect already
  // created `DateFormat`s.
  static DateFormat formatHour() => DateFormat.j();
  static DateFormat formatHourMinute() => DateFormat.jm();
  static DateFormat formatHourMinuteSecond() => DateFormat.jms();

  static DateFormat formatHour24() => DateFormat.H();
  static DateFormat formatHour24Minute() => DateFormat.Hm();
  static DateFormat formatHour24MinuteSecond() => DateFormat.Hms();

  static TimeFormatter _formatterFromDateFormat(
      ValueGetter<DateFormat> format) {
    return (time) => format().format(DateTime(0) + time);
  }

  final Duration time;
  final TimeFormatter formatter;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    context.dependOnTimetableLocalizations();
    return Text(
      formatter(time),
      style: textStyle ??
          context.textTheme.caption!
              .copyWith(color: context.theme.backgroundColor.disabledOnColor),
    );
  }
}

typedef TimeFormatter = String Function(Duration time);
