import 'package:flutter/gestures.dart';
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
class MultiDateContent<E extends Event> extends StatefulWidget {
  const MultiDateContent({super.key, this.geometryKey});

  final GlobalKey<MultiDateContentGeometry>? geometryKey;

  @override
  State<MultiDateContent<E>> createState() => _MultiDateContentState<E>();
}

class _MultiDateContentState<E extends Event>
    extends State<MultiDateContent<E>> {
  late GlobalKey<MultiDateContentGeometry> geometryKey;
  late bool wasGeometryKeyFromWidget;

  @override
  void initState() {
    super.initState();
    geometryKey = widget.geometryKey ?? GlobalKey<MultiDateContentGeometry>();
    wasGeometryKeyFromWidget = widget.geometryKey != null;
  }

  @override
  void didUpdateWidget(covariant MultiDateContent<E> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.geometryKey == null && wasGeometryKeyFromWidget) {
      geometryKey = GlobalKey<MultiDateContentGeometry>();
      wasGeometryKeyFromWidget = false;
    } else if (widget.geometryKey != null &&
        geometryKey != widget.geometryKey) {
      geometryKey = widget.geometryKey!;
      wasGeometryKeyFromWidget = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final datePages = DatePageView(
      controller: DefaultDateController.of(context)!,
      builder: (context, date) => DateContent<E>(
        date: date,
        events:
            DefaultEventProvider.of<E>(context)?.call(date.fullDayInterval) ??
                [],
        overlays:
            DefaultTimeOverlayProvider.of(context)?.call(context, date) ?? [],
      ),
    );

    return DateDividers(
      child: TimeZoom(
        child: HourDividers(
          child: NowIndicator(
            child: _MultiDateContentGeometryWidget(
              key: geometryKey,
              child: datePages,
            ),
          ),
        ),
      ),
    );
  }
}

class _MultiDateContentGeometryWidget extends StatefulWidget {
  const _MultiDateContentGeometryWidget({
    required GlobalKey<MultiDateContentGeometry> key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  MultiDateContentGeometry createState() => MultiDateContentGeometry._();
}

class MultiDateContentGeometry extends State<_MultiDateContentGeometryWidget> {
  MultiDateContentGeometry._();

  @override
  Widget build(BuildContext context) => widget.child;

  bool contains(Offset globalOffset) {
    final renderBox = _findRenderBox();
    final localOffset = renderBox.globalToLocal(globalOffset);
    return (Offset.zero & renderBox.size).contains(localOffset);
  }

  DateTime resolveOffset(Offset globalOffset) {
    final renderBox = _findRenderBox();
    final size = renderBox.size;
    final localOffset = renderBox.globalToLocal(globalOffset);
    final pageValue = DefaultDateController.of(context)!.value;
    final page = (pageValue.page +
            localOffset.dx / size.width * pageValue.visibleDayCount)
        .floor();
    return DateTimeTimetable.dateFromPage(page) +
        1.days * (localOffset.dy / size.height);
  }

  RenderBox _findRenderBox() => context.findRenderObject()! as RenderBox;

  static MultiDateContentGeometry? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<MultiDateContentGeometry>();
}

typedef PartDayDragStartCallback = VoidCallback;

typedef PartDayDragUpdateCallbackRaw = void Function(
  GlobalKey<MultiDateContentGeometry>? geometryKey,
  DateTime dateTime,
);
typedef PartDayDragUpdateCallback = void Function(DateTime dateTime);
typedef PartDayDragUpdateCallbackWithGeometryKey = void Function(
  GlobalKey<MultiDateContentGeometry> geometryKey,
  DateTime dateTime,
);

typedef PartDayDragEndCallbackRaw = void Function(
  GlobalKey<MultiDateContentGeometry>? geometryKey,
  DateTime? dateTime,
);
typedef PartDayDragEndCallback = void Function(DateTime? dateTime);
typedef PartDayDragEndCallbackWithGeometryKey = void Function(
  GlobalKey<MultiDateContentGeometry> geometryKey,
  DateTime? dateTime,
);

typedef PartDayDragCanceledCallbackRaw = void Function(
  GlobalKey<MultiDateContentGeometry>? geometryKey,
  bool wasMoved,
);
typedef PartDayDragCanceledCallback = void Function(bool wasMoved);
typedef PartDayDragCanceledCallbackWithGeometryKey = void Function(
  GlobalKey<MultiDateContentGeometry> geometryKey,
  bool wasMoved,
);

/// A widget that makes its child draggable starting from long press.
///
/// It must be used inside a [MultiDateContent].
class PartDayDraggableEvent extends StatefulWidget {
  PartDayDraggableEvent({
    this.onDragStart,
    PartDayDragUpdateCallback? onDragUpdate,
    PartDayDragEndCallback? onDragEnd,
    PartDayDragCanceledCallback? onDragCanceled,
    required this.child,
    Widget? childWhileDragging,
  })  : geometryKeys = {},
        onDragUpdate = onDragUpdate == null
            ? null
            : ((geometryKey, dateTime) {
                assert(geometryKey == null);
                onDragUpdate(dateTime);
              }),
        onDragEnd = onDragEnd == null
            ? null
            : ((geometryKey, dateTime) {
                assert(geometryKey == null);
                onDragEnd(dateTime);
              }),
        onDragCanceled = onDragCanceled == null
            ? null
            : ((geometryKey, wasMoved) {
                assert(geometryKey == null);
                onDragCanceled(wasMoved);
              }),
        childWhileDragging =
            childWhileDragging ?? _buildDefaultChildWhileDragging(child);

  PartDayDraggableEvent.forGeometryKeys(
    this.geometryKeys, {
    this.onDragStart,
    PartDayDragUpdateCallbackWithGeometryKey? onDragUpdate,
    PartDayDragEndCallbackWithGeometryKey? onDragEnd,
    PartDayDragCanceledCallbackWithGeometryKey? onDragCanceled,
    required this.child,
    Widget? childWhileDragging,
  })  : onDragUpdate = onDragUpdate == null
            ? null
            : ((geometryKey, dateTime) => onDragUpdate(geometryKey!, dateTime)),
        onDragEnd = onDragEnd == null
            ? null
            : ((geometryKey, dateTime) => onDragEnd(geometryKey!, dateTime)),
        onDragCanceled = onDragCanceled == null
            ? null
            : ((geometryKey, wasMoved) =>
                onDragCanceled(geometryKey!, wasMoved)),
        childWhileDragging =
            childWhileDragging ?? _buildDefaultChildWhileDragging(child);

  static Widget _buildDefaultChildWhileDragging(Widget child) =>
      Opacity(opacity: 0.6, child: child);

  /// - If this set is empty, the [MultiDateContentGeometry] will be looked up
  ///   in the widget ancestors. This is the default for events placed in a
  ///   [MultiDateContent].
  /// - If this set contains a single key, it's geometry will be used, even if
  ///   the event is not currently dragged directly over it.
  /// - If this set contains multiple keys, the first key whose geometry
  ///   contains the current drag position will be used. E.g., if you have two
  ///   [MultiDateContent] widgets next to each other, we will use the key of
  ///   the [MultiDateContent] that this is currently being dragged over.
  ///
  ///   Otherwise, if the current drag position does not match any geometry, the
  ///   first key will be used.
  final Set<GlobalKey<MultiDateContentGeometry>> geometryKeys;

  final PartDayDragStartCallback? onDragStart;
  final PartDayDragUpdateCallbackRaw? onDragUpdate;

  /// Called when a drag gesture is ended.
  ///
  /// The [DateTime] is `null` when the user long taps but then doesn't move
  /// their finger at all.
  final PartDayDragEndCallbackRaw? onDragEnd;

  /// Called when a drag gesture is canceled.
  ///
  /// The [bool] indicates whether the user moved their finger or not.
  final PartDayDragCanceledCallbackRaw? onDragCanceled;

  final Widget child;
  final Widget childWhileDragging;

  @override
  State<PartDayDraggableEvent> createState() => _PartDayDraggableEventState();
}

class _PartDayDraggableEventState extends State<PartDayDraggableEvent> {
  /// The initial pointer position inside this widget.
  double? _pointerVerticalAlignment;
  Offset? _lastOffset;
  var _wasMoved = false;
  void _resetState() {
    _pointerVerticalAlignment = null;
    _lastOffset = null;
    _wasMoved = false;
  }

  RenderBox _findRenderBox() => context.findRenderObject()! as RenderBox;

  @override
  Widget build(BuildContext context) {
    return _PartDayDraggable(
      onDragStarted: _onDragStarted,
      onDragUpdate: _onDragUpdate,
      onDragEnd: _onDragEnd,
      onDragCanceled: _onDragCanceled,
      feedback: const SizedBox.shrink(),
      childWhenDragging: widget.childWhileDragging,
      child: widget.child,
    );
  }

  void _onDragStarted(Offset offset) {
    final renderBox = _findRenderBox();
    final offsetInLocalSpace = renderBox.globalToLocal(offset);
    _pointerVerticalAlignment = offsetInLocalSpace.dy / renderBox.size.height;
    _lastOffset = offset;

    widget.onDragStart?.call();
  }

  void _onDragUpdate(Offset offset) {
    _lastOffset = offset;
    final adjustedOffset = _pointerToWidgetTopCenter(offset);
    final geometry = _findGeometry(context, adjustedOffset);
    widget.onDragUpdate?.call(
      geometry.key,
      geometry.value.resolveOffset(adjustedOffset),
    );
    _wasMoved = true;
  }

  void _onDragEnd() {
    final adjustedOffset = _pointerToWidgetTopCenter(_lastOffset!);
    final geometry = _findGeometry(context, adjustedOffset);
    widget.onDragEnd?.call(
      geometry.key,
      geometry.value.resolveOffset(adjustedOffset),
    );
    _resetState();
  }

  void _onDragCanceled() {
    if (_pointerVerticalAlignment == null) {
      // The drag already ended.
      assert(_lastOffset == null);
      assert(!_wasMoved);
      return;
    }

    if (mounted) {
      final adjustedOffset = _pointerToWidgetTopCenter(_lastOffset!);
      final geometry = _findGeometry(context, adjustedOffset);
      widget.onDragCanceled?.call(geometry.key, _wasMoved);
      _resetState();
    } else {
      widget.onDragCanceled?.call(null, _wasMoved);
      _resetState();
    }
  }

  Offset _pointerToWidgetTopCenter(Offset offset) {
    final renderBox = _findRenderBox();
    final adjustment =
        Offset(0, _pointerVerticalAlignment! * renderBox.size.height);

    final local = renderBox.globalToLocal(offset);
    final localAdjusted = local - adjustment;
    return renderBox.localToGlobal(localAdjusted);
  }

  MapEntry<GlobalKey<MultiDateContentGeometry>?, MultiDateContentGeometry>
      _findGeometry(
    BuildContext context,
    Offset globalOffset,
  ) {
    if (widget.geometryKeys.isNotEmpty) {
      if (widget.geometryKeys.length == 1) {
        final geometryKey = widget.geometryKeys.single;
        return MapEntry(geometryKey, geometryKey.currentState!);
      }

      for (final geometryKey in widget.geometryKeys) {
        final geometry = geometryKey.currentState!;
        if (!geometry.contains(globalOffset)) continue;
        return MapEntry(geometryKey, geometry);
      }

      final geometryKey = widget.geometryKeys.first;
      return MapEntry(geometryKey, geometryKey.currentState!);
    }

    final geometry = MultiDateContentGeometry.maybeOf(context);
    if (geometry != null) return MapEntry(null, geometry);

    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        "`PartDayDraggableEvent` can't find a `MultiDateContentGeometry`.",
      ),
      ErrorHint(
        'The `MultiDateContentGeometry`, which is created for every '
        '`MultiDateContent` widget, is automatically picked up if this widget '
        'is inside it, i.e., a normal event displayed by timetable.',
      ),
      ErrorHint(
        'If you want to display a `PartDayDraggableEvent` outside of a '
        '`MultiDateContent`, you have to supply a '
        '`GlobalKey<MultiDateContentGeometry> geometryKey` to both this '
        '`PartDayDraggableEvent` and the target `MultiDateContent` that this '
        'event is supposed to be dropped in.',
      ),
      context.describeElement('The context used was'),
    ]);
  }
}

class _PartDayDraggable extends LongPressDraggable<_DragData> {
  _PartDayDraggable({
    required ValueSetter<Offset> onDragStarted,
    required ValueChanged<Offset> onDragUpdate,
    required VoidCallback onDragEnd,
    required VoidCallback onDragCanceled,
    required super.child,
    required super.childWhenDragging,
    required super.feedback,
  })  : onDragStartedWithOffset = onDragStarted,
        super(
          data: const _DragData(),
          maxSimultaneousDrags: 1,
          onDragStarted: null,
          onDragUpdate: (details) => onDragUpdate(details.globalPosition),
          onDragEnd: (details) => onDragEnd(),
          onDraggableCanceled: (_, offset) => onDragCanceled(),
        );

  final ValueSetter<Offset> onDragStartedWithOffset;

  @override
  DelayedMultiDragGestureRecognizer createRecognizer(
    GestureMultiDragStartCallback onStart,
  ) {
    return super.createRecognizer((offset) {
      onDragStartedWithOffset(offset);
      return onStart(offset);
    });
  }
}

@immutable
class _DragData {
  const _DragData();
}
