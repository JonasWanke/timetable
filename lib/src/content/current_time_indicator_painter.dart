import 'dart:ui';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart' hide Offset;

import '../controller.dart';
import '../event.dart';

class CurrentTimeIndicatorPainter<E extends Event> extends CustomPainter {
  CurrentTimeIndicatorPainter({
    @required this.controller,
    @required Color color,
    this.circleRadius = 4,
  })  : assert(controller != null),
        assert(color != null),
        _paint = Paint()..color = color,
        assert(circleRadius != null),
        super(repaint: controller.scrollControllers.pageListenable);

  final TimetableController<E> controller;
  final Paint _paint;
  final double circleRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final dateWidth = size.width / controller.visibleRange.visibleDays;

    final temporalOffset =
        LocalDate.today().epochDay - controller.scrollControllers.page;
    final left = temporalOffset * dateWidth;
    final right = left + dateWidth;

    if (right < 0 || left > size.width) {
      // The current date isn't visible so we don't have to paint anything.
      return;
    }

    final actualLeft = left.coerceAtLeast(0);
    final actualRight = right.coerceAtMost(size.width);

    final time = LocalTime.currentClockTime().timeSinceMidnight.inSeconds;
    final y = (time / TimeConstants.secondsPerDay) * size.height;

    final radius = lerpDouble(circleRadius, 0, (actualLeft - left) / dateWidth);
    canvas
      ..drawCircle(Offset(actualLeft, y), radius, _paint)
      ..drawLine(Offset(actualLeft, y), Offset(actualRight, y), _paint);
  }

  @override
  bool shouldRepaint(CurrentTimeIndicatorPainter oldDelegate) =>
      _paint.color != oldDelegate._paint.color ||
      circleRadius != oldDelegate.circleRadius;
}
