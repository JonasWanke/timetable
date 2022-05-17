import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../callbacks.dart';
import '../config.dart';
import '../localization.dart';
import '../theme.dart';
import '../utils.dart';

/// A widget that displays the date of month for the given date.
///
/// If [onTap] is not supplied, [DefaultTimetableCallbacks]'s `onDateTap` is
/// used if it's provided above in the widget tree.
///
/// See also:
///
/// * [DateIndicatorStyle], which defines visual properties for this widget.
/// * [TimetableTheme] (and [TimetableConfig]), which provide styles to
///   descendant Timetable widgets.
/// * [DefaultTimetableCallbacks], which provides callbacks to descendant
///   Timetable widgets.
class DateIndicator extends StatelessWidget {
  DateIndicator(
    this.date, {
    super.key,
    this.onTap,
    this.style,
  }) : assert(date.isValidTimetableDate);

  final DateTime date;
  final VoidCallback? onTap;
  final DateIndicatorStyle? style;

  @override
  Widget build(BuildContext context) {
    final style = this.style ??
        TimetableTheme.orDefaultOf(context).dateIndicatorStyleProvider(date);
    final defaultOnTap = DefaultTimetableCallbacks.of(context)?.onDateTap;

    return InkResponse(
      onTap: onTap ?? (defaultOnTap != null ? () => defaultOnTap(date) : null),
      child: DecoratedBox(
        decoration: style.decoration,
        child: Padding(
          padding: style.padding,
          child: Text(style.label, style: style.textStyle),
        ),
      ),
    );
  }
}

/// Defines visual properties for [DateIndicator].
///
/// See also:
///
/// * [TimetableThemeData], which bundles the styles for all Timetable widgets.
@immutable
class DateIndicatorStyle {
  factory DateIndicatorStyle(
    BuildContext context,
    DateTime date, {
    Decoration? decoration,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    String? label,
  }) {
    assert(date.isValidTimetableDate);

    final today = DateTimeTimetable.today();
    final isInFuture = date > today;
    final isToday = date == today;

    final theme = context.theme;
    return DateIndicatorStyle.raw(
      decoration: decoration ??
          BoxDecoration(
            shape: BoxShape.circle,
            color: isToday ? theme.colorScheme.primary : Colors.transparent,
          ),
      padding: padding ?? EdgeInsets.all(8),
      textStyle: textStyle ??
          context.textTheme.subtitle1!.copyWith(
            color: isToday
                ? theme.colorScheme.primary.highEmphasisOnColor
                : isInFuture
                    ? theme.colorScheme.background.contrastColor
                    : theme.colorScheme.background.mediumEmphasisOnColor,
          ),
      label: label ??
          () {
            context.dependOnTimetableLocalizations();
            return DateFormat('d').format(date);
          }(),
    );
  }

  const DateIndicatorStyle.raw({
    required this.decoration,
    required this.padding,
    required this.textStyle,
    required this.label,
  });

  final Decoration decoration;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  final String label;

  DateIndicatorStyle copyWith({
    Decoration? decoration,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    String? label,
  }) {
    return DateIndicatorStyle.raw(
      decoration: decoration ?? this.decoration,
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      label: label ?? this.label,
    );
  }

  @override
  int get hashCode => hashValues(decoration, padding, textStyle, label);
  @override
  bool operator ==(Object other) {
    return other is DateIndicatorStyle &&
        decoration == other.decoration &&
        padding == other.padding &&
        textStyle == other.textStyle &&
        label == other.label;
  }
}
