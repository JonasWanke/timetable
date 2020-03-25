import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';

typedef DayWidgetBuilder = Widget Function(BuildContext context, LocalDate day);

class DayPageView extends StatelessWidget {
  const DayPageView({
    Key key,
    @required this.dayBuilder,
    @required this.startDate,
    this.visibleDayCount = 7,
  })  : assert(dayBuilder != null),
        assert(startDate != null),
        assert(visibleDayCount != null),
        super(key: key);

  final DayWidgetBuilder dayBuilder;
  final LocalDate startDate;
  final int visibleDayCount;

  static final _epochIndex = -LocalDate.minIsoValue.epochDay;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: PageController(
        // TODO(JonasWanke): initialPage is centered, whereas we probably want startDate to be the left-most day.
        initialPage: dateToIndex(startDate),
        viewportFraction: 1 / visibleDayCount,
      ),
      itemBuilder: (context, index) => dayBuilder(context, indexToDate(index)),
    );
  }

  static int dateToIndex(LocalDate date) => date.epochDay + _epochIndex;
  static LocalDate indexToDate(int index) =>
      LocalDate.fromEpochDay(index - _epochIndex);
}
