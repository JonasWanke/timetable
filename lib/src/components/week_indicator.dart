import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

import '../date/controller.dart';
import '../utils.dart';

class WeekIndicatorComponent extends StatelessWidget {
  const WeekIndicatorComponent({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final DateController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: controller.date,
      builder: (context, date, _) => WeekIndicator.forDate(date),
    );
  }
}

class WeekIndicator extends StatelessWidget {
  const WeekIndicator(this.weekInfo, {Key? key}) : super(key: key);
  WeekIndicator.forDate(DateTime date, {Key? key})
      : assert(date.isValidTimetableDate),
        weekInfo = date.weekInfo,
        super(key: key);

  final WeekInfo weekInfo;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final backgroundColor = theme.dividerColor;
    return Tooltip(
      // TODO(JonasWanke): G11n
      message: 'Week ${weekInfo.weekOfYear} of ${weekInfo.weekBasedYear}',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Text(
            weekInfo.weekOfYear.toString(),
            style: TextStyle(
              color: backgroundColor
                  .alphaBlendOn(theme.scaffoldBackgroundColor)
                  .mediumEmphasisOnColor,
            ),
          ),
        ),
      ),
    );
  }
}
