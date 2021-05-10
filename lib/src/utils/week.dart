import 'dart:ui';

import 'package:meta/meta.dart';

import '../utils.dart';

extension DateTimeWeekInfoTimetable on DateTime {
  WeekInfo get weekInfo => WeekInfo.forDate(this);

  int get dayOfYear {
    const common = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
    const leapOffsets = [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335];
    final offsets = isLeapYear ? leapOffsets : common;
    return offsets[month - 1] + day;
  }

  bool get isLeapYear => year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
}

@immutable
class WeekInfo implements Comparable<WeekInfo> {
  const WeekInfo(this.weekBasedYear, this.weekOfYear)
      : assert(weekOfYear >= 1 && weekOfYear <= 53);

  factory WeekInfo.forDate(DateTime date) {
    assert(date.isValidTimetableDate);

    // Algorithm from https://en.wikipedia.org/wiki/ISO_week_date#Algorithms
    final year = date.year;
    final weekOfYear = (10 + date.dayOfYear - date.weekday) ~/ 7;

    if (weekOfYear == 0) {
      // If the week number thus obtained equals 0, it means that the given date
      // belongs to the preceding (week-based) year.
      return WeekInfo(year - 1, DateTime(year - 1, 12, 31).weekInfo.weekOfYear);
    }

    if (weekOfYear == 53 &&
        DateTime(year, 12, 31).weekday < DateTime.thursday) {
      // If a week number of 53 is obtained, one must check that the date is not
      // actually in week 1 of the following year.
      return WeekInfo(year + 1, 1);
    }

    return WeekInfo(year, weekOfYear);
  }

  final int weekBasedYear;
  final int weekOfYear;

  @override
  int compareTo(WeekInfo other) {
    final result = weekBasedYear.compareTo(other.weekBasedYear);
    if (result != 0) return result;
    return weekOfYear.compareTo(other.weekOfYear);
  }

  @override
  int get hashCode => hashValues(weekBasedYear, weekOfYear);

  @override
  bool operator ==(Object other) {
    return other is WeekInfo &&
        other.weekBasedYear == weekBasedYear &&
        other.weekOfYear == weekOfYear;
  }

  @override
  String toString() =>
      'WeekInfo(weekBasedYear = $weekBasedYear, weekOfYear = $weekOfYear)';
}
