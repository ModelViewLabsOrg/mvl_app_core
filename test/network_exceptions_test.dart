import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/network/exceptions.dart';
import 'package:mvl_app_core/utils/app_exception.dart';

void main() {
  group('AppException (network)', () {
    test('stores userMessage and shouldLogAsError', () {
      final ex = AppException.fromStringError('Something failed', StackTrace.current);
      expect(ex.userMessage, 'Something failed');
      expect(ex.shouldLogAsError, isTrue);
    });

    test('shouldLogAsError defaults to true', () {
      final ex = AppException.fromStringError('msg', StackTrace.current);
      expect(ex.shouldLogAsError, isTrue);
    });

    test('toString includes shouldLogAsError and userMessage', () {
      final ex = AppException.fromStringError('test error', StackTrace.current);
      expect(ex.toString(), contains('test error'));
      expect(ex.toString(), contains('true'));
    });

    test('throws AssertionError when userMessage is empty', () {
      expect(
        () => AppException.fromStringError('', StackTrace.current),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('NetworkException', () {
    test('stores userMessage and shouldLogAsError', () {
      final ex = NetworkException.fromStringError('Network error', shouldLogAsError: false);
      expect(ex.userMessage, 'Network error');
      expect(ex.shouldLogAsError, isFalse);
    });

    test('is an AppException', () {
      final ex = NetworkException.fromStringError('err');
      expect(ex, isA<NetworkException>());
      expect(ex, isA<AppException>());
    });
  });

  group('OtpValidationException', () {
    test('stores userMessage and shouldLogAsError', () {
      final ex = OtpValidationException('Código inválido');
      expect(ex.userMessage, 'Código inválido');
      expect(ex.shouldLogAsError, isFalse);
      expect(ex, isA<NetworkException>());
      expect(ex, isA<AppException>());
    });
  });
}
