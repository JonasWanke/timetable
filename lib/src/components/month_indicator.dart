import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../date/controller.dart';
import '../localization.dart';
import '../utils.dart';

class MonthIndicator extends StatelessWidget {
  MonthIndicator(this.month, {Key? key})
      : assert(month.isValidTimetableMonth),
        super(key: key);
  static Widget forController(DateController controller, {Key? key}) =>
      _MonthIndicatorForController(controller, key: key);

  final int month;

  @override
  Widget build(BuildContext context) {
    context.dependOnTimetableLocalizations();
    final date = DateTimeTimetable.date(2020, month, 1);
    return Text(DateFormat.MMMM().format(date));
  }
}

class _MonthIndicatorForController extends StatelessWidget {
  const _MonthIndicatorForController(this.controller, {Key? key})
      : super(key: key);

  final DateController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: controller.date.map((it) => it.month),
      builder: (context, month, _) => MonthIndicator(month),
    );
  }
}
