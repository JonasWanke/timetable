import 'package:chrono/chrono.dart';
import 'package:flutter/widgets.dart';

import '../event/event.dart';
import '../utils.dart';

@immutable
class TimeOverlay {
  const TimeOverlay({
    required this.start,
    required this.end,
    required this.widget,
    this.position = TimeOverlayPosition.behindEvents,
  }) : assert(end == null || start < end);

  final Time start;

  /// The end time of the overlay or `null` if it doesn't end on this date.
  final Time? end;

  /// The widget that will be shown as an overlay.
  final Widget widget;

  /// Whether to paint this overlay behind or in front of events.
  final TimeOverlayPosition position;
}

enum TimeOverlayPosition { behindEvents, inFrontOfEvents }

/// Provides [TimeOverlay]s to Timetable widgets.
///
/// [TimeOverlayProvider]s may only return overlays for the given [date].
///
/// See also:
///
/// * [emptyTimeOverlayProvider], which returns an empty list for all dates.
/// * [mergeTimeOverlayProviders], which merges multiple [TimeOverlayProvider]s.
typedef TimeOverlayProvider = List<TimeOverlay> Function(
  BuildContext context,
  Date date,
);

// ignore: prefer_function_declarations_over_variables
final TimeOverlayProvider emptyTimeOverlayProvider = (context, date) {
  return [];
};

TimeOverlayProvider mergeTimeOverlayProviders(
  List<TimeOverlayProvider> overlayProviders,
) {
  return (context, date) =>
      overlayProviders.expand((it) => it(context, date)).toList();
}

class DefaultTimeOverlayProvider extends InheritedWidget {
  const DefaultTimeOverlayProvider({
    super.key,
    required this.overlayProvider,
    required super.child,
  });

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
    required Date date,
    required Widget widget,
    TimeOverlayPosition position = TimeOverlayPosition.inFrontOfEvents,
  }) {
    if (!interval.intersects(date.fullDayInterval)) return null;

    return TimeOverlay(
      start: start.difference(date.atMidnight).coerceAtLeast(Duration.zero),
      end: endInclusive.difference(date.atMidnight).coerceAtMost(1.days),
      widget: widget,
      position: position,
    );
  }
}
