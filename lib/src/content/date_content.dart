import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:time_machine/time_machine.dart';

import '../event.dart';
import '../timetable.dart';
import 'date_background_painter.dart';
import 'date_events.dart';

class DateContent<E extends Event> extends StatelessWidget {
  DateContent({
    Key key,
    @required this.date,
    @required this.events,
    @required this.eventBuilder,
  })  : assert(date != null),
        assert(events != null),
        assert(
            events.every((e) =>
                e.start <= date.at(LocalTime.maxValue) &&
                e.end >= date.at(LocalTime.minValue)),
            'All events must intersect the given date'),
        assert(events.map((e) => e.id).toSet().length == events.length,
            'Events may not contain duplicate IDs'),
        assert(eventBuilder != null),
        super(key: key);

  final LocalDate date;
  final List<E> events;
  final EventBuilder<E> eventBuilder;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DateBackgroundPainter(dividerColor: context.theme.dividerColor),
      child: DateEvents(
        date: date,
        events: events,
        eventBuilder: eventBuilder,
      ),
    );
  }
}
