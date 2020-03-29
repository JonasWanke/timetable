import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../controller.dart';
import '../event.dart';
import '../timetable.dart';
import 'date_hours.dart';
import 'multi_date_content.dart';

class TimetableContent<E extends Event> extends StatelessWidget {
  const TimetableContent({
    Key key,
    @required this.controller,
    @required this.eventProvider,
    @required this.eventBuilder,
  })  : assert(controller != null),
        assert(eventProvider != null),
        assert(eventBuilder != null),
        super(key: key);

  final TimetableController controller;
  final EventProvider<E> eventProvider;
  final EventBuilder<E> eventBuilder;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        DateHours(),
        Expanded(
          child: MultiDateContent(
            controller: controller,
            eventProvider: eventProvider,
            eventBuilder: eventBuilder,
          ),
        ),
      ],
    );
  }
}
