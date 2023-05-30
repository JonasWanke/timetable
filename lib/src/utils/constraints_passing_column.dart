import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A simplified version of [Column] that passes height constraints on to its
/// children.
///
/// The first child has the full height available, and each subsequent child can
/// only use up to how much vertical space is left.
///
/// Otherwise, it behaves like a [Column] with these properties:
///
/// * `mainAxisAlignment = MainAxisAlignment.start`
/// * `mainAxisSize = MainAxisSize.min`
/// * `crossAxisAlignment = CrossAxisAlignment.start`
class ConstraintsPassingColumn extends MultiChildRenderObjectWidget {
  const ConstraintsPassingColumn({required super.children});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _ConstraintsPassingColumnRenderObject();
}

class _ConstraintsPassingColumnParentData
    extends ContainerBoxParentData<RenderBox> {}

class _ConstraintsPassingColumnRenderObject extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox,
            _ConstraintsPassingColumnParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox,
            _ConstraintsPassingColumnParentData> {
  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _ConstraintsPassingColumnParentData) {
      child.parentData = _ConstraintsPassingColumnParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      children.map((it) => it.getMinIntrinsicWidth(height)).maxOrNull ?? 0;
  @override
  double computeMaxIntrinsicWidth(double height) =>
      children.map((it) => it.getMaxIntrinsicWidth(height)).maxOrNull ?? 0;
  @override
  double computeMinIntrinsicHeight(double width) =>
      children.map((it) => it.getMinIntrinsicHeight(width)).sum.toDouble();
  @override
  double computeMaxIntrinsicHeight(double width) =>
      children.map((it) => it.getMaxIntrinsicHeight(width)).sum.toDouble();

  @override
  void performLayout() {
    assert(!sizedByParent);

    if (children.isEmpty) {
      size = Size(0, constraints.maxHeight);
      return;
    }

    var currentHeight = 0.0;
    for (final child in children) {
      final childConstraints = BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
        maxHeight: constraints.maxHeight - currentHeight,
      );
      child.layout(childConstraints, parentUsesSize: true);

      final parentData =
          child.parentData! as _ConstraintsPassingColumnParentData;
      parentData.offset = Offset(0, currentHeight);

      currentHeight += child.size.height;
    }

    size = Size(constraints.maxWidth, currentHeight);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
}
