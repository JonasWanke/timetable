import 'package:flutter/widgets.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:time_machine/time_machine.dart';

class TimetableController {
  TimetableController({
    LocalDate initialDate,
    this.visibleDays = 7,
  })  : initialDate = initialDate ?? LocalDate.today(),
        assert(visibleDays != null),
        assert(visibleDays > 0);

  final LocalDate initialDate;
  final int visibleDays;

  final LinkedScrollControllerGroup scrollControllers =
      LinkedScrollControllerGroup();
}

// Inspired by [PageScrollPhysics]
class TimetableScrollPhysics extends ScrollPhysics {
  const TimetableScrollPhysics(this.controller, {ScrollPhysics parent})
      : assert(controller != null),
        super(parent: parent);

  final TimetableController controller;

  @override
  TimetableScrollPhysics applyTo(ScrollPhysics ancestor) {
    return TimetableScrollPhysics(controller, parent: buildParent(ancestor));
  }

  double _getTargetPixels(
      ScrollPosition position, Tolerance tolerance, double velocity) {
    var page =
        position.pixels * controller.visibleDays / position.viewportDimension;
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return page.roundToDouble() *
        position.viewportDimension /
        controller.visibleDays;
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
