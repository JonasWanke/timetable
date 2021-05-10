import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' hide Interval;

import '../date/controller.dart';
import '../date/date_page_view.dart';
import '../event/event.dart';
import '../event/provider.dart';
import '../time/overlay.dart';
import '../time/zoom.dart';
import '../utils.dart';
import '../utils/stream_change_notifier.dart';
import 'date_content.dart';
import 'date_dividers_painter.dart';
import 'date_events.dart';
import 'hour_dividers_painter.dart';
import 'now_indicator_painter.dart';

typedef MultiDateContentBackgroundTapCallback = void Function(
  DateTime dateTime,
);

class MultiDateContent<E extends Event> extends StatefulWidget {
  const MultiDateContent({
    Key? key,
    this.onBackgroundTap,
    this.style,
  }) : super(key: key);

  final MultiDateContentBackgroundTapCallback? onBackgroundTap;
  final MultiDateContentStyle? style;

  @override
  _MultiDateContentState<E> createState() => _MultiDateContentState<E>();
}

class _MultiDateContentState<E extends Event>
    extends State<MultiDateContent<E>> {
  final _timeListenable =
      StreamChangeNotifier(Stream<void>.periodic(10.seconds));

  @override
  void dispose() {
    _timeListenable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final dateController = DefaultDateController.of(context)!;

    return CustomPaint(
      painter: DateDividersPainter(
        controller: dateController,
        dividerColor: widget.style?.dividerColor ?? theme.dividerColor,
      ),
      child: TimeZoom(
        child: CustomPaint(
          painter: HourDividersPainter(
            dividerColor: widget.style?.dividerColor ?? theme.dividerColor,
          ),
          foregroundPainter: NowIndicatorPainter(
            controller: dateController,
            style: widget.style?.nowIndicatorStyle ??
                MultiDateNowIndicatorStyle(
                  color: theme.highEmphasisOnBackground,
                ),
            repaint: _timeListenable,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) =>
                _buildEvents(context, dateController, constraints.biggest),
          ),
        ),
      ),
    );
  }

  Widget _buildEvents(
    BuildContext context,
    DateController dateController,
    Size size,
  ) {
    return _DragInfos(
      context: context,
      dateController: dateController,
      size: size,
      child: DatePageView(
        controller: dateController,
        builder: (context, date) => DateContent(
          date: date,
          events: DefaultEventProvider.of<E>(context)!(date.fullDayInterval),
          overlays: DefaultTimeOverlayProvider.of(context)!(context, date),
          onBackgroundTap: widget.onBackgroundTap,
        ),
      ),
    );
  }
}

/// Defines visual properties for [MultiDateContent].
class MultiDateContentStyle {
  const MultiDateContentStyle({
    this.nowIndicatorStyle,
    this.dividerColor,
    this.dateEventsStyle,
  });

  final MultiDateNowIndicatorStyle? nowIndicatorStyle;

  /// [Color] for painting hour and day dividers in the part-day event area.
  final Color? dividerColor;

  final DateEventsStyle? dateEventsStyle;

  @override
  int get hashCode =>
      hashList([nowIndicatorStyle, dividerColor, dateEventsStyle]);
  @override
  bool operator ==(Object other) {
    return other is MultiDateContentStyle &&
        other.nowIndicatorStyle == nowIndicatorStyle &&
        other.dividerColor == dividerColor &&
        other.dateEventsStyle == dateEventsStyle;
  }
}

class _DragInfos extends InheritedWidget {
  const _DragInfos({
    required this.context,
    required this.dateController,
    required this.size,
    required Widget child,
  }) : super(child: child);

  // Storing the context feels wrong but I haven't found a different way to
  // transform global coordinates back to local ones in this context.
  final BuildContext context;
  final DateController dateController;
  final Size size;

  static DateTime resolveOffset(BuildContext context, Offset globalOffset) {
    final dragInfos = context.dependOnInheritedWidgetOfExactType<_DragInfos>()!;

    final localOffset = (dragInfos.context.findRenderObject()! as RenderBox)
        .globalToLocal(globalOffset);
    final pageValue = dragInfos.dateController.value;
    final page = (pageValue.page +
            localOffset.dx / dragInfos.size.width * pageValue.visibleDayCount)
        .floor();
    return DateTimeTimetable.dateFromPage(page) +
        1.days * (localOffset.dy / dragInfos.size.height);
  }

  @override
  bool updateShouldNotify(_DragInfos oldWidget) {
    return context != oldWidget.context ||
        dateController != oldWidget.dateController ||
        size != oldWidget.size;
  }
}

class PartDayDraggableEvent extends StatefulWidget {
  PartDayDraggableEvent({
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    required this.child,
    Widget? childWhileDragging,
  }) : childWhileDragging =
            childWhileDragging ?? Opacity(opacity: 0.6, child: child);

  final void Function()? onDragStart;
  final void Function(DateTime)? onDragUpdate;

  /// The target [DateTime] is null when the user long tapps but then doesn't
  /// move their finger at all.
  final void Function(DateTime?)? onDragEnd;

  final Widget child;
  final Widget childWhileDragging;

  @override
  _PartDayDraggableEventState createState() => _PartDayDraggableEventState();
}

class _PartDayDraggableEventState extends State<PartDayDraggableEvent> {
  DateTime? _lastDragDateTime;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<_DragData>(
      data: _DragData(),
      maxSimultaneousDrags: 1,
      onDragStarted: widget.onDragStart,
      onDragUpdate: widget.onDragUpdate != null
          ? (details) {
              _lastDragDateTime =
                  _DragInfos.resolveOffset(context, details.globalPosition);
              widget.onDragUpdate!(_lastDragDateTime!);
            }
          : null,
      onDragEnd: widget.onDragEnd != null
          ? (details) {
              widget.onDragEnd!(_lastDragDateTime!);
              _lastDragDateTime = null;
            }
          : null,
      child: widget.child,
      childWhenDragging: widget.childWhileDragging,
      feedback: SizedBox.shrink(),
    );
  }
}

@immutable
class _DragData {
  const _DragData();
}
