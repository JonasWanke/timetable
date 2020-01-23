import 'dart:math' as math;

import 'package:time_machine/time_machine.dart';

extension LocalDateTimeExtension on LocalDateTime {
  static LocalDateTime minIsoValue =
      LocalDate.minIsoValue.at(LocalTime.minValue);
  static LocalDateTime maxIsoValue =
      LocalDate.maxIsoValue.at(LocalTime.maxValue);
}

extension NumberIterableExtension<T extends num> on Iterable<T> {
  T get max => isEmpty ? null : reduce(math.max);
}
