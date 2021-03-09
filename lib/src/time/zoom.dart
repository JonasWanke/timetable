import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import '../utils.dart';
import 'controller.dart';
import 'time_range.dart';

class TimeZoom extends StatefulWidget {
  const TimeZoom({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);

  final TimeController controller;

  final Widget child;

  @override
  _TimeZoomState createState() => _TimeZoomState();
}

class _TimeZoomState extends State<TimeZoom>
    with SingleTickerProviderStateMixin {
  // Taken from [_InteractiveViewerState._kDrag].
  static const double _kDrag = 0.0000135;
  late AnimationController _animationController;
  Animation<double>? _animation;

  late double _parentHeight;
  double get _offset =>
      -widget.controller.value.startTime / 1.days * _childHeight;
  double get _childHeight =>
      _parentHeight / (widget.controller.value.duration / 1.days);

  late TimeRange? _initialRange;
  late Duration? _lastFocus;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _parentHeight = constraints.maxHeight;

        return GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          child: ClipRect(
            child: ValueListenableBuilder<TimeRange>(
              valueListenable: widget.controller,
              builder: (context, _, child) {
                return _VerticalOverflowBox(
                  height: _childHeight,
                  offset: _offset,
                  child: child,
                );
              },
              child: widget.child,
            ),
          ),
        );
      },
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _initialRange = widget.controller.value;
    _lastFocus = _getFocusTime(details.localFocalPoint.dy);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final newDuration =
        (_initialRange!.duration * (1 / details.verticalScale)).coerceIn(
      widget.controller.minDuration,
      widget.controller.maxRange.duration,
    );

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

    final frictionSimulation = FrictionSimulation(_kDrag, _offset, velocity);

    const effectivelyMotionless = 10.0;
    final finalTime = math.log(effectivelyMotionless / velocity.abs()) /
        math.log(_kDrag / 100);

    _animation = Tween<double>(begin: _offset, end: frictionSimulation.finalX)
        .animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.decelerate,
    ));
    _animationController.duration = finalTime.seconds;
    _animation!.addListener(_onAnimate);
    _animationController.forward();
  }

  // Inspired by [_InteractiveViewerState._onAnimate].
  void _onAnimate() {
    if (!_animationController.isAnimating) {
      _animation?.removeListener(_onAnimate);
      _animation = null;
      _animationController.reset();
      return;
    }

    _setNewTimeRange(
      1.days * (-_animation!.value / _childHeight),
      widget.controller.value.duration,
    );
  }

  Duration _getFocusTime(double focalPoint) {
    final range = widget.controller.value;
    return range.startTime + _focusToDuration(focalPoint, range.duration);
  }

  Duration _focusToDuration(
    double focalPoint,
    Duration visibleDuration,
  ) =>
      visibleDuration * (focalPoint / _parentHeight);
  void _setNewTimeRange(Duration startTime, Duration duration) {
    final actualStartTime = startTime.coerceIn(
      widget.controller.maxRange.startTime,
      widget.controller.maxRange.endTime - duration,
    );
    widget.controller.value =
        TimeRange.fromStartAndDuration(actualStartTime, duration);
  }
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
  })   : _height = height,
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
