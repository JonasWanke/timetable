import 'package:flutter/material.dart';

import '../event/event.dart';
import '../time/overlay.dart';
import '../utils.dart';
import 'date_content.dart';

/// A widget that displays the given [TimeOverlay]s.
///
/// This widget doesn't honor [TimeOverlay]'s `position` by itself, so you might
/// have to split your [TimeOverlay]s and display them in two separate widgets.
///
/// See also:
///
/// * [DateContent], which displays [Event]s and [TimeOverlay]s and also honors
///   the `position`s.
class TimeOverlays extends StatelessWidget {
  const TimeOverlays({super.key, required this.overlays});

  final List<TimeOverlay> overlays;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;

        return Stack(
          children: [
            for (final overlay in overlays)
              Positioned.fill(
                top: (overlay.start / 1.days) * height,
                bottom: (1 - overlay.end / 1.days) * height,
                child: overlay.widget,
              ),
          ],
        );
      },
    );
  }
}
