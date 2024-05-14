import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:chrono/chrono.dart';
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
  const MonthIndicator(this.yearMonth, {super.key, this.style});
  static Widget forController(
    DateController? controller, {
    Key? key,
    MonthIndicatorStyle? style,
  }) =>
      _MonthIndicatorForController(controller, key: key, style: style);

  final YearMonth yearMonth;
  final MonthIndicatorStyle? style;

  @override
  Widget build(BuildContext context) {
    final style = this.style ??
        TimetableTheme.orDefaultOf(context)
            .monthIndicatorStyleProvider(yearMonth);

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
    YearMonth yearMonth, {
    TextStyle? textStyle,
    String? label,
  }) {
    final theme = context.theme;
    return MonthIndicatorStyle.raw(
      textStyle: textStyle ?? theme.textTheme.titleMedium!,
      label: label ??
          () {
            context.dependOnTimetableLocalizations();
            return DateFormat.MMMM().format(
              yearMonth.firstDay.atMidnight.asCoreDateTimeInLocalZone,
            );
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
  int get hashCode => Object.hash(textStyle, label);
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
    return ValueListenableBuilder(
      valueListenable: controller.date.map((it) => it.yearMonth),
      builder: (context, yearMonth, _) =>
          MonthIndicator(yearMonth, style: style),
    );
  }
}
