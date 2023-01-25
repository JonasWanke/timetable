import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../utils.dart';
import 'event.dart';

typedef AllDayEventBuilder<E extends Event> = Widget Function(
  BuildContext context,
  E event,
  AllDayEventLayoutInfo info,
);

/// Information about how an all-day event was laid out.
@immutable
class AllDayEventLayoutInfo {
  const AllDayEventLayoutInfo({
    required this.hiddenStartDays,
    required this.hiddenEndDays,
  })  : assert(hiddenStartDays >= 0),
        assert(hiddenEndDays >= 0);

  /// How many days of this event are hidden before the viewport starts.
  final double hiddenStartDays;

  /// How many days of this event are hidden after the viewport ends.
  final double hiddenEndDays;

  @override
  int get hashCode => Object.hash(hiddenStartDays, hiddenEndDays);
  @override
  bool operator ==(dynamic other) {
    return other is AllDayEventLayoutInfo &&
        hiddenStartDays == other.hiddenStartDays &&
        hiddenEndDays == other.hiddenEndDays;
  }
}

class AllDayEventBackgroundPainter extends CustomPainter {
  AllDayEventBackgroundPainter({
    required this.info,
    required this.color,
    required this.radii,
  }) : _paint = Paint()..color = color;

  final AllDayEventLayoutInfo info;
  final Color color;
  final AllDayEventBorderRadii radii;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawPath(radii.getPath(size, info), _paint);

  @override
  bool shouldRepaint(covariant AllDayEventBackgroundPainter oldDelegate) {
    return info != oldDelegate.info ||
        color != oldDelegate.color ||
        radii != oldDelegate.radii;
  }
}

/// A modified [RoundedRectangleBorder] that morphs to triangular left and/or
/// right borders if not all of the event is currently visible.
class AllDayEventBorder extends ShapeBorder {
  const AllDayEventBorder({
    required this.info,
    this.side = BorderSide.none,
    required this.radii,
  });

  final AllDayEventLayoutInfo info;
  final BorderSide side;
  final AllDayEventBorderRadii radii;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  ShapeBorder scale(double t) {
    return AllDayEventBorder(
      info: info,
      side: side.scale(t),
      radii: AllDayEventBorderRadii(
        cornerRadius: radii.cornerRadius * t,
        leftTipRadius: radii.leftTipRadius * t,
        rightTipRadius: radii.rightTipRadius * t,
      ),
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return radii
        .getPath(rect.deflate(side.width).size, info)
        .shift(Offset(side.width, side.width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      radii.getPath(rect.size, info);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    // For some reason, when we paint the background in this shape directly, it
    // lags while scrolling. Hence, we only use it to provide the outer path
    // used for clipping.
  }

  @override
  int get hashCode => Object.hash(info, side, radii);
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is AllDayEventBorder &&
        other.info == info &&
        other.side == side &&
        other.radii == radii;
  }

  @override
  String toString() =>
      '${objectRuntimeType(this, 'AllDayEventBorder')}($side, $radii)';
}

@immutable
class AllDayEventBorderRadii {
  const AllDayEventBorderRadii({
    required this.cornerRadius,
    required this.leftTipRadius,
    required this.rightTipRadius,
  });

  final BorderRadius cornerRadius;
  final double leftTipRadius;
  final double rightTipRadius;

  Path getPath(Size size, AllDayEventLayoutInfo info) {
    final maxTipWidth = size.height / 4;
    final leftTipWidth = info.hiddenStartDays.coerceAtMost(1) * maxTipWidth;
    final rightTipWidth = info.hiddenEndDays.coerceAtMost(1) * maxTipWidth;

    final maximumRadius = size.height / 2;
    final radii = AllDayEventBorderRadii(
      cornerRadius: BorderRadius.only(
        topLeft: Radius.elliptical(
          cornerRadius.topLeft.x,
          cornerRadius.topLeft.y.coerceAtMost(maximumRadius),
        ),
        bottomLeft: Radius.elliptical(
          cornerRadius.bottomLeft.x,
          cornerRadius.bottomLeft.y.coerceAtMost(maximumRadius),
        ),
        topRight: Radius.elliptical(
          cornerRadius.topRight.x,
          cornerRadius.topRight.y.coerceAtMost(maximumRadius),
        ),
        bottomRight: Radius.elliptical(
          cornerRadius.bottomRight.x,
          cornerRadius.bottomRight.y.coerceAtMost(maximumRadius),
        ),
      ),
      leftTipRadius: leftTipRadius.coerceAtMost(maximumRadius),
      rightTipRadius: rightTipRadius.coerceAtMost(maximumRadius),
    );

    final minWidth = radii.leftTipRadius +
        leftTipWidth +
        radii.rightTipRadius +
        rightTipWidth +
        math.min(
          radii.cornerRadius.topLeft.x + radii.cornerRadius.topRight.x,
          radii.cornerRadius.bottomLeft.x + radii.cornerRadius.bottomRight.x,
        );

    // ignore: omit_local_variable_types
    final double left =
        info.hiddenStartDays == 0 ? 0 : math.min(0, size.width - minWidth);
    // ignore: omit_local_variable_types
    final double right =
        info.hiddenEndDays == 0 ? size.width : math.max(size.width, minWidth);

    // no tip:   0      ≈  0°
    // full tip: PI / 4 ≈ 45°
    final leftTipAngle =
        math.pi / 2 - math.atan2(size.height / 2, leftTipWidth);
    final rightTipAngle =
        math.pi / 2 - math.atan2(size.height / 2, rightTipWidth);

    Size toSize(Radius radius) => Size(radius.x, radius.y) * 2;

    final topLeftTipBase = left + leftTipWidth + radii.cornerRadius.topLeft.x;

    return Path()
      ..moveTo(topLeftTipBase, 0)
      // Right top
      ..arcTo(
        Offset(right - rightTipWidth - radii.cornerRadius.topRight.x * 2, 0) &
            toSize(radii.cornerRadius.topRight),
        math.pi * 3 / 2,
        math.pi / 2 - rightTipAngle,
        false,
      )
      // Right tip
      ..arcTo(
        Offset(
              right - radii.rightTipRadius * 2,
              size.height / 2 - radii.rightTipRadius,
            ) &
            Size.square(radii.rightTipRadius * 2),
        -rightTipAngle,
        rightTipAngle * 2,
        false,
      )
      // Right bottom
      ..arcTo(
        Offset(
              right - rightTipWidth - radii.cornerRadius.bottomRight.x * 2,
              size.height - radii.cornerRadius.bottomRight.y * 2,
            ) &
            toSize(radii.cornerRadius.bottomRight),
        rightTipAngle,
        math.pi / 2 - rightTipAngle,
        false,
      )
      // Left bottom
      ..arcTo(
        Offset(
              left + leftTipWidth,
              size.height - radii.cornerRadius.bottomLeft.y * 2,
            ) &
            toSize(radii.cornerRadius.bottomLeft),
        math.pi / 2,
        math.pi / 2 - leftTipAngle,
        false,
      )
      // Left tip
      ..arcTo(
        Offset(left, size.height / 2 - radii.leftTipRadius) &
            Size.square(radii.leftTipRadius * 2),
        math.pi - leftTipAngle,
        leftTipAngle * 2,
        false,
      )
      // Left top
      ..arcTo(
        Offset(topLeftTipBase - radii.cornerRadius.topLeft.x, 0) &
            toSize(radii.cornerRadius.topLeft),
        math.pi + leftTipAngle,
        math.pi / 2 - leftTipAngle,
        false,
      );
  }

  @override
  int get hashCode => Object.hash(cornerRadius, leftTipRadius, rightTipRadius);
  @override
  bool operator ==(Object other) {
    return other is AllDayEventBorderRadii &&
        cornerRadius == other.cornerRadius &&
        leftTipRadius == other.leftTipRadius &&
        rightTipRadius == other.rightTipRadius;
  }
}
