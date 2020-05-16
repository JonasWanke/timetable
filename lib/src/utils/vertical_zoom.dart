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

  double getZoom(double parentHeight);
  double getOffset(double parentHeight, double contentHeight);
}

class _FactorInitialZoom extends InitialZoom {
  const _FactorInitialZoom(this.zoom)
      : assert(zoom != null),
        assert(VerticalZoom.zoomMin <= zoom && zoom <= VerticalZoom.zoomMax);

  final double zoom;

  @override
  double getZoom(double parentHeight) => zoom;
  @override
  double getOffset(double parentHeight, double contentHeight) {
    // Center the viewport vertically.
    return (contentHeight - parentHeight) / 2;
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
  double getZoom(double parentHeight) => 1 / (endFraction - startFraction);

  @override
  double getOffset(double parentHeight, double contentHeight) =>
      contentHeight * startFraction;
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
  // We store height i/o zoom factor so our child stays constant when we change
  // height.
  double _contentHeight;
  double _contentHeightUpdateReference;
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

        _contentHeight ??= widget.initialZoom.getZoom(height);
        _scrollController ??= ScrollController(
          initialScrollOffset:
              widget.initialZoom.getOffset(height, _contentHeight),
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
              height: _contentHeight,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }

  void _onZoomStart(double height, ScaleStartDetails details) {
    _contentHeightUpdateReference = _contentHeight;
    _lastFocus = _getFocus(height, details.localFocalPoint);
  }

  void _onZoomUpdate(double height, ScaleUpdateDetails details) {
    setState(() {
      final minHeight = height;
      final maxHeight = height * 4;
      _contentHeight = (details.verticalScale * _contentHeightUpdateReference)
          .coerceIn(minHeight, maxHeight);

      final scrollOffset =
          _lastFocus * _contentHeight - details.localFocalPoint.dy;
      _scrollController
          .jumpTo(scrollOffset.coerceIn(0, _contentHeight - height));

      _lastFocus = _getFocus(height, details.localFocalPoint);
    });
  }

  double _getFocus(double height, Offset focalPoint) =>
      (_scrollController.offset + focalPoint.dy) / _contentHeight;
}
