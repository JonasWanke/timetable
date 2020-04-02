import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:time_machine/time_machine.dart';

import 'event.dart';
import 'event_provider.dart';
import 'scroll_physics.dart';
import 'utils/scrolling.dart';
import 'utils/utils.dart';
import 'visible_range.dart';

class TimetableController<E extends Event> {
  TimetableController({
    @required this.eventProvider,
    LocalDate initialDate,
    this.visibleRange = const VisibleRange.week(),
    this.firstDayOfWeek = DayOfWeek.monday,
  })  : assert(eventProvider != null),
        initialDate = initialDate ?? LocalDate.today(),
        assert(firstDayOfWeek != null),
        assert(visibleRange != null),
        scrollControllers = LinkedScrollControllerGroup(
          initialPage: (initialDate ?? LocalDate.today()).epochDay.toDouble(),
          viewportFraction: 1 / visibleRange.visibleDays,
        ) {
    _dateListenable = scrollControllers.pageListenable
        .map((page) => LocalDate.fromEpochDay(page.floor()));
    _currentlyVisibleDatesListenable = _dateListenable.map((date) {
      var visibleDays = visibleRange.visibleDays;
      final page = scrollControllers.page;
      if ((page.roundToDouble() - page).abs() < precisionErrorTolerance) {
        // When we're aligned to the viewport (page is a whole number), the
        // amount of days to add is one fewer that visibleDays, as DateInterval
        // includes the end date.
        visibleDays--;
      }
      return DateInterval(date, date.addDays(visibleDays));
    })
      ..addListener(
          () => eventProvider.onVisibleDatesChanged(currentlyVisibleDates));
  }

  final EventProvider<E> eventProvider;

  final LocalDate initialDate;
  final VisibleRange visibleRange;
  final DayOfWeek firstDayOfWeek;

  final LinkedScrollControllerGroup scrollControllers;

  ValueNotifier<LocalDate> _dateListenable;
  ValueListenable<LocalDate> get dateListenable => _dateListenable;

  ValueNotifier<DateInterval> _currentlyVisibleDatesListenable;
  ValueListenable<DateInterval> get currentlyVisibleDatesListenable =>
      _currentlyVisibleDatesListenable;
  DateInterval get currentlyVisibleDates =>
      currentlyVisibleDatesListenable.value;

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
      TimetableScrollPhysics.getTargetPageForDate(date, this),
      curve: curve,
      duration: duration,
    );
  }

  void dispose() {
    eventProvider.dispose();

    _dateListenable.dispose();
    _currentlyVisibleDatesListenable.dispose();
  }
}
