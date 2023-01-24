import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';

import '../layouts/recurring_multi_date.dart';
import '../utils.dart';

/// Defines how many days are visible at once and whether they, e.g., snap to
/// weeks.
abstract class VisibleDateRange with Diagnosticable {
  const VisibleDateRange({
    required this.visibleDayCount,
    required this.canScroll,
  }) : assert(visibleDayCount > 0);

  /// A visible range that shows [visibleDayCount] consecutive days.
  ///
  /// This range snaps to every `swipeRange` days (defaults to every day) that
  /// are aligned to `alignmentDate` (defaults to today).
  ///
  /// When set, swiping is limited from `minDate` to `maxDate` so that both can
  /// still be seen.
  factory VisibleDateRange.days(
    int visibleDayCount, {
    int swipeRange,
    DateTime? alignmentDate,
    DateTime? minDate,
    DateTime? maxDate,
  }) = DaysVisibleDateRange;

  /// A visible range that shows seven consecutive days, aligned to
  /// [startOfWeek].
  ///
  /// When set, swiping is limited from `minDate` to `maxDate` so that both can
  /// still be seen.
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

  /// A visible range that shows [visibleDayCount] consecutive days, aligned to
  /// [firstDay].
  ///
  /// When set, swiping is limited from `minDate` to `maxDate` so that both can
  /// still be seen.
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

  /// A non-scrollable visible range.
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

/// The implementation for [VisibleDateRange.days], [VisibleDateRange.week], and
/// [VisibleDateRange.weekAligned].
class DaysVisibleDateRange extends VisibleDateRange {
  DaysVisibleDateRange(
    int visibleDayCount, {
    this.swipeRange = 1,
    DateTime? alignmentDate,
    this.minDate,
    this.maxDate,
  })  : alignmentDate = alignmentDate ?? DateTimeTimetable.today(),
        assert(minDate.debugCheckIsValidTimetableDate()),
        assert(maxDate.debugCheckIsValidTimetableDate()),
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
    const kDrag = 0.0000135;
    final simulation =
        FrictionSimulation(kDrag, focusPage, velocity, tolerance: tolerance);
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
    var page = focusPage - visibleDayCount;
    while (true) {
      final target = getTargetPageForFocus(page);
      if (target + visibleDayCount > focusPage) return target;
      page += swipeRange;
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('swipeRange', swipeRange));
    properties.add(DateDiagnosticsProperty('alignmentDate', alignmentDate));
    properties
        .add(DateDiagnosticsProperty('minDate', minDate, defaultValue: null));
    properties.add(DoubleProperty('minPage', minPage, defaultValue: null));
    properties
        .add(DateDiagnosticsProperty('maxDate', maxDate, defaultValue: null));
    properties.add(DoubleProperty('maxPage', maxPage, defaultValue: null));
  }
}

/// A non-scrollable [VisibleDateRange], used by [VisibleDateRange.fixed].
///
/// This is useful for, e.g., [RecurringMultiDateTimetable].
class FixedDaysVisibleDateRange extends VisibleDateRange {
  FixedDaysVisibleDateRange(this.startDate, int visibleDayCount)
      : assert(startDate.debugCheckIsValidTimetableDate()),
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DateDiagnosticsProperty('startDate', startDate));
    properties.add(DoubleProperty('page', page));
  }
}
