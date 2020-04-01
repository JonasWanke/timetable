import 'package:flutter/foundation.dart';
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

typedef Mapper<T, R> = R Function(T data);

extension MapListenable<T> on ValueListenable<T> {
  ValueListenable<R> map<R>(Mapper<T, R> mapper) =>
      _MapValueListenable(this, mapper);
}

class _MapValueListenable<T, R> extends ValueNotifier<R> {
  _MapValueListenable(this.listenable, this.mapper)
      : assert(listenable != null),
        assert(mapper != null),
        super(mapper(listenable.value)) {
    listenable.addListener(_listener);
  }

  final ValueListenable<T> listenable;
  final Mapper<T, R> mapper;

  @override
  void dispose() {
    listenable.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    value = mapper(listenable.value);
  }
}
