import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';

import 'date_indicator.dart';
import 'weekday_indicator.dart';

class DateHeader extends StatelessWidget {
  const DateHeader(this.date, {Key key})
      : assert(date != null),
        super(key: key);

  final LocalDate date;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        WeekdayIndicator(date),
        SizedBox(height: 4),
        DateIndicator(date),
      ],
    );
  }
}
