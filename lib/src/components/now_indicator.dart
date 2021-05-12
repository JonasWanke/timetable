import 'dart:ui';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

import '../date/controller.dart';
import '../styling.dart';
import '../utils.dart';

class NowIndicator extends StatefulWidget {
  const NowIndicator({
    Key? key,
    this.style,
    this.child,
  }) : super(key: key);

  final NowIndicatorStyle? style;
  final Widget? child;

  @override
  _NowIndicatorState createState() => _NowIndicatorState();
}

class _NowIndicatorState extends State<NowIndicator> {
  // TODO(JonasWanke): Vary this depending on the widget size.
  final _timeListenable =
      StreamChangeNotifier(Stream<void>.periodic(10.seconds));

  @override
  void dispose() {
    _timeListenable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NowIndicatorPainter(
        controller: DefaultDateController.of(context)!,
        style: widget.style ?? TimetableTheme.of(context)!.nowIndicatorStyle,
        repaint: _timeListenable,
      ),
      child: widget.child,
    );
  }
}

/// Defines visual properties for [NowIndicator].
@immutable
class NowIndicatorStyle {
  factory NowIndicatorStyle(
    BuildContext context, {
    NowIndicatorShape? shape,
    Color? lineColor,
    double? lineWidth,
  }) {
    final defaultColor = context.theme.colorScheme.onBackground;
    return NowIndicatorStyle.raw(
      shape: shape ?? CircleNowIndicatorShape(color: defaultColor),
      lineColor: lineColor ?? defaultColor,
      lineWidth: lineWidth ?? 1,
    );
  }

  const NowIndicatorStyle.raw({
    required this.shape,
    required this.lineColor,
    required this.lineWidth,
  }) : assert(lineWidth >= 0);

  final NowIndicatorShape shape;
  final Color lineColor;
  final double lineWidth;

  @override
  int get hashCode => hashValues(shape, lineColor, lineWidth);
  @override
  bool operator ==(Object other) {
    return other is NowIndicatorStyle &&
        shape == other.shape &&
        lineColor == other.lineColor &&
        lineWidth == other.lineWidth;
  }
}

// Shapes

@immutable
abstract class NowIndicatorShape {
  const NowIndicatorShape();

  void paint(
    Canvas canvas,
    Size size,
    double dateStartOffset,
    double dateEndOffset,
    double timeOffset,
  );

  double interpolateSizeBasedOnVisibility(
    double value,
    Size size,
    double dateStartOffset,
    double dateEndOffset,
  ) {
    final dateWidth = dateEndOffset - dateStartOffset;
    if (dateEndOffset < dateWidth) {
      return lerpDouble(0, value, dateEndOffset / dateWidth)!;
    } else if (dateStartOffset > size.width - dateWidth) {
      return lerpDouble(0, value, (size.width - dateStartOffset) / dateWidth)!;
    } else {
      return value;
    }
  }

  @override
  int get hashCode;
  @override
  bool operator ==(Object other);
}

class CircleNowIndicatorShape extends NowIndicatorShape {
  CircleNowIndicatorShape({required this.color, this.radius = 4})
      : _paint = Paint()..color = color;

  final Color color;
  final double radius;
  final Paint _paint;

  @override
  void paint(
    Canvas canvas,
    Size size,
    double dateStartOffset,
    double dateEndOffset,
    double timeOffset,
  ) {
    canvas.drawCircle(
      Offset(dateStartOffset.coerceAtLeast(0), timeOffset),
      interpolateSizeBasedOnVisibility(
        radius,
        size,
        dateStartOffset,
        dateEndOffset,
      ),
      _paint,
    );
  }

  @override
  int get hashCode => hashValues(color, radius);
  @override
  bool operator ==(Object other) {
    return other is CircleNowIndicatorShape &&
        color == other.color &&
        radius == other.radius;
  }
}

class TriangleNowIndicatorShape extends NowIndicatorShape {
  TriangleNowIndicatorShape({required this.color, this.size = 8})
      : _paint = Paint()..color = color;

  final Color color;
  final double size;
  final Paint _paint;

  @override
  void paint(
    Canvas canvas,
    Size size,
    double dateStartOffset,
    double dateEndOffset,
    double timeOffset,
  ) {
    final actualSize = interpolateSizeBasedOnVisibility(
      this.size,
      size,
      dateStartOffset,
      dateEndOffset,
    );
    final left = dateStartOffset.coerceAtLeast(0);
    canvas.drawPath(
      Path()
        ..moveTo(left, timeOffset - actualSize / 2)
        ..lineTo(left + actualSize, timeOffset)
        ..lineTo(left, timeOffset + actualSize / 2)
        ..close(),
      _paint,
    );
  }

  @override
  int get hashCode => hashValues(color, size);
  @override
  bool operator ==(Object other) {
    return other is TriangleNowIndicatorShape &&
        color == other.color &&
        size == other.size;
  }
}

// Painter

class _NowIndicatorPainter extends CustomPainter {
  _NowIndicatorPainter({
    required this.controller,
    required this.style,
    required Listenable repaint,
  })   : _paint = Paint()
          ..color = style.lineColor
          ..strokeWidth = style.lineWidth,
        super(repaint: Listenable.merge([controller, repaint]));

  final DateController controller;
  final Paint _paint;
  final NowIndicatorStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final pageValue = controller.value;
    final dateWidth = size.width / pageValue.visibleDayCount;
    final now = DateTime.now();
    final temporalXOffset = now.toUtc().atStartOfDay.page - pageValue.page;
    final left = temporalXOffset * dateWidth;
    final right = left + dateWidth;

    // The current date isn't visible so we don't have to paint anything.
    if (right < 0 || left > size.width) return;

    final actualLeft = left.coerceAtLeast(0);
    final actualRight = right.coerceAtMost(size.width);

    final y = now.timeOfDay / 1.days * size.height;
    canvas.drawLine(Offset(actualLeft, y), Offset(actualRight, y), _paint);
    style.shape.paint(canvas, size, left, right, y);
  }

  @override
  bool shouldRepaint(_NowIndicatorPainter oldDelegate) =>
      style != oldDelegate.style;
}
