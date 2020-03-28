import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart' hide Offset;
import 'package:time_machine/time_machine_text_patterns.dart';

import 'timetable.dart';

class DateHoursWidget extends StatelessWidget {
  static final _pattern = LocalTimePattern.createWithCurrentCulture('HH:mm');

  @override
  Widget build(BuildContext context) {
    final textStyle = context.textTheme.caption;

    return CustomMultiChildLayout(
      delegate: _DateHoursLayoutDelegate(),
      children: <Widget>[
        for (var i = 1; i < TimeConstants.hoursPerDay; i++)
          LayoutId(
            id: i,
            child: Text(_formatHour(i), style: textStyle),
          ),
      ],
    );
  }

  String _formatHour(int hour) => _pattern.format(LocalTime(hour, 0, 0));
}

class _DateHoursLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  Size getSize(BoxConstraints constraints) =>
      constraints.constrainDimensions(hourColumnWidth, double.infinity);

  @override
  void performLayout(Size size) {
    final heightPerHour = size.height / TimeConstants.hoursPerDay;

    for (var i = 1; i < TimeConstants.hoursPerDay; i++) {
      final childSize = layoutChild(i, BoxConstraints.loose(size));

      final x = size.width - childSize.width;
      final y = i * heightPerHour - childSize.height / 2;
      positionChild(i, Offset(x, y));
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => false;
}
