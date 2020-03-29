import 'package:flutter/material.dart';

import '../controller.dart';
import '../date_page_view.dart';
import 'date_header.dart';

class MultiDateHeader extends StatelessWidget {
  const MultiDateHeader({
    Key key,
    @required this.controller,
  })  : assert(controller != null),
        super(key: key);

  final TimetableController controller;

  @override
  Widget build(BuildContext context) {
    return DatePageView(
      controller: controller,
      builder: (_, date) {
        return Center(child: DateHeader(date));
      },
    );
  }
}
