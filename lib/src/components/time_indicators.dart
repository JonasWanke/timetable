import 'dart:math' as math;

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../utils.dart';
import 'time_indicator.dart';

class TimeIndicators extends StatelessWidget {
  const TimeIndicators({Key? key, required this.children}) : super(key: key);

  factory TimeIndicators.hours({
    Key? key,
    ValueGetter<DateFormat>? format,
    TextStyle? textStyle,
    AlignmentGeometry alignment = Alignment.centerRight,
  }) =>
      TimeIndicators(
        key: key,
        children: [
          for (final hour in 1.until(Duration.hoursPerDay))
            _buildChild(
              hour.hours,
              alignment,
              format ?? TimeIndicator.formatHour,
              textStyle,
            ),
        ],
      );

  factory TimeIndicators.halfHours({
    Key? key,
    ValueGetter<DateFormat>? format,
    TextStyle? textStyle,
    AlignmentGeometry alignment = Alignment.centerRight,
  }) =>
      TimeIndicators(
        key: key,
        children: [
          for (final halfHour in 1.until(Duration.hoursPerDay * 2))
            _buildChild(
              30.minutes * halfHour,
              alignment,
              format ?? TimeIndicator.formatHourMinute,
              textStyle,
            ),
        ],
      );

  static TimeIndicatorsChild _buildChild(
    Duration time,
    AlignmentGeometry alignment,
    ValueGetter<DateFormat> format,
    TextStyle? textStyle,
  ) {
    assert(time.isValidTimetableTimeOfDay);

    return TimeIndicatorsChild(
      time: time,
      alignment: alignment,
      child: TimeIndicator(time: time, format: format, textStyle: textStyle),
    );
  }

  final List<TimeIndicatorsChild> children;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: context.textTheme.caption!,
      child: _TimeIndicators(children: children),
    );
  }
}

class _TimeIndicators extends MultiChildRenderObjectWidget {
  _TimeIndicators({required List<TimeIndicatorsChild> children})
      : super(children: children);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _TimeIndicatorsLayout(textDirection: context.directionality);
}

class TimeIndicatorsChild extends ParentDataWidget<_TimeIndicatorParentData> {
  TimeIndicatorsChild({
    required this.time,
    this.alignment = Alignment.center,
    required Widget child,
  })   : assert(time.isValidTimetableTimeOfDay),
        super(key: ValueKey(time), child: child);

  final Duration time;
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
      children.map((it) => it.getMinIntrinsicWidth(height)).max() ?? 0;
  @override
  double computeMaxIntrinsicWidth(double height) =>
      children.map((it) => it.getMaxIntrinsicWidth(height)).max() ?? 0;

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
        throw Exception(
          "_TimeIndicatorsLayout doesn't have an intrinsic height.",
        );
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
      (child.parentData! as _TimeIndicatorParentData).offset =
          alignment.inscribe(child.size, outerRect).topLeft;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
}
