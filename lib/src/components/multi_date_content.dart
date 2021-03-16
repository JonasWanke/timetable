import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/widgets.dart' hide Interval;

import '../date/controller.dart';
import '../date/date_page_view.dart';
import '../event.dart';
import '../event_provider.dart';
import '../time/controller.dart';
import '../time/overlay.dart';
import '../time/zoom.dart';
import '../utils.dart';
import '../utils/stream_change_notifier.dart';
import 'date_content.dart';
import 'date_dividers_painter.dart';
import 'date_events.dart';
import 'hour_dividers_painter.dart';
import 'now_indicator_painter.dart';

typedef MultiDateContentBackgroundTapCallback = void Function(
  DateTime dateTime,
);

class MultiDateContent<E extends Event> extends StatefulWidget {
  MultiDateContent({
    Key? key,
    required this.dateController,
    required this.timeController,
    required EventProvider<E> eventProvider,
    required this.eventBuilder,
    this.overlayProvider = emptyOverlayProvider,
    this.onBackgroundTap,
    this.style,
  })  : eventProvider = eventProvider.debugChecked,
        super(key: key);

  final DateController dateController;
  final TimeController timeController;

  final EventProvider<E> eventProvider;
  final EventBuilder<E> eventBuilder;

  final TimeOverlayProvider overlayProvider;

  final MultiDateContentBackgroundTapCallback? onBackgroundTap;
  final MultiDateContentStyle? style;

  @override
  _MultiDateContentState<E> createState() => _MultiDateContentState<E>();
}

class _MultiDateContentState<E extends Event>
    extends State<MultiDateContent<E>> {
  final _timeListenable =
      StreamChangeNotifier(Stream<void>.periodic(10.seconds));

  @override
  void dispose() {
    _timeListenable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return CustomPaint(
      painter: DateDividersPainter(
        controller: widget.dateController,
        dividerColor: widget.style?.dividerColor ?? theme.dividerColor,
      ),
      child: TimeZoom(
        controller: widget.timeController,
        child: CustomPaint(
          painter: HourDividersPainter(
            dividerColor: widget.style?.dividerColor ?? theme.dividerColor,
          ),
          foregroundPainter: NowIndicatorPainter(
            controller: widget.dateController,
            style: widget.style?.nowIndicatorStyle ??
                MultiDateNowIndicatorStyle(
                  color: theme.highEmphasisOnBackground,
                ),
            repaint: _timeListenable,
          ),
          child: DatePageView(
            controller: widget.dateController,
            builder: (context, date) => DateContent(
              date: date,
              events: widget.eventProvider(date.fullDayInterval),
              eventBuilder: widget.eventBuilder,
              overlays: widget.overlayProvider(context, date),
              onBackgroundTap: widget.onBackgroundTap,
              dateEventsStyle:
                  widget.style?.dateEventsStyle ?? DateEventsStyle(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Defines visual properties for [MultiDateContent].
class MultiDateContentStyle {
  const MultiDateContentStyle({
    this.nowIndicatorStyle,
    this.dividerColor,
    this.dateEventsStyle,
  });

  final MultiDateNowIndicatorStyle? nowIndicatorStyle;

  /// [Color] for painting hour and day dividers in the part-day event area.
  final Color? dividerColor;

  final DateEventsStyle? dateEventsStyle;

  @override
  int get hashCode =>
      hashList([nowIndicatorStyle, dividerColor, dateEventsStyle]);
  @override
  bool operator ==(Object other) {
    return other is MultiDateContentStyle &&
        other.nowIndicatorStyle == nowIndicatorStyle &&
        other.dividerColor == dividerColor &&
        other.dateEventsStyle == dateEventsStyle;
  }
}
