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
        TimetableTheme.of(context)!.dateIndicatorStyleProvider(date);

    return DecoratedBox(
      decoration: style.decoration,
      child: Padding(
        padding: style.padding,
        child: Text(DateFormat('d').format(date), style: style.textStyle),
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
  }) {
    assert(date.isValidTimetableDate);

    final colorScheme = context.theme.colorScheme;
    return DateIndicatorStyle.raw(
      decoration: decoration ??
          BoxDecoration(
            shape: BoxShape.circle,
            color: date.isToday ? colorScheme.primary : Colors.transparent,
          ),
      padding: padding ?? EdgeInsets.all(8),
      textStyle: textStyle ??
          context.textTheme.subtitle1!.copyWith(
            color: date.isToday
                ? colorScheme.primary.highEmphasisOnColor
                : colorScheme.background.highEmphasisOnColor,
          ),
    );
  }

  const DateIndicatorStyle.raw({
    required this.decoration,
    required this.padding,
    required this.textStyle,
  });

  final Decoration decoration;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;

  @override
  int get hashCode => hashValues(decoration, padding, textStyle);
  @override
  bool operator ==(Object other) {
    return other is DateIndicatorStyle &&
        decoration == other.decoration &&
        padding == other.padding &&
        textStyle == other.textStyle;
  }
}
