import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/network/exceptions.dart';
import 'package:mvl_app_core/utils/app_exception.dart';

void main() {
  group('AppException (network)', () {
    test('stores userMessage and shouldLogAsError', () {
      const ex = AppException('Something failed', error: 'Something failed');
      expect(ex.userMessage, 'Something failed');
      expect(ex.shouldLogAsError, isTrue);
    });

    test('shouldLogAsError defaults to true', () {
      const ex = AppException('msg', error: 'msg');
      expect(ex.shouldLogAsError, isTrue);
    });

    test('toString includes shouldLogAsError and userMessage', () {
      const ex = AppException('test error', error: 'test error');
      expect(ex.toString(), contains('test error'));
      expect(ex.toString(), contains('true'));
    });

    test('throws AssertionError when userMessage is empty', () {
      expect(
        () => AppException('', error: 'err'),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('NetworkException', () {
    test('stores userMessage and shouldLogAsError', () {
      const ex = NetworkException('Network error', error: 'Network error', shouldLogAsError: false);
      expect(ex.userMessage, 'Network error');
      expect(ex.shouldLogAsError, isFalse);
    });

    test('is an AppException', () {
      const ex = NetworkException('err', error: 'err', shouldLogAsError: true);
      expect(ex, isA<AppException>());
    });
  });

  group('OtpValidationException', () {
    test('stores userMessage and shouldLogAsError', () {
      const ex = OtpValidationException('Código inválido', error: 'Código inválido');
      expect(ex.userMessage, 'Código inválido');
      expect(ex.shouldLogAsError, isFalse);
      expect(ex, isA<NetworkException>());
    });
  });

  group('AuthOtpValidationExpiredException', () {
    final ex = AuthOtpValidationExpiredException();

    test('has a userMessage about expired code', () {
      expect(ex.userMessage, isNotNull);
      expect(ex.userMessage, isNotEmpty);
    });

    test('shouldLogAsError is false', () {
      expect(ex.shouldLogAsError, isFalse);
    });

    test('is a NetworkException', () {
      expect(AuthOtpValidationExpiredException(), isA<NetworkException>());
    });
  });
}
