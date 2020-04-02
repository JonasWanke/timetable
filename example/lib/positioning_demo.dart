import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/timetable.dart';

final EventProvider<BasicEvent> positioningDemoEventProvider =
    EventProvider.list(_events);

final _events = <BasicEvent>[
  _DemoEvent(0, 0, LocalTime(10, 0, 0), LocalTime(11, 0, 0)),
  _DemoEvent(0, 1, LocalTime(11, 0, 0), LocalTime(12, 0, 0)),
  _DemoEvent(0, 2, LocalTime(12, 0, 0), LocalTime(13, 0, 0)),
  _DemoEvent(1, 0, LocalTime(10, 0, 0), LocalTime(12, 0, 0)),
  _DemoEvent(1, 1, LocalTime(10, 0, 0), LocalTime(12, 0, 0)),
  _DemoEvent(1, 2, LocalTime(14, 0, 0), LocalTime(16, 0, 0)),
  _DemoEvent(1, 3, LocalTime(14, 15, 0), LocalTime(16, 0, 0)),
  _DemoEvent(2, 0, LocalTime(10, 0, 0), LocalTime(20, 0, 0)),
  _DemoEvent(2, 1, LocalTime(10, 0, 0), LocalTime(12, 0, 0)),
  _DemoEvent(2, 2, LocalTime(13, 0, 0), LocalTime(15, 0, 0)),
  _DemoEvent(3, 0, LocalTime(10, 0, 0), LocalTime(20, 0, 0)),
  _DemoEvent(3, 1, LocalTime(12, 0, 0), LocalTime(14, 0, 0)),
  _DemoEvent(3, 2, LocalTime(12, 0, 0), LocalTime(15, 0, 0)),
  _DemoEvent(4, 0, LocalTime(10, 0, 0), LocalTime(13, 0, 0)),
  _DemoEvent(4, 1, LocalTime(10, 15, 0), LocalTime(13, 0, 0)),
  _DemoEvent(4, 2, LocalTime(10, 30, 0), LocalTime(13, 0, 0)),
  _DemoEvent(4, 3, LocalTime(10, 45, 0), LocalTime(13, 0, 0)),
  _DemoEvent(4, 4, LocalTime(11, 0, 0), LocalTime(13, 0, 0)),
  _DemoEvent(5, 0, LocalTime(10, 30, 0), LocalTime(13, 30, 0)),
  _DemoEvent(5, 1, LocalTime(10, 30, 0), LocalTime(13, 30, 0)),
  _DemoEvent(5, 2, LocalTime(10, 30, 0), LocalTime(12, 30, 0)),
  _DemoEvent(5, 3, LocalTime(8, 30, 0), LocalTime(18, 0, 0)),
  _DemoEvent(5, 4, LocalTime(15, 30, 0), LocalTime(16, 0, 0)),
  _DemoEvent(5, 5, LocalTime(11, 0, 0), LocalTime(12, 0, 0)),
  _DemoEvent(5, 6, LocalTime(1, 0, 0), LocalTime(2, 0, 0)),
  _DemoEvent(6, 0, LocalTime(9, 30, 0), LocalTime(15, 30, 0)),
  _DemoEvent(6, 1, LocalTime(11, 0, 0), LocalTime(13, 0, 0)),
  _DemoEvent(6, 2, LocalTime(9, 30, 0), LocalTime(11, 30, 0)),
  _DemoEvent(6, 3, LocalTime(9, 30, 0), LocalTime(10, 30, 0)),
  _DemoEvent(6, 4, LocalTime(10, 0, 0), LocalTime(11, 0, 0)),
  _DemoEvent(6, 5, LocalTime(10, 0, 0), LocalTime(11, 0, 0)),
  _DemoEvent(6, 6, LocalTime(9, 30, 0), LocalTime(10, 30, 0)),
  _DemoEvent(6, 7, LocalTime(9, 30, 0), LocalTime(10, 30, 0)),
  _DemoEvent(6, 8, LocalTime(9, 30, 0), LocalTime(10, 30, 0)),
  _DemoEvent(6, 9, LocalTime(10, 30, 0), LocalTime(12, 30, 0)),
  _DemoEvent(6, 10, LocalTime(12, 0, 0), LocalTime(13, 0, 0)),
  _DemoEvent(6, 11, LocalTime(12, 0, 0), LocalTime(13, 0, 0)),
  _DemoEvent(6, 12, LocalTime(12, 0, 0), LocalTime(13, 0, 0)),
  _DemoEvent(6, 13, LocalTime(12, 0, 0), LocalTime(13, 0, 0)),
  _DemoEvent(6, 14, LocalTime(6, 30, 0), LocalTime(8, 0, 0)),
  _DemoEvent(7, 0, LocalTime(2, 30, 0), LocalTime(4, 30, 0)),
  _DemoEvent(7, 1, LocalTime(2, 30, 0), LocalTime(3, 30, 0)),
  _DemoEvent(7, 2, LocalTime(3, 0, 0), LocalTime(4, 0, 0)),
  _DemoEvent(8, 0, LocalTime(20, 0, 0), LocalTime(4, 0, 0), endDateOffset: 1),
];

class _DemoEvent extends BasicEvent {
  _DemoEvent(
    int demoId,
    int eventId,
    LocalTime start,
    LocalTime end, {
    int endDateOffset = 0,
  }) : super(
          id: '$demoId-$eventId',
          title: '$demoId-$eventId',
          color: Colors.grey,
          start: LocalDate.today().addDays(demoId).at(start),
          end: LocalDate.today().addDays(demoId + endDateOffset).at(end),
        );
}
