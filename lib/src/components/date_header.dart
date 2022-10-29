import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../callbacks.dart';
import '../config.dart';
import '../localization.dart';
import '../theme.dart';
import '../utils.dart';
import 'date_indicator.dart';
import 'weekday_indicator.dart';

/// A widget that displays the weekday and date of month for the given date.
///
/// If [onTap] is not supplied, [DefaultTimetableCallbacks]'s `onDateTap` is
/// used if it's provided above in the widget tree.
///
/// See also:
///
/// * [DateHeaderStyle], which defines visual properties for this widget.
/// * [TimetableTheme] (and [TimetableConfig]), which provide styles to
///   descendant Timetable widgets.
/// * [DefaultTimetableCallbacks], which provides callbacks to descendant
///   Timetable widgets.
class DateHeader extends StatelessWidget {
  DateHeader(
    this.date, {
    super.key,
    this.onTap,
    this.style,
  }) : assert(date.debugCheckIsValidTimetableDate());

  final DateTime date;
  final VoidCallback? onTap;
  final DateHeaderStyle? style;

  @override
  Widget build(BuildContext context) {
    final style = this.style ??
        TimetableTheme.orDefaultOf(context).dateHeaderStyleProvider(date);
    final callbacks = DefaultTimetableCallbacks.of(context);
    final defaultOnTap = callbacks?.onDateTap;

    return InkWell(
      onTap: onTap ?? (defaultOnTap != null ? () => defaultOnTap(date) : null),
      child: Tooltip(
        message: style.tooltip,
        child: Padding(
          padding: style.padding,
          child: DefaultTimetableCallbacks(
            callbacks: (callbacks ?? TimetableCallbacks())
                .copyWith(clearOnDateTap: true),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (style.showWeekdayIndicator) WeekdayIndicator(date),
                if (style.showWeekdayIndicator && style.showDateIndicator)
                  SizedBox(height: style.indicatorSpacing),
                if (style.showDateIndicator) DateIndicator(date),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Defines visual properties for [DateHeader].
///
/// See also:
///
/// * [TimetableThemeData], which bundles the styles for all Timetable widgets.
@immutable
class DateHeaderStyle {
  factory DateHeaderStyle(
    BuildContext context,
    DateTime date, {
    String? tooltip,
    EdgeInsetsGeometry? padding,
    bool? showWeekdayIndicator,
    double? indicatorSpacing,
    bool? showDateIndicator,
  }) {
    assert(date.debugCheckIsValidTimetableDate());

    return DateHeaderStyle.raw(
      tooltip: tooltip ??
          () {
            context.dependOnTimetableLocalizations();
            return DateFormat.yMMMMEEEEd().format(date);
          }(),
      padding: padding ?? EdgeInsets.all(4),
      showWeekdayIndicator: showWeekdayIndicator ?? true,
      indicatorSpacing: indicatorSpacing ?? 4,
      showDateIndicator: showDateIndicator ?? true,
    );
  }

  const DateHeaderStyle.raw({
    required this.tooltip,
    required this.padding,
    required this.showWeekdayIndicator,
    required this.indicatorSpacing,
    required this.showDateIndicator,
  });

  final String tooltip;
  final EdgeInsetsGeometry padding;
  final bool showWeekdayIndicator;
  final double indicatorSpacing;
  final bool showDateIndicator;

  DateHeaderStyle copyWith({
    String? tooltip,
    EdgeInsetsGeometry? padding,
    bool? showWeekdayIndicator,
    double? indicatorSpacing,
    bool? showDateIndicator,
  }) {
    return DateHeaderStyle.raw(
      tooltip: tooltip ?? this.tooltip,
      padding: padding ?? this.padding,
      showWeekdayIndicator: showWeekdayIndicator ?? this.showWeekdayIndicator,
      indicatorSpacing: indicatorSpacing ?? this.indicatorSpacing,
      showDateIndicator: showDateIndicator ?? this.showDateIndicator,
    );
  }

  @override
  int get hashCode {
    return Object.hash(
      tooltip,
      padding,
      showWeekdayIndicator,
      indicatorSpacing,
      showDateIndicator,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DateHeaderStyle &&
        tooltip == other.tooltip &&
        padding == other.padding &&
        showWeekdayIndicator == other.showWeekdayIndicator &&
        indicatorSpacing == other.indicatorSpacing &&
        showDateIndicator == other.showDateIndicator;
  }
}
