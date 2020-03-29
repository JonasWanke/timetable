import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';

import '../utils.dart';

class WeekdayIndicator extends StatelessWidget {
  const WeekdayIndicator(this.date, {Key key}) : super(key: key);

  static final _pattern = LocalDatePattern.createWithCurrentCulture('ddd');

  final LocalDate date;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Text(
      _pattern.format(date),
      style: TextStyle(
        color:
            date.isToday ? theme.primaryColor : theme.highEmphasisOnBackground,
      ),
    );
  }
}
