import 'package:flutter/material.dart';

import '../components/multi_date_content.dart';
import '../components/multi_date_event_header.dart';
import '../components/multi_date_header.dart';
import '../components/time_indicators.dart';
import '../components/week_indicator.dart';
import '../date/controller.dart';
import '../date/visible_date_range.dart';
import '../event.dart';
import '../event_provider.dart';
import '../time/controller.dart';
import '../time/zoom.dart';

class MultiDateTimetable<E extends Event> extends StatefulWidget {
  MultiDateTimetable({
    Key? key,
    this.controller,
    this.timeController,
    required EventProvider<E> eventProvider,
    required this.headerEventBuilder,
    this.onHeaderDateTap,
    this.onHeaderBackgroundTap,
    this.headerStyle = const MultiDateEventHeaderStyle(),
    this.headerPadding = EdgeInsets.zero,
    required this.contentEventBuilder,
    this.onContentBackgroundTap,
    this.contentStyle,
  })  : eventProvider = eventProvider.debugChecked,
        super(key: key);

  final DateController? controller;
  final TimeController? timeController;
  final EventProvider<E> eventProvider;

  // Header:
  final MultiDateHeaderTapCallback? onHeaderDateTap;
  final MultiDateEventHeaderEventBuilder<E> headerEventBuilder;
  final MultiDateEventHeaderBackgroundTapCallback? onHeaderBackgroundTap;
  final MultiDateEventHeaderStyle headerStyle;
  final EdgeInsetsGeometry headerPadding;

  // Content:
  final MultiDateContentEventBuilder<E> contentEventBuilder;
  final MultiDateContentBackgroundTapCallback? onContentBackgroundTap;
  final MultiDateContentStyle? contentStyle;

  @override
  _MultiDateTimetableState<E> createState() => _MultiDateTimetableState();
}

class _MultiDateTimetableState<E extends Event>
    extends State<MultiDateTimetable<E>> {
  late DateController _dateController;
  late TimeController _timeController;

  @override
  void initState() {
    super.initState();

    _dateController = widget.controller ?? DateController();
    _timeController = widget.timeController ?? TimeController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MultiDateTimetableHeader<E>(
          controller: _dateController,
          eventProvider: (visibleDates) => widget
              .eventProvider(visibleDates)
              .where((it) => it.isAllDay)
              .toList(),
          eventBuilder: widget.headerEventBuilder,
          onBackgroundTap: widget.onHeaderBackgroundTap,
          style: widget.headerStyle,
          padding: widget.headerPadding,
        ),
        Expanded(
          child: MultiDateTimetableContent<E>(
            dateController: _dateController,
            timeController: _timeController,
            eventProvider: (visibleDates) => widget
                .eventProvider(visibleDates)
                .where((it) => it.isPartDay)
                .toList(),
            eventBuilder: widget.contentEventBuilder,
            onBackgroundTap: widget.onContentBackgroundTap,
            style: widget.contentStyle,
          ),
        ),
      ],
    );
  }
}

class MultiDateTimetableHeader<E extends Event> extends StatelessWidget {
  MultiDateTimetableHeader({
    Key? key,
    required this.controller,
    required EventProvider<E> eventProvider,
    required this.eventBuilder,
    this.onDateTap,
    this.onBackgroundTap,
    this.style = const MultiDateEventHeaderStyle(),
    this.padding = EdgeInsets.zero,
  })  : eventProvider = eventProvider.debugChecked,
        super(key: key);

  final DateController controller;
  final EventProvider<E> eventProvider;
  final MultiDateEventHeaderEventBuilder<E> eventBuilder;

  final MultiDateHeaderTapCallback? onDateTap;
  final MultiDateEventHeaderBackgroundTapCallback? onBackgroundTap;
  final MultiDateEventHeaderStyle style;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: WeekIndicatorComponent(controller: controller),
        ),
        Expanded(
          child: Column(
            children: [
              MultiDateHeader(controller: controller, onTap: onDateTap),
              MultiDateEventHeader<E>(
                controller: controller,
                eventProvider: eventProvider,
                eventBuilder: eventBuilder,
                onBackgroundTap: onBackgroundTap,
                style: style,
                padding: padding,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MultiDateTimetableContent<E extends Event> extends StatelessWidget {
  MultiDateTimetableContent({
    Key? key,
    required this.dateController,
    required this.timeController,
    required EventProvider<E> eventProvider,
    required this.eventBuilder,
    this.onBackgroundTap,
    this.style,
  })  : eventProvider = eventProvider.debugChecked,
        super(key: key);

  final DateController dateController;
  final TimeController timeController;
  final EventProvider<E> eventProvider;
  final MultiDateContentEventBuilder<E> eventBuilder;

  final MultiDateContentBackgroundTapCallback? onBackgroundTap;
  final MultiDateContentStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: TimeZoom(
            controller: timeController,
            child: TimeIndicators.hours(),
          ),
        ),
        VerticalDivider(width: 0),
        Expanded(
          child: MultiDateContent<E>(
            dateController: dateController,
            eventProvider: eventProvider,
            timeController: timeController,
            eventBuilder: eventBuilder,
            onBackgroundTap: onBackgroundTap,
            style: style,
          ),
        ),
      ],
    );
  }
}
