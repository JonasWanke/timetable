import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';

import '../theme.dart';
import '../utils/utils.dart';
import 'date_indicator.dart';

class WeekdayIndicator extends StatelessWidget {
  const WeekdayIndicator(this.date, {Key key})
      : assert(date != null),
        super(key: key);

  static final _pattern = LocalDatePattern.createWithCurrentCulture('ddd');

  final LocalDate date;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final timetableTheme = context.timetableTheme;

    final states = DateIndicator.statesFor(date);
    final decoration =
        timetableTheme?.weekDayIndicatorDecoration?.resolve(states) ??
            BoxDecoration();
    final textStyle =
        timetableTheme?.weekDayIndicatorTextStyle?.resolve(states) ??
            TextStyle(
              color: date.isToday
                  ? timetableTheme?.primaryColor ?? theme.primaryColor
                  : theme.highEmphasisOnBackground,
            );

    return DecoratedBox(
      decoration: decoration,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          _pattern.format(date),
          style: textStyle,
        ),
      ),
    );
  }
}
