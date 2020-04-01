import 'package:time_machine/time_machine.dart';

extension TimetableLocalDate on LocalDate {
  bool get isToday => this == LocalDate.today();
}

final List<int> innerDateHours =
    List.generate(TimeConstants.hoursPerDay - 1, (i) => i + 1);

extension TimetableLocalDateTime on LocalDateTime {
  static LocalDateTime minIsoValue =
      LocalDate.minIsoValue.at(LocalTime.minValue);
  static LocalDateTime maxIsoValue =
      LocalDate.maxIsoValue.at(LocalTime.maxValue);
}
