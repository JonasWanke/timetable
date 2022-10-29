import 'dart:math' as math;

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme.dart';
import '../utils.dart';
import 'time_indicator.dart';

/// A widget that positions [TimeIndicator] widgets.
///
/// See also:
///
/// * [TimeIndicators.hours], which displays an indicator at every full hour.
/// * [TimeIndicators.halfHours], which displays an indicator at every half
///   hour.
/// * [TimeIndicatorsChild], which wraps children of this layout.
/// * [TimeIndicator], which is usually used inside a [TimeIndicatorsChild] to
///   display a label.
class TimeIndicators extends StatelessWidget {
  const TimeIndicators({super.key, required this.children});

  factory TimeIndicators.hours({
    Key? key,
    TimeBasedStyleProvider<TimeIndicatorStyle>? styleProvider,
    Alignment alignment = Alignment.centerRight,
    int firstHour = 1,
    int lastHour = Duration.hoursPerDay - 1,
    bool alignFirstAndLastLabelsInside = false,
  }) {
    return TimeIndicators._build(
      key: key,
      styleProvider: styleProvider,
      alignment: alignment,
      firstIndex: firstHour,
      lastIndex: lastHour,
      alignFirstAndLastLabelsInside: alignFirstAndLastLabelsInside,
      indexToTime: (it) => it.hours,
      formatter: TimeIndicator.formatHour,
    );
  }

  factory TimeIndicators.halfHours({
    Key? key,
    TimeBasedStyleProvider<TimeIndicatorStyle>? styleProvider,
    Alignment alignment = Alignment.centerRight,
    int firstHalfHour = 1,
    int lastHalfHour = Duration.hoursPerDay * 2 - 1,
    bool alignFirstAndLastLabelsInside = false,
  }) {
    return TimeIndicators._build(
      key: key,
      styleProvider: styleProvider,
      alignment: alignment,
      firstIndex: firstHalfHour,
      lastIndex: lastHalfHour,
      alignFirstAndLastLabelsInside: alignFirstAndLastLabelsInside,
      indexToTime: (it) => 30.minutes * it,
      formatter: TimeIndicator.formatHourMinute,
    );
  }

  factory TimeIndicators._build({
    required Key? key,
    required TimeBasedStyleProvider<TimeIndicatorStyle>? styleProvider,
    required Alignment alignment,
    required int firstIndex,
    required int lastIndex,
    required bool alignFirstAndLastLabelsInside,
    required Duration Function(int) indexToTime,
    required String Function(Duration time) formatter,
  }) {
    Alignment getAlignmentFor(int index) {
      if (alignFirstAndLastLabelsInside) {
        if (index == firstIndex) return Alignment(alignment.x, 1);
        if (index == lastIndex) return Alignment(alignment.x, -1);
      }
      return alignment;
    }

    return TimeIndicators(
      key: key,
      children: [
        for (final i in firstIndex.rangeTo(lastIndex))
          _buildChild(
            indexToTime(i),
            getAlignmentFor(i),
            styleProvider,
            formatter,
          ),
      ],
    );
  }

  static TimeIndicatorsChild _buildChild(
    Duration time,
    Alignment alignment,
    TimeBasedStyleProvider<TimeIndicatorStyle>? styleProvider,
    String Function(Duration time) formatter,
  ) {
    assert(time.debugCheckIsValidTimetableTimeOfDay());

    return TimeIndicatorsChild(
      time: time,
      alignment: alignment,
      child: styleProvider != null
          ? TimeIndicator(time: time, style: styleProvider(time))
          : Builder(
              builder: (context) => TimeIndicator(
                time: time,
                style: TimetableTheme.orDefaultOf(context)
                    .timeIndicatorStyleProvider(time)
                    .copyWith(label: formatter(time)),
              ),
            ),
    );
  }

  final List<TimeIndicatorsChild> children;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: context.textTheme.bodySmall!,
      child: _TimeIndicators(children: children),
    );
  }
}

class _TimeIndicators extends MultiChildRenderObjectWidget {
  _TimeIndicators({required super.children});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _TimeIndicatorsLayout(textDirection: context.directionality);
}

/// Wraps children of [TimeIndicators] and determines their position.
class TimeIndicatorsChild extends ParentDataWidget<_TimeIndicatorParentData> {
  TimeIndicatorsChild({
    required this.time,
    this.alignment = Alignment.centerRight,
    required super.child,
  })  : assert(time.debugCheckIsValidTimetableTimeOfDay()),
        super(key: ValueKey(time));

  /// The time of day that this widget positioned next to.
  final Duration time;

  /// How to align the widget to the [time].
  ///
  /// The horizontal alignment works as expected. A vertical alignment of top
  /// places the widget so it sits on top of where the corresponding time is,
  /// and a vertical alignment of bottom places it directly below that time.
  final AlignmentGeometry alignment;

  @override
  Type get debugTypicalAncestorWidgetClass => TimeIndicators;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is _TimeIndicatorParentData);
    final parentData = renderObject.parentData! as _TimeIndicatorParentData;
    if (parentData.time == time && parentData.alignment == alignment) return;

    parentData.time = time;
    parentData.alignment = alignment;
    final targetParent = renderObject.parent;
    if (targetParent is RenderObject) targetParent.markNeedsLayout();
  }
}

class _TimeIndicatorParentData extends ContainerBoxParentData<RenderBox> {
  Duration? time;
  AlignmentGeometry? alignment;
}

class _TimeIndicatorsLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _TimeIndicatorParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _TimeIndicatorParentData> {
  _TimeIndicatorsLayout({required TextDirection textDirection})
      : _textDirection = textDirection;

  TextDirection _textDirection;
  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;

    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _TimeIndicatorParentData) {
      child.parentData = _TimeIndicatorParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      children.map((it) => it.getMinIntrinsicWidth(height)).maxOrNull ?? 0;
  @override
  double computeMaxIntrinsicWidth(double height) =>
      children.map((it) => it.getMaxIntrinsicWidth(height)).maxOrNull ?? 0;

  @override
  double computeMinIntrinsicHeight(double width) {
    assert(_debugThrowIfNotCheckingIntrinsics());
    return 0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    assert(_debugThrowIfNotCheckingIntrinsics());
    return 0;
  }

  bool _debugThrowIfNotCheckingIntrinsics() {
    assert(() {
      if (!RenderObject.debugCheckingIntrinsics) {
        throw Exception("$runtimeType doesn't have an intrinsic height.");
      }
      return true;
    }());
    return true;
  }

  @override
  void performLayout() {
    assert(!sizedByParent);

    if (children.isEmpty) {
      size = Size(0, constraints.maxHeight);
      return;
    }

    var width = 0.0;
    final childConstraints = BoxConstraints.loose(constraints.biggest);
    for (final child in children) {
      child.layout(childConstraints, parentUsesSize: true);
      width = math.max(width, child.size.width);
    }

    size = Size(width, constraints.maxHeight);
    for (final child in children) {
      final data = child.parentData! as _TimeIndicatorParentData;
      final time = data.time!;
      final alignment = data.alignment!.resolve(textDirection);

      final yAnchor = time / 1.days * size.height;
      final outerRect = Rect.fromLTRB(
        0,
        yAnchor - child.size.height,
        size.width,
        yAnchor + child.size.height,
      );
      data.offset = alignment.inscribe(child.size, outerRect).topLeft;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
}
