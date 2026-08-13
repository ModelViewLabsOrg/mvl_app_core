import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/network/exceptions.dart';
import 'package:mvl_app_core/utils/app_exception.dart';

void main() {
  group('AppException', () {
    test('stores message and error', () {
      final exception = AppException(
        'Something went wrong',
        error: Exception('raw error'),
        stackTrace: StackTrace.current,
      );
      expect(exception.userMessage, 'Something went wrong');
      expect(exception.error.toString(), 'Exception: raw error');
    });

    test('shouldLogAsError defaults to true', () {
      final exception = AppException(
        'msg',
        error: Exception('err'),
        stackTrace: StackTrace.current,
      );
      expect(exception.shouldLogAsError, isTrue);
    });

    test('shouldLogAsError can be set to false', () {
      final exception = AppException(
        'msg',
        error: Exception('err'),
        stackTrace: StackTrace.current,
        shouldLogAsError: false,
      );
      expect(exception.shouldLogAsError, isFalse);
    });

    test('toString includes message and error', () {
      final exception = AppException(
        'Something went wrong',
        error: Exception('raw error'),
        stackTrace: StackTrace.current,
      );
      final str = exception.toString();
      expect(str, contains('Something went wrong'));
      expect(str, contains('raw error'));
    });

    group('AppFormError', () {
      test('stores message', () {
        final error = AppFormError();
        expect(error.userMessage, 'Campo obrigatório');
      });

      test('shouldLogAsError is always false', () {
        final error = AppFormError('some error');
        expect(error.shouldLogAsError, isFalse);
      });

      test('toString omits the class name, already sent as the report type', () {
        final error = AppFormError('Campo inválido');
        expect(error.toString(), 'Campo inválido');
        expect(error.report.type, 'AppFormError');
      });

      test('is an AppException', () {
        final error = AppFormError('err');
        expect(error, isA<AppException>());
      });
    });
  });
}
