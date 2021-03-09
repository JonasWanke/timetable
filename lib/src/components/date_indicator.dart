import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils.dart';

class DateIndicator extends StatelessWidget {
  DateIndicator(this.date, {Key? key})
      : assert(date.isValidTimetableDate),
        super(key: key);

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final primaryColor = theme.primaryColor;
    final decoration = BoxDecoration(
      shape: BoxShape.circle,
      color: date.isToday ? primaryColor : Colors.transparent,
    );
    final textStyle = context.textTheme.subtitle1!.copyWith(
      color: date.isToday
          ? primaryColor.highEmphasisOnColor
          : theme.highEmphasisOnBackground,
    );

    return DecoratedBox(
      decoration: decoration,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Text(DateFormat('d').format(date), style: textStyle),
      ),
    );
  }

  static Set<MaterialState> statesFor(DateTime date) {
    return {
      if (date < DateTimeTimetable.today()) MaterialState.disabled,
      if (date.isToday) MaterialState.selected,
    };
  }
}
