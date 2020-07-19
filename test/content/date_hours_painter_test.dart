import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/src/content/date_hours_painter.dart';

void main() {
  testWidgets('Format hour', (tester) async {
    final painter = DateHoursPainter(textDirection: TextDirection.ltr, textStyle: TextStyle());
    await tester.pumpWidget(CustomPaint(painter: painter));
    // find.text('01:00') does not work with text painters :(
  });
  testWidgets('Custom hour format', (tester) async {
    final painter = DateHoursPainter(
      textDirection: TextDirection.ltr,
      textStyle: TextStyle(),
      formatHour: (x) => '${x.hourOfDay}',
    );
    await tester.pumpWidget(CustomPaint(painter: painter));
  });
}
