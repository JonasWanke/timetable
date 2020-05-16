import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';

import '../utils/utils.dart';

class DateIndicator extends StatelessWidget {
  const DateIndicator(this.date, {Key key}) : super(key: key);

  final LocalDate date;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: date.isToday ? theme.primaryColor : Colors.transparent,
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          date.dayOfMonth.toString(),
          style: TextStyle(
            color: date.isToday
                ? theme.primaryColor.highEmphasisOnColor
                : theme.highEmphasisOnBackground,
          ),
        ),
      ),
    );
  }
}
