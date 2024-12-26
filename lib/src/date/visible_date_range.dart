import 'package:chrono/chrono.dart';
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
    Date? alignmentDate,
    Date? minDate,
    Date? maxDate,
  }) = DaysVisibleDateRange;

  /// A visible range that shows seven consecutive days, aligned to
  /// [startOfWeek].
  ///
  /// When set, swiping is limited from `minDate` to `maxDate` so that both can
  /// still be seen.
  factory VisibleDateRange.week({
    Weekday startOfWeek = Weekday.monday,
    Date? minDate,
    Date? maxDate,
  }) {
    return VisibleDateRange.weekAligned(
      Days.perWeek,
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
    Weekday firstDay = Weekday.monday,
    Date? minDate,
    Date? maxDate,
  }) {
    return VisibleDateRange.days(
      visibleDayCount,
      swipeRange: Days.perWeek,
      // This just has to be any date fitting `firstDay`. The addition results
      // in a correct value because 2021-01-03 was a Sunday and
      // `Weekday.monday.number = 1`.
      alignmentDate: Date.from(const Year(2021), Month.january, 3).unwrap() +
          Days(firstDay.isoNumber),
      minDate: minDate,
      maxDate: maxDate,
    );
  }

  /// A non-scrollable visible range.
  ///
  /// This is useful for, e.g., [RecurringMultiDateTimetable].
  factory VisibleDateRange.fixed(Date startDate, int visibleDayCount) =>
      FixedDaysVisibleDateRange(startDate, visibleDayCount);

  final int visibleDayCount;
  final bool canScroll;

  int getTargetPageForFocus(num focusPage);

  int getTargetPageForCurrent(
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
    Date? alignmentDate,
    this.minDate,
    this.maxDate,
  })  : alignmentDate = alignmentDate ?? Date.todayInLocalZone(),
        assert(minDate == null || maxDate == null || minDate <= maxDate),
        super(visibleDayCount: visibleDayCount, canScroll: true) {
    minPage = minDate == null
        ? null
        : getTargetPageForFocus(minDate!.page.toDouble());
    maxPage = maxDate == null
        ? null
        : () {
            var result = _getMinimumPageForFocus(maxDate!.page);
            if (minPage != null) result = result.coerceAtLeast(minPage!);
            return result;
          }();
  }

  final int swipeRange;
  final Date alignmentDate;

  final Date? minDate;
  late final int? minPage;
  final Date? maxDate;
  late final int? maxPage;

  @override
  int getTargetPageForFocus(
    num focusPage, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) {
    // Taken from [_InteractiveViewerState._kDrag].
    const kDrag = 0.0000135;
    final simulation = FrictionSimulation(
      kDrag,
      focusPage.toDouble(),
      velocity,
      tolerance: tolerance,
    );
    final targetFocusPage = simulation.finalX;

    final alignmentOffset = alignmentDate.page % swipeRange;
    final alignmentDifference =
        (targetFocusPage.floor() - alignmentDate.page) % swipeRange;
    final alignmentCorrectedTargetPage = targetFocusPage - alignmentDifference;
    final swipeAlignedTargetPage =
        (alignmentCorrectedTargetPage / swipeRange).floor() * swipeRange;
    return alignmentOffset + swipeAlignedTargetPage;
  }

  int _getMinimumPageForFocus(int focusPage) {
    var page = focusPage - visibleDayCount;
    while (true) {
      final target = getTargetPageForFocus(page);
      if (target + visibleDayCount > focusPage) return target;
      page += swipeRange;
    }
  }

  @override
  int getTargetPageForCurrent(
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
      minPage?.toDouble() ?? double.negativeInfinity,
      maxPage?.toDouble() ?? double.infinity,
    );
    return page - targetPage;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('swipeRange', swipeRange));
    properties.add(DiagnosticsProperty('alignmentDate', alignmentDate));
    properties.add(DiagnosticsProperty('minDate', minDate, defaultValue: null));
    properties.add(IntProperty('minPage', minPage, defaultValue: null));
    properties.add(DiagnosticsProperty('maxDate', maxDate, defaultValue: null));
    properties.add(IntProperty('maxPage', maxPage, defaultValue: null));
  }
}

/// A non-scrollable [VisibleDateRange], used by [VisibleDateRange.fixed].
///
/// This is useful for, e.g., [RecurringMultiDateTimetable].
class FixedDaysVisibleDateRange extends VisibleDateRange {
  FixedDaysVisibleDateRange(this.startDate, int visibleDayCount)
      : super(visibleDayCount: visibleDayCount, canScroll: false);

  final Date startDate;
  int get page => startDate.page;

  @override
  int getTargetPageForFocus(
    num focusPage, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) =>
      page;

  @override
  int getTargetPageForCurrent(
    double currentPage, {
    double velocity = 0,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) =>
      page;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('startDate', startDate));
    properties.add(IntProperty('page', page));
  }
}
