abstract class Result<T> {
  const Result();

  /// Safely handle both branches without manual `is` checks.
  R fold<R>(
    R Function(T data) onSuccess,
    R Function(String message) onError,
  ) {
    final self = this;
    if (self is Success<T>) return onSuccess(self.data);
    if (self is Error<T>) return onError(self.message);
    throw StateError('Unhandled Result subtype: $runtimeType');
  }

  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final String message;
  const Error(this.message);
}