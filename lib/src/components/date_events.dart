import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../event.dart';
import '../utils.dart';
import 'multi_date_content.dart';

class DateEvents<E extends Event> extends StatelessWidget {
  DateEvents({
    Key? key,
    required this.date,
    required Iterable<E> events,
    required this.eventBuilder,
    this.style = const DateEventsStyle(),
  })  : assert(date.isValidTimetableDate),
        assert(
          events.every((e) => e.interval.intersects(date.fullDayInterval)),
          'All events must intersect the given date',
        ),
        assert(
          events.map((e) => e.id).toSet().length == events.length,
          'Events may not contain duplicate IDs',
        ),
        events = events.sortedByStartLength(),
        super(key: key);

  final DateTime date;
  final List<E> events;
  final MultiDateContentEventBuilder<E> eventBuilder;
  final DateEventsStyle style;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _DayEventsLayoutDelegate(
        date: date,
        events: events,
        minEventDuration: style.minEventDuration,
        minEventHeight: style.minEventHeight,
        eventSpacing: style.eventSpacing,
        enableStacking: style.enableEventStacking,
        minDeltaForStacking: style.minEventDeltaForStacking,
        stackedEventSpacing: style.stackedEventSpacing,
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

/// Defines visual properties for [MultiDateContent].
class DateEventsStyle {
  const DateEventsStyle({
    this.minHourHeight = 16,
    this.maxHourHeight = 64,
    this.minHourZoom = 0,
    this.maxHourZoom = double.infinity,
    this.minEventDuration = const Duration(minutes: 30),
    this.minEventHeight = 16,
    this.eventSpacing = 1,
    this.enableEventStacking = true,
    this.minEventDeltaForStacking = const Duration(minutes: 15),
    this.stackedEventSpacing = 4,
  })  : assert(minHourHeight > 0),
        assert(maxHourHeight > 0),
        assert(minHourHeight <= maxHourHeight),
        // For some reason, the following line produces a
        // "const_eval_throws_exception" error:
        // assert(minHourZoom > 0),
        assert(maxHourZoom > 0),
        assert(minHourZoom <= minHourZoom);

  /// Minimum height of a single hour when zooming in.
  final double minHourHeight;

  /// Maximum height of a single hour when zooming in.
  ///
  /// [double.infinity] is supported.
  final double maxHourHeight;

  /// Minimum time zoom factor.
  ///
  /// `1` means that the hours content is exactly as high as the parent. Larger
  /// values mean zooming in, and smaller values mean zooming out.
  ///
  /// If both hour height limits ([minHourHeight] or [maxHourHeight])
  /// and hour zoom limits (this property or [maxHourZoom]) are set, zoom
  /// limits take precedence.
  final double minHourZoom;

  /// Maximum time zoom factor.
  ///
  /// See also:
  /// - [minHourZoom] for an explanation of zoom values.
  final double maxHourZoom;

  /// Minimum [Duration] to size a part-day event.
  ///
  /// Can be used together with [minEventHeight].
  final Duration minEventDuration;

  /// Minimum height to size a part-day event.
  ///
  /// Can be used together with [minEventDuration].
  final double minEventHeight;

  /// Horizontal space between two parallel events shown next to each other.
  // TODO(JonasWanke): Can we convert this to margin of individual events?
  final double eventSpacing;

  /// Controls whether overlapping events may be stacked on top of each other.
  ///
  /// If set to `true`, intersecting events may be stacked if their start values
  /// differ by at least [minEventDeltaForStacking]. If set to
  /// `false`, intersecting events will always be shown next to each other and
  /// not overlap.
  final bool enableEventStacking;

  /// When the start values of two events differ by at least this value, they
  /// may be stacked on top of each other.
  ///
  /// If the difference is less, they will be shown next to each other.
  ///
  /// See also:
  /// - [enableEventStacking], which can disable the stacking behavior
  ///   completely.
  final Duration minEventDeltaForStacking;

  /// Horizontal space between two parallel events stacked on top of each other.
  final double stackedEventSpacing;

  @override
  int get hashCode {
    return hashList([
      minHourHeight,
      maxHourHeight,
      minHourZoom,
      maxHourZoom,
      minEventDuration,
      minEventHeight,
      eventSpacing,
      enableEventStacking,
      minEventDeltaForStacking,
      stackedEventSpacing,
    ]);
  }

  @override
  bool operator ==(Object other) {
    return other is DateEventsStyle &&
        other.minHourHeight == minHourHeight &&
        other.maxHourHeight == maxHourHeight &&
        other.minHourZoom == minHourZoom &&
        other.maxHourZoom == maxHourZoom &&
        other.minEventDuration == minEventDuration &&
        other.minEventHeight == minEventHeight &&
        other.eventSpacing == eventSpacing &&
        other.enableEventStacking == enableEventStacking &&
        other.minEventDeltaForStacking == minEventDeltaForStacking &&
        other.stackedEventSpacing == stackedEventSpacing;
  }
}

class _DayEventsLayoutDelegate<E extends Event>
    extends MultiChildLayoutDelegate {
  _DayEventsLayoutDelegate({
    required this.date,
    required this.events,
    required this.minEventDuration,
    required this.minEventHeight,
    required this.eventSpacing,
    required this.enableStacking,
    required this.minDeltaForStacking,
    required this.stackedEventSpacing,
  })   : assert(date.isValidTimetableDate),
        assert(!minEventDuration.isNegative),
        assert(!minDeltaForStacking.isNegative);

  static const minWidth = 4.0;

  final DateTime date;
  final List<E> events;

  final Duration minEventDuration;
  final double minEventHeight;
  final double eventSpacing;
  final bool enableStacking;
  final Duration minDeltaForStacking;
  final double stackedEventSpacing;

  @override
  void performLayout(Size size) {
    final positions = _calculatePositions(size.height);

    double timeToY(DateTime dateTime) {
      assert(dateTime.isValidTimetableDateTime);

      if (dateTime < date) {
        return 0;
      } else if (dateTime.atStartOfDay > date) {
        return size.height;
      } else {
        return lerpDouble(0, size.height, dateTime.timeOfDay / 1.days)!;
      }
    }

    double durationToY(Duration duration) => timeToY(date + duration);

    for (final event in events) {
      final position = positions.eventPositions[event]!;
      final top = timeToY(event.start)
          .coerceAtMost(size.height - durationToY(minEventDuration))
          .coerceAtMost(size.height - minEventHeight);
      final height = durationToY(_durationOn(event, date, size.height))
          .clamp(0, size.height - top)
          .toDouble();

      final columnWidth = (size.width - eventSpacing) /
          positions.groupColumnCounts[position.group];
      final columnLeft = columnWidth * position.column;
      final left = columnLeft + position.index * stackedEventSpacing;
      final width = columnWidth * position.columnSpan -
          position.index * stackedEventSpacing -
          eventSpacing;

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
    DateTime? currentEnd;
    for (final event in events) {
      if (currentEnd != null && event.start >= currentEnd) {
        _endGroup(positions, currentGroup, height);
        currentGroup = [];
        currentEnd = null;
      }

      currentGroup.add(event);
      final actualEnd = _actualEnd(event, height);
      currentEnd = currentEnd == null
          ? actualEnd
          : currentEnd.coerceAtLeast(_actualEnd(event, height));
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
      DateTime? minEnd;
      var columnFound = false;
      for (var columnIndex = 0; columnIndex < columns.length; columnIndex++) {
        final column = columns[columnIndex];
        final other = column.last;

        // No space in current column
        if (!enableStacking && event.start < _actualEnd(other, height) ||
            enableStacking && event.start < other.start + minDeltaForStacking) {
          continue;
        }

        final index = column
                .where((e) => _actualEnd(e, height) >= event.start)
                .map((e) => positions.eventPositions[e]!.index)
                .max() ??
            -1;

        final previousEnd = column
            .map((it) => it.end)
            .reduce((value, element) => value.coerceAtLeast(element));

        // Further at the top and hence wider
        if (index < minIndex ||
            (index == minIndex && (minEnd != null && previousEnd < minEnd))) {
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

    // Expand events to multiple columns if possible.
    for (final event in currentGroup) {
      final position = positions.eventPositions[event]!;
      if (position.column == columns.length - 1) {
        continue;
      }

      var columnSpan = 1;
      for (var i = position.column + 1; i < columns.length; i++) {
        final hasOverlapInColumn = currentGroup
            .where((e) => positions.eventPositions[e]!.column == i)
            .where((e) =>
                event.start < _actualEnd(e, height) &&
                e.start < _actualEnd(event, height))
            .isNotEmpty;
        if (hasOverlapInColumn) {
          break;
        }

        columnSpan++;
      }
      positions.eventPositions[event] = position.copyWith(
        columnSpan: columnSpan,
      );
    }

    positions.groupColumnCounts.add(columns.length);
  }

  DateTime _actualEnd(E event, double height) {
    final minDurationForHeight = (minEventHeight / height).days;
    return event.end
        .coerceAtLeast(event.start + minEventDuration)
        .coerceAtLeast(event.start + minDurationForHeight);
  }

  Duration _durationOn(E event, DateTime date, double height) {
    assert(date.isValidTimetableDate);

    final todayStart = event.start.coerceAtLeast(date);
    final todayEnd = _actualEnd(event, height).coerceAtMost(date + 1.days);
    return todayEnd.difference(todayStart);
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
  _SingleEventPosition(
    this.group,
    this.column,
    this.index, {
    this.columnSpan = 1,
  });

  final int group;
  final int column;
  final int columnSpan;
  final int index;

  _SingleEventPosition copyWith({int? columnSpan}) {
    return _SingleEventPosition(
      group,
      column,
      index,
      columnSpan: columnSpan ?? this.columnSpan,
    );
  }
}
