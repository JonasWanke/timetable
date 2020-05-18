import 'dart:math' as math;

import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

/// Information about how an all-day event was laid out.
@immutable
class AllDayEventLayoutInfo {
  const AllDayEventLayoutInfo({
    @required this.hiddenStartDays,
    @required this.hiddenEndDays,
  })  : assert(hiddenStartDays != null),
        assert(hiddenStartDays >= 0),
        assert(hiddenEndDays != null),
        assert(hiddenEndDays >= 0);

  final double hiddenStartDays;
  final double hiddenEndDays;

  @override
  bool operator ==(dynamic other) {
    return other is AllDayEventLayoutInfo &&
        hiddenStartDays == other.hiddenStartDays &&
        hiddenEndDays == other.hiddenEndDays;
  }

  @override
  int get hashCode => hashList([hiddenStartDays, hiddenEndDays]);
}

class AllDayEventBackgroundPainter extends CustomPainter {
  const AllDayEventBackgroundPainter({
    @required this.info,
    @required this.color,
    this.borderRadius = 0,
  })  : assert(info != null),
        assert(color != null),
        assert(borderRadius != null);

  final AllDayEventLayoutInfo info;
  final Color color;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _getPath(size, info, borderRadius),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant AllDayEventBackgroundPainter oldDelegate) {
    return info != oldDelegate.info ||
        color != oldDelegate.color ||
        borderRadius != oldDelegate.borderRadius;
  }
}

/// A modified [RoundedRectangleBorder] that morphs to triangular left and/or
/// right borders if not all of the event is currently visible.
class AllDayEventBorder extends ShapeBorder {
  const AllDayEventBorder({
    @required this.info,
    this.side = BorderSide.none,
    this.borderRadius = 0,
  })  : assert(info != null),
        assert(side != null),
        assert(borderRadius != null);

  final AllDayEventLayoutInfo info;
  final BorderSide side;
  final double borderRadius;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  ShapeBorder scale(double t) {
    return AllDayEventBorder(
      info: info,
      side: side.scale(t),
      borderRadius: borderRadius * t,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return null;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    return _getPath(rect.size, info, borderRadius);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    // For some reason, when we paint the background in this shape directly, it
    // lags while scrolling. Hence, we only use it to provide the outer path
    // used for clipping.
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is AllDayEventBorder &&
        other.info == info &&
        other.side == side &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => hashValues(info, side, borderRadius);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'RoundedRectangleBorder')}($side, $borderRadius)';
}

Path _getPath(Size size, AllDayEventLayoutInfo info, double radius) {
  final height = size.height;
  // final radius = borderRadius.coerceAtMost(width / 2);

  final maxTipWidth = height / 4;
  final leftTipWidth = info.hiddenStartDays.coerceAtMost(1) * maxTipWidth;
  final rightTipWidth = info.hiddenEndDays.coerceAtMost(1) * maxTipWidth;

  final width = size.width;
  // final leftTipBase = math.min(leftTipWidth + radius, width - radius);
  // final rightTipBase = math.max(width - rightTipWidth - radius, radius);
  final leftTipBase = info.hiddenStartDays > 0
      ? math.min(leftTipWidth + radius, width - radius)
      : leftTipWidth + radius;
  final rightTipBase = info.hiddenEndDays > 0
      ? math.max(width - rightTipWidth - radius, radius)
      : width - rightTipWidth - radius;

  final tipSize = Size.square(radius * 2);

  // no tip:   0      ≈  0°
  // full tip: PI / 4 ≈ 45°
  final leftTipAngle = math.pi / 2 - math.atan2(height / 2, leftTipWidth);
  final rightTipAngle = math.pi / 2 - math.atan2(height / 2, rightTipWidth);

  return Path()
    ..moveTo(leftTipBase, 0)
    // Right top
    ..arcTo(
      Offset(rightTipBase - radius, 0) & tipSize,
      math.pi * 3 / 2,
      math.pi / 2 - rightTipAngle,
      false,
    )
    // Right tip
    ..arcTo(
      Offset(rightTipBase + rightTipWidth - radius, height / 2 - radius) &
          tipSize,
      -rightTipAngle,
      2 * rightTipAngle,
      false,
    )
    // Right bottom
    ..arcTo(
      Offset(rightTipBase - radius, height - radius * 2) & tipSize,
      rightTipAngle,
      math.pi / 2 - rightTipAngle,
      false,
    )
    // Left bottom
    ..arcTo(
      Offset(leftTipBase - radius, height - radius * 2) & tipSize,
      math.pi / 2,
      math.pi / 2 - leftTipAngle,
      false,
    )
    // Left tip
    ..arcTo(
      Offset(leftTipBase - leftTipWidth - radius, height / 2 - radius) &
          tipSize,
      math.pi - leftTipAngle,
      2 * leftTipAngle,
      false,
    )
    // Left top
    ..arcTo(
      Offset(leftTipBase - radius, 0) & tipSize,
      math.pi + leftTipAngle,
      math.pi / 2 - leftTipAngle,
      false,
    );
}
