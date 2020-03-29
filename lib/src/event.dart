import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

abstract class Event {
  Event({
    @required this.id,
    @required this.start,
    @required this.end,
  })  : assert(id != null),
        assert(start != null),
        assert(end != null);

  final Object id;
  final LocalDateTime start;
  final LocalDateTime end;
}

extension TimetableEvent on Event {
  bool intersectsDate(LocalDate date) =>
      start <= date.at(LocalTime.maxValue) &&
      end >= date.at(LocalTime.minValue);
}
