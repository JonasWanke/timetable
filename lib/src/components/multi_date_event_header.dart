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
import '../theme.dart';
import '../utils.dart';

/// A widget that displays all-day [Event]s.
///
/// A [DefaultDateController] and [DefaultEventBuilder] must be above in the
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

    return Stack(children: [
      Positioned.fill(
        child: DatePageView(builder: (context, date) => SizedBox()),
      ),
      ClipRect(
        child: Padding(
          padding: style.padding,
          child: LayoutBuilder(
            builder: (context, constraints) =>
                ValueListenableBuilder<DatePageValue>(
              valueListenable: DefaultDateController.of(context)!,
              builder: (context, pageValue, __) => _buildContent(
                context,
                style,
                pageValue,
                constraints.maxWidth,
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildContent(
    BuildContext context,
    MultiDateEventHeaderStyle style,
    DatePageValue pageValue,
    double width,
  ) {
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
      child: _buildEventLayout(context, style, pageValue),
    );
  }

  Widget _buildEventLayout(
    BuildContext context,
    MultiDateEventHeaderStyle style,
    DatePageValue pageValue,
  ) {
    final events =
        DefaultEventProvider.of<E>(context)?.call(pageValue.visibleDates) ?? [];

    return _EventsWidget<E>(
      pageValue: pageValue,
      eventHeight: style.eventHeight,
      children: [
        for (final event in events)
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
    super.key,
    required this.event,
    required super.child,
  });

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
    required this.pageValue,
    required this.eventHeight,
    required super.children,
  });

  final DatePageValue pageValue;
  final double eventHeight;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _EventsLayout<E>(
      pageValue: pageValue,
      eventHeight: eventHeight,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _EventsLayout<E> renderObject) {
    renderObject
      ..pageValue = pageValue
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
    required DatePageValue pageValue,
    required double eventHeight,
  })  : _pageValue = pageValue,
        _eventHeight = eventHeight;

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

  final _yPositions = <E, int>{};

  @override
  void performLayout() {
    assert(!sizedByParent);

    if (children.isEmpty) {
      size = Size(constraints.maxWidth, 0);
      return;
    }

    _updateEventPositions();
    size = Size(constraints.maxWidth, _parallelEventCount() * eventHeight);
    _positionEvents();
  }

  void _updateEventPositions() {
    // Remove events outside the current viewport (with some buffer).
    _yPositions.removeWhere((e, _) {
      return e.start.page.floor() > pageValue.lastVisiblePage ||
          e.end.page.ceil() <= pageValue.firstVisibleDate.page;
    });

    // Remove old events.
    _yPositions.removeWhere((e, _) => !_events.contains(e));

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

  void _positionEvents() {
    final dateWidth = size.width / pageValue.visibleDayCount;
    for (final child in children) {
      final data = child.data<E>();
      final event = data.event!;

      final dateInterval = event.interval.dateInterval;
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
      data.offset = Offset(actualLeft, _yPositions[event]! * eventHeight);
    }
  }

  double _parallelEventCount() {
    int parallelEventsFrom(int page) {
      final visibleDates = pageValue.visibleDates;
      final maxEventPosition = _yPositions.entries
          .where((e) => e.key.interval.intersects(visibleDates))
          .map<num>((e) => e.value)
          .maxOrNull as int?;
      return maxEventPosition != null ? maxEventPosition + 1 : 0;
    }

    _updateEventPositions();
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
  _EventParentData<E> data<E extends Event>() =>
      parentData! as _EventParentData<E>;
}
