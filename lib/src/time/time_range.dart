import 'package:chrono/chrono.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oxidized/oxidized.dart';

import 'controller.dart';

// TODO(JonasWanke): use `RangeInclusive<Time>` instead?
/// The value held by [TimeController].
@immutable
class TimeRange {
  const TimeRange(this.startTime, this.endTime)
      : assert(endTime == null || startTime <= endTime);
  factory TimeRange.fromStartAndDuration(
    Time startTime,
    TimeDuration duration,
  ) {
    final endAsDuration = startTime.nanosecondsSinceMidnight + duration;
    assert(endAsDuration <= Hours.normalDay);
    return TimeRange(
      startTime,
      Time.fromTimeSinceMidnight(endAsDuration).unwrapOrNull(),
    );
  }

  factory TimeRange.centeredAround(
    Time center,
    TimeDuration duration, {
    bool canShiftIfDoesntFit = true,
  }) {
    assert(duration.isPositive);
    assert(duration <= Hours.normalDay);

    final TimeRange newRange;
    // TODO(JonasWanke): `timeDuration.dividedByNum(…)`
    final halfDuration = duration.asNanoseconds ~/ 2;
    if (center.nanosecondsSinceMidnight < halfDuration) {
      assert(canShiftIfDoesntFit);
      newRange = TimeRange(
        Time.midnight,
        Time.fromTimeSinceMidnight(duration).unwrap(),
      );
    } else if (center.add(halfDuration).isErr()) {
      assert(canShiftIfDoesntFit);
      newRange = TimeRange(
        Time.fromTimeSinceMidnight(Nanoseconds.normalDay - duration).unwrap(),
        null,
      );
    } else {
      newRange = TimeRange(
        // Ensure that the resulting duration is exactly [duration], even if
        // [halfDuration] was rounded.
        center.add(-duration.asNanoseconds + halfDuration).unwrap(),
        center.add(halfDuration).unwrapOrNull(),
      );
    }
    assert(newRange.duration == duration);
    return newRange;
  }

  static final fullDay = TimeRange(Time.midnight, null);

  final Time startTime;
  // TODO(JonasWanke): `timeDuration.dividedByNum(…)`
  Time get centerTime => startTime.add(duration.asNanoseconds ~/ 2).unwrap();
  final Time? endTime;
  Nanoseconds get duration =>
      (endTime?.nanosecondsSinceMidnight ?? Nanoseconds.normalDay) -
      startTime.nanosecondsSinceMidnight;

  bool contains(TimeRange other) {
    return startTime <= other.startTime &&
        (endTime == null ||
            (other.endTime != null && other.endTime! <= endTime!));
  }

  static Result<TimeRange, String> lerp(TimeRange a, TimeRange b, double t) {
    return Time.lerp(a.startTime, b.startTime, t)
        .andThenAlso(
          () => Option.from(Time.lerpNullable(a.endTime, b.endTime, t))
              .transpose(),
        )
        .map((it) => TimeRange(it.$1, it.$2.toNullable()));
  }

  @override
  int get hashCode => Object.hash(startTime, endTime);
  @override
  bool operator ==(Object other) {
    return other is TimeRange &&
        startTime == other.startTime &&
        endTime == other.endTime;
  }

  @override
  String toString() => 'TimeRange($startTime – $endTime)';
}

extension<T extends Object, E extends Object> on Result<T, E> {
  Result<(T, T2), E> andThenAlso<T2 extends Object>(
    ValueGetter<Result<T2, E>> op,
  ) =>
      andThen((t1) => op().map((t2) => (t1, t2)));
}
