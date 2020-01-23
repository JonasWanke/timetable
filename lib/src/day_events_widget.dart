import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:time_machine/time_machine.dart' hide Offset;

import 'event.dart';
import 'timetable.dart';
import 'utils.dart';

class DayEventsWidget<E extends Event> extends StatelessWidget {
  DayEventsWidget({
    Key key,
    @required this.date,
    @required this.events,
    @required this.eventBuilder,
  })  : assert(date != null),
        assert(events != null),
        assert(
            events.every((e) =>
                e.start <= date.at(LocalTime.maxValue) &&
                e.end >= date.at(LocalTime.minValue)),
            'All events must intersect the given date'),
        assert(events.map((e) => e.id).toSet().length == events.length,
            'Events may not contain duplicate IDs'),
        assert(eventBuilder != null),
        super(key: key) {
    events.sort((a, b) {
      final startResult = a.start.compareTo(b.start);
      if (startResult != 0) {
        return startResult;
      }

      return a.end.compareTo(b.end);
    });
  }

  static final Period minEventLength = Period(minutes: 30);
  static const double eventSpacing = 4;
  static final Period minStackOverlap = Period(minutes: 15);

  final LocalDate date;
  final List<E> events;
  final EventBuilder<E> eventBuilder;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _DayEventsLayoutDelegate(this),
      children: events
          .map(
            (e) => LayoutId(
              id: e.id,
              child: eventBuilder(e),
            ),
          )
          .toList(),
    );
  }
}

class _DayEventsLayoutDelegate<E extends Event>
    extends MultiChildLayoutDelegate {
  _DayEventsLayoutDelegate(this.widget) : assert(widget != null);

  final DayEventsWidget<E> widget;

  @override
  void performLayout(Size size) {
    final positions = _calculatePositions();

    double timeToY(LocalDateTime dateTime) {
      if (dateTime.calendarDate < widget.date) {
        return 0;
      } else if (dateTime.calendarDate > widget.date) {
        return size.height;
      } else {
        final progress = dateTime.clockTime.timeSinceMidnight.inMilliseconds /
            TimeConstants.millisecondsPerDay;
        return lerpDouble(0, size.height, progress);
      }
    }

    double periodToY(Period period) =>
        timeToY(widget.date.at(LocalTime.midnight) + period);

    for (final event in widget.events) {
      final position = positions.eventPositions[event];

      final top = min(
        timeToY(event.start),
        size.height - periodToY(DayEventsWidget.minEventLength),
      );
      final height =
          periodToY(event.actualDuration).clamp(0, size.height - top);

      final columnWidth =
          size.width / positions.groupColumnCounts[position.group];
      final columnLeft =
          columnWidth * position.column + DayEventsWidget.eventSpacing;
      final left = columnLeft + position.index * DayEventsWidget.eventSpacing;
      final width = columnWidth - DayEventsWidget.eventSpacing;

      final childSize = Size(width, height);
      layoutChild(event.id, BoxConstraints.tight(childSize));
      positionChild(event.id, Offset(left, top));
    }
  }

  _EventPositions _calculatePositions() {
    // How this layout algorithm works:
    // We first divide all events into group, whereas a group contains all
    // events that (partially) overlap one another.
    // Inside a group, events whose start times are very close, we split them
    // into multiple columns.
    final positions = _EventPositions();

    List<E> currentGroup = [];
    var currentEnd = LocalDateTimeExtension.minIsoValue;
    for (final event in widget.events) {
      if (event.start >= currentEnd) {
        _endGroup(positions, currentGroup);
        currentGroup = [];
        currentEnd = LocalDateTimeExtension.minIsoValue;
      }

      currentGroup.add(event);
      currentEnd = LocalDateTime.max(currentEnd, event.actualEnd);
    }
    _endGroup(positions, currentGroup);

    return positions;
  }

  void _endGroup(_EventPositions positions, List<Event> currentGroup) {
    if (currentGroup.isEmpty) {
      return;
    }
    if (currentGroup.length == 1) {
      positions.eventPositions[currentGroup.first] =
          _SingleEventPosition(positions.groupColumnCounts.length, 0, 0);
      positions.groupColumnCounts.add(1);
      return;
    }

    final List<List<Event>> columns = [];
    for (final event in currentGroup) {
      var minColumn = -1;
      var minIndex = 1 << 31;
      var minEnd = LocalDateTimeExtension.minIsoValue;
      var columnFound = false;
      for (var columnIndex = 0; columnIndex < columns.length; columnIndex++) {
        final column = columns[columnIndex];
        final other = column.last;

        // No space in current column
        if (event.start <= other.start + DayEventsWidget.minStackOverlap) {
          continue;
        }

        final index = column
                .where((e) => e.actualEnd >= event.start)
                .map((e) => positions.eventPositions[e].index)
                .max ??
            -1;
        final previousEnd = column.fold(
          LocalDateTimeExtension.maxIsoValue,
          (max, e) => LocalDateTime.max(max, e.end),
        );
        // Further at the top and hence wider
        if (index < minIndex || (index == minIndex && previousEnd < minEnd)) {
          minColumn = columnIndex;
          minIndex = index;
          minEnd = previousEnd;
          columnFound = true;
        }
      }

      // If no column fits
      if (!columnFound) {
        positions.eventPositions[event] = _SingleEventPosition(
            positions.groupColumnCounts.length, columns.length, 0);
        columns.add([event]);
        continue;
      }

      positions.eventPositions[event] = _SingleEventPosition(
          positions.groupColumnCounts.length, minColumn, minIndex + 1);
      columns[minColumn].add(event);
    }
    positions.groupColumnCounts.add(columns.length);
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}

class _EventPositions {
  final List<int> groupColumnCounts = [];
  final Map<Event, _SingleEventPosition> eventPositions = {};
}

class _SingleEventPosition {
  _SingleEventPosition(this.group, this.column, this.index)
      : assert(group != null),
        assert(column != null),
        assert(index != null);

  final int group;
  final int column;
  final int index;
}

extension _TimeCalculation on Event {
  LocalDateTime get actualEnd =>
      LocalDateTime.max(end, start + DayEventsWidget.minEventLength);

  Period get actualDuration => start.periodUntil(actualEnd);
}
