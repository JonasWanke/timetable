import 'dart:async';

import 'package:flutter/foundation.dart';

class StreamChangeNotifier extends ChangeNotifier {
  StreamChangeNotifier(Stream<dynamic> stream) : assert(stream != null) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
