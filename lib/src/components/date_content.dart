import 'package:flutter/widgets.dart';

import '../event.dart';
import '../utils.dart';
import 'date_events.dart';

typedef DateContentBackgroundTapCallback = void Function(DateTime dateTime);

class DateContent<E extends Event> extends StatelessWidget {
  DateContent({
    Key? key,
    required this.date,
    required Iterable<E> events,
    required this.eventBuilder,
    this.onBackgroundTap,
    this.eventsStyle = const DateEventsStyle(),
  })  : assert(date.isValidTimetableDate),
        assert(
          events.every((e) => e.interval.intersects(date.fullDayInterval)),
          'All events must intersect the given date',
        ),
        assert(
          events.map((e) => e.id).toSet().length == events.length,
          'Events may not contain duplicate IDs',
        ),
        events = events.sortedByStartLength(),
        super(key: key);

  final DateTime date;
  final List<E> events;
  final EventBuilder<E> eventBuilder;
  final DateContentBackgroundTapCallback? onBackgroundTap;
  final DateEventsStyle eventsStyle;

  @override
  Widget build(BuildContext context) {
    assert(date.isValidTimetableDate);

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: onBackgroundTap != null
              ? (details) => _onBackgroundTap(height, details.localPosition.dy)
              : null,
          child: DateEvents<E>(
            date: date,
            events: events,
            eventBuilder: eventBuilder,
            style: eventsStyle,
          ),
        );
      },
    );
  }

  void _onBackgroundTap(double height, double yOffset) =>
      onBackgroundTap!(date + (yOffset / height).days);
}
