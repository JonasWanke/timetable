import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

import '../utils.dart';
import 'controller.dart';
import 'time_range.dart';

class TimeZoom extends StatefulWidget {
  const TimeZoom({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  _TimeZoomState createState() => _TimeZoomState();
}

class _TimeZoomState extends State<TimeZoom>
    with SingleTickerProviderStateMixin {
  // Taken from [_InteractiveViewerState._kDrag].
  static const _kDrag = 0.0000135;
  late AnimationController _animationController;
  Animation<double>? _animation;

  TimeController get _controller => DefaultTimeController.of(context)!;
  ScrollController? _scrollController;
  bool _scrollControllerIsInitialized = false;

  late double _parentHeight;

  // Layouts the child so only [_controller.value] out of [_controller.maxRange]
  // is visible.
  double get _outerChildHeight =>
      _parentHeight *
      (_controller.maxRange.duration / _controller.value.duration);
  double get _outerOffset {
    final timeRange = _controller.value;
    return (timeRange.startTime - _controller.maxRange.startTime) /
        _controller.maxRange.duration *
        _outerChildHeight;
  }

  late TimeRange? _initialRange;
  late Duration? _lastFocus;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController?.dispose();
    _scrollControllerIsInitialized = false;
  }

  void _onControllerChanged() {
    _scrollController!.jumpTo(_outerOffset);
  }

  void _onScrollControllerChanged() {
    _controller.value = TimeRange.fromStartAndDuration(
      _controller.maxRange.startTime +
          _controller.maxRange.duration *
              (_scrollController!.offset / _outerChildHeight),
      _controller.value.duration,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _parentHeight = constraints.maxHeight;

        if (!_scrollControllerIsInitialized) {
          _scrollController =
              ScrollController(initialScrollOffset: _outerOffset)
                ..addListener(_onScrollControllerChanged);
          _controller.addListener(_onControllerChanged);
          _scrollControllerIsInitialized = true;
        }

        return GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          child: ClipRect(
            child: _NoDragSingleChildScrollView(
              controller: _scrollController!,
              child: ValueListenableBuilder<TimeRange>(
                valueListenable: _controller,
                builder: (context, _, child) {
                  // Layouts the child so only [_controller.maxRange] is
                  // visible.
                  final innerChildHeight = _outerChildHeight *
                      (1.days / _controller.maxRange.duration);
                  final innerOffset = -innerChildHeight *
                      (_controller.maxRange.startTime / 1.days);

                  return SizedBox(
                    height: _outerChildHeight,
                    child: _VerticalOverflowBox(
                      offset: innerOffset,
                      height: innerChildHeight,
                      child: widget.child,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _initialRange = _controller.value;
    _lastFocus = _getFocusTime(details.localFocalPoint.dy);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final newDuration = (_initialRange!.duration * (1 / details.verticalScale))
        .coerceIn(_controller.minDuration, _controller.maxRange.duration);

    final newFocus = _focusToDuration(details.localFocalPoint.dy, newDuration);
    final newStart = _lastFocus! - newFocus;
    _setNewTimeRange(newStart, newDuration);
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _initialRange = null;
    _lastFocus = null;

    // The following is inspired by [_InteractiveViewerState._onScaleEnd].
    _animation?.removeListener(_onAnimate);
    _animationController.reset();

    final velocity = details.velocity.pixelsPerSecond.dy;
    if (velocity.abs() < kMinFlingVelocity) return;

    final frictionSimulation =
        FrictionSimulation(_kDrag, _outerOffset, -velocity);

    const effectivelyMotionless = 10.0;
    final finalTime = math.log(effectivelyMotionless / velocity.abs()) /
        math.log(_kDrag / 100);

    _animation =
        Tween<double>(begin: _outerOffset, end: frictionSimulation.finalX)
            .animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.decelerate,
    ));
    _animationController.duration = finalTime.seconds;
    _animation!.addListener(_onAnimate);
    _animationController.forward();
  }

  void _onAnimate() {
    if (!_animationController.isAnimating) {
      _animation?.removeListener(_onAnimate);
      _animation = null;
      _animationController.reset();
      return;
    }

    _setNewTimeRange(
      _controller.maxRange.duration * (_animation!.value / _outerChildHeight),
      _controller.value.duration,
    );
  }

  Duration _getFocusTime(double focalPoint) {
    final range = _controller.value;
    return range.startTime + _focusToDuration(focalPoint, range.duration);
  }

  Duration _focusToDuration(
    double focalPoint,
    Duration visibleDuration,
  ) =>
      visibleDuration * (focalPoint / _parentHeight);
  void _setNewTimeRange(Duration startTime, Duration duration) {
    final actualStartTime = startTime.coerceIn(
      _controller.maxRange.startTime,
      _controller.maxRange.endTime - duration,
    );
    _controller.value =
        TimeRange.fromStartAndDuration(actualStartTime, duration);
  }
}

/// A modified [SingleChildScrollView] that doesn't allow drags from a pointer.
///
/// Necessary because we handle drags ourselves to also detect zoom gestures.
class _NoDragSingleChildScrollView extends SingleChildScrollView {
  /// Creates a box in which a single widget can be scrolled.
  const _NoDragSingleChildScrollView({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
    ScrollController? controller,
    Widget? child,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    Clip clipBehavior = Clip.hardEdge,
    String? restorationId,
  }) : super(
          key: key,
          scrollDirection: scrollDirection,
          reverse: reverse,
          padding: padding,
          controller: controller,
          primary: false,
          physics: physics,
          child: child,
          dragStartBehavior: dragStartBehavior,
          clipBehavior: clipBehavior,
          restorationId: restorationId,
        );

  @override
  Widget build(BuildContext context) {
    // This is really ugly and relies on the implementation of
    // [SingleChildScrollView.build].
    final result = super.build(context) as Scrollable;
    return _Scrollable(
      dragStartBehavior: result.dragStartBehavior,
      axisDirection: result.axisDirection,
      controller: result.controller,
      physics: result.physics,
      restorationId: result.restorationId,
      viewportBuilder: result.viewportBuilder,
    );
  }
}

class _Scrollable extends Scrollable {
  const _Scrollable({
    Key? key,
    AxisDirection axisDirection = AxisDirection.down,
    ScrollController? controller,
    ScrollPhysics? physics,
    required ViewportBuilder viewportBuilder,
    ScrollIncrementCalculator? incrementCalculator,
    bool excludeFromSemantics = false,
    int? semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    String? restorationId,
  }) : super(
          key: key,
          axisDirection: axisDirection,
          controller: controller,
          physics: physics,
          viewportBuilder: viewportBuilder,
          incrementCalculator: incrementCalculator,
          excludeFromSemantics: excludeFromSemantics,
          semanticChildCount: semanticChildCount,
          dragStartBehavior: dragStartBehavior,
          restorationId: restorationId,
        );

  @override
  _ScrollableState createState() => _ScrollableState();
}

class _ScrollableState extends ScrollableState {
  @override
  @protected
  void setCanDrag(bool canDrag) {}
}

// Copied and modified from [OverflowBox].
class _VerticalOverflowBox extends SingleChildRenderObjectWidget {
  const _VerticalOverflowBox({
    Key? key,
    required this.height,
    required this.offset,
    Widget? child,
  }) : super(key: key, child: child);

  final double height;
  final double offset;

  @override
  _RenderVerticalOverflowBox createRenderObject(BuildContext context) {
    return _RenderVerticalOverflowBox(
      height: height,
      offset: offset,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderVerticalOverflowBox renderObject,
  ) {
    renderObject.height = height;
    renderObject.offset = offset;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('height', height));
    properties.add(DoubleProperty('offset', offset));
  }
}

// Copied and modified from [RenderConstrainedOverflowBox].
class _RenderVerticalOverflowBox extends RenderShiftedBox {
  _RenderVerticalOverflowBox({
    RenderBox? child,
    required double height,
    required double offset,
  })  : _height = height,
        _offset = offset,
        super(child);

  double get height => _height;
  double _height;
  set height(double value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  double get offset => _offset;
  double _offset;
  set offset(double value) {
    if (_offset == value) return;
    _offset = value;
    markNeedsLayout();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _getInnerConstraints(constraints).biggest;

  @override
  void performLayout() {
    assert(!sizedByParent);

    if (child == null) return;

    child!.layout(_getInnerConstraints(constraints), parentUsesSize: true);
    (child!.parentData! as BoxParentData).offset = Offset(0, offset);
    size = Size(child!.size.width, constraints.maxHeight);
  }

  BoxConstraints _getInnerConstraints(BoxConstraints constraints) =>
      constraints.copyWith(minHeight: height, maxHeight: height);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('height', height));
    properties.add(DoubleProperty('offset', offset));
  }
}
