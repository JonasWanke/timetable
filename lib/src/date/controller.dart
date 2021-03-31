import 'dart:ui';

import 'package:flutter/animation.dart' hide Interval;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../utils.dart';
import 'visible_date_range.dart';

class DateController extends ValueNotifier<double> {
  DateController({
    DateTime? initialDate,
    VisibleDateRange? visibleRange,
    this.firstDayOfWeek = DateTime.monday,
  })  : assert(initialDate.isValidTimetableDate),
        visibleRange = visibleRange ??
            VisibleDateRange.week(firstDayOfWeek: firstDayOfWeek),
        // We set the correct value in the body below.
        super(0) {
    // The correct value is set via the listener when we assign to our value.
    _date = _DateValueNotifier(DateTimeTimetable.dateFromPage(0));
    addListener(() {
      _date.value = DateTimeTimetable.dateFromPage(value.floor());
    });

    final rawStartPage = initialDate?.page ?? DateTimeTimetable.today().page;
    value = this.visibleRange.getTargetPageForFocus(rawStartPage);
  }

  final VisibleDateRange visibleRange;
  final int firstDayOfWeek;

  late final ValueNotifier<DateTime> _date;
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
    final controller =
        AnimationController(debugLabel: 'TimeController', vsync: vsync);
    _animationController = controller;

    final previousPage = value;
    final targetPage = visibleRange.getTargetPageForFocus(page);
    controller.addListener(() {
      value = lerpDouble(previousPage, targetPage, controller.value)!;
    });

    controller.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      controller.dispose();
      _animationController = null;
    });

    await controller.animateTo(1, duration: duration, curve: curve);
  }

  void jumpToToday() => jumpTo(DateTimeTimetable.today());
  void jumpTo(DateTime date) {
    assert(date.isValidTimetableDate);
    jumpToPage(date.page);
  }

  void jumpToPage(double page) =>
      value = visibleRange.getTargetPageForFocus(page);

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
