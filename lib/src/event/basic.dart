import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'all_day.dart';
import 'event.dart';

/// A basic implementation of [Event] to get you started.
///
/// See also:
/// * [BasicEventWidget], which can display instances of [BasicEvent].
class BasicEvent extends Event {
  const BasicEvent({
    required this.id,
    required this.title,
    required this.color,
    required DateTime start,
    required DateTime end,
  }) : super(start: start, end: end);

  /// An ID for this event.
  ///
  /// This is not used by timetable itself, but can be handy, e.g., when
  /// implementing drag & drop.
  final String id;

  /// A title for the user, used e.g. by [BasicEventWidget].
  final String title;

  /// [Color] used for displaying this event.
  ///
  /// This is used e.g. by [BasicEventWidget] as the background color.
  final Color color;

  BasicEvent copyWith({
    String? id,
    String? title,
    Color? color,
    bool? showOnTop,
    DateTime? start,
    DateTime? end,
  }) {
    return BasicEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      color: color ?? this.color,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  @override
  int get hashCode => hashValues(super.hashCode, title, color);
  @override
  bool operator ==(dynamic other) =>
      super == other && title == other.title && color == other.color;
}

/// A simple [Widget] for displaying a [BasicEvent].
class BasicEventWidget extends StatelessWidget {
  const BasicEventWidget(
    this.event, {
    Key? key,
    this.onTap,
    this.margin = const EdgeInsets.only(right: 1),
  }) : super(key: key);

  /// The [BasicEvent] to be displayed.
  final BasicEvent event;

  /// An optional [VoidCallback] that will be invoked when the user taps this
  /// widget.
  final VoidCallback? onTap;

  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Material(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: context.theme.scaffoldBackgroundColor,
            width: 0.75,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.hardEdge,
        color: event.color,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.fromLTRB(4, 2, 4, 0),
            child: DefaultTextStyle(
              style: context.textTheme.bodyText2!.copyWith(
                fontSize: 12,
                color: event.color.highEmphasisOnColor,
              ),
              child: Text(event.title),
            ),
          ),
        ),
      ),
    );
  }
}

/// A simple [Widget] for displaying a [BasicEvent] as an all-day event.
class BasicAllDayEventWidget extends StatelessWidget {
  const BasicAllDayEventWidget(
    this.event, {
    Key? key,
    required this.info,
    this.borderRadius = 4,
    this.onTap,
  }) : super(key: key);

  /// The [BasicEvent] to be displayed.
  final BasicEvent event;
  final AllDayEventLayoutInfo info;
  final double borderRadius;

  /// An optional [VoidCallback] that will be invoked when the user taps this
  /// widget.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2),
      child: CustomPaint(
        painter: AllDayEventBackgroundPainter(
          info: info,
          color: event.color,
          borderRadius: borderRadius,
        ),
        child: Material(
          shape: AllDayEventBorder(
            info: info,
            side: BorderSide.none,
            borderRadius: borderRadius,
          ),
          clipBehavior: Clip.antiAlias,
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4, 2, 0, 2),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: DefaultTextStyle(
          style: context.textTheme.bodyText2!.copyWith(
            fontSize: 14,
            color: event.color.highEmphasisOnColor,
          ),
          child: Text(event.title, maxLines: 1),
        ),
      ),
    );
  }
}
