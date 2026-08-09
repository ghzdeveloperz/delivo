sealed class Result<T> {
  const Result();

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Object error) onFailure,
  }) {
    return switch (this) {
      Success<T>(value: final value) => onSuccess(value),
      Failure<T>(error: final error) => onFailure(error),
    };
  }

  bool get isSuccess => this is Success<T>;

  bool get isFailure => this is Failure<T>;
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);

  final Object error;
}
