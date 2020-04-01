import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:time_machine/time_machine.dart' hide Offset;

import '../event.dart';
import '../timetable.dart';
import '../utils/utils.dart';

class DateEvents<E extends Event> extends StatelessWidget {
  DateEvents({
    Key key,
    @required this.date,
    @required Iterable<E> events,
    @required this.eventBuilder,
  })  : assert(date != null),
        assert(events != null),
        assert(
          events.every((e) => e.intersectsDate(date)),
          'All events must intersect the given date',
        ),
        assert(
          events.map((e) => e.id).toSet().length == events.length,
          'Events may not contain duplicate IDs',
        ),
        events = events.sortedBy((e) => e.start).thenByDescending((e) => e.end),
        assert(eventBuilder != null),
        super(key: key);

  static final Period minEventLength = Period(minutes: 30);
  static const double eventSpacing = 4;
  static final Period minStackOverlap = Period(minutes: 15);

  final LocalDate date;
  final List<E> events;
  final EventBuilder<E> eventBuilder;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _DayEventsLayoutDelegate(date, events),
      children: [
        for (final event in events)
          LayoutId(
            key: ValueKey(event.id),
            id: event.id,
            child: eventBuilder(event),
          ),
      ],
    );
  }
}

class _DayEventsLayoutDelegate<E extends Event>
    extends MultiChildLayoutDelegate {
  _DayEventsLayoutDelegate(this.date, this.events)
      : assert(date != null),
        assert(events != null);

  final LocalDate date;
  final List<E> events;

  @override
  void performLayout(Size size) {
    final positions = _calculatePositions();

    double timeToY(LocalDateTime dateTime) {
      if (dateTime.calendarDate < date) {
        return 0;
      } else if (dateTime.calendarDate > date) {
        return size.height;
      } else {
        final progress = dateTime.clockTime.timeSinceMidnight.inMilliseconds /
            TimeConstants.millisecondsPerDay;
        return lerpDouble(0, size.height, progress);
      }
    }

    double periodToY(Period period) =>
        timeToY(date.at(LocalTime.midnight) + period);

    for (final event in events) {
      final position = positions.eventPositions[event];

      final top = min(
        timeToY(event.start),
        size.height - periodToY(DateEvents.minEventLength),
      );
      final height =
          periodToY(event.actualDuration).clamp(0, size.height - top);

      final columnWidth =
          size.width / positions.groupColumnCounts[position.group] -
              DateEvents.eventSpacing;
      final columnLeft =
          columnWidth * position.column + DateEvents.eventSpacing;
      final left = columnLeft + position.index * DateEvents.eventSpacing;
      final width = columnWidth - position.index * DateEvents.eventSpacing;

      final childSize = Size(width, height);
      layoutChild(event.id, BoxConstraints.tight(childSize));
      positionChild(event.id, Offset(left, top));
    }
  }

  _EventPositions _calculatePositions() {
    // How this layout algorithm works:
    // We first divide all events into groups, whereas a group contains all
    // events that intersect one another.
    // Inside a group, events with very close start times are split into
    // multiple columns.
    final positions = _EventPositions();

    var currentGroup = <E>[];
    var currentEnd = TimetableLocalDateTime.minIsoValue;
    for (final event in events) {
      if (event.start >= currentEnd) {
        _endGroup(positions, currentGroup);
        currentGroup = [];
        currentEnd = TimetableLocalDateTime.minIsoValue;
      }

      currentGroup.add(event);
      currentEnd = LocalDateTime.max(currentEnd, event.actualEnd);
    }
    _endGroup(positions, currentGroup);

    return positions;
  }

  void _endGroup(_EventPositions positions, List<E> currentGroup) {
    if (currentGroup.isEmpty) {
      return;
    }
    if (currentGroup.length == 1) {
      positions.eventPositions[currentGroup.first] =
          _SingleEventPosition(positions.groupColumnCounts.length, 0, 0);
      positions.groupColumnCounts.add(1);
      return;
    }

    final columns = <List<E>>[];
    for (final event in currentGroup) {
      var minColumn = -1;
      var minIndex = 1 << 31;
      var minEnd = TimetableLocalDateTime.minIsoValue;
      var columnFound = false;
      for (var columnIndex = 0; columnIndex < columns.length; columnIndex++) {
        final column = columns[columnIndex];
        final other = column.last;

        // No space in current column
        if (event.start < other.start + DateEvents.minStackOverlap) {
          continue;
        }

        final index = column
                .where((e) => e.actualEnd >= event.start)
                .map((e) => positions.eventPositions[e].index)
                .max() ??
            -1;
        final previousEnd = column.fold(
          TimetableLocalDateTime.maxIsoValue,
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
  bool shouldRelayout(_DayEventsLayoutDelegate<E> oldDelegate) {
    return date != oldDelegate.date ||
        !DeepCollectionEquality().equals(events, oldDelegate.events);
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
      LocalDateTime.max(end, start + DateEvents.minEventLength);

  Period get actualDuration => start.periodUntil(actualEnd);
}
