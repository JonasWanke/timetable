import 'package:flutter/widgets.dart';

import 'utils.dart';

typedef WeekTapCallback = void Function(WeekInfo week);
typedef DateTapCallback = void Function(DateTime date);
typedef DateBackgroundTapCallback = void Function(DateTime dateTime);

@immutable
class TimetableCallbacks {
  const TimetableCallbacks({
    this.onWeekTap,
    this.onDateTap,
    this.onDateBackgroundTap,
  });

  final WeekTapCallback? onWeekTap;
  final DateTapCallback? onDateTap;
  final DateBackgroundTapCallback? onDateBackgroundTap;

  @override
  int get hashCode => hashValues(onWeekTap, onDateTap, onDateBackgroundTap);
  @override
  bool operator ==(Object other) {
    return other is TimetableCallbacks &&
        onWeekTap == other.onWeekTap &&
        onDateTap == other.onDateTap &&
        onDateBackgroundTap == other.onDateBackgroundTap;
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
