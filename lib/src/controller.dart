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
  }

  final EventProvider<E> eventProvider;

  final LocalDate initialDate;
  final VisibleRange visibleRange;
  final DayOfWeek firstDayOfWeek;

  final LinkedScrollControllerGroup scrollControllers;
  ValueListenable<LocalDate> _dateListenable;
  ValueListenable<LocalDate> get dateListenable => _dateListenable;

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
  }
}
