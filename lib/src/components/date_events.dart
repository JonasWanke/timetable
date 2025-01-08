import 'package:chrono/chrono.dart';
import 'package:flutter/widgets.dart';

import '../config.dart';
import '../event/builder.dart';
import '../event/event.dart';
import '../theme.dart';
import '../utils.dart';

/// A widget that displays the given [Event]s.
///
/// If [eventBuilder] is not provided, a [DefaultEventBuilder] must be above in
/// the widget tree.
///
/// See also:
///
/// * [DateEventsStyle], which defines visual properties for this widget.
/// * [TimetableTheme] (and [TimetableConfig]), which provide styles to
///   descendant Timetable widgets.
class DateEvents<E extends Event> extends StatelessWidget {
  DateEvents({
    super.key,
    required this.date,
    required List<E> events,
    this.eventBuilder,
    this.style,
  })  : assert(
          events.every((e) => e.range.intersects(date.dateTimes)),
          'All events must intersect the given date',
        ),
        events = events.sortedByStartLength();

  final Date date;
  final List<E> events;
  final EventBuilder<E>? eventBuilder;
  final DateEventsStyle? style;

  @override
  Widget build(BuildContext context) {
    final eventBuilder =
        this.eventBuilder ?? DefaultEventBuilder.of<E>(context)!;
    final style = this.style ??
        TimetableTheme.orDefaultOf(context).dateEventsStyleProvider(date);
    return Padding(
      padding: style.padding,
      child: CustomMultiChildLayout(
        delegate: _DayEventsLayoutDelegate(date, events, style),
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

/// Defines visual properties for [DateEvents].
///
/// See also:
///
/// * [TimetableThemeData], which bundles the styles for all Timetable widgets.
@immutable
class DateEventsStyle {
  factory DateEventsStyle(
    // To allow future updates to use the context and align the parameters to
    // other style constructors.
    // ignore: avoid_unused_constructor_parameters
    BuildContext context,
    // ignore: avoid_unused_constructor_parameters, See above.
    Date date, {
    TimeDuration? minEventDuration,
    double? minEventHeight,
    EdgeInsetsGeometry? padding,
    bool? enableStacking,
    TimeDuration? minEventDeltaForStacking,
    double? stackedEventSpacing,
  }) {
    return DateEventsStyle.raw(
      minEventDuration: minEventDuration ?? const Minutes(30),
      minEventHeight: minEventHeight ?? 16,
      padding: padding ?? const EdgeInsets.only(right: 1),
      enableStacking: enableStacking ?? true,
      minEventDeltaForStacking: minEventDeltaForStacking ?? const Minutes(15),
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

  /// Minimum duration to size a part-day event.
  ///
  /// Can be used together with [minEventHeight].
  final TimeDuration minEventDuration;

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
  ///
  /// * [enableStacking], which can disable the stacking behavior completely.
  final TimeDuration minEventDeltaForStacking;

  /// Horizontal space between two parallel events stacked on top of each other.
  final double stackedEventSpacing;

  DateEventsStyle copyWith({
    TimeDuration? minEventDuration,
    double? minEventHeight,
    EdgeInsetsGeometry? padding,
    bool? enableStacking,
    TimeDuration? minEventDeltaForStacking,
    double? stackedEventSpacing,
  }) {
    return DateEventsStyle.raw(
      minEventDuration: minEventDuration ?? this.minEventDuration,
      minEventHeight: minEventHeight ?? this.minEventHeight,
      padding: padding ?? this.padding,
      enableStacking: enableStacking ?? this.enableStacking,
      minEventDeltaForStacking:
          minEventDeltaForStacking ?? this.minEventDeltaForStacking,
      stackedEventSpacing: stackedEventSpacing ?? this.stackedEventSpacing,
    );
  }

  @override
  int get hashCode {
    return Object.hash(
      minEventDuration,
      minEventHeight,
      padding,
      enableStacking,
      minEventDeltaForStacking,
      stackedEventSpacing,
    );
  }

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
  _DayEventsLayoutDelegate(this.date, this.events, this.style);

  static const minWidth = 4.0;

  final Date date;
  final List<E> events;

  final DateEventsStyle style;

  @override
  void performLayout(Size size) {
    assert(size.height > 0);

    final positions = _calculatePositions(size.height);

    double durationToY(TimeDuration duration) {
      assert(duration.isNonNegative && duration <= Hours.normalDay);
      return duration.dayFraction * size.height;
    }

    double dateTimeToY(CDateTime dateTime) {
      if (dateTime.date < date) return 0;
      if (dateTime.date > date) return size.height;
      return durationToY(dateTime.time.nanosecondsSinceMidnight);
    }

    for (final event in events) {
      final top = dateTimeToY(event.range.start)
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
    CDateTime? currentEnd;
    for (final event in events) {
      if (currentEnd != null && event.range.start >= currentEnd) {
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
    if (currentGroup.isEmpty) return;
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
      CDateTime? minEnd;
      var columnFound = false;
      for (var columnIndex = 0; columnIndex < columns.length; columnIndex++) {
        final column = columns[columnIndex];
        final other = column.last;

        // No space in current column
        if (!style.enableStacking &&
                event.range.start < _actualEnd(other, height) ||
            style.enableStacking &&
                event.range.start <
                    other.range.start + style.minEventDeltaForStacking) {
          continue;
        }

        final index = column
                .where((e) => _actualEnd(e, height) >= event.range.start)
                .map((e) => positions.eventPositions[e]!.index)
                .maxOrNull ??
            -1;

        final previousEnd = column
            .map((it) => it.range.end)
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
          positions.groupColumnCounts.length,
          columns.length,
          0,
        );
        columns.add([event]);
        continue;
      }

      positions.eventPositions[event] = _SingleEventPosition(
        positions.groupColumnCounts.length,
        minColumn,
        minIndex + 1,
      );
      columns[minColumn].add(event);
    }

    // Expand events to multiple columns if possible.
    for (final event in currentGroup) {
      final position = positions.eventPositions[event]!;
      if (position.column == columns.length - 1) continue;

      var columnSpan = 1;
      for (var i = position.column + 1; i < columns.length; i++) {
        final hasOverlapInColumn = currentGroup
            .where((e) => positions.eventPositions[e]!.column == i)
            .where(
              (e) =>
                  event.range.start < _actualEnd(e, height) &&
                  e.range.start < _actualEnd(event, height),
            )
            .isNotEmpty;
        if (hasOverlapInColumn) break;

        columnSpan++;
      }
      positions.eventPositions[event] =
          position.copyWith(columnSpan: columnSpan);
    }

    positions.groupColumnCounts.add(columns.length);
  }

  CDateTime _actualEnd(E event, double height) {
    final minDurationForHeight =
        Nanoseconds.normalDay.timesDouble(style.minEventHeight / height);
    return event.range.end
        .coerceAtLeast(event.range.start + style.minEventDuration)
        .coerceAtLeast(event.range.start + minDurationForHeight);
  }

  TimeDuration _durationOn(E event, double height) {
    final start = event.range.start.coerceAtLeast(date.atMidnight);
    final end = _actualEnd(event, height).coerceAtMost(date.next.atMidnight);
    return end.timeDifference(start);
  }

  @override
  bool shouldRelayout(_DayEventsLayoutDelegate<E> oldDelegate) {
    return date != oldDelegate.date ||
        style != oldDelegate.style ||
        !const DeepCollectionEquality().equals(events, oldDelegate.events);
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
