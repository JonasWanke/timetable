import 'package:flutter/material.dart';

import '../config.dart';
import '../date/controller.dart';
import '../date/visible_date_range.dart';
import '../event/builder.dart';
import '../event/event.dart';
import '../event/provider.dart';
import '../theme.dart';
import '../time/controller.dart';
import 'multi_date.dart';

/// A Timetable widget that displays multiple consecutive days without their
/// dates and without a week indicator.
///
/// To configure it, provide a [DateController] (with a
/// [VisibleDateRange.fixed]), [TimeController], [EventProvider], and
/// [EventBuilder] via a [TimetableConfig] widget above in the widget tree. (You
/// can also provide these via `DefaultFoo` widgets directly, like
/// [DefaultDateController].)
///
/// See also:
///
/// * [MultiDateTimetable], which is used under the hood and can also display
///   concrete dates and be swipeable.
class RecurringMultiDateTimetable<E extends Event> extends StatelessWidget {
  RecurringMultiDateTimetable({
    Key? key,
    WidgetBuilder? timetableBuilder,
  })  : timetableBuilder = timetableBuilder ?? _defaultTimetableBuilder<E>(),
        super(key: key);

  final WidgetBuilder timetableBuilder;
  static WidgetBuilder _defaultTimetableBuilder<E extends Event>() {
    return (context) => MultiDateTimetable<E>(
          headerBuilder: (header, leadingWidth) => MultiDateTimetableHeader<E>(
              leading: SizedBox(width: leadingWidth)),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = TimetableTheme.orDefaultOf(context);

    return TimetableTheme(
      data: theme.copyWith(
        dateHeaderStyleProvider: (date) => theme
            .dateHeaderStyleProvider(date)
            .copyWith(showDateIndicator: false),
      ),
      child: Builder(builder: timetableBuilder),
    );
  }
}
