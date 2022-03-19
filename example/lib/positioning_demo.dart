import 'dart:math';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:timetable/src/utils.dart';
import 'package:timetable/timetable.dart';

// A basic EventProvider containing a single event:
// eventProvider: EventProvider.list([
//   BasicEvent(
//     id: 0,
//     title: 'My Event',
//     color: Colors.blue,
//     start: LocalDate.today().at(LocalTime(13, 0, 0)),
//     end: LocalDate.today().at(LocalTime(15, 0, 0)),
//   ),
// ]),

// For a demo of overlapping events, use this one instead:
// eventProvider: positioningDemoEventProvider,

// Or even this short example using a Stream:
// eventProvider: EventProvider.stream(
//   eventGetter: (range) => Stream.periodic(
//     Duration(milliseconds: 16),
//     (i) {
//       final start =
//           LocalDate.today().atMidnight() + Period(minutes: i * 2);
//       return [
//         BasicEvent(
//           id: 0,
//           title: 'Event',
//           color: Colors.blue,
//           start: start,
//           end: start + Period(hours: 5),
//         ),
//       ];
//     },
//   ),
// ),

// _dateController.page.addListener(() {
//   print('New page: ${_dateController.page.value}');
// });
// _timeController.addListener(() {
//   print('New time range: ${_timeController.value}');
// });

final positioningDemoEvents = <BasicEvent>[
  _DemoEvent(0, 0, Duration(hours: 10), Duration(hours: 11)),
  _DemoEvent(0, 1, Duration(hours: 11), Duration(hours: 12)),
  _DemoEvent(0, 2, Duration(hours: 12), Duration(hours: 13)),
  _DemoEvent(1, 0, Duration(hours: 10), Duration(hours: 12)),
  _DemoEvent(1, 1, Duration(hours: 10), Duration(hours: 12)),
  _DemoEvent(1, 2, Duration(hours: 14), Duration(hours: 16)),
  _DemoEvent(1, 3, Duration(hours: 14, minutes: 15), Duration(hours: 16)),
  _DemoEvent(2, 0, Duration(hours: 10), Duration(hours: 20)),
  _DemoEvent(2, 1, Duration(hours: 10), Duration(hours: 12)),
  _DemoEvent(2, 2, Duration(hours: 13), Duration(hours: 15)),
  _DemoEvent(3, 0, Duration(hours: 10), Duration(hours: 20)),
  _DemoEvent(3, 1, Duration(hours: 12), Duration(hours: 14)),
  _DemoEvent(3, 2, Duration(hours: 12), Duration(hours: 15)),
  _DemoEvent(4, 0, Duration(hours: 10), Duration(hours: 13)),
  _DemoEvent(4, 1, Duration(hours: 10, minutes: 15), Duration(hours: 13)),
  _DemoEvent(4, 2, Duration(hours: 10, minutes: 30), Duration(hours: 13)),
  _DemoEvent(4, 3, Duration(hours: 10, minutes: 45), Duration(hours: 13)),
  _DemoEvent(4, 4, Duration(hours: 11), Duration(hours: 13)),
  _DemoEvent(
    5,
    0,
    Duration(hours: 10, minutes: 30),
    Duration(hours: 13, minutes: 30),
  ),
  _DemoEvent(
    5,
    1,
    Duration(hours: 10, minutes: 30),
    Duration(hours: 13, minutes: 30),
  ),
  _DemoEvent(
    5,
    2,
    Duration(hours: 10, minutes: 30),
    Duration(hours: 12, minutes: 30),
  ),
  _DemoEvent(5, 3, Duration(hours: 8, minutes: 30), Duration(hours: 18)),
  _DemoEvent(5, 4, Duration(hours: 15, minutes: 30), Duration(hours: 16)),
  _DemoEvent(5, 5, Duration(hours: 11), Duration(hours: 12)),
  _DemoEvent(5, 6, Duration(hours: 1), Duration(hours: 2)),
  _DemoEvent(
    6,
    0,
    Duration(hours: 9, minutes: 30),
    Duration(hours: 15, minutes: 30),
  ),
  _DemoEvent(6, 1, Duration(hours: 11), Duration(hours: 13)),
  _DemoEvent(
    6,
    2,
    Duration(hours: 9, minutes: 30),
    Duration(hours: 11, minutes: 30),
  ),
  _DemoEvent(
    6,
    3,
    Duration(hours: 9, minutes: 30),
    Duration(hours: 10, minutes: 30),
  ),
  _DemoEvent(6, 4, Duration(hours: 10), Duration(hours: 11)),
  _DemoEvent(6, 5, Duration(hours: 10), Duration(hours: 11)),
  _DemoEvent(
    6,
    6,
    Duration(hours: 9, minutes: 30),
    Duration(hours: 10, minutes: 30),
  ),
  _DemoEvent(
    6,
    7,
    Duration(hours: 9, minutes: 30),
    Duration(hours: 10, minutes: 30),
  ),
  _DemoEvent(
    6,
    8,
    Duration(hours: 9, minutes: 30),
    Duration(hours: 10, minutes: 30),
  ),
  _DemoEvent(
    6,
    9,
    Duration(hours: 10, minutes: 30),
    Duration(hours: 12, minutes: 30),
  ),
  _DemoEvent(6, 10, Duration(hours: 12), Duration(hours: 13)),
  _DemoEvent(6, 11, Duration(hours: 12), Duration(hours: 13)),
  _DemoEvent(6, 12, Duration(hours: 12), Duration(hours: 13)),
  _DemoEvent(6, 13, Duration(hours: 12), Duration(hours: 13)),
  _DemoEvent(6, 14, Duration(hours: 6, minutes: 30), Duration(hours: 8)),
  _DemoEvent(
    7,
    0,
    Duration(hours: 2, minutes: 30),
    Duration(hours: 4, minutes: 30),
  ),
  _DemoEvent(
    7,
    1,
    Duration(hours: 2, minutes: 30),
    Duration(hours: 3, minutes: 30),
  ),
  _DemoEvent(7, 2, Duration(hours: 3), Duration(hours: 4)),
  _DemoEvent(8, 0, Duration(hours: 20), Duration(hours: 4), endDateOffset: 1),
  _DemoEvent(9, 1, Duration(hours: 12), Duration(hours: 16)),
  _DemoEvent(9, 2, Duration(hours: 12), Duration(hours: 13)),
  _DemoEvent(9, 3, Duration(hours: 12), Duration(hours: 13)),
  _DemoEvent(9, 4, Duration(hours: 12), Duration(hours: 13)),
  _DemoEvent(9, 5, Duration(hours: 15), Duration(hours: 16)),
  _DemoEvent.allDay(0, 0, 1),
  _DemoEvent.allDay(1, 1, 1),
  _DemoEvent.allDay(2, 0, 2),
  _DemoEvent.allDay(3, 2, 2),
  _DemoEvent.allDay(4, 2, 2),
  _DemoEvent.allDay(5, 1, 2),
  _DemoEvent.allDay(6, 3, 2),
  _DemoEvent.allDay(7, 4, 4),
  _DemoEvent.allDay(8, -1, 2),
  _DemoEvent.allDay(9, -2, 2),
  _DemoEvent.allDay(10, -3, 2),
];

class _DemoEvent extends BasicEvent {
  _DemoEvent(
    int demoId,
    int eventId,
    Duration start,
    Duration end, {
    int endDateOffset = 0,
  }) : super(
          id: '$demoId-$eventId',
          title: '$demoId-$eventId',
          backgroundColor: _getColor('$demoId-$eventId'),
          start: DateTime.now().toUtc().atStartOfDay + demoId.days + start,
          end: DateTime.now().toUtc().atStartOfDay +
              (demoId + endDateOffset).days +
              end,
        );

  _DemoEvent.allDay(int id, int startOffset, int length)
      : super(
          id: 'a-$id',
          title: 'a-$id',
          backgroundColor: _getColor('a-$id'),
          start: DateTime.now().toUtc().atStartOfDay + startOffset.days,
          end:
              DateTime.now().toUtc().atStartOfDay + (startOffset + length).days,
        );

  static Color _getColor(String id) {
    return Random(id.hashCode)
        .nextColorHsv(saturation: 0.6, value: 0.8, alpha: 1)
        .toColor();
  }
}

List<TimeOverlay> positioningDemoOverlayProvider(
  BuildContext context,
  DateTime date,
) {
  assert(date.isValidTimetableDate);

  final widget =
      ColoredBox(color: context.theme.brightness.contrastColor.withOpacity(.1));

  if (DateTime.monday <= date.weekday && date.weekday <= DateTime.friday) {
    return [
      TimeOverlay(start: 0.hours, end: 8.hours, widget: widget),
      TimeOverlay(start: 20.hours, end: 24.hours, widget: widget),
    ];
  } else {
    return [TimeOverlay(start: 0.hours, end: 24.hours, widget: widget)];
  }
}
