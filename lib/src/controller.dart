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
  })  : assert(minDate.isValidTimetableDate),
        assert(maxDate.isValidTimetableDate),
        assert(minDate == null || maxDate == null || minDate <= maxDate),
        _date = _DateValueNotifier(DateTimeTimetable.dateFromPage(
          _startPageFromInitialDate(initialDate).toInt(),
        )),
        super(_startPageFromInitialDate(initialDate)) {
    addListener(() {
      _date.value = DateTimeTimetable.dateFromPage(value.toInt());
    });
  }

  static double _startPageFromInitialDate(DateTime? initialDate) {
    assert(initialDate.isValidTimetableDate);

    final date = initialDate?.atStartOfDay ?? DateTimeTimetable.today();
    return date.page;
  }

  final int firstDayOfWeek;
  final DateTime? minDate;
  final DateTime? maxDate;

  final ValueNotifier<DateTime> _date;
  ValueListenable<DateTime> get date => _date;

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
