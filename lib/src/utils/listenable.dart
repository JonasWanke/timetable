import 'package:flutter/foundation.dart';

typedef Mapper<T, R> = R Function(T data);

extension MapValueListenable<T> on ValueListenable<T> {
  ValueListenable<R> map<R>(Mapper<T, R> mapper) =>
      _MapValueListenable(this, mapper);
}

class _MapValueListenable<T, R> extends ValueNotifier<R> {
  _MapValueListenable(this.listenable, this.mapper)
      : super(mapper(listenable.value)) {
    listenable.addListener(_listener);
  }

  final ValueListenable<T> listenable;
  final Mapper<T, R> mapper;

  void _listener() => value = mapper(listenable.value);

  @override
  void dispose() {
    listenable.removeListener(_listener);
    super.dispose();
  }
}
