import 'package:meta/meta.dart';

import 'utils.dart';

extension DateTimeWeekTimetable on DateTime {
  Week get week => Week.forDate(this);

  int get dayOfYear {
    const common = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
    const leapOffsets = [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335];
    final offsets = isLeapYear ? leapOffsets : common;
    return offsets[month - 1] + day;
  }

  bool get isLeapYear => year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
}

@immutable
class Week implements Comparable<Week> {
  const Week(this.weekBasedYear, this.weekOfYear)
      : assert(weekOfYear >= 1 && weekOfYear <= 53);

  factory Week.forDate(DateTime date) {
    assert(date.debugCheckIsValidTimetableDate());

    // Algorithm from https://en.wikipedia.org/wiki/ISO_week_date#Calculating_the_week_number_from_a_month_and_day_of_the_month_or_ordinal_date
    final year = date.year;
    final weekOfYear = (date.dayOfYear + 10 - date.weekday) ~/ 7;

    if (weekOfYear == 0) {
      // If the week number thus obtained equals 0, it means that the given date
      // belongs to the preceding (week-based) year.
      final weekOfYear =
          DateTimeTimetable.date(year - 1, 12, 31).week.weekOfYear;
      return Week(year - 1, weekOfYear);
    }

    if (weekOfYear == 53 &&
        DateTime(year, 12, 31).weekday < DateTime.thursday) {
      // If a week number of 53 is obtained, one must check that the date is not
      // actually in week 1 of the following year.
      return Week(year + 1, 1);
    }

    return Week(year, weekOfYear);
  }

  final int weekBasedYear;
  final int weekOfYear;

  DateTime getDayOfWeek(int dayOfWeek) {
    assert(dayOfWeek.debugCheckIsValidTimetableDayOfWeek());

    // Algorithm from https://en.wikipedia.org/wiki/ISO_week_date#`Calculating_an_ordinal_or_month_date_from_a_week_date`
    final base = weekOfYear * DateTime.daysPerWeek + dayOfWeek;
    final yearCorrection =
        DateTimeTimetable.date(weekBasedYear, 1, 4).weekday + 3;
    return DateTimeTimetable.date(weekBasedYear, 1, 1) +
        (base - yearCorrection - 1).days;
  }

  @override
  int compareTo(Week other) {
    final result = weekBasedYear.compareTo(other.weekBasedYear);
    if (result != 0) return result;
    return weekOfYear.compareTo(other.weekOfYear);
  }

  @override
  int get hashCode => Object.hash(weekBasedYear, weekOfYear);
  @override
  bool operator ==(Object other) {
    return other is Week &&
        other.weekBasedYear == weekBasedYear &&
        other.weekOfYear == weekOfYear;
  }

  @override
  String toString() {
    final paddedWeek = weekOfYear < 10 ? '0$weekOfYear' : weekOfYear.toString();
    return '$weekBasedYear-W$paddedWeek';
  }
}
