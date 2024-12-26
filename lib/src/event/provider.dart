import 'package:chrono/chrono.dart';
import 'package:flutter/widgets.dart';
import 'package:ranges/ranges.dart';

import 'event.dart';

/// Provides [Event]s to Timetable widgets.
///
/// [EventProvider]s may only return events that intersect the given
/// [visibleRange].
///
/// See also:
///
/// * [eventProviderFromFixedList], which creates an [EventProvider] from a
///   fixed list of events.
/// * [mergeEventProviders], which merges multiple [EventProvider]s.
/// * [DefaultEventProvider], which provides [EventProvider]s to Timetable
///   widgets below it.
typedef EventProvider<E extends Event> = List<E> Function(
  RangeInclusive<Date> visibleRange,
);

EventProvider<E> eventProviderFromFixedList<E extends Event>(List<E> events) {
  return (visibleRange) =>
      events.where((it) => it.dateRange.intersects(visibleRange)).toList();
}

EventProvider<E> mergeEventProviders<E extends Event>(
  List<EventProvider<E>> eventProviders,
) {
  return (visibleRange) =>
      eventProviders.expand((it) => it(visibleRange)).toList();
}

extension EventProviderTimetable<E extends Event> on EventProvider<E> {
  EventProvider<E> get debugChecked {
    return (visibleRange) {
      final events = this(visibleRange);
      assert(() {
        final invalidEvents = events
            .where((it) => !it.dateRange.intersects(visibleRange))
            .toList();
        if (invalidEvents.isNotEmpty) {
          throw FlutterError.fromParts([
            ErrorSummary(
              'EventProvider returned events not intersecting the provided '
              'visible range.',
            ),
            ErrorDescription(
              'For the visible range ${visibleRange.start} – '
              '${visibleRange.endInclusive}, ${invalidEvents.length} out of '
              "${events.length} events don't intersect this range: "
              '$invalidEvents',
            ),
            ErrorDescription(
              "This property is enforced so that you don't accidentally, e.g., "
              'load thousands of events spread over multiple years when only a '
              'single week is visible.',
            ),
            ErrorHint(
              'If you only have a fixed list of events, use '
              '`eventProviderFromFixedList(myListOfEvents)`.',
            ),
          ]);
        }
        return true;
      }());

      return events;
    };
  }
}

class DefaultEventProvider<E extends Event> extends InheritedWidget {
  DefaultEventProvider({
    super.key,
    required EventProvider<E> eventProvider,
    required super.child,
  }) : eventProvider = eventProvider.debugChecked;

  final EventProvider<E> eventProvider;

  @override
  bool updateShouldNotify(DefaultEventProvider oldWidget) =>
      eventProvider != oldWidget.eventProvider;

  static EventProvider<E>? of<E extends Event>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DefaultEventProvider<E>>()
        ?.eventProvider;
  }
}
