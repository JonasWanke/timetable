import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../date/controller.dart';
import '../localization.dart';
import '../utils.dart';

class WeekIndicatorComponent extends StatelessWidget {
  const WeekIndicatorComponent({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final DateController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: controller.date,
      builder: (context, date, _) => WeekIndicator.forDate(date),
    );
  }
}

class WeekIndicator extends StatelessWidget {
  const WeekIndicator(this.weekInfo, {Key? key}) : super(key: key);
  WeekIndicator.forDate(DateTime date, {Key? key})
      : assert(date.isValidTimetableDate),
        weekInfo = date.weekInfo,
        super(key: key);

  final WeekInfo weekInfo;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final backgroundColor = theme.dividerColor;
    final l10n = TimetableLocalizations.of(context);

    return Tooltip(
      message: l10n.weekOfYear(weekInfo),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: _buildText(l10n, backgroundColor),
        ),
      ),
    );
  }

  Widget _buildText(TimetableLocalizations l10n, Color backgroundColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveTextStyle =
            _getEffectiveTextStyle(context, backgroundColor);

        final labels = l10n.weekLabels(weekInfo);
        assert(labels.isNotEmpty);
        final textVariants = labels.map((it) {
          final textPainter = TextPainter(
            text: TextSpan(text: it, style: effectiveTextStyle),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout(minWidth: 0, maxWidth: double.infinity);
          return Tuple2(it, textPainter.size.width);
        });

        // Select the first one that fits, or otherwise the narrowest one.
        final text = textVariants
            .where((it) => it.item2 >= constraints.minWidth)
            .where((it) => it.item2 <= constraints.maxWidth)
            .map((it) => it.item1)
            .firstOrElse(
              () => textVariants
                  .minBy((a, b) => a.item2.compareTo(b.item2))!
                  .item1,
            );

        return Text(text, style: effectiveTextStyle, maxLines: 1);
      },
    );
  }

  TextStyle _getEffectiveTextStyle(
    BuildContext context,
    Color backgroundColor,
  ) {
    var effectiveTextStyle = TextStyle(
      color: backgroundColor
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
