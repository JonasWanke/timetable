import 'package:flutter/material.dart';

import '../config.dart';
import '../date/controller.dart';
import '../theme.dart';

/// A widget that displays vertical dividers between dates.
///
/// A [DefaultDateController] must be above in the widget tree.
///
/// See also:
///
/// * [DateDividersStyle], which defines visual properties for this widget.
/// * [TimetableTheme] (and [TimetableConfig]), which provide styles to
///   descendant Timetable widgets.
class DateDividers extends StatelessWidget {
  const DateDividers({
    super.key,
    this.style,
    this.child,
  });

  final DateDividersStyle? style;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DateDividersPainter(
        controller: DefaultDateController.of(context)!,
        style: style ?? TimetableTheme.orDefaultOf(context).dateDividersStyle,
      ),
      child: child,
    );
  }
}

/// Defines visual properties for [DateDividers].
///
/// See also:
///
/// * [TimetableThemeData], which bundles the styles for all Timetable widgets.
@immutable
class DateDividersStyle {
  factory DateDividersStyle(
    BuildContext context, {
    Color? color,
    double? width,
  }) {
    final dividerBorderSide = Divider.createBorderSide(context);
    return DateDividersStyle.raw(
      color: color ?? dividerBorderSide.color,
      width: width ?? dividerBorderSide.width,
    );
  }

  const DateDividersStyle.raw({
    required this.color,
    required this.width,
  }) : assert(width >= 0);

  final Color color;
  final double width;

  DateDividersStyle copyWith({Color? color, double? width}) {
    return DateDividersStyle.raw(
      color: color ?? this.color,
      width: width ?? this.width,
    );
  }

  @override
  int get hashCode => hashValues(color, width);
  @override
  bool operator ==(Object other) {
    return other is DateDividersStyle &&
        color == other.color &&
        width == other.width;
  }
}

class _DateDividersPainter extends CustomPainter {
  _DateDividersPainter({
    required this.controller,
    required this.style,
  })  : _paint = Paint()
          ..color = style.color
          ..strokeWidth = style.width,
        super(repaint: controller);

  final DateController controller;
  final DateDividersStyle style;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final pageValue = controller.value;
    final initialOffset = 1 - pageValue.page % 1;
    for (var i = -1; i + initialOffset < pageValue.visibleDayCount + 1; i++) {
      final x = (initialOffset + i) * size.width / pageValue.visibleDayCount;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), _paint);
    }
  }

  @override
  bool shouldRepaint(_DateDividersPainter oldDelegate) =>
      style != oldDelegate.style;
}
