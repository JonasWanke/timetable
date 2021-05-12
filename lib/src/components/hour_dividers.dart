import 'package:flutter/material.dart';

import '../theme.dart';
import '../utils.dart';

class HourDividers extends StatelessWidget {
  const HourDividers({
    Key? key,
    this.style,
    this.child,
  }) : super(key: key);

  final HourDividersStyle? style;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HourDividersPainter(
        style: style ?? TimetableTheme.orDefaultOf(context).hourDividersStyle,
      ),
      child: child,
    );
  }
}

/// Defines visual properties for [HourDividers].
@immutable
class HourDividersStyle {
  factory HourDividersStyle(
    BuildContext context, {
    Color? color,
    double? width,
  }) {
    final dividerBorderSide = Divider.createBorderSide(context);
    return HourDividersStyle.raw(
      color: color ?? dividerBorderSide.color,
      width: width ?? dividerBorderSide.width,
    );
  }

  const HourDividersStyle.raw({
    required this.color,
    required this.width,
  }) : assert(width >= 0);

  final Color color;
  final double width;

  @override
  int get hashCode => hashValues(color, width);
  @override
  bool operator ==(Object other) {
    return other is HourDividersStyle &&
        color == other.color &&
        width == other.width;
  }
}

class _HourDividersPainter extends CustomPainter {
  _HourDividersPainter({
    required this.style,
  }) : _paint = Paint()
          ..color = style.color
          ..strokeWidth = style.width;

  final HourDividersStyle style;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final heightPerHour = size.height / Duration.hoursPerDay;
    for (final h in DateTimeTimetable.innerDateHours) {
      final y = h * heightPerHour;
      canvas.drawLine(Offset(-8, y), Offset(size.width, y), _paint);
    }
  }

  @override
  bool shouldRepaint(_HourDividersPainter oldDelegate) =>
      style != oldDelegate.style;
}
