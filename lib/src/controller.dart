import 'dart:ui';

import 'package:flutter/animation.dart' hide Interval;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'utils.dart';

class DateController extends ValueNotifier<double> {
  DateController({
    DateTime? initialDate,
    this.firstDayOfWeek = DateTime.monday,
    this.minDate,
    this.maxDate,
  })  : assert(initialDate.isValidTimetableDate),
        assert(minDate.isValidTimetableDate),
        assert(maxDate.isValidTimetableDate),
        assert(minDate == null || maxDate == null || minDate <= maxDate),
        assert(
          minDate == null || initialDate == null || minDate <= initialDate,
        ),
        assert(
          maxDate == null || initialDate == null || maxDate >= initialDate,
        ),
        // We set the correct value in the body below.
        super(0) {
    final startDate = initialDate ?? coerceDate(DateTimeTimetable.today());
    value = startDate.page;

    _date = _DateValueNotifier(startDate);
    addListener(() {
      _date.value = DateTimeTimetable.dateFromPage(value.floor());
    });
  }

  final int firstDayOfWeek;
  final DateTime? minDate;
  final DateTime? maxDate;

  late final ValueNotifier<DateTime> _date;
  ValueListenable<DateTime> get date => _date;

  @override
  set value(double value) {
    assert(_isInRange(value));
    super.value = value;
  }

  bool _isInRange(double page) {
    final date = DateTimeTimetable.dateFromPage(page.floor());
    return date == coerceDate(date);
  }

  DateTime coerceDate(DateTime date) {
    assert(date.isValidTimetableDate);

    return DateTimeTimetable.dateFromPage(coercePage(date.page).floor());
    // if (minDate != null && date < minDate!) return minDate!;
    // if (maxDate != null && date >= maxDate!) return maxDate!;
    // return date;
  }

  double coercePage(double page) {
    if (minDate != null && page < minDate!.page) return minDate!.page;
    if (maxDate != null && page >= maxDate!.page) return maxDate!.page;
    return page;
  }

  // Animation
  AnimationController? _animationController;

  Future<void> animateToToday({
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 200),
    required TickerProvider vsync,
  }) {
    return animateTo(
      DateTimeTimetable.today(),
      curve: curve,
      duration: duration,
      vsync: vsync,
    );
  }

  Future<void> animateTo(
    DateTime date, {
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 200),
    required TickerProvider vsync,
  }) async {
    return animateToPage(
      date.page,
      curve: curve,
      duration: duration,
      vsync: vsync,
    );
  }

  Future<void> animateToPage(
    double page, {
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 200),
    required TickerProvider vsync,
  }) async {
    assert(_isInRange(page));

    _animationController?.dispose();
    final previousPage = value;
    _animationController =
        AnimationController(debugLabel: 'TimeController', vsync: vsync)
          ..addListener(() {
            value =
                lerpDouble(previousPage, page, _animationController!.value)!;
          })
          ..animateTo(1, duration: duration, curve: curve);
  }

  void jumpToToday() => jumpTo(DateTimeTimetable.today());
  void jumpTo(DateTime date) {
    assert(date.isValidTimetableDate);
    assert(_isInRange(date.page));

    value = date.page;
  }

  @override
  void dispose() {
    _date.dispose();
    super.dispose();
  }
}

class _DateValueNotifier extends ValueNotifier<DateTime> {
  _DateValueNotifier(DateTime date)
      : assert(date.isValidTimetableDate),
        super(date);
}
