import 'package:flutter/material.dart';

import '../components/date_header.dart';
import '../components/multi_date_content.dart';
import '../components/multi_date_event_header.dart';
import '../components/time_indicators.dart';
import '../components/week_indicator.dart';
import '../config.dart';
import '../date/controller.dart';
import '../date/date_page_view.dart';
import '../event/builder.dart';
import '../event/event.dart';
import '../event/provider.dart';
import '../theme.dart';
import '../time/controller.dart';
import '../time/zoom.dart';
import '../utils.dart';
import 'recurring_multi_date.dart';

typedef MultiDateTimetableHeaderBuilder = Widget Function(
  BuildContext context,
  double? leadingWidth,
);
typedef MultiDateTimetableContentBuilder = Widget Function(
  BuildContext context,
  ValueChanged<double> onLeadingWidthChanged,
);

/// A Timetable widget that displays multiple consecutive days.
///
/// To configure it, provide a [DateController], [TimeController],
/// [EventProvider], and [EventBuilder] via a [TimetableConfig] widget above in
/// the widget tree. (You can also provide these via `DefaultFoo` widgets
/// directly, like [DefaultDateController].)
///
/// See also:
///
/// * [RecurringMultiDateTimetable], which is a customized variation without
///   scrolling and specific dates – e.g., to show a generic week from Monday to
///   Sunday without dates.
class MultiDateTimetable<E extends Event> extends StatefulWidget {
  MultiDateTimetable({
    super.key,
    MultiDateTimetableHeaderBuilder? headerBuilder,
    MultiDateTimetableContentBuilder? contentBuilder,
    Widget? contentLeading,
  })  : headerBuilder = headerBuilder ?? _defaultHeaderBuilder<E>(),
        assert(
          contentBuilder == null || contentLeading == null,
          "`contentLeading` can't be used when `contentBuilder` is specified.",
        ),
        contentBuilder =
            contentBuilder ?? _defaultContentBuilder<E>(contentLeading);

  final MultiDateTimetableHeaderBuilder headerBuilder;
  static MultiDateTimetableHeaderBuilder
      _defaultHeaderBuilder<E extends Event>() {
    return (context, leadingWidth) => MultiDateTimetableHeader<E>(
          leading: SizedBox(
            width: leadingWidth,
            child: Center(child: WeekIndicator.forController(null)),
          ),
        );
  }

  final MultiDateTimetableContentBuilder contentBuilder;
  static MultiDateTimetableContentBuilder
      _defaultContentBuilder<E extends Event>(Widget? contentLeading) {
    return (context, onLeadingWidthChanged) => MultiDateTimetableContent<E>(
          leading: SizeReportingWidget(
            onSizeChanged: (size) => onLeadingWidthChanged(size.width),
            child: contentLeading ?? _DefaultContentLeading(),
          ),
        );
  }

  @override
  _MultiDateTimetableState<E> createState() => _MultiDateTimetableState();
}

class _MultiDateTimetableState<E extends Event>
    extends State<MultiDateTimetable<E>> {
  double? _leadingWidth;

  @override
  Widget build(BuildContext context) {
    final eventProvider = DefaultEventProvider.of<E>(context) ?? (_) => [];

    return Column(children: [
      DefaultEventProvider<E>(
        eventProvider: (visibleDates) =>
            eventProvider(visibleDates).where((it) => it.isAllDay).toList(),
        child: Builder(
          builder: (context) => widget.headerBuilder(context, _leadingWidth),
        ),
      ),
      Expanded(
        child: DefaultEventProvider<E>(
          eventProvider: (visibleDates) =>
              eventProvider(visibleDates).where((it) => it.isPartDay).toList(),
          child: Builder(
            builder: (context) => widget.contentBuilder(
              context,
              (newWidth) => setState(() => _leadingWidth = newWidth),
            ),
          ),
        ),
      ),
    ]);
  }
}

class MultiDateTimetableHeader<E extends Event> extends StatelessWidget {
  MultiDateTimetableHeader({
    super.key,
    Widget? leading,
    DateWidgetBuilder? dateHeaderBuilder,
    Widget? bottom,
  })  : leading = leading ?? Center(child: WeekIndicator.forController(null)),
        dateHeaderBuilder =
            dateHeaderBuilder ?? ((context, date) => DateHeader(date)),
        bottom = bottom ?? MultiDateEventHeader<E>();

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
    super.key,
    Widget? leading,
    Widget? divider,
    Widget? content,
  })  : leading = leading ?? _DefaultContentLeading(),
        divider = divider ?? VerticalDivider(width: 0),
        content = content ?? MultiDateContent<E>();

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

class _DefaultContentLeading extends StatelessWidget {
  const _DefaultContentLeading({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: TimeZoom(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Builder(
            builder: (context) => TimeIndicators.hours(
              // `TimeIndicators.hours` overwrites the style provider's labels by
              // default, but here we want the user's style provider from the ambient
              // theme to take precedence.
              styleProvider:
                  TimetableTheme.of(context)?.timeIndicatorStyleProvider,
            ),
          ),
        ),
      ),
    );
  }
}
