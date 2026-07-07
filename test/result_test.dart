import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/utils/result.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('holds the success value', () {
        const result = Success<int, Exception>(42);
        expect(result.value, 42);
      });

      test('matches Success in pattern matching', () {
        const Result<String, Exception> result = Success('ok');
        final String label = switch (result) {
          Success(:final value) => 'success: $value',
          Failure() => 'failure',
        };
        expect(label, 'success: ok');
      });
    });

    group('Failure', () {
      test('holds the exception', () {
        final exception = Exception('error');
        final result = Failure<int, Exception>(exception);
        expect(result.exception, exception);
      });

      test('matches Failure in pattern matching', () {
        final Result<String, Exception> result = Failure(Exception('oops'));
        final String label = switch (result) {
          Success() => 'success',
          Failure(:final exception) => 'failure: $exception',
        };
        expect(label, contains('failure'));
      });
    });

    group('type checking', () {
      test('Success is a Result', () {
        const Result<int, Exception> r = Success(1);
        expect(r, isA<Success<int, Exception>>());
        expect(r, isNot(isA<Failure<int, Exception>>()));
      });

      test('Failure is a Result', () {
        final Result<int, Exception> r = Failure(Exception());
        expect(r, isA<Failure<int, Exception>>());
        expect(r, isNot(isA<Success<int, Exception>>()));
      });
    });
  });
}
