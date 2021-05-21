import 'package:flutter/physics.dart';

import '../layouts/recurring_multi_date.dart';
import '../utils.dart';

abstract class VisibleDateRange {
  const VisibleDateRange({
    required this.visibleDayCount,
    required this.canScroll,
  }) : assert(visibleDayCount > 0);

  factory VisibleDateRange.days(
    int visibleDayCount, {
    int swipeRange,
    DateTime? alignmentDate,
    DateTime? minDate,
    DateTime? maxDate,
  }) = DaysVisibleDateRange;
  factory VisibleDateRange.week({
    int startOfWeek = DateTime.monday,
    DateTime? minDate,
    DateTime? maxDate,
  }) {
    return VisibleDateRange.weekAligned(
      DateTime.daysPerWeek,
      firstDay: startOfWeek,
      minDate: minDate,
      maxDate: maxDate,
    );
  }
  factory VisibleDateRange.weekAligned(
    int visibleDayCount, {
    int firstDay = DateTime.monday,
    DateTime? minDate,
    DateTime? maxDate,
  }) {
    return VisibleDateRange.days(
      visibleDayCount,
      swipeRange: DateTime.daysPerWeek,
      // This just has to be any date fitting `firstDay`. The addition results
      // in a correct value because 2021-01-03 was a Sunday and
      // `DateTime.monday = 1`.
      alignmentDate: DateTimeTimetable.date(2021, 1, 3) + firstDay.days,
      minDate: minDate,
      maxDate: maxDate,
    );
  }

  /// Creates a non-scrollable [VisibleDateRange].
  ///
  /// This is useful for, e.g., [RecurringMultiDateTimetable].
  factory VisibleDateRange.fixed(DateTime startDate, int visibleDayCount) =>
      FixedDaysVisibleDateRange(startDate, visibleDayCount);

  final int visibleDayCount;
  final bool canScroll;

  double getTargetPageForFocus(double focusPage);

  double getTargetPageForCurrent(
    double currentPage, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  });

  double applyBoundaryConditions(double page) {
    if (!canScroll) {
      throw StateError(
        'A non-scrollable `$runtimeType` was used in a scrollable view.',
      );
    }
    return 0;
  }
}

class DaysVisibleDateRange extends VisibleDateRange {
  DaysVisibleDateRange(
    int visibleDayCount, {
    this.swipeRange = 1,
    DateTime? alignmentDate,
    this.minDate,
    this.maxDate,
  })  : alignmentDate = alignmentDate ?? DateTimeTimetable.today(),
        assert(minDate.isValidTimetableDate),
        assert(maxDate.isValidTimetableDate),
        assert(minDate == null || maxDate == null || minDate <= maxDate),
        super(visibleDayCount: visibleDayCount, canScroll: true) {
    minPage = minDate == null ? null : getTargetPageForFocus(minDate!.page);
    maxPage = maxDate == null
        ? null
        : _getMinimumPageForFocus(maxDate!.page)
            .coerceAtLeast(minPage ?? double.negativeInfinity);
  }

  final int swipeRange;
  final DateTime alignmentDate;

  final DateTime? minDate;
  late final double? minPage;
  final DateTime? maxDate;
  late final double? maxPage;

  @override
  double getTargetPageForFocus(
    double focusPage, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) {
    // Taken from [_InteractiveViewerState._kDrag].
    const _kDrag = 0.0000135;
    final simulation =
        FrictionSimulation(_kDrag, focusPage, velocity, tolerance: tolerance);
    final targetFocusPage = simulation.finalX;

    final alignmentOffset = alignmentDate.datePage % swipeRange;
    final alignmentDifference =
        (targetFocusPage.floor() - alignmentDate.datePage) % swipeRange;
    final alignmentCorrectedTargetPage = targetFocusPage - alignmentDifference;
    final swipeAlignedTargetPage =
        (alignmentCorrectedTargetPage / swipeRange).floor() * swipeRange;
    return (alignmentOffset + swipeAlignedTargetPage).toDouble();
  }

  double _getMinimumPageForFocus(double focusPage) {
    var page = focusPage;
    while (true) {
      final target = getTargetPageForFocus(page);
      if (target + visibleDayCount > page) return target;
      page -= swipeRange;
    }
  }

  @override
  double getTargetPageForCurrent(
    double currentPage, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) {
    return getTargetPageForFocus(
      currentPage + swipeRange / 2,
      velocity: velocity,
      tolerance: tolerance,
    );
  }

  @override
  double applyBoundaryConditions(double page) {
    final targetPage = page.coerceIn(
      minPage ?? double.negativeInfinity,
      maxPage ?? double.infinity,
    );
    return page - targetPage;
  }
}

/// A non-scrollable [VisibleDateRange].
///
/// This is useful for, e.g., [RecurringMultiDateTimetable].
class FixedDaysVisibleDateRange extends VisibleDateRange {
  FixedDaysVisibleDateRange(
    this.startDate,
    int visibleDayCount,
  )   : assert(startDate.isValidTimetableDate),
        super(visibleDayCount: visibleDayCount, canScroll: false);

  final DateTime startDate;
  double get page => startDate.page;

  @override
  double getTargetPageForFocus(
    double focusPage, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) =>
      page;

  @override
  double getTargetPageForCurrent(
    double currentPage, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) =>
      page;
}
