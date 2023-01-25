import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'all_day.dart';
import 'event.dart';

/// A basic implementation of [Event] to get you started.
///
/// See also:
///
/// * [BasicEventWidget], which can display instances of [BasicEvent].
class BasicEvent extends Event {
  const BasicEvent({
    required this.id,
    required this.title,
    required this.backgroundColor,
    required super.start,
    required super.end,
  });

  /// An ID for this event.
  ///
  /// This is not used by Timetable itself, but can be handy, e.g., when
  /// implementing drag & drop.
  // ignore: no-object-declaration
  final Object id;

  /// A title displayed to the user.
  ///
  /// This is currently used by [BasicEventWidget] and [BasicAllDayEventWidget].
  final String title;

  /// The background color used for displaying this event.
  ///
  /// This is currently used by [BasicEventWidget] and [BasicAllDayEventWidget].
  final Color backgroundColor;

  BasicEvent copyWith({
    Object? id,
    String? title,
    Color? backgroundColor,
    DateTime? start,
    DateTime? end,
  }) {
    return BasicEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  @override
  int get hashCode => Object.hash(super.hashCode, title, backgroundColor);
  @override
  bool operator ==(dynamic other) =>
      other is BasicEvent &&
      super == other &&
      title == other.title &&
      backgroundColor == other.backgroundColor;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('id', id));
    properties.add(StringProperty('title', title));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
  }
}

/// A simple [Widget] for displaying a [BasicEvent].
class BasicEventWidget extends StatelessWidget {
  const BasicEventWidget(
    this.event, {
    super.key,
    this.onTap,
    this.margin = const EdgeInsets.only(right: 1),
  });

  /// The event to be displayed.
  final BasicEvent event;

  /// An optional callback that will be invoked when the user taps this widget.
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
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        clipBehavior: Clip.hardEdge,
        color: event.backgroundColor,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 4, top: 2, right: 4),
            child: DefaultTextStyle(
              style: context.textTheme.bodyMedium!.copyWith(
                fontSize: 12,
                color: event.backgroundColor.highEmphasisOnColor,
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
    super.key,
    required this.info,
    this.onTap,
    this.style,
  });

  /// The event to be displayed.
  final BasicEvent event;
  final AllDayEventLayoutInfo info;

  /// An optional callback that will be invoked when the user taps this widget.
  final VoidCallback? onTap;
  final BasicAllDayEventWidgetStyle? style;

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? BasicAllDayEventWidgetStyle(context, event);

    return Padding(
      padding: style.margin,
      child: CustomPaint(
        painter: AllDayEventBackgroundPainter(
          info: info,
          color: event.backgroundColor,
          radii: style.radii,
        ),
        child: Material(
          shape: AllDayEventBorder(
            info: info,
            side: BorderSide.none,
            radii: style.radii,
          ),
          clipBehavior: Clip.antiAlias,
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: style.padding,
              child: Text(
                event.title,
                style: style.textStyle,
                maxLines: 1,
                overflow: TextOverflow.visible,
                softWrap: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Defines visual properties for [BasicAllDayEventWidget].
@immutable
class BasicAllDayEventWidgetStyle {
  factory BasicAllDayEventWidgetStyle(
    BuildContext context,
    BasicEvent event, {
    EdgeInsetsGeometry? margin,
    AllDayEventBorderRadii? radii,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
  }) {
    return BasicAllDayEventWidgetStyle.raw(
      margin: margin ?? const EdgeInsets.all(2),
      radii: radii ??
          const AllDayEventBorderRadii(
            cornerRadius: BorderRadius.all(Radius.circular(4)),
            leftTipRadius: 4,
            rightTipRadius: 4,
          ),
      padding: padding ?? const EdgeInsets.only(left: 4, top: 2, bottom: 2),
      textStyle: textStyle ??
          context.theme.textTheme.bodyMedium!.copyWith(
            fontSize: 14,
            color: event.backgroundColor.highEmphasisOnColor,
          ),
    );
  }

  const BasicAllDayEventWidgetStyle.raw({
    required this.margin,
    required this.radii,
    required this.padding,
    required this.textStyle,
  });

  final EdgeInsetsGeometry margin;
  final AllDayEventBorderRadii radii;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;

  BasicAllDayEventWidgetStyle copyWith({
    EdgeInsetsGeometry? margin,
    AllDayEventBorderRadii? radii,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
  }) {
    return BasicAllDayEventWidgetStyle.raw(
      margin: margin ?? this.margin,
      radii: radii ?? this.radii,
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  @override
  int get hashCode => Object.hash(margin, radii, padding, textStyle);
  @override
  bool operator ==(Object other) {
    return other is BasicAllDayEventWidgetStyle &&
        margin == other.margin &&
        radii == other.radii &&
        padding == other.padding &&
        textStyle == other.textStyle;
  }
}
