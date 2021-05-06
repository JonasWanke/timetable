import 'package:flutter/widgets.dart' hide Interval;

import 'event.dart';

typedef EventBuilder<E extends Event> = Widget Function(
  BuildContext context,
  E event,
);

class DefaultEventBuilder<E extends Event> extends InheritedWidget {
  const DefaultEventBuilder({
    required this.builder,
    required Widget child,
  }) : super(child: child);

  final EventBuilder<E> builder;

  @override
  bool updateShouldNotify(DefaultEventBuilder<E> oldWidget) =>
      builder != oldWidget.builder;

  static EventBuilder<E>? of<E extends Event>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DefaultEventBuilder<E>>()
        ?.builder;
  }
}
