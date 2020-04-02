import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/timetable.dart';

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
      eventProvider: positioningDemoEventProvider,
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
        ),
      ),
    );
  }
}
