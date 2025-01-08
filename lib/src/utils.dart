import 'package:chrono/chrono.dart';
import 'package:flutter/widgets.dart' hide Interval;

export 'package:collection/collection.dart';
export 'package:dartx/dartx.dart'
    show
        ComparableCoerceAtLeastExtension,
        ComparableCoerceAtMostExtension,
        ComparableCoerceInExtension,
        IterableMapNotNull,
        IterableMinBy,
        IterableSecondItem,
        NumCoerceAtLeastExtension,
        NumCoerceAtMostExtension;

export 'utils/listenable.dart';
export 'utils/size_reporting_widget.dart';

extension DoubleTimetableInternal on double {
  double coerceAtLeast(double min) => this < min ? min : this;
  double coerceAtMost(double max) => this > max ? max : this;
  double coerceIn(double min, double max) =>
      coerceAtLeast(min).coerceAtMost(max);
}

extension NanosecondsTimetableInternal on Nanoseconds {
  Nanoseconds coerceAtLeast(TimeDuration min) =>
      this < min.asNanoseconds ? min.asNanoseconds : this;
  Nanoseconds coerceAtMost(TimeDuration max) =>
      this > max.asNanoseconds ? max.asNanoseconds : this;
  Nanoseconds coerceIn(TimeDuration min, TimeDuration max) =>
      coerceAtLeast(min).coerceAtMost(max);
}

typedef YearMonthWidgetBuilder = Widget Function(
  BuildContext context,
  YearMonth yearMonth,
);
typedef YearWeekWidgetBuilder = Widget Function(
  BuildContext context,
  IsoYearWeek yearWeek,
);
typedef DateWidgetBuilder = Widget Function(BuildContext context, Date date);

extension CDateTimeTimetable on CDateTime {
  static CDateTime fromPage(double page) {
    return Instant.fromDurationSinceUnixEpoch(
      Nanoseconds.normalDay.timesDouble(page),
    ).dateTimeInUtc;
  }

  double get page =>
      durationSinceUnixEpoch.dividedByTimeDuration(Hours.normalDay);
}

extension DateTimetable on Date {
  static Date fromPage(int page) => Date.fromDaysSinceUnixEpoch(Days(page));

  int get page => daysSinceUnixEpoch.inDays;
}

extension TimeDurationTimetableInternal on TimeDuration {
  double get dayFraction => dividedByTimeDuration(Nanoseconds.normalDay);
}

extension TimeTimetableInternal on Time {
  double get dayFraction => nanosecondsSinceMidnight.dayFraction;
}

extension NullableTimeTimetableInternal on Time? {
  double get dayFraction => this?.dayFraction ?? 1;
}
