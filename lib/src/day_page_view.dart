import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';

import 'controller.dart';

typedef DayWidgetBuilder = Widget Function(BuildContext context, LocalDate day);

class DayPageView extends StatefulWidget {
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
  _DayPageViewState createState() => _DayPageViewState();
}

class _DayPageViewState extends State<DayPageView> {
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller.scrollControllers.addAndGet();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollable(
      axisDirection: AxisDirection.right,
      physics: TimetableScrollPhysics(widget.controller),
      controller: _controller,
      viewportBuilder: (context, position) {
        return Viewport(
          // TODO(JonasWanke): anchor
          axisDirection: AxisDirection.right,
          offset: position,
          slivers: <Widget>[
            SliverFillViewport(
              viewportFraction: 1 / widget.controller.visibleDays,
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    widget.dayBuilder(context, LocalDate.fromEpochDay(index)),
              ),
            ),
          ],
        );
      },
    );
  }
}
