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

  @override
  bool operator ==(dynamic other) =>
      super == other && title == other.title && color == other.color;

  @override
  int get hashCode => hashList([super.hashCode, title, color]);
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
        side: BorderSide(
          color: context.theme.scaffoldBackgroundColor,
          width: 0.75,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      color: event.color,
      child: Padding(
        padding: EdgeInsets.fromLTRB(4, 2, 4, 0),
        child: DefaultTextStyle(
          style: context.textTheme.body1.copyWith(
            fontSize: 12,
            color: event.color.highEmphasisOnColor,
          ),
          child: Text(event.title),
        ),
      ),
    );
  }
}
