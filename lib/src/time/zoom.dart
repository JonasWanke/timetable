import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

import '../utils.dart';
import 'controller.dart';
import 'time_range.dart';

/// A widget that allows the user to scroll and zoom into a single day.
///
/// This uses a [TimeController] to maintain its state, which has to be supplied
/// by a [DefaultTimeController] above in the widget tree.
class TimeZoom extends StatefulWidget {
  const TimeZoom({super.key, required this.child});

  final Widget child;

  @override
  State<TimeZoom> createState() => _TimeZoomState();
}

class _TimeZoomState extends State<TimeZoom>
    with SingleTickerProviderStateMixin {
  // Taken from [_InteractiveViewerState._kDrag].
  static const _kDrag = 0.0000135;
  late AnimationController _animationController;
  Animation<double>? _animation;

  TimeController? _controller;
  TimeControllerClientRegistration? _registration;
  _ScrollController? _scrollController;

  late double _parentHeight;

  // Layouts the child so only [_controller.value] out of [_controller.maxRange]
  // is visible.
  double get _outerChildHeight =>
      _parentHeight *
      (_controller!.maxRange.duration / _controller!.value.duration);
  double get _outerOffset {
    final timeRange = _controller!.value;
    return (timeRange.startTime - _controller!.maxRange.startTime) /
        _controller!.maxRange.duration *
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

    final newController = DefaultTimeController.of(context)!;
    if (_controller == null) {
      assert(_registration == null);
    } else if (newController != _controller) {
      _controller!.removeListener(_onControllerChanged);
      _registration?.unregister();
    }
    _controller = newController;
    newController.addListener(_onControllerChanged);

    _scrollController?.dispose();
    _scrollController = null;
  }

  void _onControllerChanged() {
    final scrollController = _scrollController;
    if (scrollController == null || !scrollController.hasClients) return;
    scrollController.jumpToInternal(_outerOffset);
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (_controller != null) {
      _controller!.removeListener(_onControllerChanged);
      _registration?.unregister();
    } else {
      assert(_registration == null);
    }
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _parentHeight = constraints.maxHeight;

        final heightToReport =
            _parentHeight * (1.days / _controller!.maxRange.duration);
        if (_registration == null || heightToReport != _registration!.height) {
          scheduleMicrotask(() {
            // This might update the controller's value, causing a rebuild
            //  which is not permitted during the build phase).
            if (_registration == null) {
              _registration = _controller!.registerClient(heightToReport);
            } else {
              _registration!.notifyHeightChanged(heightToReport);
            }
          });
        }

        _scrollController ??= _ScrollController(
          getOffset: () => _outerOffset,
          setOffset: _setOffset,
        );

        return RawGestureDetector(
          gestures: {
            // We can't use a `GestureDetector` with scaling as that uses
            // `computePanSlop` to determine the minimum distance a pointer has
            // to move before it is considered a pan (in this case, a scroll).
            // If this widget is used in a scrollable context, then the outer
            // scrollable view would always win in the gesture arena because it
            // uses `computeHitSlop`, which is half that amount.
            _ScaleGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<_ScaleGestureRecognizer>(
              () => _ScaleGestureRecognizer(debugOwner: this),
              (instance) {
                instance
                  ..onStart = _onScaleStart
                  ..onUpdate = _onScaleUpdate
                  ..onEnd = _onScaleEnd
                  ..dragStartBehavior = DragStartBehavior.down;
              },
            ),
          },
          child: ClipRect(
            child: _NoDragSingleChildScrollView(
              controller: _scrollController!,
              child: ValueListenableBuilder(
                valueListenable: _controller!,
                builder: (context, _, child) {
                  // Layouts the child so only [_controller.maxRange] is
                  // visible.
                  final innerChildHeight = _outerChildHeight *
                      (1.days / _controller!.maxRange.duration);
                  final innerOffset = -innerChildHeight *
                      (_controller!.maxRange.startTime / 1.days);

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

  void _setOffset(double value) {
    final controller = _controller!;
    controller.value = TimeRange.fromStartAndDuration(
      controller.maxRange.startTime +
          controller.maxRange.duration * (value / _outerChildHeight),
      controller.value.duration,
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _initialRange = _controller!.value;
    _lastFocus = _getFocusTime(details.localFocalPoint.dy);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final controller = _controller!;
    final rawScale = details.verticalScale;
    assert(rawScale >= 0);

    final Duration newDuration;
    if (rawScale <= precisionErrorTolerance) {
      // When `rawScale` approaches zero, `1 / rawScale` in the `else`-branch
      // can become infinity, producing an error when multiplying a `Duration`
      // with it. Hence, we catch this early and coerce the `newDuration` to the
      // maximum possible value directly.
      newDuration = controller.actualMaxDuration;
    } else {
      newDuration = (_initialRange!.duration * (1 / rawScale))
          .coerceIn(controller.actualMinDuration, controller.actualMaxDuration);
    }

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
        Tween(begin: _outerOffset, end: frictionSimulation.finalX).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.decelerate),
    );
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

    final controller = _controller!;
    final offsetFromStartTime =
        controller.maxRange.duration * (_animation!.value / _outerChildHeight);
    _setNewTimeRange(
      controller.maxRange.startTime + offsetFromStartTime,
      controller.value.duration,
    );
  }

  Duration _getFocusTime(double focalPoint) {
    final range = _controller!.value;
    return range.startTime + _focusToDuration(focalPoint, range.duration);
  }

  Duration _focusToDuration(
    double focalPoint,
    Duration visibleDuration,
  ) =>
      visibleDuration * (focalPoint / _parentHeight);
  void _setNewTimeRange(Duration startTime, Duration duration) {
    final actualStartTime = startTime.coerceIn(
      _controller!.maxRange.startTime,
      _controller!.maxRange.endTime - duration,
    );
    _controller!.value =
        TimeRange.fromStartAndDuration(actualStartTime, duration);
  }
}

// SingleChildScrollView

/// A modified [SingleChildScrollView] that doesn't allow drags from a pointer.
///
/// Necessary because we handle drags ourselves to also detect zoom gestures.
class _NoDragSingleChildScrollView extends SingleChildScrollView {
  /// Creates a box in which a single widget can be scrolled.
  const _NoDragSingleChildScrollView({super.controller, super.child})
      : super(primary: false);

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
    super.axisDirection = AxisDirection.down,
    super.controller,
    super.physics,
    required super.viewportBuilder,
    super.dragStartBehavior = DragStartBehavior.start,
    super.restorationId,
  });

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
    required this.height,
    required this.offset,
    super.child,
  });

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

// ScaleGestureRecognizer

// Copied and modified from https://github.com/flutter/flutter/blob/f4abaa0735eba4dfd8f33f73363911d63931fe03/packages/flutter/lib/src/gestures/scale.dart
class _ScaleGestureRecognizer extends OneSequenceGestureRecognizer {
  _ScaleGestureRecognizer({
    super.debugOwner,
    // ignore: unused_element_parameter
    this.dragStartBehavior = DragStartBehavior.down,
  });

  DragStartBehavior dragStartBehavior;
  GestureScaleStartCallback? onStart;
  GestureScaleUpdateCallback? onUpdate;
  GestureScaleEndCallback? onEnd;

  _ScaleState _state = _ScaleState.ready;

  Matrix4? _lastTransform;

  late Offset _initialFocalPoint;
  late Offset _currentFocalPoint;
  late double _initialSpan;
  late double _currentSpan;
  late double _initialHorizontalSpan;
  late double _currentHorizontalSpan;
  late double _initialVerticalSpan;
  late double _currentVerticalSpan;
  _LineBetweenPointers? _initialLine;
  _LineBetweenPointers? _currentLine;
  late Map<int, Offset> _pointerLocations;
  late List<int> _pointerQueue; // A queue to sort pointers in order of entrance
  final Map<int, VelocityTracker> _velocityTrackers = <int, VelocityTracker>{};

  double get _scaleFactor => _initialSpan > 0 ? _currentSpan / _initialSpan : 1;
  double get _horizontalScaleFactor => _initialHorizontalSpan > 0
      ? _currentHorizontalSpan / _initialHorizontalSpan
      : 1;
  double get _verticalScaleFactor => _initialVerticalSpan > 0
      ? _currentVerticalSpan / _initialVerticalSpan
      : 1;

  double _computeRotationFactor() {
    if (_initialLine == null || _currentLine == null) return 0;

    final fx = _initialLine!.pointerStartLocation.dx;
    final fy = _initialLine!.pointerStartLocation.dy;
    final sx = _initialLine!.pointerEndLocation.dx;
    final sy = _initialLine!.pointerEndLocation.dy;

    final nfx = _currentLine!.pointerStartLocation.dx;
    final nfy = _currentLine!.pointerStartLocation.dy;
    final nsx = _currentLine!.pointerEndLocation.dx;
    final nsy = _currentLine!.pointerEndLocation.dy;

    final angle1 = math.atan2(fy - sy, fx - sx);
    final angle2 = math.atan2(nfy - nsy, nfx - nsx);
    return angle2 - angle1;
  }

  @override
  void addAllowedPointer(PointerEvent event) {
    startTrackingPointer(event.pointer, event.transform);
    _velocityTrackers[event.pointer] = VelocityTracker.withKind(event.kind);
    if (_state == _ScaleState.ready) {
      _state = _ScaleState.possible;
      _initialSpan = 0.0;
      _currentSpan = 0.0;
      _initialHorizontalSpan = 0.0;
      _currentHorizontalSpan = 0.0;
      _initialVerticalSpan = 0.0;
      _currentVerticalSpan = 0.0;
      _pointerLocations = {};
      _pointerQueue = [];
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    assert(_state != _ScaleState.ready);
    var didChangeConfiguration = false;
    var shouldStartIfAccepted = false;
    if (event is PointerMoveEvent) {
      final tracker = _velocityTrackers[event.pointer]!;
      if (!event.synthesized) {
        tracker.addPosition(event.timeStamp, event.position);
      }
      _pointerLocations[event.pointer] = event.position;
      shouldStartIfAccepted = true;
      _lastTransform = event.transform;
    } else if (event is PointerDownEvent) {
      _pointerLocations[event.pointer] = event.position;
      _pointerQueue.add(event.pointer);
      didChangeConfiguration = true;
      shouldStartIfAccepted = true;
      _lastTransform = event.transform;
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _pointerLocations.remove(event.pointer);
      _pointerQueue.remove(event.pointer);
      didChangeConfiguration = true;
      _lastTransform = event.transform;
    }

    _updateLines();
    _update();

    if (!didChangeConfiguration || _reconfigure(event.pointer)) {
      _advanceStateMachine(shouldStartIfAccepted, event.kind);
    }
    stopTrackingIfPointerNoLongerDown(event);
  }

  void _update() {
    final count = _pointerLocations.keys.length;

    // Compute the focal point
    var focalPoint = Offset.zero;
    for (final pointer in _pointerLocations.keys) {
      focalPoint += _pointerLocations[pointer]!;
    }
    _currentFocalPoint =
        count > 0 ? focalPoint / count.toDouble() : Offset.zero;

    // Span is the average deviation from focal point. Horizontal and vertical
    // spans are the average deviations from the focal point's horizontal and
    // vertical coordinates, respectively.
    var totalDeviation = 0.0;
    var totalHorizontalDeviation = 0.0;
    var totalVerticalDeviation = 0.0;
    for (final pointer in _pointerLocations.keys) {
      totalDeviation +=
          (_currentFocalPoint - _pointerLocations[pointer]!).distance;
      totalHorizontalDeviation +=
          (_currentFocalPoint.dx - _pointerLocations[pointer]!.dx).abs();
      totalVerticalDeviation +=
          (_currentFocalPoint.dy - _pointerLocations[pointer]!.dy).abs();
    }
    _currentSpan = count > 0 ? totalDeviation / count : 0.0;
    _currentHorizontalSpan = count > 0 ? totalHorizontalDeviation / count : 0.0;
    _currentVerticalSpan = count > 0 ? totalVerticalDeviation / count : 0.0;
  }

  void _updateLines() {
    final count = _pointerLocations.keys.length;
    assert(_pointerQueue.length >= count);

    /// In case of just one pointer registered, reconfigure [_initialLine]
    if (count < 2) {
      _initialLine = _currentLine;
    } else if (_initialLine != null &&
        _initialLine!.pointerStartId == _pointerQueue.first &&
        _initialLine!.pointerEndId == _pointerQueue.second) {
      /// Rotation updated, set the [_currentLine]
      _currentLine = _LineBetweenPointers(
        pointerStartId: _pointerQueue.first,
        pointerStartLocation: _pointerLocations[_pointerQueue.first]!,
        pointerEndId: _pointerQueue.second,
        pointerEndLocation: _pointerLocations[_pointerQueue.second]!,
      );
    } else {
      /// A new rotation process is on the way, set the [_initialLine]
      _initialLine = _LineBetweenPointers(
        pointerStartId: _pointerQueue.first,
        pointerStartLocation: _pointerLocations[_pointerQueue.first]!,
        pointerEndId: _pointerQueue.second,
        pointerEndLocation: _pointerLocations[_pointerQueue.second]!,
      );
      _currentLine = null;
    }
  }

  bool _reconfigure(int pointer) {
    _initialFocalPoint = _currentFocalPoint;
    _initialSpan = _currentSpan;
    _initialLine = _currentLine;
    _initialHorizontalSpan = _currentHorizontalSpan;
    _initialVerticalSpan = _currentVerticalSpan;
    if (_state == _ScaleState.started) {
      if (onEnd != null) {
        final tracker = _velocityTrackers[pointer]!;

        var velocity = tracker.getVelocity();
        if (_isFlingGesture(velocity)) {
          final pixelsPerSecond = velocity.pixelsPerSecond;
          if (pixelsPerSecond.distanceSquared >
              kMaxFlingVelocity * kMaxFlingVelocity) {
            velocity = Velocity(
              pixelsPerSecond: (pixelsPerSecond / pixelsPerSecond.distance) *
                  kMaxFlingVelocity,
            );
          }
          invokeCallback(
            'onEnd',
            () => onEnd!(
              ScaleEndDetails(
                velocity: velocity,
                pointerCount: _pointerQueue.length,
              ),
            ),
          );
        } else {
          invokeCallback(
            'onEnd',
            () => onEnd!(ScaleEndDetails(pointerCount: _pointerQueue.length)),
          );
        }
      }
      _state = _ScaleState.accepted;
      return false;
    }
    return true;
  }

  void _advanceStateMachine(
    bool shouldStartIfAccepted,
    PointerDeviceKind pointerDeviceKind,
  ) {
    if (_state == _ScaleState.ready) _state = _ScaleState.possible;

    if (_state == _ScaleState.possible) {
      final spanDelta = (_currentSpan - _initialSpan).abs();
      final focalPointDelta =
          (_currentFocalPoint - _initialFocalPoint).distance;

      // Change: We use the hit slop instead of the pan slop to allow scrolling
      // even inside a scrollable parent.
      if (spanDelta > computeScaleSlop(pointerDeviceKind) ||
          focalPointDelta >
              computeHitSlop(pointerDeviceKind, gestureSettings)) {
        resolve(GestureDisposition.accepted);
      }
    } else if (_state.index >= _ScaleState.accepted.index) {
      resolve(GestureDisposition.accepted);
    }

    if (_state == _ScaleState.accepted && shouldStartIfAccepted) {
      _state = _ScaleState.started;
      _dispatchOnStartCallbackIfNeeded();
    }

    if (_state == _ScaleState.started && onUpdate != null) {
      invokeCallback('onUpdate', () {
        onUpdate!(
          ScaleUpdateDetails(
            scale: _scaleFactor,
            horizontalScale: _horizontalScaleFactor,
            verticalScale: _verticalScaleFactor,
            focalPoint: _currentFocalPoint,
            localFocalPoint: PointerEvent.transformPosition(
              _lastTransform,
              _currentFocalPoint,
            ),
            rotation: _computeRotationFactor(),
            pointerCount: _pointerQueue.length,
          ),
        );
      });
    }
  }

  void _dispatchOnStartCallbackIfNeeded() {
    assert(_state == _ScaleState.started);
    if (onStart != null) {
      invokeCallback('onStart', () {
        onStart!(
          ScaleStartDetails(
            focalPoint: _currentFocalPoint,
            localFocalPoint: PointerEvent.transformPosition(
              _lastTransform,
              _currentFocalPoint,
            ),
            pointerCount: _pointerQueue.length,
          ),
        );
      });
    }
  }

  @override
  void acceptGesture(int pointer) {
    if (_state == _ScaleState.possible) {
      _state = _ScaleState.started;
      _dispatchOnStartCallbackIfNeeded();
      if (dragStartBehavior == DragStartBehavior.start) {
        _initialFocalPoint = _currentFocalPoint;
        _initialSpan = _currentSpan;
        _initialLine = _currentLine;
        _initialHorizontalSpan = _currentHorizontalSpan;
        _initialVerticalSpan = _currentVerticalSpan;
      }
    }
  }

  @override
  void rejectGesture(int pointer) {
    stopTrackingPointer(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    switch (_state) {
      case _ScaleState.possible:
        resolve(GestureDisposition.rejected);
      case _ScaleState.ready:
        assert(false); // We should have not seen a pointer yet
      case _ScaleState.accepted:
        break;
      case _ScaleState.started:
        assert(false); // We should be in the accepted state when user is done
    }
    _state = _ScaleState.ready;
  }

  @override
  void dispose() {
    _velocityTrackers.clear();
    super.dispose();
  }

  @override
  String get debugDescription => 'scale';
}

enum _ScaleState { ready, possible, accepted, started }

bool _isFlingGesture(Velocity velocity) {
  final speedSquared = velocity.pixelsPerSecond.distanceSquared;
  return speedSquared > kMinFlingVelocity * kMinFlingVelocity;
}

class _LineBetweenPointers {
  _LineBetweenPointers({
    this.pointerStartLocation = Offset.zero,
    this.pointerStartId = 0,
    this.pointerEndLocation = Offset.zero,
    this.pointerEndId = 1,
  }) : assert(pointerStartId != pointerEndId);

  // The location and the id of the pointer that marks the start of the line.
  final Offset pointerStartLocation;
  final int pointerStartId;

  // The location and the id of the pointer that marks the end of the line.
  final Offset pointerEndLocation;
  final int pointerEndId;
}

// ScrollController

/// Instead of storing the offset itself, or recalculating the position when the
/// parent size changes, this class (and its `_ScrollPositionWithSingleContext`)
/// retrieve the appropriate offset using `getOffset`, which calculates it from
/// the `TimeController`.
class _ScrollController extends ScrollController {
  _ScrollController({required this.getOffset, required this.setOffset})
      : super(initialScrollOffset: getOffset());

  final ValueGetter<double> getOffset;
  final ValueSetter<double> setOffset;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _ScrollPositionWithSingleContext(
      physics: physics,
      context: context,
      getOffset: getOffset,
      setOffset: setOffset,
      oldPosition: oldPosition,
    );
  }

  void jumpToInternal(double value) {
    assert(
      positions.isNotEmpty,
      '$runtimeType it not attached to any scroll views.',
    );
    for (final position in List.of(positions)) {
      (position as _ScrollPositionWithSingleContext).jumpToInternal(value);
    }
  }
}

class _ScrollPositionWithSingleContext extends ScrollPositionWithSingleContext {
  _ScrollPositionWithSingleContext({
    required super.physics,
    required super.context,
    required this.getOffset,
    required this.setOffset,
    super.oldPosition,
  }) : super(keepScrollOffset: false) {
    correctPixels(getOffset());
  }

  final ValueGetter<double> getOffset;
  final ValueSetter<double> setOffset;

  @override
  void applyNewDimensions() {
    super.applyNewDimensions();
    correctPixels(getOffset());
  }

  @override
  void goBallistic(double velocity) {
    assert(velocity == 0);
    return;
  }

  @override
  Future<void> animateTo(
    double to, {
    required Duration duration,
    required Curve curve,
  }) {
    throw UnsupportedError(
      "TimeZoom's `_ScrollPositionWithSingleContext` doesn't support "
      '`animateTo`.',
    );
  }

  @override
  void pointerScroll(double delta) =>
      setOffset((pixels + delta).clamp(minScrollExtent, maxScrollExtent));

  @override
  void jumpTo(double value, {bool isInternalCall = false}) {
    // This method was not called by us, but, e.g., by a [Scrollbar].
    setOffset(value);
  }

  void jumpToInternal(double value) => super.jumpTo(value);

  @override
  void jumpToWithoutSettling(double value) {
    throw UnsupportedError(
      "TimeZoom's `_ScrollPositionWithSingleContext` doesn't support "
      '`jumpToWithoutSettling`.',
    );
  }

  @override
  ScrollHoldController hold(VoidCallback holdCancelCallback) {
    throw UnsupportedError(
      "TimeZoom's `_ScrollPositionWithSingleContext` doesn't support `hold`.",
    );
  }

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    throw UnsupportedError(
      "TimeZoom's `_ScrollPositionWithSingleContext` doesn't support `drag`.",
    );
  }
}
