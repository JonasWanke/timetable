import 'package:flutter/widgets.dart';

import '../callbacks.dart';
import '../event/event.dart';
import '../time/overlay.dart';
import '../utils.dart';
import 'date_events.dart';
import 'overlays.dart';

class DateContent<E extends Event> extends StatelessWidget {
  DateContent({
    Key? key,
    required this.date,
    required List<E> events,
    this.overlays = const [],
    this.onBackgroundTap,
  })  : assert(date.isValidTimetableDate),
        assert(
          events.every((e) => e.interval.intersects(date.fullDayInterval)),
          'All events must intersect the given date',
        ),
        assert(
          events.toSet().length == events.length,
          'Events may not contain duplicates',
        ),
        events = events.sortedByStartLength(),
        super(key: key);

  final DateTime date;

  final List<E> events;
  final List<TimeOverlay> overlays;

  final DateTimeTapCallback? onBackgroundTap;

  @override
  Widget build(BuildContext context) {
    final onBackgroundTap = this.onBackgroundTap ??
        DefaultTimetableCallbacks.of(context)?.onDateTimeBackgroundTap;

    return LayoutBuilder(builder: (context, constraints) {
      final height = constraints.maxHeight;

      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapUp: onBackgroundTap != null
            ? (details) =>
                onBackgroundTap(date + (details.localPosition.dy / height).days)
            : null,
        child: Stack(children: [
          _buildOverlaysForPosition(DecorationPosition.background),
          DateEvents<E>(date: date, events: events),
          _buildOverlaysForPosition(DecorationPosition.foreground),
        ]),
      );
    });
  }

  Widget _buildOverlaysForPosition(DecorationPosition position) {
    return Positioned.fill(
      child: TimeOverlays(
        overlays: overlays.where((it) => it.position == position).toList(),
      ),
    );
  }
}
