import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';

import 'controller.dart';

typedef DayWidgetBuilder = Widget Function(BuildContext context, LocalDate day);

class DayPageView extends StatelessWidget {
  const DayPageView({
    Key key,
    @required this.controller,
    @required this.dayBuilder,
  })  : assert(controller != null),
        assert(dayBuilder != null),
        super(key: key);

  final TimetableController controller;
  final DayWidgetBuilder dayBuilder;

  @override
  Widget build(BuildContext context) {
    return Scrollable(
      axisDirection: AxisDirection.right,
      physics: TimetableScrollPhysics(),
      controller: controller,
      viewportBuilder: (context, position) {
        return Viewport(
          // TODO(JonasWanke): anchor
          axisDirection: AxisDirection.right,
          offset: position,
          slivers: <Widget>[
            SliverFillViewport(
              viewportFraction: 1 / controller.visibleDays,
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    dayBuilder(context, LocalDate.fromEpochDay(index)),
              ),
            ),
          ],
        );
      },
    );
  }
}
