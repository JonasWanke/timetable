import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';

class TimetableController extends ScrollController {
  TimetableController({
    LocalDate initialDate,
    this.visibleDays = 7,
  })  : initialDate = initialDate ?? LocalDate.today(),
        assert(visibleDays != null),
        assert(visibleDays > 0);

  final LocalDate initialDate;
  final int visibleDays;

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition oldPosition) {
    return _TimetablePosition(
      initialDate: initialDate,
      visibleDays: visibleDays,
      physics: physics,
      context: context,
      oldPosition: oldPosition,
    );
  }

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    (position as _TimetablePosition).visibleDays = visibleDays;
  }
}

// Inspired by Flutter's [_PagePosition].
class _TimetablePosition extends ScrollPositionWithSingleContext {
  _TimetablePosition({
    @required this.initialDate,
    @required int visibleDays,
    ScrollPhysics physics,
    ScrollContext context,
    bool keepPage = true,
    ScrollPosition oldPosition,
  })  : assert(initialDate != null),
        _dateToUseOnStartup = _DatePosition(initialDate),
        assert(visibleDays != null),
        assert(visibleDays > 0),
        _visibleDays = visibleDays,
        assert(keepPage != null),
        super(
          physics: physics,
          context: context,
          initialPixels: null,
          keepScrollOffset: keepPage,
          oldPosition: oldPosition,
        );

  final LocalDate initialDate;
  _DatePosition _dateToUseOnStartup;

  int _visibleDays;
  int get visibleDays => _visibleDays;
  set visibleDays(int value) {
    if (visibleDays == value) {
      return;
    }
    final oldPosition = datePosition;
    _visibleDays = value;
    if (oldPosition != null) {
      forcePixels(getPixelsFromDate(oldPosition));
    }
  }

  _DatePosition get datePosition => getDateFromPixels(pixels);

  @override
  void saveScrollOffset() {
    context.storageContext.pageStorage
        ?.writeState(context.storageContext, getDateFromPixels(pixels));
  }

  @override
  void restoreScrollOffset() {
    if (pixels != null) {
      return;
    }

    final _DatePosition value =
        context.storageContext.pageStorage?.readState(context.storageContext);
    if (value != null) {
      _dateToUseOnStartup = value;
    }
  }

  @override
  bool applyViewportDimension(double viewportDimension) {
    final oldViewportDimension = viewportDimension;
    final result = super.applyViewportDimension(viewportDimension);
    final date = (pixels == null || oldViewportDimension == 0)
        ? _dateToUseOnStartup
        : getDateFromPixels(pixels, oldViewportDimension);
    final newPixels = getPixelsFromDate(date);

    if (newPixels != pixels) {
      correctPixels(newPixels);
      return false;
    }
    return result;
  }

  _DatePosition getDateFromPixels(double pixels, [double viewportDimension]) {
    final position =
        pixels * visibleDays / (viewportDimension ?? this.viewportDimension);
    final rounded = position.round();
    final epochDay = rounded <= position ? rounded : rounded - 1;

    return _DatePosition.forEpochDay(epochDay, position - epochDay);
  }

  double getPixelsFromPage(double page) =>
      page * viewportDimension / visibleDays;
  double getPixelsFromDate(_DatePosition datePosition) =>
      getPixelsFromPage(datePosition.page);
}

// Inspired by [PageScrollPhysics]
class TimetableScrollPhysics extends ScrollPhysics {
  const TimetableScrollPhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  TimetableScrollPhysics applyTo(ScrollPhysics ancestor) {
    return TimetableScrollPhysics(parent: buildParent(ancestor));
  }

  double _getTargetPixels(
      ScrollPosition position, Tolerance tolerance, double velocity) {
    final timetablePosition = position as _TimetablePosition;
    double page = timetablePosition.datePosition.page;
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return timetablePosition.getPixelsFromPage(page.roundToDouble());
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

class _DatePosition {
  const _DatePosition(this.date, [this.offset = 0])
      : assert(date != null),
        assert(offset != null),
        assert(0 <= offset && offset < 1);
  _DatePosition.forEpochDay(int epochDay, [double offset = 0])
      : this(LocalDate.fromEpochDay(epochDay), offset);

  static final _datePattern = LocalDatePattern.iso;

  final LocalDate date;
  final double offset;

  double get page => date.epochDay + offset;

  @override
  String toString() => '${_datePattern.format(date)} $offset';
}
