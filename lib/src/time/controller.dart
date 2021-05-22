import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../utils.dart';
import 'time_range.dart';

class TimeController extends ValueNotifier<TimeRange> {
  TimeController({
    this.minDuration = const Duration(minutes: 1),
    TimeRange? initialRange,
    TimeRange? maxRange,
  })  : assert(!minDuration.isNegative),
        assert(minDuration <= 1.days),
        assert(initialRange == null || initialRange.duration >= minDuration),
        maxRange = maxRange ?? TimeRange.fullDay,
        assert(maxRange == null || maxRange.duration >= minDuration),
        assert(
          initialRange == null ||
              _isValidRange(
                initialRange,
                minDuration,
                maxRange ?? TimeRange.fullDay,
              ),
        ),
        super(initialRange ?? maxRange ?? TimeRange.fullDay);

  static bool _isValidRange(
    TimeRange range,
    Duration minDuration,
    TimeRange maxRange,
  ) =>
      range.duration >= minDuration && maxRange.contains(range);

  /// The minimum visible duration when zooming in.
  final Duration minDuration;

  /// The maximum [TimeRange] that can be revealed when zooming out.
  final TimeRange maxRange;

  @override
  set value(TimeRange value) {
    assert(value.duration >= minDuration);
    assert(maxRange.contains(value));
    super.value = value;
  }

  // Animation
  AnimationController? _animationController;

  Future<void> animateToShowFullDay({
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 200),
    required TickerProvider vsync,
  }) {
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
    assert(_isValidRange(newValue, minDuration, maxRange));

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
