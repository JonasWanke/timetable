import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

class WeekIndicator extends StatelessWidget {
  const WeekIndicator(this.week, {Key key}) : super(key: key);

  final int week;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final color = theme.cardColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          week.toString(),
          style: TextStyle(color: color.highEmphasisOnColor),
        ),
      ),
    );
  }
}
