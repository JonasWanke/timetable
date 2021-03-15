import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../utils.dart';
import 'controller.dart';
import 'scroll_physics.dart';

// "DateTimes can represent time values that are at a distance of at most
/// 100,000,000 days from epoch […]".
const _minPage = -100000000;

typedef DateWidgetBuilder = Widget Function(
  BuildContext context,
  DateTime date,
);

class DatePageView extends StatefulWidget {
  const DatePageView({
    Key? key,
    required this.controller,
    this.shrinkWrapInCrossAxis = false,
    required this.builder,
  }) : super(key: key);

  final DateController controller;
  final bool shrinkWrapInCrossAxis;
  final DateWidgetBuilder builder;

  @override
  _DatePageViewState createState() => _DatePageViewState();
}

class _DatePageViewState extends State<DatePageView> {
  int get visibleDayCount => widget.controller.visibleRange.visibleDayCount;
  late _MultiDateScrollController _scrollController;

  // TODO(JonasWanke): remove old entries
  final _heights = <int, double>{};

  @override
  void initState() {
    super.initState();
    _scrollController = _MultiDateScrollController(widget.controller);
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
      physics: DateScrollPhysics(widget.controller),
      controller: _scrollController,
      viewportBuilder: (context, position) {
        return Viewport(
          axisDirection: AxisDirection.right,
          offset: position,
          slivers: <Widget>[
            SliverFillViewport(
              padEnds: false,
              viewportFraction: 1 / visibleDayCount,
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildPage(context, _minPage + index),
              ),
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
          .until(page + visibleDayCount)
          .map((it) => _heights[it] ?? 0)
          .max()!;
    }

    final oldMaxHeight = maxHeightFrom(page.floor());
    final newMaxHeight = maxHeightFrom(page.ceil());
    final t = page - page.floorToDouble();
    return lerpDouble(oldMaxHeight, newMaxHeight, t)!;
  }

  Widget _buildPage(BuildContext context, int page) {
    var child = widget.builder(context, DateTimeTimetable.dateFromPage(page));
    if (widget.shrinkWrapInCrossAxis) {
      child = _OverflowPage(
        onSizeChanged: (size) => setState(() => _heights[page] = size.height),
        child: child,
      );
    }
    return child;
  }
}

class _MultiDateScrollController extends ScrollController {
  _MultiDateScrollController(this.controller)
      : super(initialScrollOffset: controller.value) {
    controller.addListener(_listenToController);
  }

  final DateController controller;
  int get visibleDayCount => controller.visibleRange.visibleDayCount;

  double get page => position.page;

  void _listenToController() => position.forcePage(controller.value);

  @override
  void dispose() {
    controller.removeListener(_listenToController);
    super.dispose();
  }

  @override
  void attach(ScrollPosition position) {
    assert(
      position is MultiDateScrollPosition,
      '_MultiDateScrollControllers can only be used with '
      'MultiDateScrollPositions.',
    );
    final linkedPosition = position as MultiDateScrollPosition;
    assert(
      linkedPosition.owner == this,
      'MultiDateScrollPosition cannot change controllers once created.',
    );
    super.attach(position);
  }

  @override
  MultiDateScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return MultiDateScrollPosition(
      this,
      physics: physics,
      context: context,
      initialPage: initialScrollOffset,
      oldPosition: oldPosition,
    );
  }

  @override
  MultiDateScrollPosition get position =>
      super.position as MultiDateScrollPosition;
}

class MultiDateScrollPosition extends ScrollPositionWithSingleContext {
  MultiDateScrollPosition(
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
  DateController get controller => owner.controller;
  double initialPage;

  double get page => pixelsToPage(pixels);

  @override
  bool applyViewportDimension(double viewportDimension) {
    final hadViewportDimension = hasViewportDimension;
    final isInitialLayout = !hasPixels || !hadViewportDimension;
    final oldPixels = hasPixels ? pixels : null;
    final page = isInitialLayout ? initialPage : this.page;

    final result = super.applyViewportDimension(viewportDimension);
    final newPixels = pageToPixels(page);
    if (newPixels != oldPixels) {
      correctPixels(newPixels);
      return false;
    }
    return result;
  }

  bool _isApplyingNewDimensions = false;
  @override
  void applyNewDimensions() {
    _isApplyingNewDimensions = true;
    super.applyNewDimensions();
    _isApplyingNewDimensions = false;
  }

  @override
  void goBallistic(double velocity) {
    if (_isApplyingNewDimensions) {
      assert(velocity == 0);
      return;
    }
    super.goBallistic(velocity);
  }

  // @override
  // double applyBoundaryConditions(double value) {
  //   // TODO(JonasWanke): move this to ScrollPhysics
  //   return value - pageToPixels(controller.coercePage(pixelsToPage(value)));
  // }

  @override
  double setPixels(double newPixels) {
    if (newPixels == pixels) return 0;

    _updateUserScrollDirectionFromDelta(newPixels - pixels);
    controller.value = controller.coercePage(pixelsToPage(newPixels));
    return super.setPixels(newPixels);
  }

  void forcePage(double page) => forcePixels(pageToPixels(page));
  @override
  void forcePixels(double value) {
    if (value == pixels) return;

    _updateUserScrollDirectionFromDelta(value - pixels);
    // controller.page.value = pixelsToPage(value);
    super.forcePixels(value);
  }

  void _updateUserScrollDirectionFromDelta(double delta) {
    final direction =
        delta > 0 ? ScrollDirection.forward : ScrollDirection.reverse;
    updateUserScrollDirection(direction);
  }

  double pixelsToPage(double pixels) =>
      _minPage + pixels * owner.visibleDayCount / viewportDimension;
  double pageToPixels(double page) =>
      (page - _minPage) / owner.visibleDayCount * viewportDimension;

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
      child: SizeReportingWidget(onSizeChanged: onSizeChanged, child: child),
    );
  }
}
