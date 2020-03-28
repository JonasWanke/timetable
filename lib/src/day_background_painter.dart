import 'package:flutter/widgets.dart';
import 'package:time_machine/time_machine.dart' hide Offset;

class DayBackgroundPainter extends CustomPainter {
  DayBackgroundPainter({@required Color dividerColor})
      : assert(dividerColor != null),
        dividerPaint = Paint()..color = dividerColor;

  final Paint dividerPaint;

  @override
  void paint(Canvas canvas, Size size) {
    final heightPerHour = size.height / TimeConstants.hoursPerDay;
    for (var i = 1; i < TimeConstants.hoursPerDay; i++) {
      final y = i * heightPerHour;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), dividerPaint);
    }
  }

  @override
  bool shouldRepaint(DayBackgroundPainter oldDelegate) =>
      dividerPaint.color != oldDelegate.dividerPaint.color;
}
