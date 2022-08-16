import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

import '../event/all_day.dart';
import '../event/basic.dart';
import '../localization.dart';
import '../utils.dart';

class AllDayOverflow extends StatelessWidget {
  AllDayOverflow(this.date, {super.key, required this.overflowCount})
      : assert(date.debugCheckIsValidTimetableDate()),
        assert(overflowCount >= 1);

  final DateTime date;
  final int overflowCount;

  @override
  Widget build(BuildContext context) {
    return BasicAllDayEventWidget(
      BasicEvent(
        id: date,
        title: TimetableLocalizations.of(context).allDayOverflow(overflowCount),
        backgroundColor: context.theme.backgroundColor.withOpacity(0),
        start: date,
        end: date.atEndOfDay,
      ),
      info: AllDayEventLayoutInfo(hiddenStartDays: 0, hiddenEndDays: 0),
    );
  }
}
