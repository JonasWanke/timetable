import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';

import '../controller.dart';
import '../event.dart';
import '../timetable.dart';
import 'multi_date_header.dart';
import 'week_indicator.dart';

class TimetableHeader<E extends Event> extends StatelessWidget {
  const TimetableHeader({
    Key key,
    @required this.controller,
  })  : assert(controller != null),
        super(key: key);

  final TimetableController<E> controller;

  @override
  Widget build(BuildContext context) {
    // Like [WeekYearRules.iso], but with a variable first day of week.
    final weekYearRule =
        WeekYearRules.forMinDaysInFirstWeek(4, controller.firstDayOfWeek);

    return SizedBox(
      // TODO(JonasWanke): dynamic height based on content
      height: 64,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: hourColumnWidth,
            child: Center(
              child: ValueListenableBuilder<LocalDate>(
                valueListenable: controller.dateListenable,
                builder: (context, date, _) =>
                    WeekIndicator(weekYearRule.getWeekOfWeekYear(date)),
              ),
            ),
          ),
          Expanded(
            child: MultiDateHeader(controller: controller),
          ),
        ],
      ),
    );
  }
}
