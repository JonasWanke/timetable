import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:time_machine/time_machine.dart';

import '../controller.dart';
import '../event.dart';
import '../theme.dart';
import '../timetable.dart';
import '../utils/vertical_zoom.dart';
import 'date_hours_painter.dart';
import 'multi_date_content.dart';

class TimetableContent<E extends Event> extends StatelessWidget {
  const TimetableContent({
    Key key,
    @required this.controller,
    @required this.eventBuilder,
    this.onCreateEvent,
  })  : assert(controller != null),
        assert(eventBuilder != null),
        super(key: key);

  final TimetableController<E> controller;
  final EventBuilder<E> eventBuilder;
  final OnCreateEventCallback onCreateEvent;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final timetableTheme = context.timetableTheme;

    return VerticalZoom(
      initialZoom: controller.initialTimeRange.asInitialZoom(),
      minChildHeight:
          (timetableTheme?.minimumHourHeight ?? 16) * TimeConstants.hoursPerDay,
      maxChildHeight:
          (timetableTheme?.maximumHourHeight ?? 64) * TimeConstants.hoursPerDay,
      child: Row(
        children: <Widget>[
          Container(
            width: hourColumnWidth,
            padding: EdgeInsets.only(right: 12),
            child: CustomPaint(
              painter: DateHoursPainter(
                textStyle: timetableTheme?.hourTextStyle ??
                    theme.textTheme.caption.copyWith(
                      color: context.theme.disabledOnBackground,
                    ),
                textDirection: context.directionality,
              ),
              size: Size.infinite,
            ),
          ),
          Expanded(
            child: MultiDateContent<E>(
              controller: controller,
              eventBuilder: eventBuilder,
              onCreateEvent: onCreateEvent
            ),
          ),
        ],
      ),
    );
  }
}
