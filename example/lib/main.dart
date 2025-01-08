// ignore_for_file: avoid_print

import 'dart:async';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:chrono/chrono.dart';
import 'package:deranged/deranged.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timetable/timetable.dart';

// ignore: unused_import
import 'positioning_demo.dart';
import 'utils.dart';

Future<void> main() async {
  initDebugOverlay();
  runApp(const ExampleApp(child: TimetableExample()));
}

class TimetableExample extends StatefulWidget {
  const TimetableExample({super.key});

  @override
  State<TimetableExample> createState() => _TimetableExampleState();
}

class _TimetableExampleState extends State<TimetableExample>
    with TickerProviderStateMixin {
  var _visibleDateRange = PredefinedVisibleDateRange.week;
  void _updateVisibleDateRange(PredefinedVisibleDateRange newValue) {
    setState(() {
      _visibleDateRange = newValue;
      _dateController.visibleRange = newValue.visibleDateRange;
    });
  }

  bool get _isRecurringLayout =>
      _visibleDateRange == PredefinedVisibleDateRange.fixed;

  late final _dateController = DateController(
    // All parameters are optional.
    // initialDate: DateTimeTimetable.today(),
    visibleRange: _visibleDateRange.visibleDateRange,
  );

  final _timeController = TimeController(
    // All parameters are optional.
    // minDuration: 1.hours,
    // maxDuration: 10.hours,
    // initialRange: TimeRange(8.hours, 20.hours),
    maxRange: TimeRange(Time.midnight, null),
  );

  final _draggedEvents = <BasicEvent>[];

  @override
  void dispose() {
    _timeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TimetableConfig<BasicEvent>(
      // Required:
      dateController: _dateController,
      timeController: _timeController,
      eventBuilder: (context, event) => _buildPartDayEvent(event),
      // ignore: sort_child_properties_last
      child: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _isRecurringLayout
                ? RecurringMultiDateTimetable<BasicEvent>()
                : MultiDateTimetable<BasicEvent>(),
          ),
        ],
      ),
      // Optional:
      eventProvider: eventProviderFromFixedList(positioningDemoEvents),
      allDayEventBuilder: (context, event, info) => BasicAllDayEventWidget(
        event,
        info: info,
        onTap: () => _showSnackBar('All-day event $event tapped'),
      ),
      timeOverlayProvider: mergeTimeOverlayProviders([
        positioningDemoOverlayProvider,
        (context, date) => _draggedEvents
            .map(
              (it) =>
                  it.toTimeOverlay(date: date, widget: BasicEventWidget(it)),
            )
            .nonNulls
            .toList(),
      ]),
      callbacks: TimetableCallbacks(
        onWeekTap: (week) {
          _showSnackBar('Tapped on week $week.');
          _updateVisibleDateRange(PredefinedVisibleDateRange.week);
          unawaited(_dateController.animateTo(week.dates.start, vsync: this));
        },
        onDateTap: (date) {
          _showSnackBar('Tapped on date $date.');
          unawaited(_dateController.animateTo(date, vsync: this));
        },
        onDateBackgroundTap: (date) =>
            _showSnackBar('Tapped on date background at $date.'),
        onDateTimeBackgroundTap: (dateTime) =>
            _showSnackBar('Tapped on date-time background at $dateTime.'),
        onMultiDateHeaderOverflowTap: (date) =>
            _showSnackBar('Tapped on the overflow of $date.'),
      ),
      theme: TimetableThemeData(
        context,
        // startOfWeek: DateTime.monday,
        // dateDividersStyle: DateDividersStyle(
        //   context,
        //   color: Colors.blue.withOpacity(.3),
        //   width: 2,
        // ),
        // nowIndicatorStyle: NowIndicatorStyle(
        //   context,
        //   lineColor: Colors.green,
        //   shape: TriangleNowIndicatorShape(color: Colors.green),
        // ),
        // timeIndicatorStyleProvider: (time) => TimeIndicatorStyle(
        //   context,
        //   time,
        //   alwaysUse24HourFormat: false,
        // ),
      ),
    );
  }

  Widget _buildPartDayEvent(BasicEvent event) {
    const roundedTo = Minutes(15);

    return PartDayDraggableEvent(
      onDragStart: () => setState(() => _draggedEvents.add(event)),
      onDragUpdate: (dateTime) => setState(() {
        dateTime = dateTime.roundTimeToMultipleOf(roundedTo);
        final index = _draggedEvents.indexWhere((it) => it.id == event.id);
        final oldEvent = _draggedEvents[index];
        _draggedEvents[index] = oldEvent.copyWith(
          range: dateTime.rangeUntil(dateTime + oldEvent.range.timeDuration),
        );
      }),
      onDragEnd: (dateTime) {
        dateTime =
            (dateTime ?? event.range.start).roundTimeToMultipleOf(roundedTo);
        setState(() => _draggedEvents.removeWhere((it) => it.id == event.id));
        _showSnackBar('Dragged event to $dateTime.');
      },
      onDragCanceled: (isMoved) => _showSnackBar('Your finger moved: $isMoved'),
      child: BasicEventWidget(
        event,
        onTap: () => _showSnackBar('Part-day event $event tapped'),
      ),
    );
  }

  Widget _buildAppBar() {
    final colorScheme = context.theme.colorScheme;
    Widget child = AppBar(
      elevation: 0,
      titleTextStyle: TextStyle(color: colorScheme.onSurface),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: Colors.transparent,
      title: _isRecurringLayout
          ? null
          : MonthIndicator.forController(_dateController),
      actions: [
        IconButton(
          icon: const Icon(Icons.today),
          onPressed: () {
            unawaited(_dateController.animateToToday(vsync: this));
            unawaited(_timeController.animateToShowFullDay(vsync: this));
          },
          tooltip: 'Go to today',
        ),
        const SizedBox(width: 8),
        DropdownButton(
          onChanged: (visibleRange) => _updateVisibleDateRange(visibleRange!),
          value: _visibleDateRange,
          items: [
            for (final visibleRange in PredefinedVisibleDateRange.values)
              DropdownMenuItem(
                value: visibleRange,
                child: Text(visibleRange.title),
              ),
          ],
        ),
        const SizedBox(width: 16),
      ],
    );

    if (!_isRecurringLayout) {
      child = Column(
        children: [
          child,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Builder(
              builder: (context) {
                return DefaultTimetableCallbacks(
                  callbacks: DefaultTimetableCallbacks.of(context)!.copyWith(
                    onDateTap: (date) {
                      _showSnackBar('Tapped on date $date.');
                      _updateVisibleDateRange(PredefinedVisibleDateRange.day);
                      unawaited(_dateController.animateTo(date, vsync: this));
                    },
                  ),
                  child: CompactMonthTimetable(),
                );
              },
            ),
          ),
        ],
      );
    }

    return Material(color: colorScheme.surface, elevation: 4, child: child);
  }

  void _showSnackBar(String content) =>
      context.scaffoldMessenger.showSnackBar(SnackBar(content: Text(content)));
}

enum PredefinedVisibleDateRange { day, threeDays, workWeek, week, fixed }

extension on PredefinedVisibleDateRange {
  VisibleDateRange get visibleDateRange {
    return switch (this) {
      PredefinedVisibleDateRange.day => VisibleDateRange.days(1),
      PredefinedVisibleDateRange.threeDays => VisibleDateRange.days(3),
      PredefinedVisibleDateRange.workWeek => VisibleDateRange.weekAligned(5),
      PredefinedVisibleDateRange.week => VisibleDateRange.week(),
      PredefinedVisibleDateRange.fixed =>
        VisibleDateRange.fixed(Date.todayInLocalZone(), Days.perWeek),
    };
  }

  String get title {
    return switch (this) {
      PredefinedVisibleDateRange.day => 'Day',
      PredefinedVisibleDateRange.threeDays => '3 Days',
      PredefinedVisibleDateRange.workWeek => 'Work Week',
      PredefinedVisibleDateRange.week => 'Week',
      PredefinedVisibleDateRange.fixed => '7 Days (fixed)',
    };
  }
}
