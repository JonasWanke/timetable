import 'package:chrono/chrono.dart';
import 'package:flutter/widgets.dart';

class InheritedTimetableDate extends InheritedWidget {
  const InheritedTimetableDate({
    super.key,
    required this.date,
    required super.child,
  });

  final Date date;

  @override
  bool updateShouldNotify(covariant InheritedTimetableDate oldWidget) =>
      date != oldWidget.date;

  static Date of(BuildContext context) {
    final date = maybeOf(context);
    if (date == null) {
      throw FlutterError('No `InheritedTimetableDate` found in context.');
    }
    return date;
  }

  static Date? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InheritedTimetableDate>()
      ?.date;
}
