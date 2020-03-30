import 'package:dartx/dartx.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class VerticalZoom extends StatefulWidget {
  const VerticalZoom({
    Key key,
    this.initialScale = 1,
    @required this.child,
  })  : assert(initialScale != null),
        assert(scaleMin <= initialScale && initialScale <= scaleMax),
        assert(child != null),
        super(key: key);

  static const scaleMax = 4;
  static const scaleMin = 1;
  final double initialScale;

  final Widget child;

  @override
  _VerticalZoomState createState() => _VerticalZoomState();
}

class _VerticalZoomState extends State<VerticalZoom> {
  ScrollController _scrollController;
  double _scale;
  double _scaleUpdateReference;
  double _lastFocus;

  @override
  void initState() {
    super.initState();
    _scale = widget.initialScale;
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;

        _scrollController ??= ScrollController(
          // Center the viewport vertically.
          initialScrollOffset: (_scale - 1) / 2 * height,
        );

        return GestureDetector(
          dragStartBehavior: DragStartBehavior.down,
          onScaleStart: (details) => _onScaleStart(height, details),
          onScaleUpdate: (details) => _onScaleUpdate(height, details),
          child: SingleChildScrollView(
            // We handle scrolling manually to improve scale detection.
            physics: NeverScrollableScrollPhysics(),
            controller: _scrollController,
            child: SizedBox(
              height: _scale * height,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }

  void _onScaleStart(double height, ScaleStartDetails details) {
    _scaleUpdateReference = _scale;
    _lastFocus = _getFocus(height, details.localFocalPoint);
  }

  void _onScaleUpdate(double height, ScaleUpdateDetails details) {
    setState(() {
      _scale = (details.verticalScale * _scaleUpdateReference).coerceIn(1, 4);

      final scrollOffset =
          _lastFocus * height * _scale - details.localFocalPoint.dy;
      _scrollController.jumpTo(scrollOffset.coerceIn(0, (_scale - 1) * height));

      _lastFocus = _getFocus(height, details.localFocalPoint);
    });
  }

  double _getFocus(double height, Offset focalPoint) =>
      (_scrollController.offset + focalPoint.dy) / (height * _scale);
}
