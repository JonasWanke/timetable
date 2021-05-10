import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../event/event.dart';
import '../utils.dart';

@immutable
class TimeOverlay {
  TimeOverlay({
    required this.start,
    required this.end,
    required this.widget,
    this.position = DecorationPosition.background,
  })  : assert(start.isValidTimetableTimeOfDay),
        assert(end.isValidTimetableTimeOfDay),
        assert(start < end);

  final Duration start;
  final Duration end;
  final Widget widget;
  final DecorationPosition position;
}

/// Provides [TimeOverlay]s to timetable widgets.
typedef TimeOverlayProvider = List<TimeOverlay> Function(
  BuildContext context,
  DateTime date,
);

List<TimeOverlay> emptyTimeOverlayProvider(
  BuildContext context,
  DateTime date,
) {
  assert(date.isValidTimetableDate);
  return [];
}

TimeOverlayProvider mergeTimeOverlayProviders(
  List<TimeOverlayProvider> overlayProviders,
) {
  return (context, date) =>
      overlayProviders.expand((it) => it(context, date)).toList();
}

class DefaultTimeOverlayProvider extends InheritedWidget {
  const DefaultTimeOverlayProvider({
    required this.overlayProvider,
    required Widget child,
  }) : super(child: child);

  final TimeOverlayProvider overlayProvider;

  @override
  bool updateShouldNotify(DefaultTimeOverlayProvider oldWidget) =>
      overlayProvider != oldWidget.overlayProvider;

  static TimeOverlayProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DefaultTimeOverlayProvider>()
        ?.overlayProvider;
  }
}

extension EventToTimeOverlay on Event {
  TimeOverlay? toTimeOverlay({
    required DateTime date,
    required Widget widget,
    DecorationPosition position = DecorationPosition.foreground,
  }) {
    assert(date.isValidTimetableDate);

    if (start.atStartOfDay > date || endInclusive.atStartOfDay < date)
      return null;

    return TimeOverlay(
      start: start.difference(date).coerceAtLeast(Duration.zero),
      end: endInclusive.difference(date).coerceAtMost(1.days),
      widget: widget,
      position: position,
    );
  }
}
