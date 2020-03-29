import 'package:flutter/widgets.dart';
import 'package:time_machine/time_machine.dart' hide Offset;

import '../controller.dart';

class MultiDateBackgroundPainter extends CustomPainter {
  MultiDateBackgroundPainter({
    @required this.controller,
    @required Color dividerColor,
  })  : assert(controller != null),
        assert(dividerColor != null),
        dividerPaint = Paint()..color = dividerColor,
        super(repaint: controller.scrollControllers.pageListenable);

  final TimetableController controller;
  final Paint dividerPaint;

  @override
  void paint(Canvas canvas, Size size) {
    _drawDateDividers(canvas, size);
    _drawHourDividers(canvas, size);
  }

  void _drawDateDividers(Canvas canvas, Size size) {
    final initialOffset = 1 - controller.scrollControllers.page % 1;
    final dateCount = controller.visibleDays;
    final widthPerDate = size.width / dateCount;
    for (var i = 0; i + initialOffset < dateCount; i++) {
      final x = (initialOffset + i) * widthPerDate;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), dividerPaint);
    }
  }

  void _drawHourDividers(Canvas canvas, Size size) {
    final heightPerHour = size.height / TimeConstants.hoursPerDay;
    for (var i = 1; i < TimeConstants.hoursPerDay; i++) {
      final y = i * heightPerHour;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), dividerPaint);
    }
  }

  @override
  bool shouldRepaint(MultiDateBackgroundPainter oldDelegate) =>
      dividerPaint.color != oldDelegate.dividerPaint.color;
}
