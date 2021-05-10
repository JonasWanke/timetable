import 'package:flutter/material.dart';

import '../components/multi_date_content.dart';
import '../components/multi_date_event_header.dart';
import '../components/multi_date_header.dart';
import '../components/time_indicators.dart';
import '../components/week_indicator.dart';
import '../date/controller.dart';
import '../date/date_page_view.dart';
import '../event/all_day.dart';
import '../event/builder.dart';
import '../event/event.dart';
import '../event/provider.dart';
import '../time/controller.dart';
import '../time/overlay.dart';
import '../time/zoom.dart';
import '../utils.dart';

typedef MultiDateTimetableHeaderBuilder = Widget Function(
  BuildContext context,
  double? leadingWidth,
);
typedef MultiDateTimetableContentBuilder = Widget Function(
  BuildContext context,
  ValueChanged<double> onLeadingWidthChanged,
);

class MultiDateTimetable<E extends Event> extends StatefulWidget {
  MultiDateTimetable({
    Key? key,
    this.dateController,
    this.timeController,
    EventProvider<E>? eventProvider,
    this.eventBuilder,
    this.allDayEventBuilder,
    this.timeOverlayProvider,
    MultiDateTimetableHeaderBuilder? headerBuilder,
    MultiDateTimetableContentBuilder? contentBuilder,
  })  : eventProvider = eventProvider?.debugChecked,
        headerBuilder = headerBuilder ??
            ((context, leadingWidth) => MultiDateTimetableHeader<E>(
                  leading: SizedBox(
                    width: leadingWidth,
                    child: Center(child: WeekIndicator.forController(null)),
                  ),
                )),
        contentBuilder = contentBuilder ??
            ((context, onLeadingWidthChanged) => MultiDateTimetableContent<E>(
                  leading: SizeReportingWidget(
                    onSizeChanged: (size) => onLeadingWidthChanged(size.width),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: TimeZoom(child: TimeIndicators.hours()),
                    ),
                  ),
                )),
        super(key: key);

  final DateController? dateController;
  final TimeController? timeController;
  final EventProvider<E>? eventProvider;
  final EventBuilder<E>? eventBuilder;
  final AllDayEventBuilder<E>? allDayEventBuilder;
  final TimeOverlayProvider? timeOverlayProvider;

  final MultiDateTimetableHeaderBuilder headerBuilder;
  final MultiDateTimetableContentBuilder contentBuilder;

  @override
  _MultiDateTimetableState<E> createState() => _MultiDateTimetableState();
}

class _MultiDateTimetableState<E extends Event>
    extends State<MultiDateTimetable<E>> {
  double? _leadingWidth;

  @override
  Widget build(BuildContext context) {
    final _dateController = widget.dateController ??
        DefaultDateController.of(context) ??
        DateController();
    final _timeController = widget.timeController ??
        DefaultTimeController.of(context) ??
        TimeController();
    final _eventProvider = widget.eventProvider ??
        DefaultEventProvider.of<E>(context) ??
        (_) => [];
    final _eventBuilder =
        widget.eventBuilder ?? DefaultEventBuilder.of<E>(context)!;
    final _allDayEventBuilder = widget.allDayEventBuilder ??
        (widget.eventBuilder != null
            ? (context, event, _) => widget.eventBuilder!(context, event)
            : null) ??
        DefaultAllDayEventBuilder.of<E>(context)!;
    final _timeOverlayProvider = widget.timeOverlayProvider ??
        DefaultTimeOverlayProvider.of(context) ??
        emptyTimeOverlayProvider;

    final child = Column(children: [
      DefaultEventProvider<E>(
        eventProvider: (visibleDates) =>
            _eventProvider(visibleDates).where((it) => it.isAllDay).toList(),
        child: Builder(
          builder: (context) => widget.headerBuilder(context, _leadingWidth),
        ),
      ),
      Expanded(
        child: DefaultEventProvider<E>(
          eventProvider: (visibleDates) =>
              _eventProvider(visibleDates).where((it) => it.isPartDay).toList(),
          child: Builder(
            builder: (contxt) => widget.contentBuilder(
              context,
              (newWidth) => setState(() => _leadingWidth = newWidth),
            ),
          ),
        ),
      ),
    ]);

    return DefaultDateController(
      controller: _dateController,
      child: DefaultTimeController(
        controller: _timeController,
        child: DefaultEventBuilder(
          builder: _eventBuilder,
          child: DefaultAllDayEventBuilder(
            builder: _allDayEventBuilder,
            child: DefaultTimeOverlayProvider(
              overlayProvider: _timeOverlayProvider,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class MultiDateTimetableHeader<E extends Event> extends StatelessWidget {
  MultiDateTimetableHeader({
    Key? key,
    Widget? leading,
    DateWidgetBuilder? dateHeaderBuilder,
    Widget? bottom,
  })  : leading = leading ?? Center(child: WeekIndicator.forController(null)),
        dateHeaderBuilder =
            dateHeaderBuilder ?? ((context, date) => DateHeader(date)),
        bottom = bottom ?? MultiDateEventHeader<E>(),
        super(key: key);

  final Widget leading;
  final DateWidgetBuilder dateHeaderBuilder;
  final Widget bottom;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      leading,
      Expanded(
        child: Column(children: [
          DatePageView(shrinkWrapInCrossAxis: true, builder: dateHeaderBuilder),
          bottom,
        ]),
      ),
    ]);
  }
}

class MultiDateTimetableContent<E extends Event> extends StatelessWidget {
  MultiDateTimetableContent({
    Key? key,
    Widget? leading,
    Widget? divider,
    Widget? content,
  })  : leading = leading ??
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: TimeZoom(child: TimeIndicators.hours()),
            ),
        divider = divider ?? VerticalDivider(width: 0),
        content = content ?? MultiDateContent<E>(),
        super(key: key);

  final Widget leading;
  final Widget divider;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      leading,
      divider,
      Expanded(child: content),
    ]);
  }
}
