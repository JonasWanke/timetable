import 'dart:math';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:chrono/chrono.dart';
import 'package:flutter/material.dart';
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
//           LocalDate.today().atMidnight() + Period(i * 2);
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
  _DemoEvent(0, 0, Time.from(10).unwrap(), Time.from(11).unwrap()),
  _DemoEvent(0, 1, Time.from(11).unwrap(), Time.from(12).unwrap()),
  _DemoEvent(0, 2, Time.from(12).unwrap(), Time.from(13).unwrap()),
  _DemoEvent(1, 0, Time.from(10).unwrap(), Time.from(12).unwrap()),
  _DemoEvent(1, 1, Time.from(10).unwrap(), Time.from(12).unwrap()),
  _DemoEvent(1, 2, Time.from(14).unwrap(), Time.from(16).unwrap()),
  _DemoEvent(1, 3, Time.from(14, 15).unwrap(), Time.from(16).unwrap()),
  _DemoEvent(2, 0, Time.from(10).unwrap(), Time.from(20).unwrap()),
  _DemoEvent(2, 1, Time.from(10).unwrap(), Time.from(12).unwrap()),
  _DemoEvent(2, 2, Time.from(13).unwrap(), Time.from(15).unwrap()),
  _DemoEvent(3, 0, Time.from(10).unwrap(), Time.from(20).unwrap()),
  _DemoEvent(3, 1, Time.from(12).unwrap(), Time.from(14).unwrap()),
  _DemoEvent(3, 2, Time.from(12).unwrap(), Time.from(15).unwrap()),
  _DemoEvent(4, 0, Time.from(10).unwrap(), Time.from(13).unwrap()),
  _DemoEvent(4, 1, Time.from(10, 15).unwrap(), Time.from(13).unwrap()),
  _DemoEvent(4, 2, Time.from(10, 30).unwrap(), Time.from(13).unwrap()),
  _DemoEvent(4, 3, Time.from(10, 45).unwrap(), Time.from(13).unwrap()),
  _DemoEvent(4, 4, Time.from(11).unwrap(), Time.from(13).unwrap()),
  _DemoEvent(5, 0, Time.from(10, 30).unwrap(), Time.from(13, 30).unwrap()),
  _DemoEvent(5, 1, Time.from(10, 30).unwrap(), Time.from(13, 30).unwrap()),
  _DemoEvent(5, 2, Time.from(10, 30).unwrap(), Time.from(12, 30).unwrap()),
  _DemoEvent(5, 3, Time.from(8, 30).unwrap(), Time.from(18).unwrap()),
  _DemoEvent(5, 4, Time.from(15, 30).unwrap(), Time.from(16).unwrap()),
  _DemoEvent(5, 5, Time.from(11).unwrap(), Time.from(12).unwrap()),
  _DemoEvent(5, 6, Time.from(1).unwrap(), Time.from(2).unwrap()),
  _DemoEvent(6, 0, Time.from(9, 30).unwrap(), Time.from(15, 30).unwrap()),
  _DemoEvent(6, 1, Time.from(11).unwrap(), Time.from(13).unwrap()),
  _DemoEvent(6, 2, Time.from(9, 30).unwrap(), Time.from(11, 30).unwrap()),
  _DemoEvent(6, 3, Time.from(9, 30).unwrap(), Time.from(10, 30).unwrap()),
  _DemoEvent(6, 4, Time.from(10).unwrap(), Time.from(11).unwrap()),
  _DemoEvent(6, 5, Time.from(10).unwrap(), Time.from(11).unwrap()),
  _DemoEvent(6, 6, Time.from(9, 30).unwrap(), Time.from(10, 30).unwrap()),
  _DemoEvent(6, 7, Time.from(9, 30).unwrap(), Time.from(10, 30).unwrap()),
  _DemoEvent(6, 8, Time.from(9, 30).unwrap(), Time.from(10, 30).unwrap()),
  _DemoEvent(6, 9, Time.from(10, 30).unwrap(), Time.from(12, 30).unwrap()),
  _DemoEvent(6, 10, Time.from(12).unwrap(), Time.from(13).unwrap()),
  _DemoEvent(6, 11, Time.from(12).unwrap(), Time.from(13).unwrap()),
  _DemoEvent(6, 12, Time.from(12).unwrap(), Time.from(13).unwrap()),
  _DemoEvent(6, 13, Time.from(12).unwrap(), Time.from(13).unwrap()),
  _DemoEvent(6, 14, Time.from(6, 30).unwrap(), Time.from(8).unwrap()),
  _DemoEvent(7, 0, Time.from(2, 30).unwrap(), Time.from(4, 30).unwrap()),
  _DemoEvent(7, 1, Time.from(2, 30).unwrap(), Time.from(3, 30).unwrap()),
  _DemoEvent(7, 2, Time.from(3).unwrap(), Time.from(4).unwrap()),
  _DemoEvent(
    8,
    0,
    Time.from(20).unwrap(),
    Time.from(4).unwrap(),
    endDateOffset: 1,
  ),
  _DemoEvent(9, 1, Time.from(12).unwrap(), Time.from(16).unwrap()),
  _DemoEvent(9, 2, Time.from(12).unwrap(), Time.from(13).unwrap()),
  _DemoEvent(9, 3, Time.from(12).unwrap(), Time.from(13).unwrap()),
  _DemoEvent(9, 4, Time.from(12).unwrap(), Time.from(13).unwrap()),
  _DemoEvent(9, 5, Time.from(15).unwrap(), Time.from(16).unwrap()),
  _DemoEvent.allDay(0, 0, 1),
  _DemoEvent.allDay(1, 1, 1),
  _DemoEvent.allDay(2, 0, 2),
  _DemoEvent.allDay(3, 2, 2),
  _DemoEvent.allDay(4, 2, 2),
  _DemoEvent.allDay(5, 1, 2),
  _DemoEvent.allDay(6, 3, 2),
  _DemoEvent.allDay(7, 4, 4),
  _DemoEvent.allDay(8, -1, 4),
  _DemoEvent.allDay(9, -1, 2),
  _DemoEvent.allDay(10, 1, 3),
  _DemoEvent.allDay(11, -2, 2),
  _DemoEvent.allDay(12, -3, 2),
];

class _DemoEvent extends BasicEvent {
  factory _DemoEvent(
    int demoId,
    int eventId,
    Time start,
    Time end, {
    int endDateOffset = 0,
  }) {
    final today = Date.todayInLocalZone();
    return _DemoEvent._(
      demoId.toString(),
      eventId,
      start: (today + Days(demoId)).at(start),
      end: (today + Days(demoId + endDateOffset)).at(end),
    );
  }

  factory _DemoEvent.allDay(int id, int startOffset, int length) {
    final today = Date.todayInLocalZone();
    return _DemoEvent._(
      'a',
      id,
      start: (today + Days(startOffset)).atMidnight,
      end: (today + Days(startOffset + length)).atMidnight,
    );
  }
  _DemoEvent._(
    String demoId,
    int eventId, {
    required super.start,
    required super.end,
  }) : super(
          id: '$demoId-$eventId',
          title: '$demoId-$eventId',
          backgroundColor: _getColor('$demoId-$eventId'),
        );

  static Color _getColor(String id) {
    return Random(id.hashCode)
        .nextColorHsv(saturation: 0.6, value: 0.8, alpha: 1)
        .toColor();
  }
}

List<TimeOverlay> positioningDemoOverlayProvider(
  BuildContext context,
  Date date,
) {
  final widget =
      ColoredBox(color: context.theme.brightness.contrastColor.withOpacity(.1));

  if (Weekday.monday <= date.weekday && date.weekday <= Weekday.friday) {
    return [
      TimeOverlay(
        start: Time.from(0).unwrap(),
        end: Time.from(8).unwrap(),
        widget: widget,
      ),
      TimeOverlay(start: Time.from(20).unwrap(), end: null, widget: widget),
    ];
  } else {
    return [
      TimeOverlay(
        start: Time.from(0).unwrap(),
        end: Time.from(24).unwrap(),
        widget: widget,
      ),
    ];
  }
}
