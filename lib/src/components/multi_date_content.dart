import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' hide Interval;

import '../config.dart';
import '../date/controller.dart';
import '../date/date_page_view.dart';
import '../event/event.dart';
import '../event/provider.dart';
import '../time/overlay.dart';
import '../time/zoom.dart';
import '../utils.dart';
import 'date_content.dart';
import 'date_dividers.dart';
import 'hour_dividers.dart';
import 'now_indicator.dart';

/// A widget that displays the content of multiple consecutive dates, zoomable
/// and with decoration like date and hour dividers.
///
/// A [DefaultDateController] must be above in the widget tree.
///
/// See also:
///
/// * [PartDayDraggableEvent], which can be wrapped around an event widget to
///   make it draggable to a different time or date.
/// * [DefaultEventProvider] (and [TimetableConfig]), which provide the [Event]s
///   to be displayed.
/// * [DefaultTimeOverlayProvider] (and [TimetableConfig]), which provide the
///   [TimeOverlay]s to be displayed.
/// * [DateDividers], [TimeZoom], [HourDividers], [NowIndicator],
///   [DatePageView], and [DateContent], which are used internally by this
///   widget and can be styled.
class MultiDateContent<E extends Event> extends StatelessWidget {
  const MultiDateContent({super.key});

  @override
  Widget build(BuildContext context) {
    return DateDividers(
      child: TimeZoom(
        child: HourDividers(
          child: NowIndicator(
            child: Builder(builder: _buildEvents),
          ),
        ),
      ),
    );
  }

  Widget _buildEvents(BuildContext context) {
    final dateController = DefaultDateController.of(context)!;

    return _MultiDateContentDragInfo(
      context: context,
      dateController: dateController,
      child: DatePageView(
        controller: dateController,
        builder: (context, date) => DateContent<E>(
          date: date,
          events:
              DefaultEventProvider.of<E>(context)?.call(date.fullDayInterval) ??
                  [],
          overlays:
              DefaultTimeOverlayProvider.of(context)?.call(context, date) ?? [],
        ),
      ),
    );
  }
}

class _MultiDateContentDragInfo extends InheritedWidget {
  const _MultiDateContentDragInfo({
    required this.context,
    required this.dateController,
    required super.child,
  });

  // Storing the context feels wrong but I haven't found a different way to
  // transform global coordinates back to local ones in this context.
  final BuildContext context;
  final DateController dateController;

  static DateTime resolveOffset(BuildContext context, Offset globalOffset) {
    final dragInfos = context
        .dependOnInheritedWidgetOfExactType<_MultiDateContentDragInfo>()!;

    final renderBox = dragInfos.context.findRenderObject()! as RenderBox;
    final size = renderBox.size;
    final localOffset = renderBox.globalToLocal(globalOffset);
    final pageValue = dragInfos.dateController.value;
    final page = (pageValue.page +
            localOffset.dx / size.width * pageValue.visibleDayCount)
        .floor();
    return DateTimeTimetable.dateFromPage(page) +
        1.days * (localOffset.dy / size.height);
  }

  @override
  bool updateShouldNotify(_MultiDateContentDragInfo oldWidget) {
    return context != oldWidget.context ||
        dateController != oldWidget.dateController;
  }
}

/// A widget that makes its child draggable starting from long press.
///
/// It must be used inside a [MultiDateContent].
class PartDayDraggableEvent extends StatefulWidget {
  PartDayDraggableEvent({
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onDragCanceled,
    required this.child,
    Widget? childWhileDragging,
  }) : childWhileDragging =
            childWhileDragging ?? Opacity(opacity: 0.6, child: child);

  final void Function()? onDragStart;
  final void Function(DateTime)? onDragUpdate;

  /// Called when a drag gesture is ended.
  ///
  /// The [DateTime] is `null` when the user long taps but then doesn't move
  /// their finger at all.
  final void Function(DateTime?)? onDragEnd;

  /// Called when a drag gesture is canceled.
  ///
  /// The [bool] indicates whether the user moved their finger or not.
  final void Function(bool isMoved)? onDragCanceled;

  final Widget child;
  final Widget childWhileDragging;

  @override
  State<PartDayDraggableEvent> createState() => _PartDayDraggableEventState();
}

class _PartDayDraggableEventState extends State<PartDayDraggableEvent> {
  DateTime? _lastDragDateTime;
  var _isMoved = false;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<_DragData>(
      data: _DragData(),
      maxSimultaneousDrags: 1,
      onDragStarted: widget.onDragStart,
      onDragUpdate: (details) {
        if (widget.onDragUpdate != null) {
          _lastDragDateTime = _MultiDateContentDragInfo.resolveOffset(
              context, details.globalPosition);
          widget.onDragUpdate!(_lastDragDateTime!);
        }
        _isMoved = true;
      },
      onDragEnd: (details) {
        if (widget.onDragEnd != null) {
          widget.onDragEnd!(_lastDragDateTime);
          _lastDragDateTime = null;
        }
        _isMoved = false;
      },
      onDraggableCanceled: widget.onDragCanceled != null
          ? (_, __) => widget.onDragCanceled!(_isMoved)
          : null,
      feedback: SizedBox.shrink(),
      childWhenDragging: widget.childWhileDragging,
      child: widget.child,
    );
  }
}

@immutable
class _DragData {
  const _DragData();
}
