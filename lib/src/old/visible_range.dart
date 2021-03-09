import 'package:flutter/physics.dart';
import 'package:meta/meta.dart';

import '../utils.dart';

abstract class VisibleRange {
  const VisibleRange({required this.visibleDayCount})
      : assert(visibleDayCount > 0);

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

  final int visibleDayCount;

  /// Convenience method of [getTargetPageForFocus] taking a [LocalDate].
  double getTargetPageForFocusDate(DateTime focusDate, int firstDayOfWeek) {
    assert(focusDate.isAtStartOfDay);

    return getTargetPageForFocus(focusDate.page, firstDayOfWeek);
  }

  /// Gets the page to align to the viewport's left side based on the
  /// [focusPage] to show.
  double getTargetPageForFocus(double focusPage, int firstDayOfWeek);

  /// Gets the page to align to the viewport's left side based on the
  /// [currentPage] in that position.
  double getTargetPageForCurrent(
    double currentPage,
    int firstDayOfWeek, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  });

  @protected
  double getDefaultVelocityAddition(double velocity, Tolerance tolerance) =>
      velocity.abs() > tolerance.velocity ? 0.5 * velocity.sign : 0.0;
}

class DaysVisibleRange extends VisibleRange {
  const DaysVisibleRange(int count) : super(visibleDayCount: count);

  @override
  double getTargetPageForFocus(double focusPage, int firstDayOfWeek) =>
      getTargetPageForCurrent(focusPage, firstDayOfWeek);

  @override
  double getTargetPageForCurrent(
    double focusPage,
    int firstDayOfWeek, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) {
    final velocityAddition = getDefaultVelocityAddition(velocity, tolerance);
    return (focusPage + velocityAddition).roundToDouble();
  }
}

/// The [Timetable] will show exactly one week and will snap to week boundaries.
///
/// You can configure the first day of a week via
/// [TimetableController.firstDayOfWeek].
class WeekVisibleRange extends VisibleRange {
  const WeekVisibleRange() : super(visibleDayCount: DateTime.daysPerWeek);

  @override
  double getTargetPageForFocus(
    double focusPage,
    int firstDayOfWeek, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) {
    final epochWeekDayOffset =
        firstDayOfWeek - DateTimeTimetable.dateFromPage(0).weekday;
    final focusWeek = (focusPage - epochWeekDayOffset) / DateTime.daysPerWeek;

    final velocityAddition = getDefaultVelocityAddition(velocity, tolerance);
    final targetWeek = (focusWeek + velocityAddition).floorToDouble();
    return targetWeek * DateTime.daysPerWeek + epochWeekDayOffset;
  }

  @override
  double getTargetPageForCurrent(
    double focusPage,
    int firstDayOfWeek, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) {
    return getTargetPageForFocus(
      focusPage + DateTime.daysPerWeek / 2,
      firstDayOfWeek,
      velocity: velocity,
      tolerance: tolerance,
    );
  }
}
