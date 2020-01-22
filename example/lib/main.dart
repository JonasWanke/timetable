import 'package:flutter/material.dart';

import 'utils.dart';

void main() {
  setTargetPlatformForDesktop();
  runApp(TimetableExample());
}

class TimetableExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timetable example',
      home: Text('Hello, World!'),
    );
  }
}
