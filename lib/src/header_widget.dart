import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';
import 'package:timetable/src/controller.dart';
import 'package:timetable/src/day_page_view.dart';

import 'timetable.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    Key key,
    @required this.controller,
  })  : assert(controller != null),
        super(key: key);

  final TimetableController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // TODO(JonasWanke): dynamic height based on content
      height: 100,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: hourColumnWidth,
            child: Center(child: WeekIndicator(13)),
          ),
          Expanded(
            child: DayPageView(
              controller: controller,
              dayBuilder: (_, date) {
                return Center(child: DateIndicator(date));
              },
            ),
          ),
        ],
      ),
    );
  }
}

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
          '$week',
          style: TextStyle(color: color.highEmphasisOnColor),
        ),
      ),
    );
  }
}

class DateIndicator extends StatelessWidget {
  const DateIndicator(this.date, {Key key}) : super(key: key);

  static final _weekDayPattern =
      LocalDatePattern.createWithCurrentCulture('ddd');

  final LocalDate date;
  bool get isToday => date == LocalDate.today();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildWeekDay(context),
        SizedBox(height: 4),
        _buildDayOfMonth(context),
      ],
    );
  }

  Widget _buildWeekDay(BuildContext context) {
    final theme = context.theme;

    return Text(
      _weekDayPattern.format(date),
      style: TextStyle(
        color: isToday ? theme.primaryColor : theme.highEmphasisOnBackground,
      ),
    );
  }

  Widget _buildDayOfMonth(BuildContext context) {
    final theme = context.theme;

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isToday ? theme.primaryColor : Colors.transparent,
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          '${date.dayOfMonth}',
          style: TextStyle(
            color: isToday
                ? theme.primaryColor.highEmphasisOnColor
                : theme.highEmphasisOnBackground,
          ),
        ),
      ),
    );
  }
}
