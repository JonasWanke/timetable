import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../event/all_day.dart';
import '../event/basic.dart';
import '../event/builder.dart';
import '../layouts/multi_date.dart';
import '../localization.dart';
import '../utils.dart';
import 'multi_date_event_header.dart';

/// The default widget for displaying the overflow of a [MultiDateEventHeader].
///
/// These overflows are shown when there are more multi-date events in
/// parallel than may be shown as separate rows in the header.
///
/// See also:
///
/// * [TimetableCallbacks.onMultiDateHeaderOverflowTap], which is called when
///   the user taps this widget.
/// * [MultiDateEventHeader], which shows these overflow widgets.
/// * [MultiDateEventHeaderStyle.maxEventRows] and
///   [MultiDateTimetableStyle.maxHeaderFraction], which control how many rows
///   are allowed before creating an overflow.
/// * [DefaultEventBuilder.allDayOverflowBuilder], which creates this widget by
///   default.
class MultiDateEventHeaderOverflow extends StatelessWidget {
  MultiDateEventHeaderOverflow(
    this.date, {
    super.key,
    required this.overflowCount,
  })  : assert(date.debugCheckIsValidTimetableDate()),
        assert(overflowCount >= 1);

  final DateTime date;
  final int overflowCount;

  @override
  Widget build(BuildContext context) {
    final onMultiDateHeaderOverflowTap =
        DefaultTimetableCallbacks.of(context)?.onMultiDateHeaderOverflowTap;
    return BasicAllDayEventWidget(
      BasicEvent(
        id: date,
        title: TimetableLocalizations.of(context).allDayOverflow(overflowCount),
        backgroundColor: context.theme.backgroundColor.withOpacity(0),
        start: date,
        end: date.atEndOfDay,
      ),
      info: const AllDayEventLayoutInfo(hiddenStartDays: 0, hiddenEndDays: 0),
      onTap: onMultiDateHeaderOverflowTap == null
          ? null
          : () => onMultiDateHeaderOverflowTap(date),
    );
  }
}
