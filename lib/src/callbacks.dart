import 'package:flutter/widgets.dart';

import 'week.dart';

typedef WeekTapCallback = void Function(WeekInfo week);
typedef DateTapCallback = void Function(DateTime date);
typedef DateTimeTapCallback = void Function(DateTime dateTime);

@immutable
class TimetableCallbacks {
  const TimetableCallbacks({
    this.onWeekTap,
    this.onDateTap,
    this.onDateBackgroundTap,
    this.onDateTimeBackgroundTap,
  });

  final WeekTapCallback? onWeekTap;
  final DateTapCallback? onDateTap;
  final DateTapCallback? onDateBackgroundTap;
  final DateTimeTapCallback? onDateTimeBackgroundTap;

  @override
  int get hashCode => hashValues(
        onWeekTap,
        onDateTap,
        onDateBackgroundTap,
        onDateTimeBackgroundTap,
      );
  @override
  bool operator ==(Object other) {
    return other is TimetableCallbacks &&
        onWeekTap == other.onWeekTap &&
        onDateTap == other.onDateTap &&
        onDateBackgroundTap == other.onDateBackgroundTap &&
        onDateTimeBackgroundTap == other.onDateTimeBackgroundTap;
  }
}

class DefaultTimetableCallbacks extends InheritedWidget {
  const DefaultTimetableCallbacks({
    required this.callbacks,
    required Widget child,
  }) : super(child: child);

  final TimetableCallbacks callbacks;

  @override
  bool updateShouldNotify(DefaultTimetableCallbacks oldWidget) =>
      callbacks != oldWidget.callbacks;

  static TimetableCallbacks? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DefaultTimetableCallbacks>()
        ?.callbacks;
  }
}
