import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/widgets.dart';

import '../controller.dart';
import '../date_page_view.dart';
import '../event.dart';
import '../timetable.dart';
import '../utils/stream_change_notifier.dart';
import 'current_time_indicator_painter.dart';
import 'multi_date_background_painter.dart';
import 'streamed_date_events.dart';

class MultiDateContent<E extends Event> extends StatefulWidget {
  const MultiDateContent({
    Key key,
    @required this.controller,
    @required this.eventBuilder,
  })  : assert(controller != null),
        assert(eventBuilder != null),
        super(key: key);

  final TimetableController<E> controller;
  final EventBuilder<E> eventBuilder;

  @override
  _MultiDateContentState<E> createState() => _MultiDateContentState<E>();
}

class _MultiDateContentState<E extends Event>
    extends State<MultiDateContent<E>> {
  final _timeListenable =
      StreamChangeNotifier(Stream.periodic(Duration(seconds: 10)));

  @override
  void dispose() {
    _timeListenable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MultiDateBackgroundPainter(
        controller: widget.controller,
        dividerColor: context.theme.dividerColor,
      ),
      foregroundPainter: CurrentTimeIndicatorPainter(
        controller: widget.controller,
        color: context.theme.highEmphasisOnBackground,
      ),
      child: DatePageView(
        controller: widget.controller,
        builder: (_, date) {
          return StreamedDateEvents<E>(
            date: date,
            controller: widget.controller,
            eventBuilder: widget.eventBuilder,
          );
        },
      ),
    );
  }
}
