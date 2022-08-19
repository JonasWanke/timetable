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
import '../utils/constraints_passing_column.dart';
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
  factory MultiDateTimetable({
    Key? key,
    MultiDateTimetableHeaderBuilder? headerBuilder,
    MultiDateTimetableContentBuilder? contentBuilder,
    Widget? contentLeading,
    GlobalKey<MultiDateContentGeometry>? contentGeometryKey,
  }) {
    assert(
      contentBuilder == null || contentLeading == null,
      "`contentLeading` can't be used when `contentBuilder` is specified.",
    );
    assert(
      contentBuilder == null || contentGeometryKey == null,
      "`contentGeometryKey` can't be used when `contentBuilder` is specified.",
    );

    return MultiDateTimetable.raw(
      key: key,
      headerBuilder: headerBuilder ?? _defaultHeaderBuilder<E>(),
      contentBuilder: contentBuilder ??
          _defaultContentBuilder<E>(contentLeading, contentGeometryKey),
    );
  }

  const MultiDateTimetable.raw({
    super.key,
    required this.headerBuilder,
    required this.contentBuilder,
  });

  final MultiDateTimetableHeaderBuilder headerBuilder;
  static MultiDateTimetableHeaderBuilder
      _defaultHeaderBuilder<E extends Event>() {
    return (context, leadingWidth) => MultiDateTimetableHeader<E>(
          leading: SizedBox(
            width: leadingWidth,
            child: Align(
              heightFactor: 1,
              alignment: Alignment.center,
              child: WeekIndicator.forController(null),
            ),
          ),
        );
  }

  final MultiDateTimetableContentBuilder contentBuilder;
  static MultiDateTimetableContentBuilder
      _defaultContentBuilder<E extends Event>(
    Widget? contentLeading,
    GlobalKey<MultiDateContentGeometry>? contentGeometryKey,
  ) {
    return (context, onLeadingWidthChanged) => MultiDateTimetableContent<E>(
          leading: SizeReportingWidget(
            onSizeChanged: (size) => onLeadingWidthChanged(size.width),
            child: contentLeading ?? _DefaultContentLeading(),
          ),
          contentGeometryKey: contentGeometryKey,
        );
  }

  @override
  State<MultiDateTimetable<E>> createState() => _MultiDateTimetableState();
}

class _MultiDateTimetableState<E extends Event>
    extends State<MultiDateTimetable<E>> {
  double? _leadingWidth;

  @override
  Widget build(BuildContext context) {
    final style = TimetableTheme.orDefaultOf(context).multiDateTimetableStyle;
    final eventProvider = DefaultEventProvider.of<E>(context) ?? (_) => [];

    final header = DefaultEventProvider<E>(
      eventProvider: (visibleDates) =>
          eventProvider(visibleDates).where((it) => it.isAllDay).toList(),
      child: Builder(
        builder: (context) => widget.headerBuilder(context, _leadingWidth),
      ),
    );

    final content = DefaultEventProvider<E>(
      eventProvider: (visibleDates) =>
          eventProvider(visibleDates).where((it) => it.isPartDay).toList(),
      child: Builder(
        builder: (context) => widget.contentBuilder(
          context,
          (newWidth) => setState(() => _leadingWidth = newWidth),
        ),
      ),
    );

    return LayoutBuilder(builder: (context, constraints) {
      final maxHeaderHeight = constraints.maxHeight * style.maxHeaderFraction;
      return Column(children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeaderHeight),
          child: header,
        ),
        Expanded(child: content),
      ]);
    });
  }
}

class MultiDateTimetableHeader<E extends Event> extends StatelessWidget {
  MultiDateTimetableHeader({
    Key? key,
    Widget? leading,
    DateWidgetBuilder? dateHeaderBuilder,
    Widget? bottom,
  }) : this.raw(
          key: key,
          leading: leading ?? WeekIndicator.forController(null),
          dateHeaderBuilder:
              dateHeaderBuilder ?? ((context, date) => DateHeader(date)),
          bottom: bottom ?? MultiDateEventHeader<E>(),
        );

  const MultiDateTimetableHeader.raw({
    super.key,
    required this.leading,
    required this.dateHeaderBuilder,
    required this.bottom,
  });

  final Widget leading;
  final DateWidgetBuilder dateHeaderBuilder;
  final Widget bottom;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      leading,
      Expanded(
        child: ConstraintsPassingColumn(children: [
          DatePageView(
            shrinkWrapInCrossAxis: true,
            builder: dateHeaderBuilder,
          ),
          bottom,
        ]),
      ),
    ]);
  }
}

class MultiDateTimetableContent<E extends Event> extends StatelessWidget {
  factory MultiDateTimetableContent({
    Key? key,
    Widget? leading,
    Widget? divider,
    Widget? content,
    GlobalKey<MultiDateContentGeometry>? contentGeometryKey,
  }) {
    assert(
      content == null || contentGeometryKey == null,
      "`contentGeometryKey` can't be used when `content` is specified.",
    );
    return MultiDateTimetableContent.raw(
      key: key,
      leading: leading ?? _DefaultContentLeading(),
      divider: divider ?? VerticalDivider(width: 0),
      content: content ?? MultiDateContent<E>(geometryKey: contentGeometryKey),
    );
  }

  const MultiDateTimetableContent.raw({
    super.key,
    required this.leading,
    required this.divider,
    required this.content,
  });

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

/// Defines visual properties for [MultiDateTimetable] and
/// [RecurringMultiDateTimetable].
class MultiDateTimetableStyle {
  factory MultiDateTimetableStyle(
    // To allow future updates to use the context and align the parameters to
    // other style constructors.
    // ignore: avoid_unused_constructor_parameters
    BuildContext context, {
    double? maxHeaderFraction,
  }) {
    return MultiDateTimetableStyle.raw(
      maxHeaderFraction: maxHeaderFraction ?? 0.5,
    );
  }

  const MultiDateTimetableStyle.raw({this.maxHeaderFraction = 0.5})
      : assert(0 < maxHeaderFraction),
        assert(maxHeaderFraction < 1);

  /// The maximum fraction (between 0 and 1, exclusive) that the header
  /// [MultiDateTimetableHeader] may consume of the timetable's total height.
  ///
  /// This ensures that a header containing many all-day events in parallel
  /// doesn't push away the content (i.e., part-time events).
  ///
  /// See also:
  ///
  /// * [MultiDateEventHeaderStyle.maxEventRows], which configures the maximum
  ///   number of rows that header events can allocate.
  final double maxHeaderFraction;

  MultiDateTimetableStyle copyWith({double? maxHeaderFraction}) {
    return MultiDateTimetableStyle.raw(
      maxHeaderFraction: maxHeaderFraction ?? this.maxHeaderFraction,
    );
  }

  @override
  int get hashCode => maxHeaderFraction.hashCode;
  @override
  bool operator ==(Object other) {
    return other is MultiDateTimetableStyle &&
        maxHeaderFraction == other.maxHeaderFraction;
  }
}

class _DefaultContentLeading extends StatelessWidget {
  const _DefaultContentLeading();

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
