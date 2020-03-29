import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:timetable/src/content/multi_date_background_painter.dart';

import '../controller.dart';
import '../date_page_view.dart';
import '../event.dart';
import '../timetable.dart';
import 'date_events.dart';

class MultiDateContent<E extends Event> extends StatelessWidget {
  const MultiDateContent({
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
    return CustomPaint(
      painter: MultiDateBackgroundPainter(
        controller: controller,
        dividerColor: context.theme.dividerColor,
      ),
      child: DatePageView(
        controller: controller,
        builder: (_, date) => DateEvents<E>(
          date: date,
          events: eventProvider(date),
          eventBuilder: eventBuilder,
        ),
      ),
    );
  }
}
