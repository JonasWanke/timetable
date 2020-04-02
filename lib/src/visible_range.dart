import 'package:flutter/physics.dart';
import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

import 'controller.dart';
import 'timetable.dart';

abstract class VisibleRange {
  const VisibleRange({
    @required this.visibleDays,
  })  : assert(visibleDays != null),
        assert(visibleDays > 0);

  const factory VisibleRange.days(int count) = DaysVisibleRange;
  const factory VisibleRange.week() = WeekVisibleRange;

  final int visibleDays;

  double getTargetPageForDate(
    LocalDate focusDate,
    DayOfWeek firstDayOfWeek, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) {
    return getTargetPage(
      focusDate.epochDay.toDouble(),
      firstDayOfWeek,
      velocity: velocity,
      tolerance: tolerance,
    );
  }

  double getTargetPage(
    double focusPage,
    DayOfWeek firstDayOfWeek, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  });

  @protected
  double getDefaultVelocityAddition(double velocity, Tolerance tolerance) {
    assert(velocity != null);
    assert(tolerance != null);

    return velocity.abs() > tolerance.velocity ? 0.5 * velocity.sign : 0.0;
  }
}

class DaysVisibleRange extends VisibleRange {
  const DaysVisibleRange(int count) : super(visibleDays: count);

  @override
  double getTargetPage(
    double focusPage,
    DayOfWeek firstDayOfWeek, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) {
    assert(focusPage != null);
    assert(firstDayOfWeek != null);
    assert(velocity != null);
    assert(tolerance != null);

    final velocityAddition = getDefaultVelocityAddition(velocity, tolerance);
    return (focusPage + velocityAddition).roundToDouble();
  }
}

/// The [Timetable] will show exactly one week and will snap to week boundaries.
///
/// You can configure the first day of a week via
/// [TimetableController.firstDayOfWeek].
class WeekVisibleRange extends VisibleRange {
  const WeekVisibleRange() : super(visibleDays: TimeConstants.daysPerWeek);

  @override
  double getTargetPage(
    double focusPage,
    DayOfWeek firstDayOfWeek, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) {
    assert(focusPage != null);
    assert(firstDayOfWeek != null);
    assert(velocity != null);
    assert(tolerance != null);

    final epochWeekDayOffset =
        firstDayOfWeek.value - LocalDate.fromEpochDay(0).dayOfWeek.value;
    final focusWeek =
        (focusPage - epochWeekDayOffset) / TimeConstants.daysPerWeek;

    final velocityAddition = getDefaultVelocityAddition(velocity, tolerance);
    final targetWeek = (focusWeek + velocityAddition).roundToDouble();
    return targetWeek * TimeConstants.daysPerWeek + epochWeekDayOffset;
  }
}
