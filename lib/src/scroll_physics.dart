// Inspired by [PageScrollPhysics]
import 'package:flutter/widgets.dart';
import 'package:time_machine/time_machine.dart';

import 'controller.dart';
import 'visible_range.dart';

class TimetableScrollPhysics extends ScrollPhysics {
  const TimetableScrollPhysics(this.controller, {ScrollPhysics parent})
      : assert(controller != null),
        super(parent: parent);

  final TimetableController controller;

  static double getTargetPageForDate(
    LocalDate date,
    TimetableController controller,
  ) {
    assert(date != null);
    assert(controller != null);
    return getTargetPage(date.epochDay.toDouble(), controller);
  }

  static double getTargetPage(
    double page,
    TimetableController controller, {
    double velocityAddition = 0,
  }) {
    assert(page != null);
    assert(controller != null);
    assert(velocityAddition != null);

    final visibleRange = controller.visibleRange;
    if (visibleRange is DaysVisibleRange) {
      return (page + velocityAddition).roundToDouble();
    } else if (visibleRange is WeekVisibleRange) {
      final epochWeekDayOffset = controller.firstDayOfWeek.value -
          LocalDate.fromEpochDay(0).dayOfWeek.value;
      final currentWeek =
          (page - epochWeekDayOffset) / TimeConstants.daysPerWeek;
      final targetWeek = (currentWeek + velocityAddition).roundToDouble();
      return targetWeek * TimeConstants.daysPerWeek + epochWeekDayOffset;
    } else {
      assert(false,
          'Unsupported VisibleRange subclass: ${visibleRange.runtimeType}');
      return 0;
    }
  }

  @override
  TimetableScrollPhysics applyTo(ScrollPhysics ancestor) {
    return TimetableScrollPhysics(controller, parent: buildParent(ancestor));
  }

  double _getTargetPixels(
      ScrollPosition position, Tolerance tolerance, double velocity) {
    final pixelsToPage =
        controller.visibleRange.visibleDays / position.viewportDimension;

    final currentPage = position.pixels * pixelsToPage;

    final targetPage = getTargetPage(
      currentPage,
      controller,
      velocityAddition:
          velocity.abs() > tolerance.velocity ? 0.5 * velocity.sign : 0.0,
    );
    return targetPage / pixelsToPage;
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final tolerance = this.tolerance;
    final target = _getTargetPixels(position, tolerance, velocity);
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
