import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:timetable/src/content/timetable_content.dart';

import 'controller.dart';
import 'event.dart';
import 'header/timetable_header.dart';

typedef EventBuilder<E extends Event> = Widget Function(E event);

const double hourColumnWidth = 48;

class Timetable<E extends Event> extends StatelessWidget {
  const Timetable({
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
    return Column(
      children: <Widget>[
        TimetableHeader(
          controller: controller,
          eventBuilder: eventBuilder,
        ),
        Expanded(
          child: TimetableContent<E>(
            controller: controller,
            eventBuilder: eventBuilder,
          ),
        ),
      ],
    );
  }
}
