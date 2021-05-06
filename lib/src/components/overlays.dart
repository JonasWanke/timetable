import 'package:flutter/material.dart';

import '../time/overlay.dart';
import '../utils.dart';

class TimeOverlays extends StatelessWidget {
  const TimeOverlays({required this.overlays});

  final List<TimeOverlay> overlays;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final height = constraints.maxHeight;

      return Stack(children: [
        for (final overlay in overlays)
          Positioned.fill(
            top: (overlay.start / 1.days) * height,
            bottom: (1 - overlay.end / 1.days) * height,
            child: overlay.widget,
          ),
      ]);
    });
  }
}
