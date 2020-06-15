import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';

import '../theme.dart';
import '../utils/utils.dart';

class DateIndicator extends StatelessWidget {
  const DateIndicator(this.date, {Key key}) : super(key: key);

  final LocalDate date;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final timetableTheme = context.timetableTheme;

    final pattern = timetableTheme?.dateIndicatorPattern ??
        LocalDatePattern.createWithCurrentCulture('%d');
    final states = statesFor(date);
    final primaryColor = timetableTheme?.primaryColor ?? theme.primaryColor;
    final decoration =
        timetableTheme?.dateIndicatorDecoration?.resolve(states) ??
            BoxDecoration(
              shape: BoxShape.circle,
              color: date.isToday ? primaryColor : Colors.transparent,
            );
    final textStyle = timetableTheme?.dateIndicatorTextStyle?.resolve(states) ??
        TextStyle(
          color: date.isToday
              ? primaryColor.highEmphasisOnColor
              : theme.highEmphasisOnBackground,
        );

    return DecoratedBox(
      decoration: decoration,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Text(pattern.format(date), style: textStyle),
      ),
    );
  }

  static Set<MaterialState> statesFor(LocalDate date) {
    return {
      if (date < LocalDate.today()) MaterialState.disabled,
      if (date.isToday) MaterialState.selected,
    };
  }
}
