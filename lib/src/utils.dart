import 'package:dart_date/dart_date.dart' show Interval;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' hide Interval;

import 'week.dart';

export 'package:collection/collection.dart';
export 'package:dart_date/dart_date.dart' show Interval;
export 'package:dartx/dartx.dart' show IntRangeToExtension, IterableMinBy;

export 'utils/listenable.dart';
export 'utils/size_reporting_widget.dart';

extension DoubleTimetable on double {
  double coerceAtLeast(double min) => this < min ? min : this;
  double coerceAtMost(double max) => this > max ? max : this;
  double coerceIn(double min, double max) =>
      coerceAtLeast(min).coerceAtMost(max);
}

extension ComparableTimetable<T extends Comparable<T>> on T {
  bool operator <(T other) => compareTo(other) < 0;
  bool operator <=(T other) => compareTo(other) <= 0;
  bool operator >(T other) => compareTo(other) > 0;
  bool operator >=(T other) => compareTo(other) >= 0;

  T coerceAtLeast(T min) => (this < min) ? min : this;
  T coerceAtMost(T max) => this > max ? max : this;
  T coerceIn(T min, T max) => coerceAtLeast(min).coerceAtMost(max);
}

typedef MonthWidgetBuilder = Widget Function(
  BuildContext context,
  DateTime month,
);
typedef WeekWidgetBuilder = Widget Function(BuildContext context, Week week);
typedef DateWidgetBuilder = Widget Function(
  BuildContext context,
  DateTime date,
);

extension DateTimeTimetable on DateTime {
  static DateTime date(int year, [int month = 1, int day = 1]) {
    final date = DateTime.utc(year, month, day);
    assert(date.debugCheckIsValidTimetableDate());
    return date;
  }

  static DateTime month(int year, int month) {
    final date = DateTime.utc(year, month, 1);
    assert(date.debugCheckIsValidTimetableMonth());
    return date;
  }

  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    bool? isUtc,
  }) {
    return InternalDateTimeTimetable.create(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
      millisecond: millisecond ?? this.millisecond,
      isUtc: isUtc ?? this.isUtc,
    );
  }

  Duration get timeOfDay => difference(atStartOfDay);

  DateTime get atStartOfDay =>
      copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
  bool get isAtStartOfDay => this == atStartOfDay;
  DateTime get atEndOfDay =>
      copyWith(hour: 23, minute: 59, second: 59, millisecond: 999);
  bool get isAtEndOfDay => this == atEndOfDay;

  static DateTime now() {
    final date = DateTime.now().copyWith(isUtc: true);
    assert(date.debugCheckIsValidTimetableDateTime());
    return date;
  }

  static DateTime today() {
    final date = DateTimeTimetable.now().atStartOfDay;
    assert(date.debugCheckIsValidTimetableDate());
    return date;
  }

  static DateTime currentMonth() {
    final month = DateTimeTimetable.today().firstDayOfMonth;
    assert(month.debugCheckIsValidTimetableMonth());
    return month;
  }

  bool get isToday => atStartOfDay == DateTimeTimetable.today();

  Interval get fullDayInterval {
    assert(debugCheckIsValidTimetableDate());
    return Interval(this, atEndOfDay);
  }

  DateTime nextOrSame(int dayOfWeek) {
    assert(debugCheckIsValidTimetableDate());
    assert(weekday.debugCheckIsValidTimetableDayOfWeek());

    return this + ((dayOfWeek - weekday) % DateTime.daysPerWeek).days;
  }

  DateTime previousOrSame(int weekday) {
    assert(debugCheckIsValidTimetableDate());
    assert(weekday.debugCheckIsValidTimetableDayOfWeek());

    return this - ((this.weekday - weekday) % DateTime.daysPerWeek).days;
  }

  int get daysInMonth {
    final february = isLeapYear ? 29 : 28;
    final index = this.month - 1;
    return [31, february, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][index];
  }

  DateTime get firstDayOfMonth => atStartOfDay.copyWith(day: 1);
  DateTime get lastDayOfMonth => copyWith(day: daysInMonth);

  DateTime roundTimeToMultipleOf(Duration duration) {
    assert(duration.debugCheckIsValidTimetableTimeOfDay());
    return atStartOfDay + duration * (timeOfDay / duration).floor();
  }

  double get page {
    assert(debugCheckIsValidTimetableDateTime());
    return millisecondsSinceEpoch / Duration.millisecondsPerDay;
  }

  int get datePage {
    assert(debugCheckIsValidTimetableDate());
    return page.floor();
  }

  static DateTime dateFromPage(int page) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      (page * Duration.millisecondsPerDay).toInt(),
      isUtc: true,
    );
    assert(date.debugCheckIsValidTimetableDate());
    return date;
  }

  static DateTime dateTimeFromPage(double page) {
    return DateTime.fromMillisecondsSinceEpoch(
      (page * Duration.millisecondsPerDay).toInt(),
      isUtc: true,
    );
  }
}

class DateDiagnosticsProperty extends DiagnosticsProperty<DateTime> {
  /// Create a diagnostics property for [Color].
  ///
  /// The [showName], [style], and [level] arguments must not be null.
  DateDiagnosticsProperty(
    String super.name,
    super.value, {
    super.showName,
    super.defaultValue,
    super.style,
    super.level,
  }) : assert(value.isValidTimetableDate);

  @override
  String valueToString({TextTreeConfiguration? parentConfiguration}) {
    final value = this.value;
    if (value == null) return value.toString();

    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

extension InternalDateTimeTimetable on DateTime {
  static DateTime create({
    required int year,
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    bool isUtc = true,
  }) {
    final constructor = isUtc ? DateTime.utc : DateTime.new;
    return constructor(year, month, day, hour, minute, second, millisecond);
  }

  DateTime operator +(Duration duration) => add(duration);
  DateTime operator -(Duration duration) => subtract(duration);

  bool operator <(DateTime other) => isBefore(other);
  bool operator <=(DateTime other) =>
      isBefore(other) || isAtSameMomentAs(other);
  bool operator >(DateTime other) => isAfter(other);
  bool operator >=(DateTime other) => isAfter(other) || isAtSameMomentAs(other);

  static final List<int> innerDateHours =
      List.generate(Duration.hoursPerDay - 1, (i) => i + 1);
}

extension NullableDateTimeTimetable on DateTime? {
  bool get isValidTimetableDateTime => this == null || this!.isUtc;
  bool debugCheckIsValidTimetableDateTime() {
    assert(() {
      if (isValidTimetableDateTime) return true;

      throw FlutterError.fromParts([
        ErrorSummary('Invalid DateTime for timetable: `$this`'),
        ..._dateTimeExplanation,
      ]);
    }());
    return true;
  }

  bool get isValidTimetableDate =>
      isValidTimetableDateTime && (this == null || this!.isAtStartOfDay);
  bool debugCheckIsValidTimetableDate() {
    assert(() {
      if (isValidTimetableDate) return true;

      throw FlutterError.fromParts([
        ErrorSummary('Invalid date for timetable: `$this`'),
        ..._dateExplanation,
      ]);
    }());
    return true;
  }

  static final _dateTimeExplanation = [
    ErrorDescription(
      'A valid `DateTime` for timetable must have `isUtc` set to `true`.',
    ),
    ErrorHint(
      'The actual time zone is ignored when displaying events, timetable '
      'only uses the `year`, `month`, `day`, `hour`, `minute`, `second`, '
      'and `millisecond` fields.',
    ),
    _localDateTimeNotUtcExplanation,
    _localDateTimeToTimetableExplanation,
  ];
  static final _dateExplanation = [
    ErrorDescription(
      'A valid date for timetable must be a valid `DateTime` for timetable '
      'and be at midnight.',
    ),
    ErrorHint(
      'The actual time zone is ignored when displaying events, timetable '
      'only uses the `year`, `month`, and `day` fields.',
    ),
    _localDateTimeNotUtcExplanation,
    _localDateTimeToTimetableExplanation,
  ];
  static final _localDateTimeNotUtcExplanation = ErrorHint(
    "We're not using `DateTime.utc(…)` to represent a `DateTime` in UTC, but "
    'to represent a `DateTime` independent of time zones because these are '
    'not relevant for the calendar widgets. Other languages like Kotlin/Java '
    'or C# have separate types for these: `Instant` is a point in time, '
    'whereas `LocalDateTime` only has a time-zone-independent date and time '
    '(which is what we want).',
  );
  static final _localDateTimeToTimetableExplanation = ErrorHint(
    'To convert a `DateTime` with `isUtc` set to `false` (i.e., a local one) '
    'into a `DateTime` for timetable, use our provided extension method '
    '`dateTime.copyWith(isUtc: true)` instead of `dateTime.toUtc()`.',
  );

  bool get isValidTimetableMonth =>
      isValidTimetableDate && (this == null || this!.day == 1);
  bool debugCheckIsValidTimetableMonth() {
    assert(() {
      if (isValidTimetableMonth) return true;

      throw FlutterError.fromParts([
        ErrorSummary('Invalid month for timetable: `$this`'),
        ErrorDescription(
          'A valid month for timetable must be a valid month for timetable '
          'and be the first day of the month.',
        ),
        ErrorHint(
          'The actual time zone is ignored when displaying events, timetable '
          'only uses the `year` and `month` fields.',
        ),
        _localDateTimeNotUtcExplanation,
        _localDateTimeToTimetableExplanation,
      ]);
    }());
    return true;
  }
}

extension InternalDurationTimetable on Duration {
  double operator /(Duration other) => inMicroseconds / other.inMicroseconds;
}

extension NullableDurationTimetable on Duration? {
  bool get isValidTimetableTimeOfDay =>
      this == null || (0.days <= this! && this! <= 1.days);
  bool debugCheckIsValidTimetableTimeOfDay() {
    assert(() {
      if (isValidTimetableTimeOfDay) return true;

      throw FlutterError.fromParts([
        ErrorSummary('Invalid time of day for timetable: `$this`'),
        ErrorDescription(
          'A time of the day must be a `Duration` between `Duration.zero` '
          '(midnight / start of the day) and `Duration(days: 1)` (midnight / '
          'end of the day), inclusive.',
        ),
      ]);
    }());
    return true;
  }
}

extension InternalNumTimetable on num {
  Duration get weeks => (this * DateTime.daysPerWeek).days;
  Duration get days => (this * Duration.hoursPerDay).hours;
  Duration get hours => (this * Duration.minutesPerHour).minutes;
  Duration get minutes => (this * Duration.secondsPerMinute).seconds;
  Duration get seconds =>
      (this * Duration.millisecondsPerSecond).round().milliseconds;
}

extension InternalIntTimetable on int {
  Duration get milliseconds => Duration(milliseconds: this);
}

extension NullableIntTimetable on int? {
  bool get isValidTimetableDayOfWeek =>
      this == null || (DateTime.monday <= this! && this! <= DateTime.sunday);
  bool debugCheckIsValidTimetableDayOfWeek() {
    assert(() {
      if (isValidTimetableDayOfWeek) return true;

      throw FlutterError.fromParts([
        ErrorSummary('Invalid day of week for timetable: `$this`'),
        ErrorDescription(
          'A day of the week must be an integer between ${DateTime.monday} '
          '(Monday) and ${DateTime.sunday} (Sunday), inclusive.',
        ),
      ]);
    }());
    return true;
  }

  bool get isValidTimetableMonth =>
      this == null || (1 <= this! && this! <= DateTime.monthsPerYear);
  bool debugCheckIsValidTimetableMonth() {
    assert(() {
      if (isValidTimetableMonth) return true;

      throw FlutterError.fromParts([
        ErrorSummary('Invalid month for timetable: `$this`'),
        ErrorDescription(
          'A month must be an integer between 1 (January) and '
          '${DateTime.monthsPerYear} (December), inclusive.',
        ),
      ]);
    }());
    return true;
  }
}

extension IntervalTimetable on Interval {
  bool intersects(Interval other) => start <= other.end && end >= other.start;

  Interval get dateInterval {
    final interval = Interval(
      start.atStartOfDay,
      (end - 1.milliseconds).atEndOfDay,
    );
    assert(interval.debugCheckIsValidTimetableDateInterval());
    return interval;
  }
}

extension NullableIntervalTimetable on Interval? {
  bool get isValidTimetableInterval {
    if (this == null) return true;
    return this!.start.isValidTimetableDateTime &&
        this!.end.isValidTimetableDateTime;
  }

  bool debugCheckIsValidTimetableInterval() {
    assert(() {
      if (isValidTimetableInterval) return true;

      throw FlutterError.fromParts([
        ErrorSummary('Invalid interval for timetable: `$this`'),
        ErrorDescription(
          'A (date/time) interval for timetable must have valid timetable '
          '`DateTime`s for its `start` and `end`.',
        ),
        ErrorHint(
          'The actual time zone is ignored when displaying events, timetable '
          'only uses the `year`, `month`, `day`, `hour`, `minute`, `second`, '
          'and `millisecond` fields.',
        ),
        ...NullableDateTimeTimetable._dateTimeExplanation,
      ]);
    }());
    return true;
  }

  bool get isValidTimetableDateInterval {
    return isValidTimetableInterval &&
        (this == null ||
            (this!.start.isValidTimetableDate && this!.end.isAtEndOfDay));
  }

  bool debugCheckIsValidTimetableDateInterval() {
    assert(() {
      if (isValidTimetableDateInterval) return true;

      throw FlutterError.fromParts([
        ErrorSummary('Invalid date interval for timetable: `$this`'),
        ErrorDescription(
          'A date interval for timetable must have a valid timetable date for '
          'its `start` and a valid timetable `DateTime` at with '
          '`dateTime.isAtEndOfDay` for `end`.',
        ),
        ErrorHint(
          'The actual time zone is ignored when displaying events, timetable '
          'only uses the `year`, `month`, `day`, `hour`, `minute`, `second`, '
          'and `millisecond` fields.',
        ),
        ...NullableDateTimeTimetable._dateTimeExplanation,
      ]);
    }());
    return true;
  }
}
