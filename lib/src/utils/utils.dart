import 'package:flutter/foundation.dart';
import 'package:time_machine/time_machine.dart';

extension TimetableLocalDate on LocalDate {
  bool get isToday => this == LocalDate.today(calendar);
}

final List<int> innerDateHours =
    List.generate(TimeConstants.hoursPerDay - 1, (i) => i + 1);

extension TimetableDateInterval on DateInterval {
  Iterable<LocalDate> get dates => Iterable.generate(length, start.addDays);
}

typedef Mapper<T, R> = R Function(T data);

extension MapListenable<T> on ValueListenable<T> {
  ValueNotifier<R> map<R>(Mapper<T, R> mapper) =>
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
