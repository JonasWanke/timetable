import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/widgets.dart';

import '../controller.dart';
import '../event.dart';
import '../timetable.dart';
import '../utils/vertical_zoom.dart';
import 'date_hours_painter.dart';
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
    return VerticalZoom(
      child: Row(
        children: <Widget>[
          Container(
            width: hourColumnWidth,
            padding: EdgeInsets.only(right: 12),
            child: CustomPaint(
              painter: DateHoursPainter(
                textStyle: context.textTheme.caption.copyWith(
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
              eventProvider: eventProvider,
              eventBuilder: eventBuilder,
            ),
          ),
        ],
      ),
    );
  }
}
