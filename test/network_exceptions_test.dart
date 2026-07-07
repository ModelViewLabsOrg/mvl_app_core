import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/network/exceptions.dart';

void main() {
  group('AppException (network)', () {
    test('stores userMessage and shouldLogAsError', () {
      const ex = AppException(userMessage: 'Something failed');
      expect(ex.userMessage, 'Something failed');
      expect(ex.shouldLogAsError, isTrue);
    });

    test('shouldLogAsError defaults to true', () {
      const ex = AppException(userMessage: 'msg');
      expect(ex.shouldLogAsError, isTrue);
    });

    test('toString includes shouldLogAsError and userMessage', () {
      const ex = AppException(userMessage: 'test error');
      expect(ex.toString(), contains('test error'));
      expect(ex.toString(), contains('true'));
    });

    test('implements Exception', () {
      const ex = AppException(userMessage: null);
      expect(ex, isA<Exception>());
    });
  });

  group('NetworkException', () {
    test('stores userMessage and shouldLogAsError', () {
      const ex = NetworkException(userMessage: 'Network error', shouldLogAsError: false);
      expect(ex.userMessage, 'Network error');
      expect(ex.shouldLogAsError, isFalse);
    });

    test('is an AppException', () {
      const ex = NetworkException(userMessage: 'err', shouldLogAsError: true);
      expect(ex, isA<AppException>());
    });
  });

  group('OtpValidationException', () {
    test('stores userMessage', () {
      const ex = OtpValidationException(userMessage: 'Código inválido');
      expect(ex.userMessage, 'Código inválido');
    });

    test('shouldLogAsError is false', () {
      const ex = OtpValidationException(userMessage: 'Código inválido');
      expect(ex.shouldLogAsError, isFalse);
    });

    test('is a NetworkException', () {
      const ex = OtpValidationException(userMessage: 'err');
      expect(ex, isA<NetworkException>());
    });
  });

  group('AuthOtpValidationExpiredException', () {
    test('has a userMessage about expired code', () {
      final ex = AuthOtpValidationExpiredException();
      expect(ex.userMessage, isNotNull);
      expect(ex.userMessage, isNotEmpty);
    });

    test('shouldLogAsError is false', () {
      final ex = AuthOtpValidationExpiredException();
      expect(ex.shouldLogAsError, isFalse);
    });

    test('is a NetworkException', () {
      expect(AuthOtpValidationExpiredException(), isA<NetworkException>());
    });
  });
}
