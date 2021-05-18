import 'dart:ui';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/rendering.dart';

import '../callbacks.dart';
import '../date/controller.dart';
import '../date/visible_date_range.dart';
import '../event/all_day.dart';
import '../event/builder.dart';
import '../event/event.dart';
import '../event/provider.dart';
import '../theme.dart';
import '../utils.dart';

class MultiDateEventHeader<E extends Event> extends StatelessWidget {
  const MultiDateEventHeader({
    Key? key,
    this.onBackgroundTap,
    this.style,
  }) : super(key: key);

  final DateTapCallback? onBackgroundTap;
  final MultiDateEventHeaderStyle? style;

  @override
  Widget build(BuildContext context) {
    final style = this.style ??
        TimetableTheme.orDefaultOf(context).multiDateEventHeaderStyle;

    return ClipRect(
      child: Padding(
        padding: style.padding,
        child: LayoutBuilder(
          builder: (context, constraints) =>
              ValueListenableBuilder<DatePageValue>(
            valueListenable: DefaultDateController.of(context)!,
            builder: (context, pageValue, __) =>
                _buildContent(context, style, pageValue, constraints.maxWidth),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MultiDateEventHeaderStyle style,
    DatePageValue pageValue,
    double width,
  ) {
    final visibleDates = Interval(
      DateTimeTimetable.dateFromPage(pageValue.page.floor()),
      DateTimeTimetable.dateFromPage(
            (pageValue.page + pageValue.visibleDayCount).ceil(),
          ) -
          1.milliseconds,
    );
    assert(visibleDates.isValidTimetableDateInterval);

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
      child: _buildEventLayout(context, style, visibleDates, pageValue),
    );
  }

  Widget _buildEventLayout(
    BuildContext context,
    MultiDateEventHeaderStyle style,
    Interval visibleDates,
    DatePageValue pageValue,
  ) {
    assert(visibleDates.isValidTimetableDateInterval);

    return _EventsWidget<E>(
      visibleRange: pageValue.visibleRange,
      currentlyVisibleDates: visibleDates,
      page: pageValue.page,
      eventHeight: style.eventHeight,
      children: [
        for (final event in DefaultEventProvider.of<E>(context)!(visibleDates))
          _EventParentDataWidget<E>(
            key: ValueKey(event),
            event: event,
            child: _buildEvent(context, event, pageValue),
          ),
      ],
    );
  }

  Widget _buildEvent(BuildContext context, E event, DatePageValue pageValue) {
    return DefaultEventBuilder.allDayOf<E>(context)!(
      context,
      event,
      AllDayEventLayoutInfo(
        hiddenStartDays: (pageValue.page - event.start.page).coerceAtLeast(0),
        hiddenEndDays:
            (event.end.page.ceil() - pageValue.page - pageValue.visibleDayCount)
                .coerceAtLeast(0),
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
    EdgeInsetsGeometry? padding,
  }) {
    return MultiDateEventHeaderStyle.raw(
      eventHeight: eventHeight ?? 24,
      padding: padding ?? EdgeInsets.zero,
    );
  }

  const MultiDateEventHeaderStyle.raw({
    this.eventHeight = 24,
    this.padding = EdgeInsets.zero,
  });

  /// Height of a single all-day event.
  final double eventHeight;

  final EdgeInsetsGeometry padding;

  MultiDateEventHeaderStyle copyWith({
    double? eventHeight,
    EdgeInsetsGeometry? padding,
  }) {
    return MultiDateEventHeaderStyle.raw(
      eventHeight: eventHeight ?? this.eventHeight,
      padding: padding ?? this.padding,
    );
  }

  @override
  int get hashCode => hashValues(eventHeight, padding);
  @override
  bool operator ==(Object other) {
    return other is MultiDateEventHeaderStyle &&
        eventHeight == other.eventHeight &&
        padding == other.padding;
  }
}

class _EventParentDataWidget<E extends Event>
    extends ParentDataWidget<_EventParentData<E>> {
  const _EventParentDataWidget({
    Key? key,
    required this.event,
    required Widget child,
  }) : super(key: key, child: child);

  final E event;

  @override
  Type get debugTypicalAncestorWidgetClass => _EventsWidget;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is _EventParentData<E>);
    final parentData = renderObject.parentData! as _EventParentData<E>;

    if (parentData.event == event) return;

    parentData.event = event;
    final targetParent = renderObject.parent;
    if (targetParent is RenderObject) targetParent.markNeedsLayout();
  }
}

class _EventsWidget<E extends Event> extends MultiChildRenderObjectWidget {
  _EventsWidget({
    required this.visibleRange,
    required this.currentlyVisibleDates,
    required this.page,
    required this.eventHeight,
    required List<_EventParentDataWidget<E>> children,
  }) : super(children: children);

  final VisibleDateRange visibleRange;
  final Interval currentlyVisibleDates;
  final double page;
  final double eventHeight;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _EventsLayout<E>(
      visibleRange: visibleRange,
      currentlyVisibleDates: currentlyVisibleDates,
      page: page,
      eventHeight: eventHeight,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _EventsLayout<E> renderObject) {
    renderObject
      ..visibleRange = visibleRange
      ..currentlyVisibleDates = currentlyVisibleDates
      ..page = page
      ..eventHeight = eventHeight;
  }
}

class _EventParentData<E extends Event>
    extends ContainerBoxParentData<RenderBox> {
  E? event;
}

class _EventsLayout<E extends Event> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _EventParentData<E>>,
        RenderBoxContainerDefaultsMixin<RenderBox, _EventParentData<E>> {
  _EventsLayout({
    required VisibleDateRange visibleRange,
    required Interval currentlyVisibleDates,
    required double page,
    required double eventHeight,
  })   : _visibleRange = visibleRange,
        assert(currentlyVisibleDates.isValidTimetableDateInterval),
        _currentlyVisibleDates = currentlyVisibleDates,
        _page = page,
        _eventHeight = eventHeight;

  VisibleDateRange _visibleRange;
  VisibleDateRange get visibleRange => _visibleRange;
  set visibleRange(VisibleDateRange value) {
    if (_visibleRange == value) return;

    _visibleRange = value;
    markNeedsLayout();
  }

  Interval _currentlyVisibleDates;
  Interval get currentlyVisibleDates => _currentlyVisibleDates;
  set currentlyVisibleDates(Interval value) {
    assert(value.isValidTimetableDateInterval);
    if (_currentlyVisibleDates == value) return;

    _currentlyVisibleDates = value;
    markNeedsLayout();
  }

  double _page;
  double get page => _page;
  set page(double value) {
    if (_page == value) return;

    _page = value;
    markNeedsLayout();
  }

  double _eventHeight;
  double get eventHeight => _eventHeight;
  set eventHeight(double value) {
    if (_eventHeight == value) return;

    _eventHeight = value;
    markNeedsLayout();
  }

  Iterable<E> get _events => children.map((child) => child.data<E>().event!);

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _EventParentData<E>) {
      child.parentData = _EventParentData<E>();
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
        throw Exception("_EventsLayout doesn't have an intrinsic width.");
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

  final _yPositions = <E, int>{};

  @override
  void performLayout() {
    assert(!sizedByParent);

    if (children.isEmpty) {
      size = Size(constraints.maxWidth, 0);
      return;
    }

    _updateEventPositions();
    _setSize();
    _positionEvents();
  }

  void _updateEventPositions() {
    // Remove old events.
    _yPositions.removeWhere((e, _) {
      return e.start.page.floor() >= currentlyVisibleDates.end.page.ceil() ||
          e.end.page.ceil() <= currentlyVisibleDates.start.page;
    });

    // Insert new events.
    final sortedEvents = _events
        .where((it) => !_yPositions.containsKey(it))
        .sortedByStartLength();

    Iterable<E> eventsWithPosition(int y) {
      return _yPositions.entries.where((e) => e.value == y).map((e) => e.key);
    }

    outer:
    for (final event in sortedEvents) {
      var y = 0;
      final interval = event.interval.dateInterval;
      while (true) {
        final intersectingEvents = eventsWithPosition(y);
        if (intersectingEvents
            .every((e) => !e.interval.dateInterval.intersects(interval))) {
          _yPositions[event] = y;
          continue outer;
        }

        y++;
      }
    }
  }

  void _setSize() {
    size = Size(constraints.maxWidth, _parallelEventCount() * eventHeight);
  }

  void _positionEvents() {
    final dateWidth = size.width / visibleRange.visibleDayCount;
    for (final child in children) {
      final data = child.data<E>();
      final event = data.event!;

      final dateInterval = event.interval.dateInterval;
      final startPage = dateInterval.start.page;
      final left = ((startPage - page) * dateWidth).coerceAtLeast(0);
      final endPage = dateInterval.end.page.ceilToDouble();
      final right = ((endPage - page) * dateWidth).coerceAtMost(size.width);

      child.layout(
        BoxConstraints.tightFor(width: right - left, height: eventHeight),
      );
      data.offset = Offset(left, _yPositions[event]! * eventHeight);
    }
  }

  double _parallelEventCount() {
    int parallelEventsFrom(int page) {
      final startDate = DateTimeTimetable.dateFromPage(page);
      final interval = Interval(
        startDate,
        (startDate + (visibleRange.visibleDayCount - 1).days).atEndOfDay,
      );
      assert(interval.isValidTimetableDateInterval);

      final maxEventPosition = _yPositions.entries
          .where((e) => e.key.interval.intersects(interval))
          .map((e) => e.value)
          .max();
      return maxEventPosition != null ? maxEventPosition + 1 : 0;
    }

    _updateEventPositions();
    final oldParallelEvents = parallelEventsFrom(page.floor());
    final newParallelEvents = parallelEventsFrom(page.ceil());
    final t = page - page.floorToDouble();
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
  _EventParentData<E> data<E extends Event>() =>
      parentData! as _EventParentData<E>;
}
