import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../date/controller.dart';
import '../localization.dart';
import '../styling.dart';
import '../utils.dart';

class WeekIndicator extends StatelessWidget {
  const WeekIndicator(
    this.weekInfo, {
    Key? key,
    this.style = const WeekIndicatorStyle(),
  }) : super(key: key);
  WeekIndicator.forDate(
    DateTime date, {
    Key? key,
    this.style = const WeekIndicatorStyle(),
  })  : assert(date.isValidTimetableDate),
        weekInfo = date.weekInfo,
        super(key: key);
  static Widget forController(DateController controller, {Key? key}) =>
      _WeekIndicatorForController(controller, key: key);

  final WeekInfo weekInfo;
  final WeekIndicatorStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final state = weekInfo.state;

    return Tooltip(
      message: context.timetableLocalizations.weekOfYear(weekInfo),
      child: DecoratedBox(
        decoration: style.decoration?.resolve(state) ??
            BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(4),
            ),
        child: Padding(
          padding: style.padding?.resolve(state) ??
              EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: _buildText(context),
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    final style = _getEffectiveTextStyle(context);

    final labels = context.timetableLocalizations.weekLabels(weekInfo);
    assert(labels.isNotEmpty);
    final measuredLabels = labels.map((it) {
      final textPainter = TextPainter(
        text: TextSpan(text: it, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: double.infinity);
      return Tuple2(it, textPainter.size.width);
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        // Select the first one that fits, or otherwise the narrowest one.
        final text = measuredLabels
            .where((it) => it.item2 >= constraints.minWidth)
            .where((it) => it.item2 <= constraints.maxWidth)
            .map((it) => it.item1)
            .firstOrElse(
              () => measuredLabels
                  .minBy((a, b) => a.item2.compareTo(b.item2))!
                  .item1,
            );

        return Text(text, style: style, maxLines: 1);
      },
    );
  }

  TextStyle _getEffectiveTextStyle(BuildContext context) {
    var effectiveTextStyle = TextStyle(
      color: context.theme.dividerColor
          .alphaBlendOn(context.theme.scaffoldBackgroundColor)
          .mediumEmphasisOnColor,
    );
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
class WeekIndicatorStyle {
  const WeekIndicatorStyle({
    this.decoration,
    this.padding,
    this.textStyle,
  });

  final TemporalStateProperty<Decoration?>? decoration;
  final TemporalStateProperty<EdgeInsetsGeometry?>? padding;
  final TemporalStateProperty<TextStyle?>? textStyle;

  @override
  int get hashCode => hashList([decoration, padding, textStyle]);
  @override
  bool operator ==(Object other) {
    return other is WeekIndicatorStyle &&
        other.decoration == decoration &&
        other.padding == padding &&
        other.textStyle == textStyle;
  }
}

class _WeekIndicatorForController extends StatelessWidget {
  const _WeekIndicatorForController(this.controller, {Key? key})
      : super(key: key);

  final DateController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<WeekInfo>(
      valueListenable: controller.date.map((it) => it.weekInfo),
      builder: (context, month, _) => WeekIndicator(month),
    );
  }
}
