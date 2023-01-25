import 'dart:ui';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/rendering.dart';

import '../callbacks.dart';
import '../config.dart';
import '../date/controller.dart';
import '../date/date_page_view.dart';
import '../event/all_day.dart';
import '../event/builder.dart';
import '../event/event.dart';
import '../event/provider.dart';
import '../layouts/multi_date.dart';
import '../theme.dart';
import '../utils.dart';

/// A widget that displays all-day [Event]s.
///
/// A [DefaultDateController] and a [DefaultEventBuilder] must be above in the
/// widget tree.
///
/// If [onBackgroundTap] is not supplied, [DefaultTimetableCallbacks]'s
/// `onDateBackgroundTap` is used if it's provided above in the widget tree.
///
/// See also:
///
/// * [DefaultEventProvider] (and [TimetableConfig]), which provide the [Event]s
///   to be displayed.
/// * [MultiDateEventHeaderStyle], which defines visual properties for this
///   widget.
/// * [TimetableTheme] (and [TimetableConfig]), which provide styles to
///   descendant Timetable widgets.
/// * [DefaultTimetableCallbacks], which provides callbacks to descendant
///   Timetable widgets.
class MultiDateEventHeader<E extends Event> extends StatelessWidget {
  const MultiDateEventHeader({
    super.key,
    this.onBackgroundTap,
    this.style,
  });

  final DateTapCallback? onBackgroundTap;
  final MultiDateEventHeaderStyle? style;

  @override
  Widget build(BuildContext context) {
    final style = this.style ??
        TimetableTheme.orDefaultOf(context).multiDateEventHeaderStyle;

    final child = LayoutBuilder(builder: (context, constraints) {
      var maxEventRows = style.maxEventRows;
      if (constraints.maxHeight.isFinite) {
        final maxRowsFromHeight =
            (constraints.maxHeight / style.eventHeight).floor();
        final maxEventRowsFromHeight = (maxRowsFromHeight - 1).coerceAtLeast(0);
        maxEventRows = maxEventRowsFromHeight.coerceAtMost(maxEventRows);
      }

      return ValueListenableBuilder<DatePageValue>(
        valueListenable: DefaultDateController.of(context)!,
        builder: (context, pageValue, __) => _buildContent(
          context,
          pageValue,
          width: constraints.maxWidth,
          eventHeight: style.eventHeight,
          maxEventRows: maxEventRows,
        ),
      );
    });

    return Stack(children: [
      Positioned.fill(
        child: DatePageView(builder: (context, date) => const SizedBox()),
      ),
      ClipRect(child: Padding(padding: style.padding, child: child)),
    ]);
  }

  Widget _buildContent(
    BuildContext context,
    DatePageValue pageValue, {
    required double width,
    required double eventHeight,
    required int maxEventRows,
  }) {
    final onBackgroundTap = this.onBackgroundTap ??
        DefaultTimetableCallbacks.of(context)?.onDateBackgroundTap;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapUp: onBackgroundTap != null
          ? (details) {
              final tappedCell =
                  details.localPosition.dx / width * pageValue.visibleDayCount;
              final page = (pageValue.page + tappedCell).floor();
              onBackgroundTap(DateTimeTimetable.dateFromPage(page));
            }
          : null,
      child: _MultiDateEventHeaderEvents<E>(
        pageValue: pageValue,
        events:
            DefaultEventProvider.of<E>(context)?.call(pageValue.visibleDates) ??
                [],
        eventHeight: eventHeight,
        maxEventRows: maxEventRows,
      ),
    );
  }
}

/// Defines visual properties for [MultiDateEventHeader].
class MultiDateEventHeaderStyle {
  factory MultiDateEventHeaderStyle(
    // To allow future updates to use the context and align the parameters to
    // other style constructors.
    // ignore: avoid_unused_constructor_parameters
    BuildContext context, {
    double? eventHeight,
    int? maxEventRows,
    EdgeInsetsGeometry? padding,
  }) {
    return MultiDateEventHeaderStyle.raw(
      eventHeight: eventHeight ?? 24,
      maxEventRows: maxEventRows ?? 3,
      padding: padding ?? EdgeInsets.zero,
    );
  }

  const MultiDateEventHeaderStyle.raw({
    this.eventHeight = 24,
    this.maxEventRows = 3,
    this.padding = EdgeInsets.zero,
  });

  /// Height of a single all-day event.
  final double eventHeight;

  /// The maximum number of rows with events to display one above the other.
  ///
  /// If there are more events than this, [DefaultEventBuilder.allDayOverflowOf]
  /// will be called to display information about the overflowed events. This
  /// adds one more row.
  ///
  /// If there's not enough space to display this many rows (plus one for the
  /// overflows), [MultiDateEventHeader] will automatically reduce the number of
  /// rows to fit the available height.
  ///
  /// See also:
  ///
  /// * [MultiDateTimetableStyle.maxHeaderFraction], which additionally
  ///   constrains the header to only occupy up to that fraction of the
  ///   available height, ensuring that the content still has space on short
  ///   screens with many parallel header events.
  final int maxEventRows;

  final EdgeInsetsGeometry padding;

  MultiDateEventHeaderStyle copyWith({
    double? eventHeight,
    int? maxEventRows,
    EdgeInsetsGeometry? padding,
  }) {
    return MultiDateEventHeaderStyle.raw(
      eventHeight: eventHeight ?? this.eventHeight,
      maxEventRows: maxEventRows ?? this.maxEventRows,
      padding: padding ?? this.padding,
    );
  }

  @override
  int get hashCode => Object.hash(eventHeight, maxEventRows, padding);
  @override
  bool operator ==(Object other) {
    return other is MultiDateEventHeaderStyle &&
        eventHeight == other.eventHeight &&
        maxEventRows == other.maxEventRows &&
        padding == other.padding;
  }
}

class _MultiDateEventHeaderEvents<E extends Event> extends StatefulWidget {
  const _MultiDateEventHeaderEvents({
    required this.pageValue,
    required this.events,
    required this.eventHeight,
    required this.maxEventRows,
  });

  final DatePageValue pageValue;
  final List<E> events;
  final double eventHeight;
  final int maxEventRows;

  @override
  State<_MultiDateEventHeaderEvents<E>> createState() =>
      _MultiDateEventHeaderEventsState<E>();
}

class _MultiDateEventHeaderEventsState<E extends Event>
    extends State<_MultiDateEventHeaderEvents<E>> {
  final _yPositions = <E, int?>{};
  final _maxEventPositions = <int, int>{};

  @override
  void initState() {
    _updateEventPositions(oldMaxEventRows: null);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _MultiDateEventHeaderEvents<E> oldWidget) {
    if (oldWidget.pageValue != widget.pageValue ||
        oldWidget.eventHeight != widget.eventHeight ||
        oldWidget.maxEventRows != widget.maxEventRows ||
        !const DeepCollectionEquality()
            .equals(oldWidget.events, widget.events)) {
      _updateEventPositions(oldMaxEventRows: oldWidget.maxEventRows);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _updateEventPositions({required int? oldMaxEventRows}) {
    // Remove events outside the current viewport (with some buffer).
    _yPositions.removeWhere((event, yPosition) {
      return event.start.page.floor() > widget.pageValue.lastVisiblePage ||
          event.end.page.ceil() <= widget.pageValue.firstVisibleDate.page;
    });
    _maxEventPositions.removeWhere((date, _) {
      return date < widget.pageValue.firstVisiblePage ||
          date > widget.pageValue.lastVisiblePage;
    });

    // Remove old events.
    _yPositions.removeWhere((it, _) => !widget.events.contains(it));

    if (oldMaxEventRows != null && oldMaxEventRows > widget.maxEventRows) {
      // Remove events that no longer fit the decreased `maxEventRows`.
      for (final entry in _yPositions.entries) {
        if (entry.value == null || entry.value! < widget.maxEventRows) continue;

        _yPositions[entry.key] = null;
      }
    }

    // Insert new events and, in case [maxEventRows] increased, display
    // previously overflowed events.
    final sortedEvents = widget.events
        .where((it) => _yPositions[it] == null)
        .sortedByStartLength();

    Iterable<E> eventsWithPosition(int y) =>
        _yPositions.entries.where((it) => it.value == y).map((it) => it.key);

    outer:
    for (final event in sortedEvents) {
      var y = 0;
      final interval = event.interval.dateInterval;
      while (y < widget.maxEventRows) {
        final intersectingEvents = eventsWithPosition(y);
        if (intersectingEvents
            .every((it) => !it.interval.dateInterval.intersects(interval))) {
          _yPositions[event] = y;
          continue outer;
        }

        y++;
      }
      _yPositions[event] = null;
    }

    for (final date in widget.pageValue.visibleDatesIterable) {
      final dayInterval = date.fullDayInterval;
      final maxEventPosition = _yPositions.entries
          .where((it) => it.key.interval.intersects(dayInterval))
          .map((it) => it.value ?? widget.maxEventRows)
          .maxOrNull;
      _maxEventPositions[date.datePage] =
          maxEventPosition != null ? maxEventPosition + 1 : 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allDayBuilder = DefaultEventBuilder.allDayOf<E>(context)!;
    final allDayOverflowBuilder =
        DefaultEventBuilder.allDayOverflowOf<E>(context)!;
    return _EventsWidget(
      pageValue: widget.pageValue,
      eventHeight: widget.eventHeight,
      maxEventRows: Map.from(_maxEventPositions),
      children: [
        for (final event in widget.events)
          if (_yPositions[event] != null)
            _EventParentDataWidget(
              key: ValueKey(event),
              dateInterval: event.interval.dateInterval,
              yPosition: _yPositions[event]!,
              child: _buildEvent(allDayBuilder, event),
            ),
        ...widget.pageValue.visibleDatesIterable.mapNotNull((date) {
          final maxPosition = _maxEventPositions[date.datePage]!;
          if (maxPosition <= widget.maxEventRows) return null;

          final dateInterval = date.fullDayInterval;
          final overflowedEvents = widget.events.where((it) {
            return it.interval.dateInterval.intersects(dateInterval) &&
                _yPositions[it] == null;
          }).toList();
          return _EventParentDataWidget(
            key: ValueKey(date),
            dateInterval: dateInterval,
            yPosition: widget.maxEventRows,
            child: allDayOverflowBuilder(context, date, overflowedEvents),
          );
        }),
      ],
    );
  }

  Widget _buildEvent(AllDayEventBuilder<E> allDayBuilder, E event) {
    return allDayBuilder(
      context,
      event,
      AllDayEventLayoutInfo(
        hiddenStartDays:
            (widget.pageValue.page - event.start.page).coerceAtLeast(0),
        hiddenEndDays: (event.end.page.ceil() -
                widget.pageValue.page -
                widget.pageValue.visibleDayCount)
            .coerceAtLeast(0),
      ),
    );
  }
}

class _EventParentDataWidget extends ParentDataWidget<_EventParentData> {
  _EventParentDataWidget({
    super.key,
    required this.dateInterval,
    required this.yPosition,
    required super.child,
  }) : assert(dateInterval.debugCheckIsValidTimetableDateInterval());

  final Interval dateInterval;
  final int yPosition;

  @override
  Type get debugTypicalAncestorWidgetClass => _EventsWidget;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is _EventParentData);
    final parentData = renderObject.parentData! as _EventParentData;

    if (parentData.dateInterval == dateInterval &&
        parentData.yPosition == yPosition) {
      return;
    }

    parentData.dateInterval = dateInterval;
    parentData.yPosition = yPosition;
    final targetParent = renderObject.parent;
    if (targetParent is RenderObject) targetParent.markNeedsLayout();
  }
}

class _EventsWidget extends MultiChildRenderObjectWidget {
  _EventsWidget({
    required this.pageValue,
    required this.eventHeight,
    required this.maxEventRows,
    required super.children,
  });

  final DatePageValue pageValue;
  final double eventHeight;
  final Map<int, int> maxEventRows;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _EventsLayout(
      pageValue: pageValue,
      eventHeight: eventHeight,
      maxEventRows: maxEventRows,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _EventsLayout renderObject) {
    renderObject
      ..pageValue = pageValue
      ..eventHeight = eventHeight
      ..maxEventRows = maxEventRows;
  }
}

class _EventParentData extends ContainerBoxParentData<RenderBox> {
  Interval? dateInterval;
  int? yPosition;
}

class _EventsLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _EventParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _EventParentData> {
  _EventsLayout({
    required DatePageValue pageValue,
    required double eventHeight,
    required Map<int, int> maxEventRows,
  })  : _pageValue = pageValue,
        _eventHeight = eventHeight,
        _maxEventPositions = maxEventRows;

  DatePageValue _pageValue;
  DatePageValue get pageValue => _pageValue;
  set pageValue(DatePageValue value) {
    if (_pageValue == value) return;

    _pageValue = value;
    markNeedsLayout();
  }

  double _eventHeight;
  double get eventHeight => _eventHeight;
  set eventHeight(double value) {
    if (_eventHeight == value) return;

    _eventHeight = value;
    markNeedsLayout();
  }

  Map<int, int> _maxEventPositions;
  Map<int, int> get maxEventRows => _maxEventPositions;
  set maxEventRows(Map<int, int> value) {
    if (_maxEventPositions == value) return;

    _maxEventPositions = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _EventParentData) {
      child.parentData = _EventParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    assert(_debugThrowIfNotCheckingIntrinsics());
    return 0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    assert(_debugThrowIfNotCheckingIntrinsics());
    return 0;
  }

  bool _debugThrowIfNotCheckingIntrinsics() {
    assert(() {
      if (!RenderObject.debugCheckingIntrinsics) {
        throw Exception("$runtimeType doesn't have an intrinsic width.");
      }
      return true;
    }());
    return true;
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      _parallelEventCount() * eventHeight;
  @override
  double computeMaxIntrinsicHeight(double width) =>
      _parallelEventCount() * eventHeight;

  @override
  void performLayout() {
    assert(!sizedByParent);

    if (children.isEmpty) {
      size = Size(constraints.maxWidth, 0);
      return;
    }

    size = Size(constraints.maxWidth, _parallelEventCount() * eventHeight);
    _positionEvents();
  }

  void _positionEvents() {
    final dateWidth = size.width / pageValue.visibleDayCount;
    for (final child in children) {
      final data = child.data;
      final dateInterval = data.dateInterval!;
      final startPage = dateInterval.start.page;
      final left = ((startPage - pageValue.page) * dateWidth).coerceAtLeast(0);
      final endPage = dateInterval.end.page.ceilToDouble();
      final right =
          ((endPage - pageValue.page) * dateWidth).coerceAtMost(size.width);

      child.layout(
        BoxConstraints(
          minWidth: right - left,
          maxWidth: (right - left).coerceAtLeast(dateWidth),
          minHeight: eventHeight,
          maxHeight: eventHeight,
        ),
        parentUsesSize: true,
      );
      final actualLeft = startPage >= pageValue.page
          ? left
          : left.coerceAtMost(right - child.size.width);
      data.offset = Offset(actualLeft, data.yPosition! * eventHeight);
    }
  }

  double _parallelEventCount() {
    int parallelEventsFrom(int page) {
      return page
          .rangeTo(page + pageValue.visibleDayCount - 1)
          .map((it) => _maxEventPositions[it]!)
          .max;
    }

    final oldParallelEvents = parallelEventsFrom(pageValue.page.floor());
    final newParallelEvents = parallelEventsFrom(pageValue.page.ceil());
    final t = pageValue.page - pageValue.page.floorToDouble();
    return lerpDouble(oldParallelEvents, newParallelEvents, t)!;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
}

extension _ParentData on RenderBox {
  _EventParentData get data => parentData! as _EventParentData;
}
