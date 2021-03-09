// import 'package:flutter/widgets.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:timetable/src/utils/vertical_zoom.dart';

// void main() {
//   group('InitialZoom', () {
//     group('zoom', () {
//       test('default', () {
//         final initial = InitialZoom.zoom(1);
//         expect(initial.getContentHeight(200), equals(200));
//         expect(initial.getOffset(200, 200), equals(0));
//       });
//       test('double', () {
//         final initial = InitialZoom.zoom(2);
//         expect(initial.getContentHeight(200), equals(400));
//         expect(initial.getOffset(200, 400), equals(100));
//       });
//     });

//     group('range', () {
//       test('default', () {
//         final initial = InitialZoom.range();
//         expect(initial.getContentHeight(200), equals(200));
//         expect(initial.getOffset(200, 200), equals(0));
//       });
//       test('top half', () {
//         final initial = InitialZoom.range(endFraction: 0.5);
//         expect(initial.getContentHeight(200), equals(400));
//         expect(initial.getOffset(200, 200), equals(0));
//       });
//       test('center half', () {
//         final initial = InitialZoom.range(
//           startFraction: 0.25,
//           endFraction: 0.75,
//         );
//         expect(initial.getContentHeight(200), equals(400));
//         expect(initial.getOffset(200, 400), equals(100));
//       });
//     });
//   });

//   group('drag & zoom', () {
//     final parentFinder = find.byType(VerticalZoom).first;
//     double getParentHeight(WidgetTester tester) =>
//         tester.getSize(parentFinder).height;

//     final childFinder = find.byType(Container).first;
//     double getChildHeight(WidgetTester tester) =>
//         tester.getSize(childFinder).height;
//     double getChildOffset(WidgetTester tester) {
//       return tester
//           .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
//           .controller
//           .offset;
//     }

//     testWidgets('initial', (tester) async {
//       await tester.pumpWidget(VerticalZoom(
//         maxChildHeight: double.infinity,
//         child: Container(),
//       ));
//       expect(getChildHeight(tester), equals(getParentHeight(tester)));
//       expect(getChildOffset(tester), equals(0));
//     });
//     testWidgets('drag w/o zoom', (tester) async {
//       await tester.pumpWidget(VerticalZoom(
//         maxChildHeight: double.infinity,
//         child: Container(),
//       ));

//       await tester.drag(parentFinder, Offset(0, 100));
//       expect(getChildOffset(tester), equals(0));

//       await tester.drag(parentFinder, Offset(0, -100));
//       expect(getChildHeight(tester), equals(getParentHeight(tester)));
//       expect(getChildOffset(tester), equals(0));
//     });
//     testWidgets('drag w/ zoom', (tester) async {
//       await tester.pumpWidget(VerticalZoom(
//         initialZoom: InitialZoom.zoom(2),
//         maxChildHeight: double.infinity,
//         child: Container(),
//       ));

//       final initialOffset = getParentHeight(tester) / 2;
//       expect(getChildHeight(tester), equals(2 * getParentHeight(tester)));
//       expect(getChildOffset(tester), equals(initialOffset));

//       await tester.drag(childFinder, Offset(0, 100));
//       expect(getChildHeight(tester), equals(2 * getParentHeight(tester)));
//       expect(getChildOffset(tester), equals(initialOffset - 100));

//       await tester.drag(parentFinder, Offset(0, -100));
//       expect(getChildHeight(tester), equals(2 * getParentHeight(tester)));
//       expect(getChildOffset(tester), equals(initialOffset));
//     });
//   });
// }
