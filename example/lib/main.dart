import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:timetable/timetable.dart';

// ignore: unused_import
import 'positioning_demo.dart';
import 'utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ExampleApp(child: TimetableExample()));
}

class TimetableExample extends StatefulWidget {
  @override
  _TimetableExampleState createState() => _TimetableExampleState();
}

class _TimetableExampleState extends State<TimetableExample>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

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

  @override
  void initState() {
    super.initState();
    _dateController.date.addListener(() {
      print(
          'Viewing Date ${_dateController.date.value.toIso8601String().substring(0, 10)} (${_dateController.value}).');
    });
  }

  @override
  void dispose() {
    _timeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return _buildSimpleTimetable();
    return _buildCustomizedTimetable();
    // return _buildCustomTimetable();
  }

  Widget _buildSimpleTimetable() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(isFlat: false),
      body: MultiDateTimetable<BasicEvent>(
        controller: _dateController,
        timeController: _timeController,
        eventProvider: eventProviderFromFixedList(positioningDemoEvents),
        headerEventBuilder: (context, event, info) =>
            BasicAllDayEventWidget(event, info: info),
        contentEventBuilder: (event) => BasicEventWidget(event),
        contentOverlayProvider: positioningDemoOverlayProvider,
      ),
    );
  }

  Widget _buildCustomizedTimetable() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(isFlat: false),
      body: MultiDateTimetable<BasicEvent>(
        controller: _dateController,
        timeController: _timeController,
        eventProvider: eventProviderFromFixedList(positioningDemoEvents),
        headerEventBuilder: (context, event, info) {
          return BasicAllDayEventWidget(
            event,
            info: info,
            onTap: () => _showSnackBar('All-day event $event tapped'),
          );
        },
        onHeaderDateTap: (date) =>
            _showSnackBar('Header tapped on date $date.'),
        onHeaderBackgroundTap: (date) =>
            _showSnackBar('Multi-day header background tapped at $date'),
        contentEventBuilder: (event) {
          return BasicEventWidget(
            event,
            onTap: () => _showSnackBar('Part-day event $event tapped'),
          );
        },
        contentOverlayProvider: positioningDemoOverlayProvider,
        onContentBackgroundTap: (dateTime) =>
            _showSnackBar('Part-day background tapped at $dateTime'),
        contentStyle: MultiDateContentStyle(
          nowIndicatorStyle: MultiDateNowIndicatorStyle(color: Colors.green),
          dividerColor: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildCustomTimetable() {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: [
          Material(
            color: context.theme.scaffoldBackgroundColor,
            elevation: 4,
            child: Column(
              children: [
                _buildAppBar(isFlat: true),
                MultiDateTimetableHeader<BasicEvent>(
                  controller: _dateController,
                  eventProvider: eventProviderFromFixedList(
                    positioningDemoEvents.where((it) => it.isAllDay).toList(),
                  ),
                  eventBuilder: (context, event, info) {
                    return BasicAllDayEventWidget(
                      event,
                      info: info,
                      onTap: () => _showSnackBar('All-day event $event tapped'),
                    );
                  },
                  onDateTap: (date) =>
                      _showSnackBar('Header tapped on date $date.'),
                  onBackgroundTap: (date) => _showSnackBar(
                      'Multi-day header background tapped at $date'),
                  padding: EdgeInsets.only(bottom: 4),
                ),
              ],
            ),
          ),
          Expanded(
            child: MultiDateTimetableContent<BasicEvent>(
              dateController: _dateController,
              timeController: _timeController,
              eventProvider: eventProviderFromFixedList(
                positioningDemoEvents.where((it) => it.isPartDay).toList(),
              ),
              eventBuilder: (event) {
                return BasicEventWidget(
                  event,
                  onTap: () => _showSnackBar('Part-day event $event tapped'),
                );
              },
              overlayProvider: positioningDemoOverlayProvider,
              onBackgroundTap: (dateTime) =>
                  _showSnackBar('Part-day background tapped at $dateTime'),
              style: MultiDateContentStyle(
                nowIndicatorStyle:
                    MultiDateNowIndicatorStyle(color: Colors.green),
                dividerColor: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({required bool isFlat}) {
    return AppBar(
      backwardsCompatibility: false,
      elevation: isFlat ? 0 : null,
      brightness: isFlat ? null : Brightness.dark,
      foregroundColor:
          isFlat ? context.theme.brightness.mediumEmphasisOnColor : null,
      backgroundColor: isFlat ? Colors.transparent : null,
      title: Text('Timetable example'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.today),
          onPressed: () {
            _dateController.animateToToday(vsync: this);
            _timeController.animateToShowFullDay(vsync: this);
          },
          tooltip: 'Go to today',
        ),
        DropdownButton<PredefinedVisibleDateRange>(
          // Our `visibleDateRange` setter takes care
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
