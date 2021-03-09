import 'dart:ui';

import 'package:flutter/material.dart';

import '../controller.dart';
import '../utils.dart';

class NowIndicatorPainter extends CustomPainter {
  NowIndicatorPainter({
    required this.controller,
    required this.visibleDayCount,
    required this.style,
    Listenable? repaint,
  })  : _paint = Paint()
          ..color = style.color
          ..strokeWidth = style.lineWidth,
        super(repaint: Listenable.merge([controller, repaint]));

  final DateController controller;
  final int visibleDayCount;
  final Paint _paint;
  final MultiDateNowIndicatorStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final dateWidth = size.width / visibleDayCount;
    final now = DateTime.now();
    final temporalXOffset = now.toUtc().atStartOfDay.page - controller.value;
    final left = temporalXOffset * dateWidth;
    final right = left + dateWidth;

    if (right < 0 || left - style.circleRadius > size.width) {
      // The current date isn't visible so we don't have to paint anything.
      return;
    }

    final actualLeft = left.coerceAtLeast(0);
    final actualRight = right.coerceAtMost(size.width);

    final timeOfDay = now.timeOfDay;
    final y = timeOfDay / 1.days * size.height;

    final radius =
        lerpDouble(style.circleRadius, 0, (actualLeft - left) / dateWidth)!;
    canvas
      ..drawCircle(Offset(actualLeft, y), radius, _paint)
      ..drawLine(
        Offset(actualLeft + radius, y),
        Offset(actualRight, y),
        _paint,
      );
  }

  @override
  bool shouldRepaint(NowIndicatorPainter oldDelegate) =>
      style != oldDelegate.style;
}

/// Defines visual properties for [NowIndicatorPainter].
class MultiDateNowIndicatorStyle {
  const MultiDateNowIndicatorStyle({
    required this.color,
    this.circleRadius = 4,
    this.lineWidth = 1,
  })  : assert(circleRadius >= 0),
        assert(lineWidth >= 0);

  final Color color;
  final double circleRadius;
  final double lineWidth;

  @override
  int get hashCode => hashList([color, circleRadius, lineWidth]);

  @override
  bool operator ==(Object other) {
    return other is MultiDateNowIndicatorStyle &&
        other.color == color &&
        other.circleRadius == circleRadius &&
        other.lineWidth == lineWidth;
  }
}
