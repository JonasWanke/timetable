import 'package:flutter/widgets.dart' hide Interval;

import 'all_day.dart';
import 'event.dart';

typedef EventBuilder<E extends Event> = Widget Function(
  BuildContext context,
  E event,
);

class DefaultEventBuilder<E extends Event> extends InheritedWidget {
  DefaultEventBuilder({
    required this.builder,
    AllDayEventBuilder<E>? allDayBuilder,
    required super.child,
  }) : allDayBuilder =
            allDayBuilder ?? ((context, event, _) => builder(context, event));

  final EventBuilder<E> builder;
  final AllDayEventBuilder<E> allDayBuilder;

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
}
