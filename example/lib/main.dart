import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timetable/timetable.dart';

// ignore: unused_import
import 'positioning_demo.dart';
import 'utils.dart';

void main() async {
  initDebugOverlay();
  runApp(ExampleApp(child: TimetableExample()));
}

class TimetableExample extends StatefulWidget {
  @override
  _TimetableExampleState createState() => _TimetableExampleState();
}

class _TimetableExampleState extends State<TimetableExample>
    with TickerProviderStateMixin {
  var _visibleDateRange = PredefinedVisibleDateRange.week;

  late final _dateController = DateController(
    // All parameters are optional.
    // initialDate: DateTimeTimetable.today(),
    visibleRange: _visibleDateRange.visibleDateRange,
    firstDayOfWeek: DateTime.monday,
  );

  final _timeController = TimeController(
    // All parameters are optional.
    // initialRange: TimeRange(8.hours, 20.hours),
    maxRange: TimeRange(0.hours, 24.hours),
  );

  final List<BasicEvent> _draggedEvents = [];
  late final _eventProvider = mergeEventProviders([
    eventProviderFromFixedList(positioningDemoEvents),
    eventProviderFromFixedList(_draggedEvents),
  ]);

  @override
  void dispose() {
    _timeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildAppBar(isFlat: false),
      Expanded(
        child: MultiDateTimetable<BasicEvent>(
          controller: _dateController, // required
          timeController: _timeController, // required
          eventProvider: _eventProvider, // required
          headerEventBuilder: (context, event, info) => // required
              BasicAllDayEventWidget(
            event,
            info: info,
            onTap: () => _showSnackBar('All-day event $event tapped'),
          ),
          onHeaderDateTap: (date) =>
              _showSnackBar('Header tapped on date $date.'),
          onHeaderBackgroundTap: (date) =>
              _showSnackBar('Multi-day header background tapped at $date'),
          contentEventBuilder: (context, event) =>
              _buildPartDayEvent(event), // required
          contentOverlayProvider: positioningDemoOverlayProvider,
          onContentBackgroundTap: (dateTime) =>
              _showSnackBar('Part-day background tapped at $dateTime'),
          contentStyle: MultiDateContentStyle(
            nowIndicatorStyle: MultiDateNowIndicatorStyle(color: Colors.green),
            dividerColor: Colors.orange.withOpacity(.3),
          ),
        ),
      ),
    ]);
  }

  Widget _buildPartDayEvent(BasicEvent event) {
    DateTime roundTo15mins(DateTime dateTime) {
      final intervalCount = (dateTime.timeOfDay / 15.minutes).floor();
      return dateTime.atStartOfDay + 15.minutes * intervalCount;
    }

    return PartDayDraggableEvent(
      onDragStart: () => setState(() {
        _draggedEvents.add(event.copyWith(showOnTop: true));
      }),
      onDragUpdate: (dateTime) => setState(() {
        dateTime = roundTo15mins(dateTime);
        final index = _draggedEvents.indexWhere((it) => it.id == event.id);
        final oldEvent = _draggedEvents[index];
        _draggedEvents[index] = oldEvent.copyWith(
          start: dateTime,
          end: dateTime + oldEvent.duration,
        );
      }),
      onDragEnd: (dateTime) {
        setState(() => _draggedEvents.removeWhere((it) => it.id == event.id));
        _showSnackBar('Dragged to: ${roundTo15mins(dateTime ?? event.start)}');
      },
      child: BasicEventWidget(
        event,
        onTap: () => _showSnackBar('Part-day event $event tapped'),
      ),
    );
  }

  Widget _buildAppBar({required bool isFlat}) {
    Widget child = AppBar(
      backwardsCompatibility: false,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: Colors.transparent,
      title: MonthIndicator.forController(_dateController),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.today),
          onPressed: () {
            _dateController.animateToToday(vsync: this);
            _timeController.animateToShowFullDay(vsync: this);
          },
          tooltip: 'Go to today',
        ),
        SizedBox(width: 8),
        DropdownButton<PredefinedVisibleDateRange>(
          onChanged: (visibleRange) => setState(() {
            _visibleDateRange = visibleRange!;
            _dateController.setVisibleRange(visibleRange.visibleDateRange);
          }),
          value: _visibleDateRange,
          items: [
            for (final visibleRange in PredefinedVisibleDateRange.values)
              DropdownMenuItem(
                value: visibleRange,
                child: Text(visibleRange.title),
              ),
          ],
        ),
        SizedBox(width: 16),
      ],
    );

    child = Column(children: [
      child,
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: CompactMonthTimetable(dateController: _dateController),
      ),
    ]);

    if (!isFlat) {
      final colorScheme = context.theme.colorScheme;
      child = Material(
        color: colorScheme.brightness == Brightness.dark
            ? colorScheme.surface
            : colorScheme.primary,
        elevation: 4,
        child: child,
      );
    }
    return child;
  }

  void _showSnackBar(String content) =>
      context.scaffoldMessenger.showSnackBar(SnackBar(content: Text(content)));
}

enum PredefinedVisibleDateRange { day, threeDays, workWeek, week }

extension on PredefinedVisibleDateRange {
  VisibleDateRange get visibleDateRange {
    switch (this) {
      case PredefinedVisibleDateRange.day:
        return VisibleDateRange.days(1);
      case PredefinedVisibleDateRange.threeDays:
        return VisibleDateRange.days(3);
      case PredefinedVisibleDateRange.workWeek:
        return VisibleDateRange.weekAligned(5);
      case PredefinedVisibleDateRange.week:
        return VisibleDateRange.week();
    }
  }

  String get title {
    switch (this) {
      case PredefinedVisibleDateRange.day:
        return 'Day';
      case PredefinedVisibleDateRange.threeDays:
        return '3 Days';
      case PredefinedVisibleDateRange.workWeek:
        return 'Work Week';
      case PredefinedVisibleDateRange.week:
        return 'Week';
    }
  }
}

// ignore_for_file: avoid_print, unused_element
