import 'package:flutter/material.dart';

import '../controller.dart';
import '../date_page_view.dart';
import '../event.dart';
import '../timetable.dart';
import 'date_header.dart';

class MultiDateHeader<E extends Event> extends StatelessWidget {
  const MultiDateHeader({
    Key key,
    @required this.controller,
    this.builder,
  })  : assert(controller != null),
        super(key: key);

  final TimetableController<E> controller;
  final HeaderBuilder builder;

  @override
  Widget build(BuildContext context) {
    return DatePageView(
      controller: controller,
      builder: (context, date) {
        return builder?.call(context, date) ?? Center(child: DateHeader(date));
      },
    );
  }
}
