import 'package:flutter/widgets.dart';

import '../controller.dart';
import '../event.dart';
import '../utils.dart';

class MultiDateBackgroundPainter<E extends Event> extends CustomPainter {
  MultiDateBackgroundPainter({
    required this.controller,
    required this.visibleDayCount,
    required Color dividerColor,
  })   : dividerPaint = Paint()..color = dividerColor,
        super(repaint: controller);

  final DateController controller;
  final int visibleDayCount;
  final Paint dividerPaint;

  @override
  void paint(Canvas canvas, Size size) {
    _drawDateDividers(canvas, size);
    _drawHourDividers(canvas, size);
  }

  void _drawDateDividers(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), dividerPaint);

    final initialOffset = 1 - controller.value % 1;
    final widthPerDate = size.width / visibleDayCount;
    for (var i = 0; i + initialOffset < visibleDayCount; i++) {
      final x = (initialOffset + i) * widthPerDate;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), dividerPaint);
    }
  }

  void _drawHourDividers(Canvas canvas, Size size) {
    final heightPerHour = size.height / Duration.hoursPerDay;
    for (final h in DateTimeTimetable.innerDateHours) {
      final y = h * heightPerHour;
      canvas.drawLine(Offset(-8, y), Offset(size.width, y), dividerPaint);
    }
  }

  @override
  bool shouldRepaint(MultiDateBackgroundPainter oldDelegate) =>
      dividerPaint.color != oldDelegate.dividerPaint.color;
}
