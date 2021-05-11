import 'package:flutter/material.dart';

import '../date/controller.dart';
import '../styling.dart';

class DateDividers extends StatelessWidget {
  const DateDividers({
    Key? key,
    this.style,
    this.child,
  }) : super(key: key);

  final DateDividersStyle? style;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? TimetableTheme.of(context)!.dateDividersStyle;

    return CustomPaint(
      painter: _DateDividersPainter(
        controller: DefaultDateController.of(context)!,
        style: style,
      ),
      child: child,
    );
  }
}

/// Defines visual properties for [DateDividers].
@immutable
class DateDividersStyle {
  factory DateDividersStyle(
    BuildContext context, {
    Color? color,
    double? strokeWidth,
  }) {
    final dividerBorderSide = Divider.createBorderSide(context);
    return DateDividersStyle.raw(
      color: color ?? dividerBorderSide.color,
      strokeWidth: strokeWidth ?? dividerBorderSide.width,
    );
  }

  const DateDividersStyle.raw({
    required this.color,
    required this.strokeWidth,
  }) : assert(strokeWidth >= 0);

  final Color color;
  final double strokeWidth;

  @override
  int get hashCode => hashValues(color, strokeWidth);
  @override
  bool operator ==(Object other) {
    return other is DateDividersStyle &&
        color == other.color &&
        strokeWidth == other.strokeWidth;
  }
}

class _DateDividersPainter extends CustomPainter {
  _DateDividersPainter({
    required this.controller,
    required DateDividersStyle style,
  })   : dividerPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = style.color
          ..strokeWidth = style.strokeWidth,
        super(repaint: controller);

  final DateController controller;
  final Paint dividerPaint;

  @override
  void paint(Canvas canvas, Size size) {
    final pageValue = controller.value;
    final initialOffset = 1 - pageValue.page % 1;
    for (var i = 0; i + initialOffset < pageValue.visibleDayCount; i++) {
      final x = (initialOffset + i) * size.width / pageValue.visibleDayCount;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), dividerPaint);
    }
  }

  @override
  bool shouldRepaint(_DateDividersPainter oldDelegate) =>
      dividerPaint.color != oldDelegate.dividerPaint.color;
}
