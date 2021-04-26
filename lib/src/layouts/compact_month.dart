import 'package:flutter/material.dart';

import '../components/month_widget.dart';
import '../date/controller.dart';
import '../date/month_page_view.dart';
import '../utils.dart';

class CompactMonthTimetable extends StatefulWidget {
  const CompactMonthTimetable({this.dateController});

  final DateController? dateController;

  @override
  _CompactMonthTimetableState createState() => _CompactMonthTimetableState();
}

class _CompactMonthTimetableState extends State<CompactMonthTimetable>
    with TickerProviderStateMixin {
  late final MonthPageController _monthPageController;

  @override
  void initState() {
    super.initState();

    widget.dateController?.date.addListener(_onDateControllerChanged);

    _monthPageController = MonthPageController(
      initialMonth: widget.dateController?.date.value.firstDayOfMonth ??
          DateTimeTimetable.currentMonth(),
    );
    _monthPageController.addListener(_onMonthPageControllerChanged);
  }

  @override
  void dispose() {
    widget.dateController?.date.removeListener(_onDateControllerChanged);
    _monthPageController.removeListener(_onMonthPageControllerChanged);
    _monthPageController.dispose();
    super.dispose();
  }

  int _dateControllerDriverCount = 0;
  int _monthPageControllerDriverCount = 0;
  Future<void> _onDateControllerChanged() async {
    if (_dateControllerDriverCount > 0) return;
    final dateControllerMonth =
        widget.dateController!.date.value.firstDayOfMonth;
    if (dateControllerMonth == _monthPageController.value) return;

    _monthPageControllerDriverCount++;
    await _monthPageController.animateTo(dateControllerMonth);
    _monthPageControllerDriverCount--;
  }

  Future<void> _onMonthPageControllerChanged() async {
    if (_monthPageControllerDriverCount > 0) return;

    _dateControllerDriverCount++;
    await widget.dateController
        ?.animateTo(_monthPageController.value, vsync: this);
    _dateControllerDriverCount--;
  }

  @override
  Widget build(BuildContext context) {
    return MonthPageView(
      monthPageController: _monthPageController,
      shrinkWrapInCrossAxis: true,
      builder: (context, month) => MonthWidget(month),
    );
  }
}
