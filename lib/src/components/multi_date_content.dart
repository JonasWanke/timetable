import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/widgets.dart' hide Interval;

import '../controller.dart';
import '../date_page_view.dart';
import '../event.dart';
import '../event_provider.dart';
import '../old/stream_change_notifier.dart';
import '../old/visible_range.dart';
import '../time/controller.dart';
import '../time/zoom.dart';
import '../utils.dart';
import 'current_time_indicator.dart';
import 'date_dividers_painter.dart';
import 'date_events.dart';
import 'hour_dividers_painter.dart';

typedef MultiDateContentEventBuilder<E extends Event> = Widget Function(
  E event,
);
typedef MultiDateContentBackgroundTapCallback = void Function(
  DateTime dateTime,
);

class MultiDateContent<E extends Event> extends StatefulWidget {
  MultiDateContent({
    Key? key,
    required this.dateController,
    required this.timeController,
    required this.visibleRange,
    required EventProvider<E> eventProvider,
    required this.eventBuilder,
    this.onBackgroundTap,
    this.style,
  })  : eventProvider = eventProvider.debugChecked,
        super(key: key);

  final DateController dateController;
  final TimeController timeController;
  final VisibleRange visibleRange;
  final EventProvider<E> eventProvider;
  final MultiDateContentEventBuilder<E> eventBuilder;

  final MultiDateContentBackgroundTapCallback? onBackgroundTap;
  final MultiDateContentStyle? style;

  @override
  _MultiDateContentState<E> createState() => _MultiDateContentState<E>();
}

class _MultiDateContentState<E extends Event>
    extends State<MultiDateContent<E>> {
  final _timeListenable =
      StreamChangeNotifier(Stream<void>.periodic(Duration(seconds: 10)));

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
        visibleDayCount: widget.visibleRange.visibleDayCount,
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
            visibleDayCount: widget.visibleRange.visibleDayCount,
            style: widget.style?.nowIndicatorStyle ??
                MultiDateNowIndicatorStyle(
                  color: theme.highEmphasisOnBackground,
                ),
          ),
          child: DatePageView(
            controller: widget.dateController,
            visibleRange: widget.visibleRange,
            builder: (_, date) => _buildDate(date),
          ),
        ),
      ),
    );
  }

  Widget _buildDate(DateTime date) {
    assert(date.isValidTimetableDate);

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: widget.onBackgroundTap != null
              ? (details) {
                  final y = details.localPosition.dy;
                  widget.onBackgroundTap!(date + (y / height).days);
                }
              : null,
          child: DateEvents<E>(
            date: date,
            events: widget.eventProvider(date.fullDayInterval),
            eventBuilder: widget.eventBuilder,
            style: widget.style?.dateEventsStyle ?? DateEventsStyle(),
          ),
        );
      },
    );
  }
}

/// Defines visual properties for [MultiDateContent].
class MultiDateContentStyle {
  const MultiDateContentStyle({
    this.nowIndicatorStyle,
    this.dividerColor,
    this.minimumHourHeight,
    this.maximumHourHeight,
    this.minimumHourZoom,
    this.maximumHourZoom,
    this.dateEventsStyle,
  })  : assert(minimumHourHeight == null || minimumHourHeight > 0),
        assert(maximumHourHeight == null || maximumHourHeight > 0),
        assert(minimumHourHeight == null ||
            maximumHourHeight == null ||
            minimumHourHeight <= maximumHourHeight),
        assert(minimumHourZoom == null || minimumHourZoom > 0),
        assert(maximumHourZoom == null || maximumHourZoom > 0),
        assert(minimumHourZoom == null ||
            maximumHourZoom == null ||
            minimumHourZoom <= minimumHourZoom);

  final MultiDateNowIndicatorStyle? nowIndicatorStyle;

  /// [Color] for painting hour and day dividers in the part-day event area.
  final Color? dividerColor;

  /// Minimum height of a single hour when zooming in.
  ///
  /// Defaults to 16.
  final double? minimumHourHeight;

  /// Maximum height of a single hour when zooming in.
  ///
  /// [double.infinity] is supported!
  ///
  /// Defaults to 64.
  final double? maximumHourHeight;

  /// Minimum time zoom factor.
  ///
  /// `1` means that the hours content is exactly as high as the parent. Larger
  /// values mean zooming in, and smaller values mean zooming out.
  ///
  /// If both hour height limits ([minimumHourHeight] or [maximumHourHeight])
  /// and hour zoom limits (this property or [maximumHourZoom]) are set, zoom
  /// limits take precedence.
  ///
  /// Defaults to 0.
  final double? minimumHourZoom;

  /// Maximum time zoom factor.
  ///
  /// Defaults to [double.infinity].
  ///
  /// See also:
  /// - [minimumHourZoom] for an explanation of zoom values.
  final double? maximumHourZoom;

  final DateEventsStyle? dateEventsStyle;

  @override
  int get hashCode {
    return hashList([
      nowIndicatorStyle,
      dividerColor,
      minimumHourHeight,
      maximumHourHeight,
      minimumHourZoom,
      maximumHourZoom,
      dateEventsStyle,
    ]);
  }

  @override
  bool operator ==(Object other) {
    return other is MultiDateContentStyle &&
        other.nowIndicatorStyle == nowIndicatorStyle &&
        other.dividerColor == dividerColor &&
        other.minimumHourHeight == minimumHourHeight &&
        other.maximumHourHeight == maximumHourHeight &&
        other.minimumHourZoom == minimumHourZoom &&
        other.maximumHourZoom == maximumHourZoom &&
        other.dateEventsStyle == dateEventsStyle;
  }
}
