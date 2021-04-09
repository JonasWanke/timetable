import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../utils.dart';

@immutable
class TimeOverlay {
  TimeOverlay({
    required this.start,
    required this.end,
    required this.widget,
    this.position = DecorationPosition.background,
  })  : assert(start.isValidTimetableTimeOfDay),
        assert(end.isValidTimetableTimeOfDay),
        assert(start < end);

  final Duration start;
  final Duration end;
  final Widget widget;
  final DecorationPosition position;
}

/// Provides [TimeOverlay]s to timetable widgets.
typedef TimeOverlayProvider = List<TimeOverlay> Function(
  BuildContext context,
  DateTime date,
);

List<TimeOverlay> emptyOverlayProvider(
  BuildContext context,
  DateTime date,
) {
  assert(date.isValidTimetableDate);
  return [];
}
