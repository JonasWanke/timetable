import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

import 'utils/vertical_zoom.dart';

@immutable
abstract class InitialTimeRange {
  const InitialTimeRange();

  const factory InitialTimeRange.zoom(double zoom) = _FactorInitialTimeRange;
  factory InitialTimeRange.range({
    LocalTime startTime,
    LocalTime endTime,
  }) = _RangeInitialTimeRange;

  InitialZoom asInitialZoom();
}

class _FactorInitialTimeRange extends InitialTimeRange {
  const _FactorInitialTimeRange(this.zoom)
      : assert(zoom != null),
        assert(VerticalZoom.zoomMin <= zoom && zoom <= VerticalZoom.zoomMax);

  final double zoom;

  @override
  InitialZoom asInitialZoom() => InitialZoom.zoom(zoom);
}

class _RangeInitialTimeRange extends InitialTimeRange {
  _RangeInitialTimeRange({
    LocalTime startTime,
    LocalTime endTime,
  })  : startTime = startTime ?? LocalTime.minValue,
        endTime = endTime ?? LocalTime.maxValue,
        assert(startTime < endTime);

  final LocalTime startTime;
  final LocalTime endTime;

  static double _timeToFraction(LocalTime time) =>
      time.timeSinceMidnight.inNanoseconds / TimeConstants.nanosecondsPerDay;

  @override
  InitialZoom asInitialZoom() => InitialZoom.range(
        startFraction: _timeToFraction(startTime),
        endFraction: _timeToFraction(endTime),
      );
}
