import 'dart:core' as core;
import 'dart:core' hide Duration;

import 'package:chrono/chrono.dart';
import 'package:flutter/material.dart';

import '../config.dart';
import '../layouts/multi_date.dart';
import '../layouts/recurring_multi_date.dart';
import '../utils.dart';
import 'time_range.dart';
import 'zoom.dart';

/// Controls the visible time range and zoom factor in a [MultiDateTimetable]
/// (or [RecurringMultiDateTimetable]).
///
/// You can programmatically change those via [animateToShowFullDay],
/// [animateTo], [jumpToShowFullDay], or by directly setting the [value].
class TimeController extends ValueNotifier<TimeRange> {
  TimeController({
    TimeDuration minDuration = const Minutes(1),
    TimeDuration? maxDuration,
    TimeRange? initialRange,
    TimeRange? maxRange,
    double? minDayHeight,
  }) : this._(
          minDuration: minDuration.asNanoseconds,
          maxDuration: maxDuration?.asNanoseconds ??
              maxRange?.duration ??
              maxPossibleDuration,
          maxRange: maxRange ?? TimeRange.fullDay,
          initialRange: initialRange ?? _getInitialRange(maxDuration, maxRange),
          minDayHeight: minDayHeight,
        );
  TimeController._({
    required this.minDuration,
    required this.maxDuration,
    required TimeRange initialRange,
    required this.maxRange,
    required this.minDayHeight,
  })  : assert(minDuration.isPositive),
        assert(minDuration <= maxPossibleDuration),
        assert(maxDuration <= maxPossibleDuration),
        assert(minDuration <= maxDuration),
        assert(minDuration <= initialRange.duration),
        assert(initialRange.duration <= maxDuration),
        assert(minDuration <= maxRange.duration),
        assert(maxDuration <= maxRange.duration),
        assert(minDayHeight == null || minDayHeight > 0),
        assert(minDayHeight == null || minDayHeight.isFinite),
        super(initialRange) {
    assert(_isValidRange(initialRange));
  }

  static TimeRange _getInitialRange(
    TimeDuration? maxDuration,
    TimeRange? maxRange,
  ) {
    if (maxDuration != null &&
        maxRange != null &&
        maxDuration <= maxRange.duration) {
      final maxDurationHalf = maxDuration ~/ 2;
      return TimeRange(
        maxRange.centerTime.subtract(maxDurationHalf).unwrap(),
        maxRange.centerTime.add(maxDurationHalf).unwrapOrNull(),
      );
    }
    return maxRange ?? TimeRange.fullDay;
  }

  bool _isValidRange(TimeRange range) {
    if (!maxRange.contains(range)) return false;

    // final max = maxDurationFromMinDayHeightOrDefault;
    // return minDuration.coerceAtMost(max) <= range.duration &&
    //     range.duration <= actualMaxDuration.coerceAtMost(max);
    return actualMinDuration <= range.duration &&
        range.duration <= actualMaxDuration;
  }

  /// The minimum visible duration when zooming in.
  ///
  /// [minDayHeight] takes precedence over this value.
  final Nanoseconds minDuration;

  /// The minimum visible duration, honoring [minDuration] and [minDayHeight].
  Nanoseconds get actualMinDuration =>
      minDuration.coerceAtMost(maxDurationFromMinDayHeightOrDefault);

  /// The maximum visible duration when zooming out.
  final Nanoseconds maxDuration;

  /// The maximum visible duration, honoring [maxDuration] and [minDayHeight].
  Nanoseconds get actualMaxDuration =>
      maxDuration.coerceAtMost(maxDurationFromMinDayHeightOrDefault);

  static final maxPossibleDuration = Nanoseconds.normalDay;

  /// The maximum range that can be revealed when zooming out.
  final TimeRange maxRange;

  @override
  set value(TimeRange value) {
    assert(_isValidRange(value));
    super.value = value;
  }

  // Connected widgets and their heights

  /// The minimum height that a full day can span when zooming out.
  ///
  /// If there are multiple [TimeZoom] widgets using this controller that have
  /// different heights, this value limits the smallest one.
  ///
  /// This takes precedence over [minDuration].
  final double? minDayHeight;

  int _nextClientId = 0;
  final _clients = <TimeControllerClientRegistration>[];

  /// The minimum height of all [TimeControllerClientRegistration]s.
  double? get minClientHeight => _clients.map((it) => it.height).minOrNull;

  Nanoseconds? _maxDurationFromMinDayHeight;

  /// The maximum visible duration when zooming out when evaluating
  /// [minDayHeight] against all registered clients (i.e., widgets using this
  /// controller).
  Nanoseconds? get maxDurationFromMinDayHeight => _maxDurationFromMinDayHeight;
  void _updateMaxDurationFromMinDayHeight() {
    if (minDayHeight == null) {
      _maxDurationFromMinDayHeight = null;
      return;
    }

    final minClientHeight = this.minClientHeight;
    if (minClientHeight == null) {
      _maxDurationFromMinDayHeight = null;
      return;
    }

    final minRangeHeight = minDayHeight! *
        maxRange.duration.dividedByTimeDuration(maxPossibleDuration);
    _maxDurationFromMinDayHeight =
        maxRange.duration.timesDouble(minClientHeight / minRangeHeight);
  }

  Nanoseconds get maxDurationFromMinDayHeightOrDefault =>
      maxDurationFromMinDayHeight ?? maxDuration;

  TimeControllerClientRegistration registerClient(double height) {
    assert(height > 0);
    assert(height.isFinite);

    final client = TimeControllerClientRegistration._(
      this,
      _nextClientId++,
      height: height,
    );
    _clients.add(client);
    _notifyClientHeightsChanged();
    return client;
  }

  void _notifyClientHeightsChanged() {
    assert(_clients.isNotEmpty);
    if (minDayHeight == null) return;

    _updateMaxDurationFromMinDayHeight();
    value = TimeRange.centeredAround(
      value.centerTime,
      value.duration.coerceAtMost(maxDurationFromMinDayHeight!),
    );
  }

  // Animation
  AnimationController? _animationController;

  Future<void> animateToShowFullDay({
    Curve curve = Curves.easeInOut,
    core.Duration duration = const core.Duration(milliseconds: 200),
    required TickerProvider vsync,
  }) {
    assert(maxDuration == maxPossibleDuration);

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
    core.Duration duration = const core.Duration(milliseconds: 200),
    required TickerProvider vsync,
  }) async {
    assert(_isValidRange(newValue));

    cancelAnimation();
    final previousRange = value;
    _animationController =
        AnimationController(debugLabel: 'TimeController', vsync: vsync)
          ..addListener(() {
            value = TimeRange.lerp(
              previousRange,
              newValue,
              _animationController!.value,
            ).unwrap();
          })
          ..animateTo(1, duration: duration, curve: curve);
  }

  void jumpToShowFullDay() {
    cancelAnimation();
    value = TimeRange.fullDay;
  }

  void jumpTo(TimeRange range) {
    assert(_isValidRange(range));

    cancelAnimation();
    value = range;
  }

  void cancelAnimation() {
    _animationController?.dispose();
    _animationController = null;
  }
}

/// Provides the [TimeController] for Timetable widgets below it.
///
/// See also:
///
/// * [TimetableConfig], which bundles multiple configuration widgets for
///   Timetable.
class DefaultTimeController extends InheritedWidget {
  const DefaultTimeController({
    super.key,
    required this.controller,
    required super.child,
  });

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

class TimeControllerClientRegistration {
  TimeControllerClientRegistration._(
    this.controller,
    this.id, {
    required double height,
  })  : assert(id >= 0),
        assert(height > 0),
        assert(height.isFinite),
        _height = height;

  final TimeController controller;
  final int id;

  double _height;
  double get height => _height;

  void notifyHeightChanged(double newHeight) {
    assert(newHeight > 0);
    assert(newHeight.isFinite);
    if (_height == newHeight) return;

    _height = newHeight;
    controller._notifyClientHeightsChanged();
  }

  void unregister() {
    final wasInList = controller._clients.remove(this);
    assert(wasInList);
  }
}
