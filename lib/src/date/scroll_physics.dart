import 'package:flutter/widgets.dart';

import 'controller.dart';
import 'date_page_view.dart';

class DateScrollPhysics extends ScrollPhysics {
  const DateScrollPhysics(this.controller, {ScrollPhysics? parent})
      : super(parent: parent);

  final DateController controller;

  @override
  DateScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return DateScrollPhysics(controller, parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (position is! MultiDateScrollPosition) {
      throw ArgumentError(
        'DateScrollPhysics must be used with MultiDateScrollPosition.',
      );
    }

    final page = position.pixelsToPage(value);
    final overscrollPages =
        controller.visibleRange.applyBoundaryConditions(controller, page);
    final overscroll = position.pageDeltaToPixelDelta(overscrollPages);

    // Flutter doesn't allow boundary conditions to apply greater differences
    // than the actual delta. Due to numbers having a limited precision, this
    // occurs fairly often after conversion between pixels and pages, hence we
    // clamp the final value.
    final maximumDelta = (value - position.pixels).abs();
    return overscroll.clamp(-maximumDelta, maximumDelta);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (position is! MultiDateScrollPosition) {
      throw ArgumentError(
        'DateScrollPhysics must be used with MultiDateScrollPosition.',
      );
    }

    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final targetPage = controller.visibleRange.getTargetPageForCurrent(
      position.page,
      velocity: position.pixelDeltaToPageDelta(velocity),
      tolerance: Tolerance(
        distance: position.pixelDeltaToPageDelta(tolerance.distance),
        time: tolerance.time,
        velocity: position.pixelDeltaToPageDelta(tolerance.velocity),
      ),
    );
    final target = position.pageToPixels(targetPage);

    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
