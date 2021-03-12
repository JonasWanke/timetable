import 'package:flutter/widgets.dart';

import '../date/controller.dart';

class DateDividersPainter extends CustomPainter {
  DateDividersPainter({
    required this.controller,
    required Color dividerColor,
  })   : dividerPaint = Paint()..color = dividerColor,
        super(repaint: controller);

  final DateController controller;
  final Paint dividerPaint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), dividerPaint);

    final initialOffset = 1 - controller.value % 1;
    final visibleDayCount = controller.visibleRange.visibleDayCount;
    final widthPerDate = size.width / visibleDayCount;
    for (var i = 0; i + initialOffset < visibleDayCount; i++) {
      final x = (initialOffset + i) * widthPerDate;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), dividerPaint);
    }
  }

  @override
  bool shouldRepaint(DateDividersPainter oldDelegate) =>
      dividerPaint.color != oldDelegate.dividerPaint.color;
}
