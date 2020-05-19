import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:time_machine/time_machine.dart' hide Offset;

import '../event.dart';
import '../theme.dart';
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
        events = events.sortedByStartLength(),
        assert(eventBuilder != null),
        super(key: key);

  static final _defaultMinEventDuration = Period(minutes: 30);
  static const _defaultMinEventHeight = 16.0;
  static const _defaultEventSpacing = 1.0;
  static const _defaultStackedEventSpacing = 4.0;
  static final Period minStackOverlap = Period(minutes: 15);

  final LocalDate date;
  final List<E> events;
  final EventBuilder<E> eventBuilder;

  @override
  Widget build(BuildContext context) {
    final timetableTheme = context.timetableTheme;

    return CustomMultiChildLayout(
      delegate: _DayEventsLayoutDelegate(
        date: date,
        events: events,
        minEventDuration: timetableTheme?.partDayEventMinimumDuration ??
            _defaultMinEventDuration,
        minEventHeight:
            timetableTheme?.partDayEventMinimumHeight ?? _defaultMinEventHeight,
        eventSpacing:
            timetableTheme?.partDayEventSpacing ?? _defaultEventSpacing,
        stackedEventSpacing: timetableTheme?.partDayStackedEventSpacing ??
            _defaultStackedEventSpacing,
      ),
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
  _DayEventsLayoutDelegate({
    @required this.date,
    @required this.events,
    @required this.minEventDuration,
    @required this.minEventHeight,
    @required this.eventSpacing,
    @required this.stackedEventSpacing,
  })  : assert(date != null),
        assert(events != null),
        assert(minEventDuration != null),
        assert(minEventHeight != null),
        assert(eventSpacing != null),
        assert(stackedEventSpacing != null);

  static const minWidth = 4.0;

  final LocalDate date;
  final List<E> events;

  final Period minEventDuration;
  final double minEventHeight;
  final double eventSpacing;
  final double stackedEventSpacing;

  @override
  void performLayout(Size size) {
    final positions = _calculatePositions(size.height);

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

      final top = timeToY(event.start)
          .coerceAtMost(size.height - periodToY(minEventDuration))
          .coerceAtMost(size.height - minEventHeight);
      final height = periodToY(_durationOn(event, date, size.height))
          .clamp(0, size.height - top);

      final columnWidth = (size.width - eventSpacing) /
          positions.groupColumnCounts[position.group];
      final columnLeft = columnWidth * position.column;
      final left = columnLeft + position.index * stackedEventSpacing;
      final width =
          columnWidth - position.index * stackedEventSpacing - eventSpacing;

      final childSize = Size(width.coerceAtLeast(minWidth), height);
      layoutChild(event.id, BoxConstraints.tight(childSize));
      positionChild(event.id, Offset(left, top));
    }
  }

  _EventPositions _calculatePositions(double height) {
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
        _endGroup(positions, currentGroup, height);
        currentGroup = [];
        currentEnd = TimetableLocalDateTime.minIsoValue;
      }

      currentGroup.add(event);
      currentEnd = currentEnd.coerceAtLeast(_actualEnd(event, height));
    }
    _endGroup(positions, currentGroup, height);

    return positions;
  }

  void _endGroup(
      _EventPositions positions, List<E> currentGroup, double height) {
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
                .where((e) => _actualEnd(e, height) >= event.start)
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

  LocalDateTime _actualEnd(E event, double height) {
    final minDurationForHeight = Period(
      milliseconds:
          (minEventHeight / height * TimeConstants.millisecondsPerDay).toInt(),
    );
    return event.end
        .coerceAtLeast(event.start + minEventDuration)
        .coerceAtLeast(event.start + minDurationForHeight);
  }

  Period _durationOn(E event, LocalDate date, double height) {
    final todayStart = event.start.coerceAtLeast(date.atMidnight());
    final todayEnd =
        _actualEnd(event, height).coerceAtMost(date.addDays(1).atMidnight());
    return todayStart.periodUntil(todayEnd);
  }

  @override
  bool shouldRelayout(_DayEventsLayoutDelegate<E> oldDelegate) {
    return date != oldDelegate.date ||
        minEventDuration != oldDelegate.minEventDuration ||
        minEventHeight != oldDelegate.minEventHeight ||
        eventSpacing != oldDelegate.eventSpacing ||
        stackedEventSpacing != oldDelegate.stackedEventSpacing ||
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
