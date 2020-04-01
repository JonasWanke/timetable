import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

import 'controller.dart';
import 'timetable.dart';

abstract class VisibleRange {
  const VisibleRange({
    @required this.visibleDays,
  })  : assert(visibleDays != null),
        assert(visibleDays > 0);

  const factory VisibleRange.days(int count) = DaysVisibleRange;
  const factory VisibleRange.week() = WeekVisibleRange;

  final int visibleDays;
}

class DaysVisibleRange extends VisibleRange {
  const DaysVisibleRange(int count) : super(visibleDays: count);
}

/// The [Timetable] will show exactly one week and will snap to week boundaries.
///
/// You can configure the first day of a week via
/// [TimetableController.firstDayOfWeek].
class WeekVisibleRange extends VisibleRange {
  const WeekVisibleRange() : super(visibleDays: TimeConstants.daysPerWeek);
}
