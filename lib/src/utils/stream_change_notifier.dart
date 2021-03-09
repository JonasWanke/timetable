import 'dart:async';

import 'package:flutter/foundation.dart';

class StreamChangeNotifier extends ChangeNotifier {
  StreamChangeNotifier(Stream<void> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<void> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
