import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';

import 'event.dart';

class BasicEvent extends Event {
  BasicEvent({
    @required Object id,
    @required this.title,
    @required this.color,
    @required LocalDateTime start,
    @required LocalDateTime end,
  })  : assert(title != null),
        super(id: id, start: start, end: end);

  final String title;
  final Color color;
}

class BasicEventWidget extends StatelessWidget {
  const BasicEventWidget(this.event, {Key key})
      : assert(event != null),
        super(key: key);

  final BasicEvent event;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: context.theme.scaffoldBackgroundColor),
        borderRadius: BorderRadius.circular(4),
      ),
      color: event.color,
      child: Padding(
        padding: EdgeInsets.fromLTRB(4, 2, 4, 0),
        child: Text(event.title),
      ),
    );
  }
}
