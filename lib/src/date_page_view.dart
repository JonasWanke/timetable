import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';

import 'controller.dart';
import 'event.dart';
import 'scroll_physics.dart';

typedef DateWidgetBuilder = Widget Function(
    BuildContext context, LocalDate date);

class DatePageView<E extends Event> extends StatefulWidget {
  const DatePageView({
    Key key,
    @required this.controller,
    @required this.builder,
  })  : assert(controller != null),
        assert(builder != null),
        super(key: key);

  final TimetableController<E> controller;
  final DateWidgetBuilder builder;

  @override
  _DatePageViewState createState() => _DatePageViewState();
}

class _DatePageViewState extends State<DatePageView> {
  final Key _centerKey = UniqueKey();
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
    final visibleDays = widget.controller.visibleRange.visibleDays;
    final centerDate = widget.controller.initialDate;

    return Scrollable(
      axisDirection: AxisDirection.right,
      physics: TimetableScrollPhysics(widget.controller),
      controller: _controller,
      viewportBuilder: (context, position) {
        return Viewport(
          axisDirection: AxisDirection.right,
          offset: position,
          anchor: 0,
          center: _centerKey,
          slivers: <Widget>[
            SliverFillViewport(
              viewportFraction: 1 / visibleDays,
              padEnds: false,
              delegate: SliverChildBuilderDelegate(
                (context, index) => widget.builder(
                  context,
                  centerDate.subtractDays(index + 1),
                ),
              ),
            ),
            SliverFillViewport(
              key: _centerKey,
              padEnds: false,
              viewportFraction: 1 / visibleDays,
              delegate: SliverChildBuilderDelegate(
                (context, index) => widget.builder(
                  context,
                  centerDate.addDays(index),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
