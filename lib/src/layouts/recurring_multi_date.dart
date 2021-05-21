import 'package:flutter/material.dart';

import '../event/event.dart';
import '../theme.dart';
import 'multi_date.dart';

class RecurringMultiDateTimetable<E extends Event> extends StatelessWidget {
  RecurringMultiDateTimetable({
    Key? key,
    WidgetBuilder? timetableBuilder,
  })  : timetableBuilder =
            timetableBuilder ?? ((context) => MultiDateTimetable<E>()),
        super(key: key);

  final WidgetBuilder timetableBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = TimetableTheme.orDefaultOf(context);

    return TimetableTheme(
      data: theme.copyWith(
        dateHeaderStyleProvider: (date) => theme
            .dateHeaderStyleProvider(date)
            .copyWith(showDateIndicator: false),
      ),
      child: Builder(builder: timetableBuilder),
    );
  }
}
