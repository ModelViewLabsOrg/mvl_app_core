import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/network/exceptions.dart';
import 'package:mvl_app_core/utils/app_exception.dart';

void main() {
  group('AppException', () {
    test('stores message and error', () {
      const exception = AppException('Something went wrong', error: 'raw error');
      expect(exception.userMessage, 'Something went wrong');
      expect(exception.error, 'raw error');
    });

    test('shouldLogAsError defaults to true', () {
      const exception = AppException('msg', error: 'err');
      expect(exception.shouldLogAsError, isTrue);
    });

    test('shouldLogAsError can be set to false', () {
      const exception = AppException('msg', error: 'err', shouldLogAsError: false);
      expect(exception.shouldLogAsError, isFalse);
    });

    test('toString includes message and error', () {
      const exception = AppException('Something went wrong', error: 'raw error');
      final str = exception.toString();
      expect(str, contains('Something went wrong'));
      expect(str, contains('raw error'));
    });

    test('stackTrace is optional', () {
      const exception = AppException('msg', error: 'err');
      expect(exception.stackTrace, isNull);
    });
  });

  group('AppFormError', () {
    test('stores message', () {
      const error = AppFormError('Campo obrigatório', error: 'Campo obrigatório');
      expect(error.userMessage, 'Campo obrigatório');
    });

    test('shouldLogAsError is always false', () {
      const error = AppFormError('some error', error: 'some error');
      expect(error.shouldLogAsError, isFalse);
    });

    test('toString includes AppFormError prefix', () {
      const error = AppFormError('Campo inválido', error: 'Campo inválido');
      expect(error.toString(), 'AppFormError: Campo inválido');
    });

    test('is an AppException', () {
      const error = AppFormError('err', error: 'err');
      expect(error, isA<AppException>());
    });
  });
}
