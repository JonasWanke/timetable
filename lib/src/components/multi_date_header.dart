import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../date/controller.dart';
import '../date/date_page_view.dart';
import '../utils.dart';
import 'date_indicator.dart';
import 'weekday_indicator.dart';

typedef MultiDateHeaderTapCallback = void Function(DateTime date);

class MultiDateHeader extends StatelessWidget {
  const MultiDateHeader({
    Key? key,
    required this.controller,
    this.onTap,
  }) : super(key: key);

  final DateController controller;

  final MultiDateHeaderTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DatePageView(
      controller: controller,
      shrinkWrapInCrossAxis: true,
      builder: (context, date) =>
          DateHeader(date, onTap: onTap != null ? () => onTap!(date) : null),
    );
  }
}

class DateHeader extends StatelessWidget {
  DateHeader(
    this.date, {
    Key? key,
    this.onTap,
    this.tooltip,
  })  : assert(date.isValidTimetableDate),
        super(key: key);

  final DateTime date;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Tooltip(
        message: tooltip ?? DateFormat.yMMMMEEEEd().format(date),
        child: Padding(
          padding: EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              WeekdayIndicator(date),
              SizedBox(height: 4),
              DateIndicator(date),
            ],
          ),
        ),
      ),
    );
  }
}
