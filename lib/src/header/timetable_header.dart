import 'package:flutter/material.dart';

import '../controller.dart';
import '../timetable.dart';
import 'multi_date_header.dart';
import 'week_indicator.dart';

class TimetableHeader extends StatelessWidget {
  const TimetableHeader({
    Key key,
    @required this.controller,
  })  : assert(controller != null),
        super(key: key);

  final TimetableController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // TODO(JonasWanke): dynamic height based on content
      height: 100,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: hourColumnWidth,
            child: Center(child: WeekIndicator(13)),
          ),
          Expanded(
            child: MultiDateHeader(controller: controller),
          ),
        ],
      ),
    );
  }
}
