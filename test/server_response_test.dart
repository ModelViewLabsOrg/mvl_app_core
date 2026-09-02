import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/app_logger.dart';
import 'package:mvl_app_core/constants/account_strings.dart';
import 'package:mvl_app_core/models/server_response.dart';

void main() {
  group('ServerResponse', () {
    group('fromJson', () {
      test('parses all fields correctly', () {
        final response = ServerResponse.fromJson(const <String, dynamic>{
          'is_error': true,
          'user_message': 'Something failed',
          'data': <String, dynamic>{'key': 'value'},
        });

        expect(response.isError, isTrue);
        expect(response.userMessage, 'Something failed');
        expect(response.data, const <String, dynamic>{'key': 'value'});
      });

      test('defaults isError to false when missing', () {
        final response = ServerResponse.fromJson(const <String, dynamic>{
          'user_message': 'ok',
        });
        expect(response.isError, isFalse);
      });

      test('defaults userMessage to empty string when missing', () {
        final response = ServerResponse.fromJson(const <String, dynamic>{
          'is_error': false,
        });
        expect(response.userMessage, '');
      });

      test('data is null when not present', () {
        final response = ServerResponse.fromJson(const <String, dynamic>{
          'is_error': false,
          'user_message': 'ok',
        });
        expect(response.data, isNull);
      });
    });

    group('success factory', () {
      test('creates a non-error response with message', () {
        final response = ServerResponse.success('Operação realizada');
        expect(response.isError, isFalse);
        expect(response.userMessage, 'Operação realizada');
        expect(response.data, isNull);
      });
    });

    group('customError factory', () {
      test('creates an error response with message', () {
        final response = ServerResponse.customError('Algo deu errado');
        expect(response.isError, isTrue);
        expect(response.userMessage, 'Algo deu errado');
      });
    });

    group('listErrorsValidation factory', () {
      test('creates error with single error (singular)', () {
        final response = ServerResponse.listErrorsValidation(const ['Campo inválido']);
        expect(response.isError, isTrue);
        expect(response.userMessage, contains('Campo inválido'));
        expect(response.userMessage, contains('Corrija o erro antes de continuar'));
      });

      test('creates error with multiple errors (plural)', () {
        final response = ServerResponse.listErrorsValidation(const ['Erro 1', 'Erro 2']);
        expect(response.isError, isTrue);
        expect(response.userMessage, contains('Corrija os erros antes de continuar'));
        expect(response.userMessage, contains('Erro 1'));
        expect(response.userMessage, contains('Erro 2'));
      });
    });

    group('internalError factory', () {
      test('creates an error response with generic message', () {
        final response = ServerResponse.internalError();
        expect(response.isError, isTrue);
        expect(response.userMessage, StringsCore.genericError);
      });
    });
  });

  group('ServerResponseException', () {
    test('is user-facing validation and must not open a crash-reporter issue', () {
      final exception = ServerResponseException(
        ServerResponse.customError('Código de validação inválido.'),
      );

      expect(exception.shouldLogAsError, isFalse);
      expect(exception.userMessage, 'Código de validação inválido.');
      expect(AppLogger.defaultShouldLogAsError(exception), isFalse);
    });
  });
}
