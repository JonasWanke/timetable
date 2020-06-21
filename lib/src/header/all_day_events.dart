import 'dart:math' as math;
import 'dart:ui';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:time_machine/time_machine.dart' hide Offset;

import '../all_day.dart';
import '../controller.dart';
import '../event.dart';
import '../theme.dart';
import '../timetable.dart';
import '../visible_range.dart';

class AllDayEvents<E extends Event> extends StatelessWidget {
  const AllDayEvents({
    Key key,
    @required this.controller,
    @required this.allDayEventBuilder,
    this.onCreateAllDayEvent,
  })  : assert(controller != null),
        assert(allDayEventBuilder != null),
        super(key: key);

  final TimetableController<E> controller;
  final AllDayEventBuilder<E> allDayEventBuilder;
  final OnCreateEventCallback onCreateAllDayEvent;

  @override
  Widget build(BuildContext context) {
    return ClipRect(child: LayoutBuilder(builder: (context, constraints) {
      return ValueListenableBuilder<DateInterval>(
        valueListenable: controller.currentlyVisibleDatesListenable,
        builder: (_, visibleDates, __) {
          return StreamBuilder<Iterable<E>>(
            stream: controller.eventProvider
                .getAllDayEventsIntersecting(visibleDates),
            builder: (_, snapshot) {
              var events = snapshot.data ?? [];
              // The StreamBuilder gets recycled and initially still has a list of
              // old events.
              events = events.where((e) => e.intersectsInterval(visibleDates));

              return ValueListenableBuilder(
                  valueListenable: controller.scrollControllers.pageListenable,
                  builder: (context, page, __) => GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapUp: (details) {
                          final tappedCell = details.localPosition.dx / (constraints.widthConstraints().maxWidth / controller.visibleRange.visibleDays);
                          final date = LocalDate.fromEpochDay(page.floor() + tappedCell.toInt());
                          final dateAndTime = DateTime(date.year, date.monthOfYear, date.dayOfYear + 2);
                          final startTime = LocalDateTime.dateTime(dateAndTime);
                          if (onCreateAllDayEvent != null) {
                            onCreateAllDayEvent(startTime, true);
                          }
                        },
                        child: _buildEventLayout(context, events, page),
                      ));
            },
          );
        },
      );
    }));
  }

  Widget _buildEventLayout(
    BuildContext context,
    Iterable<E> events,
    double page,
  ) {
    return _EventsWidget<E>(
      visibleRange: controller.visibleRange,
      currentlyVisibleDates: controller.currentlyVisibleDates,
      page: page,
      children: [
        for (final event in events)
          _EventParentDataWidget<E>(
            key: ValueKey(event.id),
            event: event,
            child: _buildEvent(context, event, page),
          ),
      ],
    );
  }

  Widget _buildEvent(BuildContext context, E event, double page) {
    final visibleDays = controller.visibleRange.visibleDays;
    final eventStartPage = event.start.calendarDate.epochDay;
    final eventEndPage = (event.endDateInclusive + Period(days: 1)).epochDay;
    final hiddenStartDays = (page - eventStartPage).coerceAtLeast(0);
    return allDayEventBuilder(
      context,
      event,
      AllDayEventLayoutInfo(
        hiddenStartDays: hiddenStartDays,
        hiddenEndDays: (eventEndPage - page - visibleDays).coerceAtLeast(0),
      ),
    );
  }
}

class _EventParentDataWidget<E extends Event>
    extends ParentDataWidget<_EventParentData<E>> {
  const _EventParentDataWidget({
    Key key,
    @required this.event,
    @required Widget child,
  }) : super(key: key, child: child);

  final E event;

  @override
  Type get debugTypicalAncestorWidgetClass => _EventsWidget;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is _EventParentData<E>);
    final _EventParentData<E> parentData = renderObject.parentData;

    if (parentData.event == event) {
      return;
    }

    parentData.event = event;
    final targetParent = renderObject.parent;
    if (targetParent is RenderObject) {
      targetParent.markNeedsLayout();
    }
  }
}

class _EventsWidget<E extends Event> extends MultiChildRenderObjectWidget {
  _EventsWidget({
    @required this.visibleRange,
    @required this.currentlyVisibleDates,
    @required this.page,
    @required List<_EventParentDataWidget<E>> children,
  })  : assert(visibleRange != null),
        assert(currentlyVisibleDates != null),
        assert(page != null),
        assert(children != null),
        super(children: children);

  static const _defaultEventHeight = 24.0;

  final VisibleRange visibleRange;
  final DateInterval currentlyVisibleDates;
  final double page;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _EventsLayout<E>(
      visibleRange: visibleRange,
      currentlyVisibleDates: currentlyVisibleDates,
      page: page,
      eventHeight:
          context.timetableTheme?.allDayEventHeight ?? _defaultEventHeight,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _EventsLayout<E> renderObject) {
    renderObject
      ..visibleRange = visibleRange
      ..currentlyVisibleDates = currentlyVisibleDates
      ..page = page
      ..eventHeight =
          context.timetableTheme?.allDayEventHeight ?? _defaultEventHeight;
  }
}

class _EventParentData<E extends Event>
    extends ContainerBoxParentData<RenderBox> {
  E event;
}

class _EventsLayout<E extends Event> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _EventParentData<E>>,
        RenderBoxContainerDefaultsMixin<RenderBox, _EventParentData<E>> {
  _EventsLayout({
    @required VisibleRange visibleRange,
    @required DateInterval currentlyVisibleDates,
    @required double page,
    @required double eventHeight,
  })  : assert(visibleRange != null),
        _visibleRange = visibleRange,
        assert(currentlyVisibleDates != null),
        _currentlyVisibleDates = currentlyVisibleDates,
        assert(page != null),
        _page = page,
        assert(eventHeight != null),
        _eventHeight = eventHeight;

  VisibleRange _visibleRange;

  VisibleRange get visibleRange => _visibleRange;

  set visibleRange(VisibleRange value) {
    assert(value != null);
    if (_visibleRange == value) {
      return;
    }

    _visibleRange = value;
    markNeedsLayout();
  }

  DateInterval _currentlyVisibleDates;

  DateInterval get currentlyVisibleDates => _currentlyVisibleDates;

  set currentlyVisibleDates(DateInterval value) {
    assert(value != null);
    if (_currentlyVisibleDates == value) {
      return;
    }

    _currentlyVisibleDates = value;
    markNeedsLayout();
  }

  double _page;

  double get page => _page;

  set page(double value) {
    assert(value != null);
    if (_page == value) {
      return;
    }

    _page = value;
    markNeedsLayout();
  }

  double _eventHeight;

  double get eventHeight => _eventHeight;

  set eventHeight(double value) {
    assert(value != null);
    if (_eventHeight == value) {
      return;
    }

    _eventHeight = value;
    markNeedsLayout();
  }

  Iterable<E> get events => children.map((child) => child.data.event);

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _EventParentData<E>) {
      child.parentData = _EventParentData<E>();
    }
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
  double computeMinIntrinsicWidth(double height) {
    assert(_debugThrowIfNotCheckingIntrinsics());
    return 0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    assert(_debugThrowIfNotCheckingIntrinsics());
    return 0;
  }

  double _parallelEventCount() {
    int parallelEventsFrom(int page) {
      final startDate = LocalDate.fromEpochDay(page);
      final interval = DateInterval(
        startDate,
        startDate + Period(days: visibleRange.visibleDays - 1),
      );

      final maxEventPosition = _yPositions.entries
          .where((e) => e.key.intersectsInterval(interval))
          .map((e) => e.value)
          .max();
      return maxEventPosition != null ? maxEventPosition + 1 : 0;
    }

    _updateEventPositions();
    final oldParallelEvents = parallelEventsFrom(page.floor());
    final newParallelEvents = parallelEventsFrom(page.ceil());
    final t = page - page.floorToDouble();
    return lerpDouble(oldParallelEvents, newParallelEvents, t);
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
      final distance = math.max(
        e.start.calendarDate.periodSince(currentlyVisibleDates.end).days,
        e.endDateInclusive.periodUntil(currentlyVisibleDates.start).days,
      );
      return distance >= visibleRange.visibleDays;
    });

    // Insert new events.
    final sortedEvents =
        events.whereNot(_yPositions.containsKey).sortedByStartLength();

    Iterable<E> eventsWithPosition(int y) {
      return _yPositions.entries.where((e) => e.value == y).map((e) => e.key);
    }

    outer:
    for (final event in sortedEvents) {
      var y = 0;
      final interval = event.intersectingDates;

      // ignore: literal_only_boolean_expressions
      while (true) {
        final intersectingEvents = eventsWithPosition(y);
        if (intersectingEvents.none((e) => e.intersectsInterval(interval))) {
          _yPositions[event] = y;
          continue outer;
        }

        y++;
      }
    }
  }

  bool _hasOverflow = false;

  void _setSize() {
    final parallelEvents = _parallelEventCount();
    size = Size(constraints.maxWidth, parallelEvents * eventHeight);
    _hasOverflow = parallelEvents.floorToDouble() != parallelEvents;
  }

  void _positionEvents() {
    final dateWidth = size.width / visibleRange.visibleDays;
    for (final child in children) {
      final event = child.data.event;

      final startDate = event.start.calendarDate;
      final left = ((startDate.epochDay - page) * dateWidth).coerceAtLeast(0);
      final endDate = event.endDateInclusive;
      final right =
          ((endDate.epochDay + 1 - page) * dateWidth).coerceAtMost(size.width);

      child.layout(BoxConstraints.tightFor(
        width: right - left,
        height: eventHeight,
      ));

      child.data.offset = Offset(left, _yPositions[event] * eventHeight);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_hasOverflow) {
      defaultPaint(context, offset);
      return;
    }

    context.pushClipRect(
        needsCompositing, offset, Offset.zero & size, defaultPaint);
  }
}

extension _ParentData<E extends Event> on RenderBox {
  _EventParentData<E> get data => parentData as _EventParentData<E>;
}
