import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../callbacks.dart';
import '../config.dart';
import '../date/controller.dart';
import '../localization.dart';
import '../theme.dart';
import '../utils.dart';
import '../week.dart';

/// A widget that displays the week number and possibly year for the given week.
///
/// If the [WeekIndicatorStyle] contains multiple labels, the longest one that
/// fits the available width is chosen. This behavior can be changed via
/// [alwaysUseNarrowestVariant].
///
/// If [onTap] is not supplied, [DefaultTimetableCallbacks]'s `onWeekTap` is
/// used if it's provided above in the widget tree.
///
/// See also:
///
/// * [WeekIndicatorStyle], which defines visual properties for this widget.
/// * [TimetableTheme] (and [TimetableConfig]), which provide styles to
///   descendant Timetable widgets.
/// * [DefaultTimetableCallbacks], which provides callbacks to descendant
///   Timetable widgets.
class WeekIndicator extends StatelessWidget {
  const WeekIndicator(
    this.week, {
    Key? key,
    this.alwaysUseNarrowestVariant = false,
    this.onTap,
    this.style,
  }) : super(key: key);
  WeekIndicator.forDate(
    DateTime date, {
    Key? key,
    this.alwaysUseNarrowestVariant = false,
    this.onTap,
    this.style,
  })  : assert(date.isValidTimetableDate),
        week = date.week,
        super(key: key);
  static Widget forController(
    DateController? controller, {
    Key? key,
    bool alwaysUseNarrowestVariant = false,
    VoidCallback? onTap,
    WeekIndicatorStyle? style,
  }) =>
      _WeekIndicatorForController(
        controller,
        key: key,
        alwaysUseNarrowestVariant: alwaysUseNarrowestVariant,
        onTap: onTap,
        style: style,
      );

  final Week week;
  final bool alwaysUseNarrowestVariant;
  final VoidCallback? onTap;
  final WeekIndicatorStyle? style;

  @override
  Widget build(BuildContext context) {
    final style = this.style ??
        TimetableTheme.orDefaultOf(context).weekIndicatorStyleProvider(week);
    final defaultOnTap = DefaultTimetableCallbacks.of(context)?.onWeekTap;

    return InkResponse(
      onTap: onTap ?? (defaultOnTap != null ? () => defaultOnTap(week) : null),
      child: Tooltip(
        message: style.tooltip,
        child: DecoratedBox(
          decoration: style.decoration,
          child: Padding(
            padding: style.padding,
            child: _buildText(context, style),
          ),
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context, WeekIndicatorStyle style) {
    final textStyle = _getEffectiveTextStyle(context, style.textStyle);

    final measuredLabels = style.labels.map((it) {
      final textPainter = TextPainter(
        text: TextSpan(text: it, style: textStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: double.infinity);
      return Tuple2(it, textPainter.size.width);
    });

    final narrowestText = measuredLabels.minBy((it) => it.item2)!.item1;
    Widget build(String text) => Text(
          text,
          style: textStyle,
          maxLines: 1,
          overflow: TextOverflow.visible,
          softWrap: false,
        );

    if (alwaysUseNarrowestVariant) return build(narrowestText);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Select the first one that fits, or otherwise the narrowest one.
        final text = measuredLabels
                .where((it) => it.item2 >= constraints.minWidth)
                .where((it) => it.item2 <= constraints.maxWidth)
                .map((it) => it.item1)
                .firstOrNull ??
            narrowestText;

        return build(text);
      },
    );
  }

  TextStyle _getEffectiveTextStyle(BuildContext context, TextStyle textStyle) {
    var effectiveTextStyle = textStyle;
    if (effectiveTextStyle.inherit) {
      effectiveTextStyle =
          context.defaultTextStyle.style.merge(effectiveTextStyle);
    }
    if (MediaQuery.boldTextOverride(context)) {
      effectiveTextStyle = effectiveTextStyle
          .merge(const TextStyle(fontWeight: FontWeight.bold));
    }
    return effectiveTextStyle;
  }
}

/// Defines visual properties for [WeekIndicator].
///
/// See also:
///
/// * [TimetableThemeData], which bundles the styles for all Timetable widgets.
@immutable
class WeekIndicatorStyle {
  factory WeekIndicatorStyle(
    BuildContext context,
    Week week, {
    String? tooltip,
    Decoration? decoration,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    List<String>? labels,
  }) {
    final colorScheme = context.theme.colorScheme;
    final localizations = TimetableLocalizations.of(context);
    return WeekIndicatorStyle.raw(
      tooltip: tooltip ?? localizations.weekOfYear(week),
      decoration: decoration ??
          BoxDecoration(
            color: colorScheme.brightness.contrastColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(4),
          ),
      padding: padding ?? EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      textStyle: textStyle ??
          context.textTheme.bodyText2!
              .copyWith(color: colorScheme.background.mediumEmphasisOnColor),
      labels: labels ?? localizations.weekLabels(week),
    );
  }

  const WeekIndicatorStyle.raw({
    required this.tooltip,
    required this.decoration,
    required this.padding,
    required this.textStyle,
    required this.labels,
  }) : assert(labels.length > 0);

  final String tooltip;
  final Decoration decoration;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  final List<String> labels;

  WeekIndicatorStyle copyWith({
    String? tooltip,
    Decoration? decoration,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    List<String>? labels,
  }) {
    return WeekIndicatorStyle.raw(
      tooltip: tooltip ?? this.tooltip,
      decoration: decoration ?? this.decoration,
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      labels: labels ?? this.labels,
    );
  }

  @override
  int get hashCode => hashValues(
        tooltip,
        decoration,
        padding,
        textStyle,
        DeepCollectionEquality().hash(labels),
      );
  @override
  bool operator ==(Object other) {
    return other is WeekIndicatorStyle &&
        tooltip == other.tooltip &&
        decoration == other.decoration &&
        padding == other.padding &&
        textStyle == other.textStyle &&
        DeepCollectionEquality().equals(labels, other.labels);
  }
}

class _WeekIndicatorForController extends StatelessWidget {
  const _WeekIndicatorForController(
    this.controller, {
    Key? key,
    this.alwaysUseNarrowestVariant = false,
    this.onTap,
    this.style,
  }) : super(key: key);

  final DateController? controller;
  final bool alwaysUseNarrowestVariant;
  final VoidCallback? onTap;
  final WeekIndicatorStyle? style;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Week>(
      valueListenable: (controller ?? DefaultDateController.of(context)!)
          .date
          .map((it) => it.week),
      builder: (context, week, _) => WeekIndicator(
        week,
        alwaysUseNarrowestVariant: alwaysUseNarrowestVariant,
        onTap: onTap,
        style: style,
      ),
    );
  }
}
