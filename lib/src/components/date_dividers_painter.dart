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

    final pageValue = controller.value;
    final initialOffset = 1 - pageValue.page % 1;
    for (var i = 0; i + initialOffset < pageValue.visibleDayCount; i++) {
      final x = (initialOffset + i) * size.width / pageValue.visibleDayCount;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), dividerPaint);
    }
  }

  @override
  bool shouldRepaint(DateDividersPainter oldDelegate) =>
      dividerPaint.color != oldDelegate.dividerPaint.color;
}
