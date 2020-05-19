import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

class WeekIndicator extends StatelessWidget {
  const WeekIndicator(this.week, {Key key}) : super(key: key);

  final int week;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final timetableTheme = context.timetableTheme;

    final defaultBackgroundColor = theme.contrastColor.withOpacity(0.12);

    final decoration = timetableTheme?.weekIndicatorDecoration ??
        BoxDecoration(
          color: defaultBackgroundColor,
          borderRadius: BorderRadius.circular(2),
        );
    final textStyle = timetableTheme?.weekIndicatorTextStyle ??
        TextStyle(
          color: defaultBackgroundColor
              .alphaBlendOn(theme.scaffoldBackgroundColor)
              .mediumEmphasisOnColor,
        );

    return DecoratedBox(
      decoration: decoration,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          week.toString(),
          style: textStyle,
        ),
      ),
    );
  }
}
