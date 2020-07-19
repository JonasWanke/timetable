import 'package:flutter_test/flutter_test.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/timetable.dart';

void main() {
  test('formatHour is null by default', () {
    final theme = TimetableThemeData();
    expect(theme.formatHour, isNull);
  });
  test('format hour', () {
    final theme = TimetableThemeData(formatHour: (time) => '${time.hourOfDay}');
    final hourString = theme.formatHour(LocalTime(9, 42, 00));
    expect(hourString, '9');
  });
}