import 'package:flutter/widgets.dart';
import 'package:time_machine/time_machine.dart';

import 'event.dart';
import 'event_provider.dart';
import 'scroll_physics.dart';
import 'utils/scrolling.dart';
import 'visible_range.dart';

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
      TimetableScrollPhysics.getTargetPageForDate(date, visibleRange),
      curve: curve,
      duration: duration,
    );
  }
}
