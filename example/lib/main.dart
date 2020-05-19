import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/timetable.dart';

// ignore: unused_import
import 'positioning_demo.dart';
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
  TimetableController<BasicEvent> _controller;

  @override
  void initState() {
    super.initState();
    _controller = TimetableController(
      // A basic EventProvider containing a single event.
      eventProvider: EventProvider.list([
        BasicEvent(
          id: 0,
          title: 'My Event',
          color: Colors.blue,
          start: LocalDate.today().at(LocalTime(13, 0, 0)),
          end: LocalDate.today().at(LocalTime(15, 0, 0)),
        ),
      ]),

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

      // Other (optional) parameters:
      initialTimeRange: InitialTimeRange.range(
        startTime: LocalTime(8, 0, 0),
        endTime: LocalTime(20, 0, 0),
      ),
      initialDate: LocalDate.today(),
      visibleRange: VisibleRange.days(3),
      firstDayOfWeek: DayOfWeek.monday,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timetable example',
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
      ),
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
          eventBuilder: (event) => BasicEventWidget(event),
          allDayEventBuilder: (context, event, info) =>
              BasicAllDayEventWidget(event, info: info),
        ),
      ),
    );
  }
}
