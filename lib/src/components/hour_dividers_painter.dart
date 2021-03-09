import 'package:flutter/widgets.dart';

import '../utils.dart';

class HourDividersPainter extends CustomPainter {
  HourDividersPainter({
    required Color dividerColor,
  }) : dividerPaint = Paint()..color = dividerColor;

  final Paint dividerPaint;

  @override
  void paint(Canvas canvas, Size size) {
    final heightPerHour = size.height / Duration.hoursPerDay;
    for (final h in DateTimeTimetable.innerDateHours) {
      final y = h * heightPerHour;
      canvas.drawLine(Offset(-8, y), Offset(size.width, y), dividerPaint);
    }
  }

  @override
  bool shouldRepaint(HourDividersPainter oldDelegate) =>
      dividerPaint.color != oldDelegate.dividerPaint.color;
}
