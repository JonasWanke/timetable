import 'package:chrono/chrono.dart';
import 'package:fixed/fixed.dart';
import 'package:flutter/widgets.dart' hide Interval;
import 'package:ranges/ranges.dart';

export 'package:collection/collection.dart';
export 'package:dart_date/dart_date.dart' show Interval;
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

extension FractionalSecondsTimetableInternal on FractionalSeconds {
  FractionalSeconds coerceAtLeast(FractionalSeconds min) =>
      this < min ? min : this;
  FractionalSeconds coerceAtMost(FractionalSeconds max) =>
      this > max ? max : this;
  FractionalSeconds coerceIn(FractionalSeconds min, FractionalSeconds max) =>
      coerceAtLeast(min).coerceAtMost(max);
}

extension FixedTimetableInternal on Fixed {
  double toDouble() => toDecimal().toDouble();
}

typedef YearMonthWidgetBuilder = Widget Function(
  BuildContext context,
  YearMonth yearMonth,
);
typedef YearWeekWidgetBuilder = Widget Function(
  BuildContext context,
  YearWeek yearWeek,
);
typedef DateWidgetBuilder = Widget Function(BuildContext context, Date date);

extension DateTimeTimetable on DateTime {
  static DateTime fromPage(double page) {
    return DateTime.fromDurationSinceUnixEpoch(
      FractionalSeconds.normalDay.timesNum(page),
    );
  }

  double get page {
    return durationSinceUnixEpoch
        .dividedByTimeDuration(Hours.normalDay)
        .toDecimal()
        .toDouble();
  }
}

extension DateTimetable on Date {
  static Date fromPage(int page) => Date.fromDaysSinceUnixEpoch(Days(page));

  int get page => daysSinceUnixEpoch.inDays;

  // TODO(JonasWanke): Move to Chrono
  Range<DateTime> get fullDayRange => Range(atMidnight, next.atMidnight);
}

extension TimeDurationTimetableInternal on TimeDuration {
  double get dayFraction =>
      dividedByTimeDuration(FractionalSeconds.normalDay).toDouble();
}

extension TimeTimetableInternal on Time {
  double get dayFraction => fractionalSecondsSinceMidnight.dayFraction;
}

extension NullableTimeTimetableInternal on Time? {
  double get dayFraction => this?.dayFraction ?? 1;
}
