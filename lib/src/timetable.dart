import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/src/content/timetable_content.dart';

import 'controller.dart';
import 'event.dart';
import 'header/timetable_header.dart';

typedef EventProvider<E extends Event> = List<E> Function(LocalDate date);
typedef EventBuilder<E extends Event> = Widget Function(E event);

const double hourColumnWidth = 48;

class Timetable<E extends Event> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TimetableHeader(controller: controller),
        Expanded(
          child: TimetableContent(
            controller: controller,
            eventProvider: eventProvider,
            eventBuilder: eventBuilder,
          ),
        ),
      ],
    );
  }
}
