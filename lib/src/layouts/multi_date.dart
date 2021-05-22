import 'package:flutter/material.dart';

import '../components/date_header.dart';
import '../components/multi_date_content.dart';
import '../components/multi_date_event_header.dart';
import '../components/time_indicators.dart';
import '../components/week_indicator.dart';
import '../date/date_page_view.dart';
import '../event/event.dart';
import '../event/provider.dart';
import '../theme.dart';
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
    MultiDateTimetableHeaderBuilder? headerBuilder,
    MultiDateTimetableContentBuilder? contentBuilder,
  })  : headerBuilder = headerBuilder ??
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
                    child: _defaultContentLeading,
                  ),
                )),
        super(key: key);

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
    final eventProvider = DefaultEventProvider.of<E>(context)!;

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
            builder: (contxt) => widget.contentBuilder(
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
  })  : leading = leading ?? _defaultContentLeading,
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

// TODO(JonasWanke): Explicitly disable the scrollbar when they're shown by
// default on desktop: https://flutter.dev/docs/release/breaking-changes/default-desktop-scrollbars
// Builder(
//   builder:(context) => ScrollConfiguration(
//   behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
// )

Widget _defaultContentLeading = Padding(
  padding: EdgeInsets.symmetric(horizontal: 8),
  child: TimeZoom(
    child: Builder(
      builder: (context) => TimeIndicators.hours(
        // `TimeIndicators.hours` overwrites the style provider's labels by
        // default, but here we want the user's style provider from the ambient
        // theme to take precedence.
        styleProvider: TimetableTheme.of(context)?.timeIndicatorStyleProvider,
      ),
    ),
  ),
);
