import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../config.dart';
import '../layouts/multi_date.dart';
import '../layouts/recurring_multi_date.dart';
import '../utils.dart';
import 'time_range.dart';

/// Controls the visible time range and zoom factor in a [MultiDateTimetable]
/// (or [RecurringMultiDateTimetable]).
///
/// You can programmatically change those via [animateToShowFullDay],
/// [animateTo], [jumpToShowFullDay], or by directly setting the [value].
class TimeController extends ValueNotifier<TimeRange> {
  TimeController({
    this.minDuration = const Duration(minutes: 1),
    Duration? maxDuration,
    TimeRange? initialRange,
    TimeRange? maxRange,
  })  : assert(!minDuration.isNegative),
        assert(minDuration <= 1.days),
        assert(maxDuration == null || maxDuration <= 1.days),
        assert(maxDuration == null || minDuration <= maxDuration),
        maxDuration = maxDuration ?? maxRange?.duration ?? 1.days,
        assert(initialRange == null || minDuration <= initialRange.duration),
        assert(
          maxDuration == null ||
              initialRange == null ||
              initialRange.duration <= maxDuration,
        ),
        assert(maxRange == null || minDuration <= maxRange.duration),
        assert(
          maxDuration == null ||
              maxRange == null ||
              maxDuration <= maxRange.duration,
        ),
        maxRange = maxRange ?? TimeRange.fullDay,
        super(initialRange ?? _getInitialRange(maxDuration, maxRange)) {
    assert(initialRange == null || _isValidRange(initialRange));
  }

  static TimeRange _getInitialRange(
    Duration? maxDuration,
    TimeRange? maxRange,
  ) {
    if (maxDuration != null &&
        maxRange != null &&
        maxDuration <= maxRange.duration) {
      final maxDurationHalf = maxDuration * (1 / 2);
      return TimeRange(
        maxRange.centerTime - maxDurationHalf,
        maxRange.centerTime + maxDurationHalf,
      );
    }
    return maxRange ?? TimeRange.fullDay;
  }

  bool _isValidRange(TimeRange range) {
    return minDuration <= range.duration &&
        range.duration <= maxDuration &&
        maxRange.contains(range);
  }

  /// The minimum visible duration when zooming in.
  final Duration minDuration;

  /// The maximim visible duration when zooming out.
  final Duration maxDuration;

  /// The maximum range that can be revealed when zooming out.
  final TimeRange maxRange;

  @override
  set value(TimeRange value) {
    assert(_isValidRange(value));
    super.value = value;
  }

  // Animation
  AnimationController? _animationController;

  Future<void> animateToShowFullDay({
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 200),
    required TickerProvider vsync,
  }) {
    assert(maxDuration == 1.days);

    return animateTo(
      TimeRange.fullDay,
      curve: curve,
      duration: duration,
      vsync: vsync,
    );
  }

  Future<void> animateTo(
    TimeRange newValue, {
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 200),
    required TickerProvider vsync,
  }) async {
    assert(_isValidRange(newValue));

    _animationController?.dispose();
    final previousRange = value;
    _animationController =
        AnimationController(debugLabel: 'TimeController', vsync: vsync)
          ..addListener(() {
            value = TimeRange.lerp(
              previousRange,
              newValue,
              _animationController!.value,
            );
          })
          ..animateTo(1, duration: duration, curve: curve);
  }

  void jumpToShowFullDay() => value = TimeRange.fullDay;
}

/// Provides the [TimeController] for Timetable widgets below it.
///
/// See also:
///
/// * [TimetableConfig], which bundles multiple configuration widgets for
///   Timetable.
class DefaultTimeController extends InheritedWidget {
  const DefaultTimeController({
    required this.controller,
    required Widget child,
  }) : super(child: child);

  final TimeController controller;

  @override
  bool updateShouldNotify(DefaultTimeController oldWidget) =>
      controller != oldWidget.controller;

  static TimeController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DefaultTimeController>()
        ?.controller;
  }
}
