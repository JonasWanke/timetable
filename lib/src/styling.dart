enum TemporalState { past, present, future }

/// Signature for the function that returns a value of type `T` based on a given
/// state.
typedef TimetablePropertyResolver<T> = T Function(TemporalState state);

abstract class TemporalStateProperty<T> {
  /// Convenience method for creating a [TemporalStateProperty] from a
  /// [TimetablePropertyResolver] function alone.
  static TemporalStateProperty<T> resolveWith<T>(
    TimetablePropertyResolver<T> callback,
  ) =>
      _TemporalStatePropertyWith<T>(callback);

  /// Convenience method for creating a [TemporalStateProperty] that resolves
  /// to a single value for all state.
  static TemporalStateProperty<T> all<T>(T value) =>
      _TemporalStatePropertyAll<T>(value);

  /// Returns a value of type `T` that depends on [state].
  T resolve(TemporalState state);
}

class _TemporalStatePropertyWith<T> implements TemporalStateProperty<T> {
  _TemporalStatePropertyWith(this._resolve);

  final TimetablePropertyResolver<T> _resolve;

  @override
  T resolve(TemporalState state) => _resolve(state);
}

class _TemporalStatePropertyAll<T> implements TemporalStateProperty<T> {
  _TemporalStatePropertyAll(this.value);

  final T value;

  @override
  T resolve(TemporalState state) => value;

  @override
  String toString() => 'TemporalStateProperty.all($value)';
}
