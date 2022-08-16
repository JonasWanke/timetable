import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config.dart';
import '../date/controller.dart';
import '../localization.dart';
import '../theme.dart';
import '../utils.dart';

/// A widget that displays the name of the given month.
///
/// See also:
///
/// * [MonthIndicatorStyle], which defines visual properties for this widget.
/// * [TimetableTheme] (and [TimetableConfig]), which provide styles to
///   descendant Timetable widgets.
class MonthIndicator extends StatelessWidget {
  MonthIndicator(
    this.month, {
    super.key,
    this.style,
  }) : assert(month.debugCheckIsValidTimetableMonth());
  static Widget forController(
    DateController? controller, {
    Key? key,
    MonthIndicatorStyle? style,
  }) =>
      _MonthIndicatorForController(controller, key: key, style: style);

  final DateTime month;
  final MonthIndicatorStyle? style;

  @override
  Widget build(BuildContext context) {
    final style = this.style ??
        TimetableTheme.orDefaultOf(context).monthIndicatorStyleProvider(month);

    return Text(style.label, style: style.textStyle);
  }
}

/// Defines visual properties for [MonthIndicator].
///
/// See also:
///
/// * [TimetableThemeData], which bundles the styles for all Timetable widgets.
@immutable
class MonthIndicatorStyle {
  factory MonthIndicatorStyle(
    BuildContext context,
    DateTime month, {
    TextStyle? textStyle,
    String? label,
  }) {
    assert(month.debugCheckIsValidTimetableMonth());

    final theme = context.theme;
    return MonthIndicatorStyle.raw(
      textStyle: textStyle ?? theme.textTheme.subtitle1!,
      label: label ??
          () {
            context.dependOnTimetableLocalizations();
            return DateFormat.MMMM().format(month);
          }(),
    );
  }

  const MonthIndicatorStyle.raw({
    required this.textStyle,
    required this.label,
  });

  final TextStyle textStyle;
  final String label;

  MonthIndicatorStyle copyWith({TextStyle? textStyle, String? label}) {
    return MonthIndicatorStyle.raw(
      textStyle: textStyle ?? this.textStyle,
      label: label ?? this.label,
    );
  }

  @override
  int get hashCode => hashValues(textStyle, label);
  @override
  bool operator ==(Object other) {
    return other is MonthIndicatorStyle &&
        textStyle == other.textStyle &&
        label == other.label;
  }
}

class _MonthIndicatorForController extends StatelessWidget {
  const _MonthIndicatorForController(
    this.controller, {
    super.key,
    this.style,
  });

  final DateController? controller;
  final MonthIndicatorStyle? style;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller ?? DefaultDateController.of(context)!;
    return ValueListenableBuilder<DateTime>(
      valueListenable: controller.date.map((it) => it.firstDayOfMonth),
      builder: (context, month, _) => MonthIndicator(month, style: style),
    );
  }
}
