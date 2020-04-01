import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart' hide Offset;
import 'package:time_machine/time_machine_text_patterns.dart';

import '../utils/utils.dart';

class DateHoursPainter extends CustomPainter {
  DateHoursPainter({
    @required this.textStyle,
    @required this.textDirection,
  })  : assert(textStyle != null),
        assert(textDirection != null),
        _painters = [
          for (final h in innerDateHours)
            TextPainter(
              text: TextSpan(
                text: _pattern.format(LocalTime(h, 0, 0)),
                style: textStyle,
              ),
              textDirection: textDirection,
              textAlign: TextAlign.right,
            ),
        ];

  static final _pattern = LocalTimePattern.createWithCurrentCulture('HH:mm');

  final TextStyle textStyle;
  final TextDirection textDirection;
  final List<TextPainter> _painters;

  double _lastWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width != _lastWidth) {
      for (final painter in _painters) {
        painter.layout(minWidth: size.width, maxWidth: size.width);
      }
      _lastWidth = size.width;
    }

    final hourHeight = size.height / TimeConstants.hoursPerDay;
    for (final h in innerDateHours) {
      final painter = _painters[h - 1];
      final y = h * hourHeight - painter.height / 2;
      painter.paint(canvas, Offset(0, y));
    }
  }

  @override
  bool shouldRepaint(DateHoursPainter oldDelegate) =>
      textStyle != oldDelegate.textStyle ||
      textDirection != oldDelegate.textDirection;
}
