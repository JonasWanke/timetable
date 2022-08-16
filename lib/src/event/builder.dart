import 'package:flutter/widgets.dart' hide Interval;

import '../components/all_day_overflow.dart';
import 'all_day.dart';
import 'event.dart';

typedef EventBuilder<E extends Event> = Widget Function(
  BuildContext context,
  E event,
);
typedef AllDayOverflowBuilder<E extends Event> = Widget Function(
  BuildContext context,
  DateTime date,
  List<E> overflowedEvents,
);

class DefaultEventBuilder<E extends Event> extends InheritedWidget {
  DefaultEventBuilder({
    required this.builder,
    AllDayEventBuilder<E>? allDayBuilder,
    AllDayOverflowBuilder<E>? allDayOverflowBuilder,
    required super.child,
  })  : allDayBuilder =
            allDayBuilder ?? ((context, event, _) => builder(context, event)),
        allDayOverflowBuilder = allDayOverflowBuilder ??
            ((context, date, overflowedEvents) =>
                AllDayOverflow(date, overflowCount: overflowedEvents.length));

  final EventBuilder<E> builder;
  final AllDayEventBuilder<E> allDayBuilder;
  final AllDayOverflowBuilder<E> allDayOverflowBuilder;

  @override
  bool updateShouldNotify(DefaultEventBuilder<E> oldWidget) =>
      builder != oldWidget.builder || allDayBuilder != oldWidget.allDayBuilder;

  static EventBuilder<E>? of<E extends Event>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DefaultEventBuilder<E>>()
        ?.builder;
  }

  static AllDayEventBuilder<E>? allDayOf<E extends Event>(
    BuildContext context,
  ) {
    return context
        .dependOnInheritedWidgetOfExactType<DefaultEventBuilder<E>>()
        ?.allDayBuilder;
  }

  static AllDayOverflowBuilder<E>? allDayOverflowOf<E extends Event>(
    BuildContext context,
  ) {
    return context
        .dependOnInheritedWidgetOfExactType<DefaultEventBuilder<E>>()
        ?.allDayOverflowBuilder;
  }
}
