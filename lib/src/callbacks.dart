import 'package:flutter/widgets.dart';

import 'components/date_content.dart';
import 'components/date_header.dart';
import 'components/multi_date_event_header.dart';
import 'components/week_indicator.dart';
import 'week.dart';

typedef WeekTapCallback = void Function(Week week);
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

  /// Called when the user taps on a week.
  ///
  /// Used internally by [WeekIndicator].
  final WeekTapCallback? onWeekTap;

  /// Called when the user taps on a date.
  ///
  /// You can react to this, e.g., by changing your view to just show this
  /// single date.
  ///
  /// Used internally by [DateHeader].
  final DateTapCallback? onDateTap;

  /// Called when the user taps on the background of a date.
  ///
  /// You can react to this, e.g., by creating an event for that specific date.
  ///
  /// Used internally by [MultiDateEventHeader].
  final DateTapCallback? onDateBackgroundTap;

  /// Called when the user taps on the background of a date at a specific time.
  ///
  /// You can react to this, e.g., by creating an event for that specific date
  /// and time.
  ///
  /// Used internally by [DateContent].
  final DateTimeTapCallback? onDateTimeBackgroundTap;

  TimetableCallbacks copyWith({
    WeekTapCallback? onWeekTap,
    bool clearOnWeekTap = false,
    DateTapCallback? onDateTap,
    bool clearOnDateTap = false,
    DateTapCallback? onDateBackgroundTap,
    bool clearOnDateBackgroundTap = false,
    DateTimeTapCallback? onDateTimeBackgroundTap,
    bool clearOnDateTimeBackgroundTap = false,
  }) {
    assert(!(clearOnWeekTap && onWeekTap != null));
    assert(!(clearOnDateTap && onDateTap != null));
    assert(!(clearOnDateBackgroundTap && onDateBackgroundTap != null));
    assert(!(clearOnDateTimeBackgroundTap && onDateTimeBackgroundTap != null));

    return TimetableCallbacks(
      onWeekTap: clearOnWeekTap ? null : onWeekTap ?? this.onWeekTap,
      onDateTap: clearOnDateTap ? null : onDateTap ?? this.onDateTap,
      onDateBackgroundTap: clearOnDateBackgroundTap
          ? null
          : onDateBackgroundTap ?? this.onDateBackgroundTap,
      onDateTimeBackgroundTap: clearOnDateTimeBackgroundTap
          ? null
          : onDateTimeBackgroundTap ?? this.onDateTimeBackgroundTap,
    );
  }

  @override
  int get hashCode {
    return hashValues(
      onWeekTap,
      onDateTap,
      onDateBackgroundTap,
      onDateTimeBackgroundTap,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TimetableCallbacks &&
        onWeekTap == other.onWeekTap &&
        onDateTap == other.onDateTap &&
        onDateBackgroundTap == other.onDateBackgroundTap &&
        onDateTimeBackgroundTap == other.onDateTimeBackgroundTap;
  }
}

/// Provides the default callbacks for Timetable widgets below it.
///
/// [DefaultTimetableCallbacks] widgets above this on are overridden.
class DefaultTimetableCallbacks extends InheritedWidget {
  const DefaultTimetableCallbacks({
    required this.callbacks,
    required super.child,
  });

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
