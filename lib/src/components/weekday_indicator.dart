import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils.dart';

class WeekdayIndicator extends StatelessWidget {
  WeekdayIndicator(this.date, {Key? key})
      : assert(date.isValidTimetableDate),
        super(key: key);

  final DateTime date;

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
