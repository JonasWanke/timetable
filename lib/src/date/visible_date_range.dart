import 'package:flutter/physics.dart';

import '../utils.dart';

abstract class VisibleDateRange {
  const VisibleDateRange({required this.visibleDayCount})
      : assert(visibleDayCount > 0);

  factory VisibleDateRange.days(
    int count, {
    int swipeRange,
    DateTime? alignmentDate,
  }) = DaysVisibleDateRange;
  factory VisibleDateRange.week({
    int firstDayOfWeek = DateTime.monday,
  }) =>
      VisibleDateRange.weekAligned(DateTime.daysPerWeek,
          firstDay: firstDayOfWeek);
  factory VisibleDateRange.weekAligned(
    int count, {
    int firstDay = DateTime.monday,
  }) {
    return VisibleDateRange.days(
      count,
      swipeRange: DateTime.daysPerWeek,
      // This just has to be any date fitting `firstDay`. The addition results
      // in a correct value because 2021-01-03 was a Friday and
      // `DateTime.monday = 1`.
      alignmentDate: DateTimeTimetable.date(2021, 1, 3) + firstDay.days,
    );
  }

  final int visibleDayCount;

  double getTargetPageForFocus(double focusPage, int firstDayOfWeek);

  double getTargetPageForCurrent(
    double currentPage,
    int firstDayOfWeek, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  });
}

class DaysVisibleDateRange extends VisibleDateRange {
  DaysVisibleDateRange(
    int count, {
    this.swipeRange = 1,
    DateTime? alignmentDate,
  })  : alignmentDate = alignmentDate ?? DateTimeTimetable.today(),
        super(visibleDayCount: count);

  final int swipeRange;
  final DateTime alignmentDate;

  @override
  double getTargetPageForFocus(
    double focusPage,
    int firstDayOfWeek, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) {
    // Taken from [_InteractiveViewerState._kDrag].
    const _kDrag = 0.0000135;
    final targetFocusPage =
        FrictionSimulation(_kDrag, focusPage, velocity).finalX;

    final alignmentDifference =
        (targetFocusPage - alignmentDate.page) % swipeRange;
    var targetPage = targetFocusPage - alignmentDifference;
    if (alignmentDifference > swipeRange / 2) targetPage += swipeRange;
    return targetPage;
  }

  @override
  double getTargetPageForCurrent(
    double currentPage,
    int firstDayOfWeek, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) {
    return getTargetPageForFocus(
      currentPage,
      firstDayOfWeek,
      velocity: velocity,
      tolerance: tolerance,
    );
  }
}
