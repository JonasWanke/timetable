import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

abstract class VisibleRange {
  const VisibleRange({
    @required this.visibleDays,
  })  : assert(visibleDays != null),
        assert(visibleDays > 0);

  const factory VisibleRange.days(int count) = DaysVisibleRange;
  const factory VisibleRange.week([DayOfWeek firstDayOfWeek]) =
      WeekVisibleRange;

  final int visibleDays;
}

class DaysVisibleRange extends VisibleRange {
  const DaysVisibleRange(int count) : super(visibleDays: count);
}

class WeekVisibleRange extends VisibleRange {
  const WeekVisibleRange([this.firstDayOfWeek = DayOfWeek.monday])
      : assert(firstDayOfWeek != null),
        super(visibleDays: TimeConstants.daysPerWeek);

  final DayOfWeek firstDayOfWeek;
}
