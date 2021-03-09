import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'controller.dart';
import 'old/visible_range.dart';
import 'utils.dart';

typedef DateWidgetBuilder = Widget Function(
  BuildContext context,
  DateTime date,
);

class DatePageView extends StatefulWidget {
  const DatePageView({
    Key? key,
    required this.controller,
    required this.visibleRange,
    this.shrinkWrapInCrossAxis = false,
    required this.builder,
  }) : super(key: key);

  final DateController controller;
  final VisibleRange visibleRange;
  final bool shrinkWrapInCrossAxis;
  final DateWidgetBuilder builder;

  @override
  _DatePageViewState createState() => _DatePageViewState();
}

class _DatePageViewState extends State<DatePageView> {
  late _MultiDateScrollController _scrollController;
  // TODO(JonasWanke): remove old entries
  final _heights = <int, double>{};

  @override
  void initState() {
    super.initState();
    _scrollController = _MultiDateScrollController(
      widget.controller,
      widget.visibleRange.visibleDayCount,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Scrollable(
      axisDirection: AxisDirection.right,
      // physics: TimetableScrollPhysics(widget.controller),
      controller: _scrollController,
      viewportBuilder: (context, position) {
        return Viewport(
          axisDirection: AxisDirection.right,
          offset: position,
          anchor: 0,
          slivers: <Widget>[
            SliverFillViewport(
              viewportFraction: 1 / widget.visibleRange.visibleDayCount,
              delegate: SliverChildBuilderDelegate(_buildPage),
            ),
          ],
        );
      },
    );

    if (widget.shrinkWrapInCrossAxis) {
      child = ValueListenableBuilder<double>(
        valueListenable: widget.controller,
        builder: (context, page, child) =>
            SizedBox(height: _getHeight(page), child: child),
        child: child,
      );
    }
    return child;
  }

  double _getHeight(double page) {
    double maxHeightFrom(int page) {
      return page
          .until(page + widget.visibleRange.visibleDayCount)
          .map((it) => _heights[it] ?? 0)
          .max()!;
    }

    final oldMaxHeight = maxHeightFrom(page.floor());
    final newMaxHeight = maxHeightFrom(page.ceil());
    final t = page - page.floorToDouble();
    return lerpDouble(oldMaxHeight, newMaxHeight, t)!;
  }

  Widget _buildPage(BuildContext context, int index) {
    final page = index + widget.visibleRange.visibleDayCount ~/ 2;
    var child = widget.builder(context, DateTimeTimetable.dateFromPage(page));
    if (widget.shrinkWrapInCrossAxis) {
      child = _OverflowPage(
        onSizeChanged: (size) => setState(() => _heights[index] = size.height),
        child: child,
      );
    }
    return child;
  }
}

class _MultiDateScrollController extends ScrollController {
  _MultiDateScrollController(this.controller, this.visibleDayCount)
      : super(initialScrollOffset: controller.value) {
    controller.addListener(_listenToController);
  }

  final DateController controller;
  final int visibleDayCount;

  double get page => position._pixelsToPage(offset);

  void _listenToController() =>
      position.forcePixels(position._pageToPixels(controller.value));

  @override
  void dispose() {
    controller.removeListener(_listenToController);
    super.dispose();
  }

  @override
  void attach(ScrollPosition position) {
    assert(
      position is _MultiDateScrollPosition,
      '_MultiDateScrollControllers can only be used with '
      '_MultiDateScrollPositions.',
    );
    final linkedPosition = position as _MultiDateScrollPosition;
    assert(
      linkedPosition.owner == this,
      '_MultiDateScrollPosition cannot change controllers once created.',
    );
    super.attach(position);
  }

  @override
  _MultiDateScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _MultiDateScrollPosition(
      this,
      physics: physics,
      context: context,
      initialPage: initialScrollOffset,
      oldPosition: oldPosition,
    );
  }

  @override
  _MultiDateScrollPosition get position =>
      super.position as _MultiDateScrollPosition;
}

class _MultiDateScrollPosition extends ScrollPositionWithSingleContext {
  _MultiDateScrollPosition(
    this.owner, {
    required ScrollPhysics physics,
    required ScrollContext context,
    required this.initialPage,
    ScrollPosition? oldPosition,
  }) : super(
          physics: physics,
          context: context,
          initialPixels: null,
          oldPosition: oldPosition,
        );

  final _MultiDateScrollController owner;
  double initialPage;

  @override
  bool applyViewportDimension(double viewportDimension) {
    final hadViewportDimension = hasViewportDimension;
    final result = super.applyViewportDimension(viewportDimension);
    final isInitialLayout = !hasPixels || !hadViewportDimension;
    final oldPixels = hasPixels ? pixels : null;
    final newPixels = isInitialLayout ? _pageToPixels(initialPage) : oldPixels!;

    if (newPixels != oldPixels) {
      correctPixels(newPixels);
      return false;
    }
    return result;
  }

  @override
  double setPixels(double newPixels) {
    if (newPixels == pixels) return 0;

    _updateUserScrollDirectionFromDelta(newPixels - pixels);
    owner.controller.value = _pixelsToPage(newPixels);
    return super.setPixels(newPixels);
  }

  @override
  void forcePixels(double value) {
    if (value == pixels) return;

    _updateUserScrollDirectionFromDelta(value - pixels);
    // owner.controller.page.value = _pixelsToPage(value);
    super.forcePixels(value);
  }

  void _updateUserScrollDirectionFromDelta(double delta) {
    final direction =
        delta > 0 ? ScrollDirection.forward : ScrollDirection.reverse;
    updateUserScrollDirection(direction);
  }

  double _pixelsToPage(double pixels) =>
      pixels * owner.visibleDayCount / viewportDimension;
  double _pageToPixels(double page) =>
      page / owner.visibleDayCount * viewportDimension;

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('owner: $owner');
  }
}

// Copied and modified from: https://github.com/Limbou/expandable_page_view/blob/d692cff38f9e098ad5c020d80123a13ab2a53083/lib/expandable_page_view.dart
class _OverflowPage extends StatelessWidget {
  const _OverflowPage({required this.onSizeChanged, required this.child});

  final ValueChanged<Size> onSizeChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      minHeight: 0,
      maxHeight: double.infinity,
      alignment: Alignment.topCenter,
      child: _SizeReportingWidget(
        onSizeChanged: onSizeChanged,
        child: child,
      ),
    );
  }
}

// Copied and modified from https://github.com/Limbou/expandable_page_view/blob/d692cff38f9e098ad5c020d80123a13ab2a53083/lib/size_reporting_widget.dart
class _SizeReportingWidget extends StatefulWidget {
  const _SizeReportingWidget({
    Key? key,
    required this.child,
    required this.onSizeChanged,
  }) : super(key: key);

  final Widget child;
  final ValueChanged<Size> onSizeChanged;

  @override
  _SizeReportingWidgetState createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<_SizeReportingWidget> {
  final _widgetKey = GlobalKey();
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) => _notifySize());
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        WidgetsBinding.instance!.addPostFrameCallback((_) => _notifySize());
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Container(key: _widgetKey, child: widget.child),
      ),
    );
  }

  void _notifySize() {
    final context = _widgetKey.currentContext;
    if (context == null) return;

    final size = context.size!;
    if (_oldSize != size) {
      _oldSize = size;
      widget.onSizeChanged(size);
    }
  }
}
