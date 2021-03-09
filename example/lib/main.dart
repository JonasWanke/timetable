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

  final _dateController = DateController(
    // All parameters are optional.
    initialDate: DateTimeTimetable.today(),
    firstDayOfWeek: DateTime.monday,
  );

  final _timeController = TimeController(
    // All parameters are optional.
    // initialRange: TimeRange(8.hours, 20.hours),
    maxRange: TimeRange(0.hours, 24.hours),
  );

  final visibleRange = VisibleRange.week();

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

  // ignore: unused_element
  Widget _buildSimpleTimetable() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(isFlat: false),
      body: MultiDateTimetable<BasicEvent>(
        controller: _dateController,
        timeController: _timeController,
        visibleRange: visibleRange,
        headerEventProvider: positioningDemoHeaderEventProvider,
        headerEventBuilder: (context, event, info) =>
            BasicAllDayEventWidget(event, info: info),
        contentEventProvider: positioningDemoContentEventProvider,
        contentEventBuilder: (event) => BasicEventWidget(event),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildCustomizedTimetable() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(isFlat: false),
      body: MultiDateTimetable<BasicEvent>(
        controller: _dateController,
        timeController: _timeController,
        visibleRange: visibleRange,
        headerEventProvider: positioningDemoHeaderEventProvider,
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
        contentEventProvider: positioningDemoContentEventProvider,
        contentEventBuilder: (event) {
          return BasicEventWidget(
            event,
            onTap: () => _showSnackBar('Part-day event $event tapped'),
          );
        },
        onContentBackgroundTap: (dateTime) =>
            _showSnackBar('Part-day background tapped at $dateTime'),
        contentStyle: MultiDateContentStyle(
            // timeIndicatorStyle:
            //     MultiDateCurrentTimeIndicatorStyle(color: Colors.green),
            // dividerColor: Colors.orange,
            ),
      ),
    );
  }

  // ignore: unused_element
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
                  visibleRange: visibleRange,
                  eventProvider: positioningDemoHeaderEventProvider,
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
              visibleRange: visibleRange,
              eventProvider: positioningDemoContentEventProvider,
              eventBuilder: (event) {
                return BasicEventWidget(
                  event,
                  onTap: () => _showSnackBar('Part-day event $event tapped'),
                );
              },
              onBackgroundTap: (dateTime) =>
                  _showSnackBar('Part-day background tapped at $dateTime'),
              style: MultiDateContentStyle(
                  // timeIndicatorStyle:
                  //     MultiDateCurrentTimeIndicatorStyle(color: Colors.green),
                  // dividerColor: Colors.orange,
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
            // _timeController.value = TimeRange(6.hours, 18.hours);
          },
          tooltip: 'Go to today',
        ),
      ],
    );
  }

  void _showSnackBar(String content) =>
      context.scaffoldMessenger.showSnackBar(SnackBar(content: Text(content)));
}
