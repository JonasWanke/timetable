import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../utils.dart';
import 'controller.dart';
import 'scroll_physics.dart';

/// "DateTimes can represent time values that are at a distance of at most
/// 100,000,000 days from epoch […]".
const _minPage = -100000000;
const _precisionErrorTolerance = 1e-5;

/// A page view for displaying dates that supports shrink-wrapping in the cross
/// axis.
///
/// A controller has to be provided, either directly via the constructor, or via
/// a [DefaultDateController] above in the widget tree.
class DatePageView extends StatefulWidget {
  const DatePageView({
    super.key,
    this.controller,
    this.shrinkWrapInCrossAxis = false,
    required this.builder,
  });

  final DateController? controller;
  final bool shrinkWrapInCrossAxis;
  final DateWidgetBuilder builder;

  @override
  State<DatePageView> createState() => _DatePageViewState();
}

class _DatePageViewState extends State<DatePageView> {
  DateController? _controller;
  MultiDateScrollController? _scrollController;
  final _heights = <int, double>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null && !_controller!.isDisposed) {
      _controller!.date.removeListener(_onDateChanged);
      _scrollController!.dispose();
    }
    _controller = widget.controller ?? DefaultDateController.of(context)!;
    _scrollController = MultiDateScrollController(_controller!);
    _controller!.date.addListener(_onDateChanged);
  }

  @override
  void dispose() {
    _controller!.date.removeListener(_onDateChanged);
    _scrollController!.dispose();
    super.dispose();
  }

  void _onDateChanged() {
    final datePageValue = _controller!.value;
    final firstPage = datePageValue.page.round();
    final lastPage = datePageValue.page.round() + datePageValue.visibleDayCount;
    _heights.removeWhere((key, _) => key < firstPage - 5 || key > lastPage + 5);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = ValueListenableBuilder<bool>(
      valueListenable: _controller!.map((it) => it.visibleRange.canScroll),
      builder: (context, canScroll, _) =>
          canScroll ? _buildScrollingChild() : _buildNonScrollingChild(),
    );

    if (widget.shrinkWrapInCrossAxis) {
      child = ValueListenableBuilder<DatePageValue>(
        valueListenable: _controller!,
        builder: (context, pageValue, child) => ImmediateSizedBox(
          heightGetter: () => _getHeight(pageValue),
          child: child!,
        ),
        child: child,
      );
    }
    return child;
  }

  Widget _buildScrollingChild() {
    return Scrollable(
      axisDirection: AxisDirection.right,
      physics: DateScrollPhysics(_controller!.map((it) => it.visibleRange)),
      controller: _scrollController!,
      viewportBuilder: (context, position) {
        return Viewport(
          axisDirection: AxisDirection.right,
          offset: position,
          slivers: [
            ValueListenableBuilder<int>(
              valueListenable: _controller!.map((it) => it.visibleDayCount),
              builder: (context, visibleDayCount, _) => SliverFillViewport(
                padEnds: false,
                viewportFraction: 1 / visibleDayCount,
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildPage(context, _minPage + index),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNonScrollingChild() {
    return ValueListenableBuilder<DatePageValue>(
      valueListenable: _controller!,
      builder: (context, value, _) => Row(
        children: [
          for (var i = 0; i < value.visibleDayCount; i++)
            Expanded(child: _buildPage(context, value.page.toInt() + i)),
        ],
      ),
    );
  }

  double _getHeight(DatePageValue pageValue) {
    double maxHeightFrom(int page) {
      return page
          .rangeTo(page + pageValue.visibleDayCount - 1)
          .map((it) => _heights[it] ?? 0)
          .max
          .toDouble();
    }

    final oldMaxHeight = maxHeightFrom(pageValue.page.floor());
    final newMaxHeight = maxHeightFrom(pageValue.page.ceil());
    final t = pageValue.page - pageValue.page.floorToDouble();
    return lerpDouble(oldMaxHeight, newMaxHeight, t)!;
  }

  Widget _buildPage(BuildContext context, int page) {
    var child = widget.builder(context, DateTimeTimetable.dateFromPage(page));
    if (widget.shrinkWrapInCrossAxis) {
      child = ImmediateSizeReportingOverflowPage(
        onSizeChanged: (size) {
          if (_heights[page] == size.height) return;
          _heights[page] = size.height;
          WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
        },
        child: child,
      );
    }
    return child;
  }
}

class MultiDateScrollController extends ScrollController {
  MultiDateScrollController(this.controller)
      : super(initialScrollOffset: controller.value.page) {
    controller.addListener(_listenToController);
  }

  final DateController controller;
  int get visibleDayCount => controller.value.visibleDayCount;

  double get page => position.page;

  void _listenToController() {
    if (hasClients) position.forcePage(controller.value.page);
  }

  @override
  void dispose() {
    controller.removeListener(_listenToController);
    super.dispose();
  }

  @override
  void attach(ScrollPosition position) {
    assert(
      position is MultiDateScrollPosition,
      'MultiDateScrollControllers can only be used with '
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
    required super.physics,
    required super.context,
    required this.initialPage,
    super.oldPosition,
  }) : super(initialPixels: null);

  final MultiDateScrollController owner;
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

  @override
  double setPixels(double newPixels) {
    if (newPixels == pixels) return 0;

    _updateUserScrollDirectionFromDelta(newPixels - pixels);
    final overscroll = super.setPixels(newPixels);

    final activity = this.activity;
    final dateScrollActivity = activity is DragScrollActivity ||
            (activity is BallisticScrollActivity &&
                activity.velocity.abs() > precisionErrorTolerance)
        ? const DragDateScrollActivity()
        : const IdleDateScrollActivity();
    controller.value = controller.value.copyWithActivity(
      page: pixelsToPage(pixels),
      activity: dateScrollActivity,
    );
    return overscroll;
  }

  void forcePage(double page) => forcePixels(pageToPixels(page));
  @override
  void forcePixels(double value) {
    if (value == pixels) return;

    _updateUserScrollDirectionFromDelta(value - pixels);
    super.forcePixels(value);
  }

  void _updateUserScrollDirectionFromDelta(double delta) {
    final direction =
        delta > 0 ? ScrollDirection.forward : ScrollDirection.reverse;
    updateUserScrollDirection(direction);
  }

  double pixelsToPage(double pixels) =>
      _minPage + pixelDeltaToPageDelta(pixels);
  double pageToPixels(double page) => pageDeltaToPixelDelta(page - _minPage);

  double pixelDeltaToPageDelta(double pixels) {
    final result = pixels * owner.visibleDayCount / viewportDimension;
    final closestWholeNumber = result.roundToDouble();
    if ((result - closestWholeNumber).abs() <= _precisionErrorTolerance) {
      return closestWholeNumber;
    }
    return result;
  }

  double pageDeltaToPixelDelta(double page) =>
      page / owner.visibleDayCount * viewportDimension;

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('owner: $owner');
  }
}
