import 'dart:async';

import 'package:flutter/foundation.dart';

class StreamChangeNotifier extends ChangeNotifier {
  StreamChangeNotifier(Stream<dynamic> stream) {
    _subscription = stream.listen((dynamic _) => notifyListeners());
  }

  late StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
