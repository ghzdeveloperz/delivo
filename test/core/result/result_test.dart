import 'package:delivo/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Success exposes success state', () {
      const result = Success<int>(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(
        result.fold(onSuccess: (value) => value, onFailure: (_) => -1),
        42,
      );
    });

    test('Failure exposes failure state', () {
      final error = StateError('failure');
      final result = Failure<int>(error);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(
        result.fold(onSuccess: (value) => value, onFailure: (_) => -1),
        -1,
      );
    });
  });
}
