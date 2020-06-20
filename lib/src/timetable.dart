import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:time_machine/time_machine.dart';

import 'all_day.dart';
import 'content/timetable_content.dart';
import 'controller.dart';
import 'event.dart';
import 'header/timetable_header.dart';
import 'theme.dart';

typedef EventBuilder<E extends Event> = Widget Function(E event);
typedef OnCreateEventCallback = void Function(LocalDateTime start, bool isAllDay);
typedef AllDayEventBuilder<E extends Event> = Widget Function(
  BuildContext context,
  E event,
  AllDayEventLayoutInfo info,
);

const double hourColumnWidth = 48;

class Timetable<E extends Event> extends StatelessWidget {

  const Timetable({
    Key key,
    @required this.controller,
    @required this.eventBuilder,
    this.allDayEventBuilder,
    this.onCreateEvent,
    this.theme,
  })  : assert(controller != null),
        assert(eventBuilder != null),
        super(key: key);

  final TimetableController<E> controller;
  final EventBuilder<E> eventBuilder;

  /// Optional [Widget] builder function for all-day event shown in the header.
  ///
  /// If not set, [eventBuilder] will be used instead.
  final AllDayEventBuilder<E> allDayEventBuilder;
  final TimetableThemeData theme;
  final OnCreateEventCallback onCreateEvent;

  @override
  Widget build(BuildContext context) {
    Widget child = Column(
      children: <Widget>[
        TimetableHeader<E>(
          controller: controller,
          onCreateEvent: onCreateEvent,
          allDayEventBuilder:
              allDayEventBuilder ?? (_, event, __) => eventBuilder(event),
        ),
        Expanded(
          child: TimetableContent<E>(
            controller: controller,
            eventBuilder: eventBuilder,
            onCreateEvent: onCreateEvent
          ),
        ),
      ],
    );

    if (theme != null) {
      child = TimetableTheme(data: theme, child: child);
    }

    return child;
  }
}
