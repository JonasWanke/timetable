import 'package:flutter/widgets.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/src/visible_range.dart';

import 'event.dart';
import 'event_provider.dart';
import 'utils/scrolling.dart';

class TimetableController<E extends Event> {
  TimetableController({
    @required this.eventProvider,
    LocalDate initialDate,
    this.visibleRange = const VisibleRange.week(),
  })  : assert(eventProvider != null),
        initialDate = initialDate ?? LocalDate.today(),
        assert(visibleRange != null),
        scrollControllers = LinkedScrollControllerGroup(
          initialPage: (initialDate ?? LocalDate.today()).epochDay.toDouble(),
          viewportFraction: 1 / visibleRange.visibleDays,
        );

  final EventProvider<E> eventProvider;

  final LocalDate initialDate;
  final VisibleRange visibleRange;

  final LinkedScrollControllerGroup scrollControllers;

  Future<void> animateToToday({
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 200),
  }) =>
      animateTo(LocalDate.today(), curve: curve, duration: duration);
  Future<void> animateTo(
    LocalDate date, {
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 200),
  }) async {
    await scrollControllers.animateTo(
      date.epochDay.toDouble(),
      curve: curve,
      duration: duration,
    );
  }
}

// Inspired by [PageScrollPhysics]
class TimetableScrollPhysics extends ScrollPhysics {
  const TimetableScrollPhysics(this.visibleRange, {ScrollPhysics parent})
      : assert(visibleRange != null),
        super(parent: parent);

  final VisibleRange visibleRange;

  @override
  TimetableScrollPhysics applyTo(ScrollPhysics ancestor) {
    return TimetableScrollPhysics(visibleRange, parent: buildParent(ancestor));
  }

  double _getTargetPixels(
      ScrollPosition position, Tolerance tolerance, double velocity) {
    final visibleRange = this.visibleRange;
    final velocityAddition =
        velocity.abs() > tolerance.velocity ? 0.5 * velocity.sign : 0;

    var page =
        position.pixels * visibleRange.visibleDays / position.viewportDimension;
    if (visibleRange is DaysVisibleRange) {
      page = (page + velocityAddition).roundToDouble();
    } else if (visibleRange is WeekVisibleRange) {
      final epochWeekDayOffset = visibleRange.firstDayOfWeek.value -
          LocalDate.fromEpochDay(0).dayOfWeek.value;
      page = (page - epochWeekDayOffset) / TimeConstants.daysPerWeek;
      page += velocityAddition;
      page =
          page.roundToDouble() * TimeConstants.daysPerWeek + epochWeekDayOffset;
    } else {
      assert(false,
          'Unsupported VisibleRange subclass: ${visibleRange.runtimeType}');
    }
    return page * position.viewportDimension / visibleRange.visibleDays;
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
