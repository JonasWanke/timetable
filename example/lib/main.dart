import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/timetable.dart';

import 'utils.dart';

void main() async {
  setTargetPlatformForDesktop();

  WidgetsFlutterBinding.ensureInitialized();
  await TimeMachine.initialize({'rootBundle': rootBundle});
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
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Timetable example'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.today),
              onPressed: () => _controller.animateToToday(),
              tooltip: 'Jump to today',
            ),
          ],
        ),
        body: Timetable<BasicEvent>(
          controller: _controller,
          eventProvider: (date) {
            return [
              BasicEvent(
                id: -1,
                title: 'SC',
                start: date.at(LocalTime(8, 15, 0)),
                end: date.at(LocalTime(8, 45, 0)),
                color: Colors.blue,
              ),
              BasicEvent(
                id: -0.5,
                title: 'st/MD: flutter europe',
                start: date.at(LocalTime(8, 30, 0)),
                end: date.at(LocalTime(8, 30, 0)),
                color: Colors.orange,
              ),
              BasicEvent(
                id: 0,
                title: 'TI: hw',
                start: date.at(LocalTime(8, 45, 0)),
                end: date.at(LocalTime(10, 45, 0)),
                color: Colors.green,
              ),
              BasicEvent(
                id: 1,
                title: 'SWA',
                start: date.at(LocalTime(9, 15, 0)),
                end: date.at(LocalTime(10, 45, 0)),
                color: Colors.green,
              ),
              BasicEvent(
                id: 2,
                title: 'BS I',
                start: date.at(LocalTime(11, 0, 0)),
                end: date.at(LocalTime(12, 30, 0)),
                color: Colors.green,
              ),
              BasicEvent(
                id: 3,
                title: 'SC',
                start: date.at(LocalTime(11, 0, 0)),
                end: date.at(LocalTime(12, 30, 0)),
                color: Colors.blue,
              ),
              BasicEvent(
                id: 4,
                title: 'St/CK: Cake pops doodle',
                start: date.at(LocalTime(11, 0, 0)),
                end: date.at(LocalTime(11, 0, 0)),
                color: Colors.orange,
              ),
              BasicEvent(
                id: 5,
                title: 'Lunch',
                start: date.at(LocalTime(12, 30, 0)),
                end: date.at(LocalTime(13, 30, 0)),
                color: Colors.grey,
              ),
            ];
          },
          eventBuilder: (event) => BasicEventWidget(event),
        ),
      ),
    );
  }
}
