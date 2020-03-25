import 'package:flutter/widgets.dart';
import 'package:time_machine/time_machine.dart';

import 'day_events_widget.dart';
import 'day_page_view.dart';
import 'event.dart';

class TimetableController {
  TimetableController({LocalDate initialDate})
      : initialDate = initialDate ?? LocalDate.today();

  final LocalDate initialDate;
}

typedef EventProvider<E extends Event> = List<E> Function(LocalDate date);
typedef EventBuilder<E extends Event> = Widget Function(E event);

class Timetable<E extends Event> extends StatefulWidget {
  Timetable({
    Key key,
    TimetableController controller,
    @required this.eventProvider,
    @required this.eventBuilder,
  })  : controller = controller ?? TimetableController(),
        assert(eventProvider != null),
        assert(eventBuilder != null),
        super(key: key);

  final TimetableController controller;
  final EventProvider<E> eventProvider;
  final EventBuilder<E> eventBuilder;

  @override
  _TimetableState<E> createState() => _TimetableState<E>();
}

class _TimetableState<E extends Event> extends State<Timetable<E>> {
  @override
  Widget build(BuildContext context) {
    return DayPageView(
      startDate: widget.controller.initialDate,
      dayBuilder: (_, day) => DayEventsWidget<E>(
        date: day,
        events: widget.eventProvider(day),
        eventBuilder: widget.eventBuilder,
      ),
    );
  }
}
