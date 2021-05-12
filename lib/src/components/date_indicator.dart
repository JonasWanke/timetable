import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../styling.dart';
import '../utils.dart';

class DateIndicator extends StatelessWidget {
  DateIndicator(
    this.date, {
    Key? key,
    this.style,
  })  : assert(date.isValidTimetableDate),
        super(key: key);

  final DateTime date;
  final DateIndicatorStyle? style;

  @override
  Widget build(BuildContext context) {
    final style = this.style ??
        TimetableTheme.orDefaultOf(context).dateIndicatorStyleProvider(date);

    return DecoratedBox(
      decoration: style.decoration,
      child: Padding(
        padding: style.padding,
        child: Text(style.label, style: style.textStyle),
      ),
    );
  }
}

/// Style for [DateIndicator].
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

    final theme = context.theme;
    return DateIndicatorStyle.raw(
      decoration: decoration ??
          BoxDecoration(
            shape: BoxShape.circle,
            color:
                date.isToday ? theme.colorScheme.primary : Colors.transparent,
          ),
      padding: padding ?? EdgeInsets.all(8),
      textStyle: textStyle ??
          context.textTheme.subtitle1!.copyWith(
            color: date.isToday
                ? theme.colorScheme.primary.highEmphasisOnColor
                : theme.colorScheme.background.highEmphasisOnColor,
          ),
      label: label ?? DateFormat('d').format(date),
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
