import 'package:dartx/dartx.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class InitialZoom {
  const InitialZoom();

  const factory InitialZoom.zoom(double zoom) = _FactorInitialZoom;
  const factory InitialZoom.range({
    double startFraction,
    double endFraction,
  }) = _RangeInitialZoom;

  double getZoom(double height);
  double getOffset(double height, double zoom);
}

class _FactorInitialZoom extends InitialZoom {
  const _FactorInitialZoom(this.zoom)
      : assert(zoom != null),
        assert(VerticalZoom.zoomMin <= zoom && zoom <= VerticalZoom.zoomMax);

  final double zoom;

  @override
  double getZoom(double height) => zoom;
  @override
  double getOffset(double height, double zoom) {
    // Center the viewport vertically.
    return height * (zoom - 1) / 2;
  }
}

class _RangeInitialZoom extends InitialZoom {
  const _RangeInitialZoom({
    this.startFraction = 0,
    this.endFraction = 1,
  })  : assert(startFraction != null),
        assert(0 <= startFraction),
        assert(endFraction != null),
        assert(endFraction <= 1),
        assert(startFraction < endFraction),
        assert(VerticalZoom.zoomMin <= 1 / (endFraction - startFraction) &&
            1 / (endFraction - startFraction) <= VerticalZoom.zoomMax);

  final double startFraction;
  final double endFraction;

  @override
  double getZoom(double height) => 1 / (endFraction - startFraction);

  @override
  double getOffset(double height, double zoom) => height * zoom * startFraction;
}

class VerticalZoom extends StatefulWidget {
  const VerticalZoom({
    Key key,
    this.initialZoom = const InitialZoom.zoom(1),
    @required this.child,
  })  : assert(initialZoom != null),
        assert(child != null),
        super(key: key);

  static const zoomMax = 4;
  static const zoomMin = 1;
  final InitialZoom initialZoom;

  final Widget child;

  @override
  _VerticalZoomState createState() => _VerticalZoomState();
}

class _VerticalZoomState extends State<VerticalZoom> {
  ScrollController _scrollController;
  double _zoom;
  double _zoomUpdateReference;
  double _lastFocus;

  @override
  void initState() {
    super.initState();
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

        _zoom ??= widget.initialZoom.getZoom(height);
        _scrollController ??= ScrollController(
          initialScrollOffset: widget.initialZoom.getOffset(height, _zoom),
        );

        return GestureDetector(
          dragStartBehavior: DragStartBehavior.down,
          onScaleStart: (details) => _onZoomStart(height, details),
          onScaleUpdate: (details) => _onZoomUpdate(height, details),
          child: SingleChildScrollView(
            // We handle scrolling manually to improve zoom detection.
            physics: NeverScrollableScrollPhysics(),
            controller: _scrollController,
            child: SizedBox(
              height: _zoom * height,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }

  void _onZoomStart(double height, ScaleStartDetails details) {
    _zoomUpdateReference = _zoom;
    _lastFocus = _getFocus(height, details.localFocalPoint);
  }

  void _onZoomUpdate(double height, ScaleUpdateDetails details) {
    setState(() {
      _zoom = (details.verticalScale * _zoomUpdateReference).coerceIn(1, 4);

      final scrollOffset =
          _lastFocus * height * _zoom - details.localFocalPoint.dy;
      _scrollController.jumpTo(scrollOffset.coerceIn(0, (_zoom - 1) * height));

      _lastFocus = _getFocus(height, details.localFocalPoint);
    });
  }

  double _getFocus(double height, Offset focalPoint) =>
      (_scrollController.offset + focalPoint.dy) / (height * _zoom);
}
