import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/timetable.dart';

import 'utils.dart';

void main() {
  setTargetPlatformForDesktop();
  runApp(TimetableExample());
}

class TimetableExample extends StatefulWidget {
  @override
  _TimetableExampleState createState() => _TimetableExampleState();
}

class _TimetableExampleState extends State<TimetableExample> {
  TimetableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TimetableController();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timetable example',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Timetable example'),
        ),
        body: Timetable<MyEvent>(
          controller: _controller,
          eventProvider: (date) {
            final today = LocalDate.today();
            return [
              MyEvent(
                id: -1,
                title: 'SC',
                start: today.at(LocalTime(8, 15, 0)),
                end: today.at(LocalTime(8, 45, 0)),
                color: Colors.blue,
              ),
              MyEvent(
                id: -0.5,
                title: 'st/MD: flutter europe',
                start: today.at(LocalTime(8, 30, 0)),
                end: today.at(LocalTime(8, 30, 0)),
                color: Colors.orange,
              ),
              MyEvent(
                id: 0,
                title: 'TI: hw',
                start: today.at(LocalTime(8, 45, 0)),
                end: today.at(LocalTime(10, 45, 0)),
                color: Colors.green,
              ),
              MyEvent(
                id: 1,
                title: 'SWA',
                start: today.at(LocalTime(9, 15, 0)),
                end: today.at(LocalTime(10, 45, 0)),
                color: Colors.green,
              ),
              MyEvent(
                id: 2,
                title: 'BS I',
                start: today.at(LocalTime(11, 0, 0)),
                end: today.at(LocalTime(12, 30, 0)),
                color: Colors.green,
              ),
              MyEvent(
                id: 3,
                title: 'SC',
                start: today.at(LocalTime(11, 0, 0)),
                end: today.at(LocalTime(12, 30, 0)),
                color: Colors.blue,
              ),
              MyEvent(
                id: 4,
                title: 'St/CK: Cake pops doodle',
                start: today.at(LocalTime(11, 0, 0)),
                end: today.at(LocalTime(11, 0, 0)),
                color: Colors.orange,
              ),
              MyEvent(
                id: 5,
                title: 'Lunch',
                start: today.at(LocalTime(12, 30, 0)),
                end: today.at(LocalTime(13, 30, 0)),
                color: Colors.grey,
              ),
            ];
          },
          eventBuilder: (event) => DecoratedBox(
            decoration: BoxDecoration(
              color: event.color,
              border: Border.all(
                color: Colors.white,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRect(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                child: Text(event.title),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyEvent extends Event {
  MyEvent({
    @required Object id,
    @required this.title,
    @required this.color,
    @required LocalDateTime start,
    @required LocalDateTime end,
  })  : assert(title != null),
        super(id: id, start: start, end: end);

  final String title;
  final Color color;
}
