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

  /// Display a fixed number of days.
  ///
  /// While scrolling, this can snap to all dates.
  ///
  /// When animating to a date (see [TimetableController.animateTo]), that day
  /// will be aligned to the left.
  const factory VisibleRange.days(int count) = DaysVisibleRange;

  /// Display seven consecutive days, aligned based on
  /// [TimetableController.firstDayOfWeek].
  ///
  /// While scrolling, this only snaps to week boundaries.
  ///
  /// When animating to a date (see [TimetableController.animateTo]), the week
  /// containing that date will fill the viewport.
  const factory VisibleRange.week() = WeekVisibleRange;

  final int visibleDays;

  LocalDate getPeriodStartDate(LocalDate date, DayOfWeek firstDayOfWeek);

  /// Convenience method of [getTargetPageForFocus] taking a [LocalDate].
  double getTargetPageForFocusDate(
      LocalDate focusDate, DayOfWeek firstDayOfWeek) {
    assert(focusDate != null);
    return getTargetPageForFocus(focusDate.epochDay.toDouble(), firstDayOfWeek);
  }

  /// Gets the page to align to the viewport's left side based on the
  /// [focusPage] to show.
  double getTargetPageForFocus(double focusPage, DayOfWeek firstDayOfWeek);

  /// Gets the page to align to the viewport's left side based on the
  /// [currentPage] in that position.
  double getTargetPageForCurrent(
    double currentPage,
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
  double getTargetPageForFocus(double focusPage, DayOfWeek firstDayOfWeek) =>
      getTargetPageForCurrent(focusPage, firstDayOfWeek);

  @override
  double getTargetPageForCurrent(
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

  @override
  LocalDate getPeriodStartDate(LocalDate date, DayOfWeek _) => date;
}

/// The [Timetable] will show exactly one week and will snap to week boundaries.
///
/// You can configure the first day of a week via
/// [TimetableController.firstDayOfWeek].
class WeekVisibleRange extends VisibleRange {
  const WeekVisibleRange() : super(visibleDays: TimeConstants.daysPerWeek);

  @override
  double getTargetPageForFocus(
    double focusPage,
    DayOfWeek firstDayOfWeek, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) {
    assert(focusPage != null);
    assert(firstDayOfWeek != null);
    assert(velocity != null);
    assert(tolerance != null);

    final focusWeek = focusPage / TimeConstants.daysPerWeek;

    final velocityAddition = getDefaultVelocityAddition(velocity, tolerance);
    final targetWeek = (focusWeek + velocityAddition).floorToDouble();
    return targetWeek * TimeConstants.daysPerWeek;
  }

  @override
  double getTargetPageForCurrent(
    double focusPage,
    DayOfWeek firstDayOfWeek, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) {
    return getTargetPageForFocus(
      focusPage + TimeConstants.daysPerWeek / 2,
      firstDayOfWeek,
      velocity: velocity,
      tolerance: tolerance,
    );
  }

  @override
  LocalDate getPeriodStartDate(LocalDate date, DayOfWeek firstDayOfWeek) {
    final epochWeekDayOffset = date.dayOfWeek.value - firstDayOfWeek.value;

    return date.subtractDays(epochWeekDayOffset);
  }
}
