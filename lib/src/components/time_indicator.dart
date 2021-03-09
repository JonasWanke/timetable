import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:black_hole_flutter/black_hole_flutter.dart';

import '../utils.dart';

class TimeIndicator extends StatelessWidget {
  TimeIndicator({
    Key? key,
    required this.time,
    DateFormat? format,
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

  static final formatHour = DateFormat.j();
  static final formatHourMinute = DateFormat.jm();
  static final formatHourMinuteSecond = DateFormat.jms();

  static final formatHour24 = DateFormat.H();
  static final formatHour24Minute = DateFormat.Hm();
  static final formatHour24MinuteSecond = DateFormat.Hms();

  static TimeFormatter _formatterFromDateFormat(DateFormat format) {
    return (time) => format.format(DateTime(0) + time);
  }

  final Duration time;
  final TimeFormatter formatter;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatter(time),
      style: textStyle ??
          context.textTheme.caption!
              .copyWith(color: context.theme.backgroundColor.disabledOnColor),
    );
  }
}

typedef TimeFormatter = String Function(Duration time);
