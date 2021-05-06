import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils.dart';

class WeekdayIndicator extends StatelessWidget {
  WeekdayIndicator(
    this.date, {
    Key? key,
    this.style,
  })  : assert(date.isValidTimetableDate),
        super(key: key);

  final DateTime date;
  final WeekdayIndicatorStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final textStyle = theme.textTheme.caption!.copyWith(
      color:
          date.isToday ? theme.primaryColor : theme.mediumEmphasisOnBackground,
    );

    return Text(DateFormat('EEE').format(date), style: textStyle);
  }
}

/// Style for [WeekdayIndicator].
@immutable
class WeekdayIndicatorStyle {
  const WeekdayIndicatorStyle({
    this.decoration,
    this.padding,
    this.textStyle,
  });

  final Decoration? decoration;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  @override
  int get hashCode => hashList([decoration, padding, textStyle]);
  @override
  bool operator ==(Object other) {
    return other is WeekdayIndicatorStyle &&
        decoration == other.decoration &&
        padding == other.padding &&
        textStyle == other.textStyle;
  }
}
