import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

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
    super.key,
    this.alwaysUseNarrowestVariant = false,
    this.onTap,
    this.style,
  });
  WeekIndicator.forDate(
    DateTime date, {
    super.key,
    this.alwaysUseNarrowestVariant = false,
    this.onTap,
    this.style,
  })  : assert(date.debugCheckIsValidTimetableDate()),
        week = date.week;
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
    return _WeekIndicatorText(
      style.labels,
      style: _getEffectiveTextStyle(context, style.textStyle),
      alwaysUseNarrowestVariant: alwaysUseNarrowestVariant,
    );
  }

  TextStyle _getEffectiveTextStyle(BuildContext context, TextStyle textStyle) {
    var effectiveTextStyle = textStyle;
    if (effectiveTextStyle.inherit) {
      effectiveTextStyle =
          context.defaultTextStyle.style.merge(effectiveTextStyle);
    }
    if (MediaQuery.boldTextOf(context)) {
      effectiveTextStyle = effectiveTextStyle
          .merge(const TextStyle(fontWeight: FontWeight.bold));
    }
    return effectiveTextStyle;
  }
}

class _WeekIndicatorText extends SingleChildRenderObjectWidget {
  const _WeekIndicatorText(
    this.labels, {
    required this.style,
    required this.alwaysUseNarrowestVariant,
  }) : assert(labels.length > 0);

  final List<String> labels;
  final TextStyle style;
  final bool alwaysUseNarrowestVariant;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderWeekIndicatorText(
      labels,
      style,
      context.directionality,
      alwaysUseNarrowestVariant,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderWeekIndicatorText renderObject,
  ) {
    renderObject.labels = labels;
    renderObject.style = style;
    renderObject.textDirection = context.directionality;
    renderObject.alwaysUseNarrowestVariant = alwaysUseNarrowestVariant;
  }
}

class _RenderWeekIndicatorText extends RenderBox {
  _RenderWeekIndicatorText(
    this._labels,
    this._style,
    this._textDirection,
    // ignore: avoid_positional_boolean_parameters
    this._alwaysUseNarrowestVariant,
  ) : assert(_labels.isNotEmpty) {
    _generateLabelPainters();
  }

  late List<String> _labels;
  List<String> get labels => _labels;
  set labels(List<String> labels) {
    if (const DeepCollectionEquality().equals(_labels, labels)) return;

    _labels = labels;
    markNeedsLayout();
    _generateLabelPainters();
  }

  TextStyle _style;
  TextStyle get style => _style;
  set style(TextStyle style) {
    if (const DeepCollectionEquality().equals(_style, style)) return;

    _style = style;
    markNeedsLayout();
    _generateLabelPainters();
  }

  TextDirection _textDirection;
  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection textDirection) {
    if (textDirection == _textDirection) return;

    _textDirection = textDirection;
    markNeedsLayout();
    _generateLabelPainters();
  }

  bool _alwaysUseNarrowestVariant;
  bool get alwaysUseNarrowestVariant => _alwaysUseNarrowestVariant;
  set alwaysUseNarrowestVariant(bool alwaysUseNarrowestVariant) {
    if (alwaysUseNarrowestVariant == _alwaysUseNarrowestVariant) return;

    _alwaysUseNarrowestVariant = alwaysUseNarrowestVariant;
    markNeedsLayout();
  }

  List<TextPainter> _labelPainters = [];
  void _generateLabelPainters() {
    _labelPainters = labels.map((it) {
      return TextPainter(
        text: TextSpan(text: it, style: _style),
        textDirection: textDirection,
        maxLines: 1,
      )..layout(minWidth: 0, maxWidth: double.infinity);
    }).toList();
  }

  late TextPainter _labelPainter;

  @override
  double computeMinIntrinsicWidth(double height) =>
      _labelPainters.map((it) => it.width).min.toDouble();
  @override
  double computeMaxIntrinsicWidth(double height) {
    final widths = _labelPainters.map((it) => it.width);
    return (alwaysUseNarrowestVariant ? widths.min : widths.max).toDouble();
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      _labelPainters.map((it) => it.height).min.toDouble();
  @override
  double computeMaxIntrinsicHeight(double width) {
    final heights = _labelPainters.map((it) => it.height);
    return (alwaysUseNarrowestVariant ? heights.min : heights.max).toDouble();
  }

  @override
  void performLayout() {
    for (final painter in _labelPainters) {
      painter.layout(minWidth: 0, maxWidth: double.infinity);
    }

    TextPainter narrowestPainter() => _labelPainters.minBy((it) => it.width)!;
    if (alwaysUseNarrowestVariant) {
      _labelPainter = narrowestPainter();
    } else {
      _labelPainter = _labelPainters
              .where(
                (it) =>
                    constraints.minWidth <= it.size.width &&
                    it.size.width <= constraints.maxWidth,
              )
              .firstOrNull ??
          narrowestPainter();
    }
    size = constraints.constrain(_labelPainter.size);
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      _labelPainter.paint(context.canvas, offset);
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
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      textStyle: textStyle ??
          context.textTheme.bodyMedium!
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
  int get hashCode {
    return Object.hash(
      tooltip,
      decoration,
      padding,
      textStyle,
      const DeepCollectionEquality().hash(labels),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WeekIndicatorStyle &&
        tooltip == other.tooltip &&
        decoration == other.decoration &&
        padding == other.padding &&
        textStyle == other.textStyle &&
        const DeepCollectionEquality().equals(labels, other.labels);
  }
}

class _WeekIndicatorForController extends StatelessWidget {
  const _WeekIndicatorForController(
    this.controller, {
    super.key,
    this.alwaysUseNarrowestVariant = false,
    this.onTap,
    this.style,
  });

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
