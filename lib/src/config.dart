import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

import 'callbacks.dart';
import 'date/controller.dart';
import 'event/all_day.dart';
import 'event/builder.dart';
import 'event/event.dart';
import 'event/provider.dart';
import 'localization.dart';
import 'styling.dart';
import 'time/controller.dart';
import 'time/overlay.dart';

class TimetableConfig<E extends Event> extends StatelessWidget {
  TimetableConfig({
    Key? key,
    this.dateController,
    this.timeController,
    EventProvider<E>? eventProvider,
    this.eventBuilder,
    this.allDayEventBuilder,
    this.timeOverlayProvider,
    this.callbacks,
    this.theme,
    required this.child,
  })   : eventProvider = eventProvider?.debugChecked,
        super(key: key);

  final DateController? dateController;
  final TimeController? timeController;
  final EventProvider<E>? eventProvider;
  final EventBuilder<E>? eventBuilder;
  final AllDayEventBuilder<E>? allDayEventBuilder;
  final TimeOverlayProvider? timeOverlayProvider;
  final TimetableCallbacks? callbacks;
  final TimetableThemeData? theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget child = DefaultTimetableCallbacks(
      callbacks: callbacks ??
          DefaultTimetableCallbacks.of(context) ??
          TimetableCallbacks(),
      child: TimetableTheme(
        data: theme ??
            TimetableTheme.of(context) ??
            TimetableThemeData(
              colorScheme: context.theme.colorScheme,
              textTheme: context.textTheme,
              localizations: TimetableLocalizations.of(context),
            ),
        child: this.child,
      ),
    );

    child = DefaultTimeOverlayProvider(
      overlayProvider: timeOverlayProvider ??
          DefaultTimeOverlayProvider.of(context) ??
          emptyTimeOverlayProvider,
      child: child,
    );

    child = DefaultEventProvider<E>(
      eventProvider:
          eventProvider ?? DefaultEventProvider.of<E>(context) ?? (_) => [],
      child: DefaultEventBuilder(
        builder: eventBuilder ?? DefaultEventBuilder.of<E>(context)!,
        child: DefaultAllDayEventBuilder<E>(
          builder: allDayEventBuilder ??
              (eventBuilder != null
                  ? (context, event, _) => eventBuilder!(context, event)
                  : null) ??
              DefaultAllDayEventBuilder.of<E>(context)!,
          child: child,
        ),
      ),
    );

    return DefaultDateController(
      controller: dateController ??
          DefaultDateController.of(context) ??
          DateController(),
      child: DefaultTimeController(
        controller: timeController ??
            DefaultTimeController.of(context) ??
            TimeController(),
        child: child,
      ),
    );
  }
}
