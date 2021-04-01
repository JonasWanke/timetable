import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/timetable.dart';

void main() {
//   group('InitialZoom', () {
//     group('zoom', () {
//       test('default', () {
//         final initial = InitialZoom.zoom(1);
//         expect(initial.getContentHeight(200), 200);
//         expect(initial.getOffset(200, 200), 0);
//       });
//       test('double', () {
//         final initial = InitialZoom.zoom(2);
//         expect(initial.getContentHeight(200), 400);
//         expect(initial.getOffset(200, 400), 100);
//       });
//     });

//     group('range', () {
//       test('default', () {
//         final initial = InitialZoom.range();
//         expect(initial.getContentHeight(200), 200);
//         expect(initial.getOffset(200, 200), 0);
//       });
//       test('top half', () {
//         final initial = InitialZoom.range(endFraction: 0.5);
//         expect(initial.getContentHeight(200), 400);
//         expect(initial.getOffset(200, 200), 0);
//       });
//       test('center half', () {
//         final initial = InitialZoom.range(
//           startFraction: 0.25,
//           endFraction: 0.75,
//         );
//         expect(initial.getContentHeight(200), 400);
//         expect(initial.getOffset(200, 400), 100);
//       });
//     });
//   });

  group('drag & zoom', () {
    final parentFinder = find.byType(TimeZoom).first;
    double getParentHeight(WidgetTester tester) =>
        tester.getSize(parentFinder).height;

    final childFinder = find.byType(Container).first;
    double getChildHeight(WidgetTester tester) =>
        tester.getSize(childFinder).height;
//     double getChildOffset(WidgetTester tester) {
//       return tester
//           .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
//           .controller
//           .offset;
//     }

    testWidgets('initial', (tester) async {
      final controller = TimeController();
      await tester.pumpWidget(TimeZoom(
        controller: controller,
        child: Container(),
      ));
      expect(controller.value, TimeRange.fullDay);
      expect(getChildHeight(tester), getParentHeight(tester));
      // expect(getChildOffset(tester), 0);
    });
//     testWidgets('drag w/o zoom', (tester) async {
//       await tester.pumpWidget(TimeZoom(
//         maxChildHeight: double.infinity,
//         child: Container(),
//       ));

//       await tester.drag(parentFinder, Offset(0, 100));
//       expect(getChildOffset(tester), 0);

//       await tester.drag(parentFinder, Offset(0, -100));
//       expect(getChildHeight(tester), getParentHeight(tester));
//       expect(getChildOffset(tester), 0);
//     });
//     testWidgets('drag w/ zoom', (tester) async {
//       await tester.pumpWidget(TimeZoom(
//         initialZoom: InitialZoom.zoom(2),
//         maxChildHeight: double.infinity,
//         child: Container(),
//       ));

//       final initialOffset = getParentHeight(tester) / 2;
//       expect(getChildHeight(tester), 2 * getParentHeight(tester));
//       expect(getChildOffset(tester), initialOffset);

//       await tester.drag(childFinder, Offset(0, 100));
//       expect(getChildHeight(tester), 2 * getParentHeight(tester));
//       expect(getChildOffset(tester), initialOffset - 100);

//       await tester.drag(parentFinder, Offset(0, -100));
//       expect(getChildHeight(tester), 2 * getParentHeight(tester));
//       expect(getChildOffset(tester), initialOffset);
//     });
  });
}
