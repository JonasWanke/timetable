import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/widgets.dart';

import '../controller.dart';
import '../date_page_view.dart';
import '../event.dart';
import '../timetable.dart';
import 'current_time_indicator_painter.dart';
import 'date_events.dart';
import 'multi_date_background_painter.dart';

class MultiDateContent<E extends Event> extends StatelessWidget {
  const MultiDateContent({
    Key key,
    @required this.controller,
    @required this.eventBuilder,
  })  : assert(controller != null),
        assert(eventBuilder != null),
        super(key: key);

  final TimetableController<E> controller;
  final EventBuilder<E> eventBuilder;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MultiDateBackgroundPainter(
        controller: controller,
        dividerColor: context.theme.dividerColor,
      ),
      foregroundPainter: CurrentTimeIndicatorPainter(
        controller: controller,
        color: context.theme.highEmphasisOnBackground,
      ),
      child: DatePageView(
        controller: controller,
        builder: (_, date) => DateEvents<E>(
          date: date,
          events: controller.eventProvider
              .getPartDayEventsIntersecting(date)
              .toList(),
          eventBuilder: eventBuilder,
        ),
      ),
    );
  }
}
