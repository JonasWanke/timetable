import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../event/builder.dart';
import '../event/event.dart';
import '../styling.dart';
import '../utils.dart';
import 'multi_date_content.dart';

class DateEvents<E extends Event> extends StatelessWidget {
  DateEvents({
    Key? key,
    required this.date,
    required List<E> events,
    this.eventBuilder,
    this.style,
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
  final EventBuilder<E>? eventBuilder;
  final DateEventsStyle? style;

  @override
  Widget build(BuildContext context) {
    final eventBuilder =
        this.eventBuilder ?? DefaultEventBuilder.of<E>(context)!;
    final style =
        this.style ?? TimetableTheme.orDefaultOf(context).dateEventsStyle;
    return Padding(
      padding: style.padding,
      child: CustomMultiChildLayout(
        delegate:
            _DayEventsLayoutDelegate(date: date, events: events, style: style),
        children: [
          for (final event in events)
            LayoutId(
              key: ValueKey(event),
              id: event,
              child: eventBuilder(context, event),
            ),
        ],
      ),
    );
  }
}

/// Defines visual properties for [MultiDateContent].
class DateEventsStyle {
  factory DateEventsStyle(
    // To allow future updates to use the context and align the parameters to
    // other style constructors.
    // ignore: avoid_unused_constructor_parameters
    BuildContext context, {
    Duration? minEventDuration,
    double? minEventHeight,
    EdgeInsetsGeometry? padding,
    bool? enableStacking,
    Duration? minEventDeltaForStacking,
    double? stackedEventSpacing,
  }) {
    return DateEventsStyle.raw(
      minEventDuration: minEventDuration ?? const Duration(minutes: 30),
      minEventHeight: minEventHeight ?? 16,
      padding: padding ?? const EdgeInsets.only(right: 1),
      enableStacking: enableStacking ?? true,
      minEventDeltaForStacking:
          minEventDeltaForStacking ?? const Duration(minutes: 15),
      stackedEventSpacing: stackedEventSpacing ?? 4,
    );
  }

  const DateEventsStyle.raw({
    required this.minEventDuration,
    required this.minEventHeight,
    required this.padding,
    required this.enableStacking,
    required this.minEventDeltaForStacking,
    required this.stackedEventSpacing,
  });

  /// Minimum [Duration] to size a part-day event.
  ///
  /// Can be used together with [minEventHeight].
  final Duration minEventDuration;

  /// Minimum height to size a part-day event.
  ///
  /// Can be used together with [minEventDuration].
  final double minEventHeight;

  final EdgeInsetsGeometry padding;

  /// Controls whether overlapping events may be stacked on top of each other.
  ///
  /// If set to `true`, intersecting events may be stacked if their start values
  /// differ by at least [minEventDeltaForStacking]. If set to
  /// `false`, intersecting events will always be shown next to each other and
  /// not overlap.
  final bool enableStacking;

  /// When the start values of two events differ by at least this value, they
  /// may be stacked on top of each other.
  ///
  /// If the difference is less, they will be shown next to each other.
  ///
  /// See also:
  /// - [enableStacking], which can disable the stacking behavior completely.
  final Duration minEventDeltaForStacking;

  /// Horizontal space between two parallel events stacked on top of each other.
  final double stackedEventSpacing;

  @override
  int get hashCode => hashValues(
        minEventDuration,
        minEventHeight,
        padding,
        enableStacking,
        minEventDeltaForStacking,
        stackedEventSpacing,
      );
  @override
  bool operator ==(Object other) {
    return other is DateEventsStyle &&
        other.minEventDuration == minEventDuration &&
        other.minEventHeight == minEventHeight &&
        other.padding == padding &&
        other.enableStacking == enableStacking &&
        other.minEventDeltaForStacking == minEventDeltaForStacking &&
        other.stackedEventSpacing == stackedEventSpacing;
  }
}

class _DayEventsLayoutDelegate<E extends Event>
    extends MultiChildLayoutDelegate {
  _DayEventsLayoutDelegate({
    required this.date,
    required this.events,
    required this.style,
  }) : assert(date.isValidTimetableDate);

  static const minWidth = 4.0;

  final DateTime date;
  final List<E> events;

  final DateEventsStyle style;

  @override
  void performLayout(Size size) {
    final positions = _calculatePositions(size.height);

    double durationToY(Duration duration) {
      assert(duration.isValidTimetableTimeOfDay);
      return size.height * (duration / 1.days);
    }

    double timeToY(DateTime dateTime) {
      assert(dateTime.isValidTimetableDateTime);

      if (dateTime < date) return 0;
      if (dateTime.atStartOfDay > date) return size.height;
      return durationToY(dateTime.timeOfDay);
    }

    for (final event in events) {
      final top = timeToY(event.start)
          .coerceAtMost(size.height - durationToY(style.minEventDuration))
          .coerceAtMost(size.height - style.minEventHeight);
      final height = durationToY(_durationOn(event, size.height))
          .clamp(0, size.height - top)
          .toDouble();

      final position = positions.eventPositions[event]!;
      final columnWidth =
          size.width / positions.groupColumnCounts[position.group];
      final columnLeft = columnWidth * position.column;
      final left = columnLeft + position.index * style.stackedEventSpacing;
      final width = columnWidth * position.columnSpan -
          position.index * style.stackedEventSpacing;

      final childSize = Size(width.coerceAtLeast(minWidth), height);
      layoutChild(event, BoxConstraints.tight(childSize));
      positionChild(event, Offset(left, top));
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
    _EventPositions positions,
    List<E> currentGroup,
    double height,
  ) {
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
        if (!style.enableStacking && event.start < _actualEnd(other, height) ||
            style.enableStacking &&
                event.start < other.start + style.minEventDeltaForStacking) {
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
    final minDurationForHeight = (style.minEventHeight / height).days;
    return event.end
        .coerceAtLeast(event.start + style.minEventDuration)
        .coerceAtLeast(event.start + minDurationForHeight);
  }

  Duration _durationOn(E event, double height) {
    final start = event.start.coerceAtLeast(date);
    final end = _actualEnd(event, height).coerceAtMost(date + 1.days);
    return end.difference(start);
  }

  @override
  bool shouldRelayout(_DayEventsLayoutDelegate<E> oldDelegate) {
    return date != oldDelegate.date ||
        style != oldDelegate.style ||
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
