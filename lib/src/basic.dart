import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';

import 'event.dart';

/// A basic implementation of [Event] to get you started.
///
/// See also:
/// - [BasicEventWidget], which can display instances of [BasicEvent].
class BasicEvent extends Event {
  const BasicEvent({
    @required Object id,
    @required this.title,
    @required this.color,
    @required LocalDateTime start,
    @required LocalDateTime end,
  })  : assert(title != null),
        super(id: id, start: start, end: end);

  /// A title for the user, used e.g. by [BasicEventWidget].
  final String title;

  /// [Color] used for displaying this event.
  ///
  /// This is used e.g. by [BasicEventWidget] as the background color.
  final Color color;

  @override
  bool operator ==(dynamic other) =>
      super == other && title == other.title && color == other.color;

  @override
  int get hashCode => hashList([super.hashCode, title, color]);
}

/// A simple [Widget] for displaying a [BasicEvent].
class BasicEventWidget extends StatelessWidget {
  const BasicEventWidget(this.event, {Key key})
      : assert(event != null),
        super(key: key);

  /// The [BasicEvent] to be displayed.
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
          style: context.textTheme.bodyText2.copyWith(
            fontSize: 12,
            color: event.color.highEmphasisOnColor,
          ),
          child: Text(event.title),
        ),
      ),
    );
  }
}
