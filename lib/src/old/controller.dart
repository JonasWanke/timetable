import 'package:flutter/widgets.dart';

import '../event.dart';
import '../event_provider.dart';
import '../utils.dart';
import 'visible_range.dart';

// class TimetableController<E extends Event> {
//   double focusedDate;
// }

/// Controls a [Timetable] and manages its state.
class TimetableController<E extends Event> {
  TimetableController({
    required this.eventProvider,
    DateTime? initialDate,
    // this.initialTimeRange = const InitialTimeRange.zoom(1),
    this.visibleRange = const VisibleRange.week(),
    this.firstDayOfWeek = DateTime.monday,
  }) : initialDate =
            initialDate?.atStartOfDay ?? DateTime.now().toUtc().atStartOfDay {
    // _date = scrollControllers.pageListenable
    //     .map((page) => LocalDate.fromEpochDay(page.floor()));
    // _visibleDates = scrollControllers.pageListenable.map((page) {
    //   return DateInterval(
    //     LocalDate.fromEpochDay(page.floor()),
    //     LocalDate.fromEpochDay(page.ceil() + visibleRange.visibleDayCount - 1),
    //   );
    // })
    //   ..addListener(
    //       () => eventProvider.onVisibleDatesChanged(visibleDates.value));
    // eventProvider.onVisibleDatesChanged(visibleDates.value);
  }

  /// The [EventProvider] used for populating [Timetable] with events.
  final EventProvider<E> eventProvider;

  /// The initially focused date.
  ///
  /// This defaults to [LocalDate.today];
  final DateTime initialDate;

  final VisibleRange visibleRange;

  /// The [DayOfWeek] on which a week starts.
  ///
  /// This defaults to [DayOfWeek.monday].
  ///
  /// It is used e.g. by [VisibleRange.week] to snap to the correct range and by
  /// [TimetableHeader] to calculate the current week number.
  final int firstDayOfWeek;

  // ValueListenable<LocalDate> get page => _page;
  // ValueNotifier<LocalDate> _page;

  // ValueListenable<DateTime> get date => _date;
  // ValueNotifier<DateTime> _date;

  // ValueListenable<DateInterval> get visibleDates => _visibleDates;
  // ValueNotifier<DateInterval> _visibleDates;

  // TimetableLayout get layout => _layout;
  // TimetableLayout _layout;
  // set layout(TimetableLayout layout) {
  //   if (_layout == layout) return;

  //   _layout = layout;
  // }

  /// Animates today into view.
  ///
  /// The alignment of today inside the viewport depends on [visibleRange].
  Future<void> animateToToday({
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 200),
  }) =>
      animateTo(DateTime.now().toUtc(), curve: curve, duration: duration);

  /// Animates the given [date] into view.
  ///
  /// The alignment of today inside the viewport depends on [visibleRange].
  Future<void> animateTo(
    DateTime date, {
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 200),
  }) async {
    // await scrollControllers.animateTo(
    //   visibleRange.getTargetPageForFocusDate(date, firstDayOfWeek),
    //   curve: curve,
    //   duration: duration,
    // );
  }

  /// Discards any resources used by the controller.
  ///
  /// After this is called, the controller is not in a usable state and should
  /// be discarded.
  ///
  /// This method should only be called by the object's owner, usually in
  /// [State.dispose].
  void dispose() {
    eventProvider.dispose();

    // _page.dispose();
    // _date.dispose();
    // _visibleDates.dispose();
  }
}
