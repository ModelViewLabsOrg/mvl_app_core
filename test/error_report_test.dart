import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/models/server_response.dart';
import 'package:mvl_app_core/tracking/error_report.dart';
import 'package:mvl_app_core/utils/app_exception.dart';

void main() {
  group('ErrorGrouping.origin', () {
    test('keeps a literal origin untouched', () {
      expect(ErrorGrouping.origin('team-withdraw'), 'team-withdraw');
      expect(ErrorGrouping.origin('finances_send_amount'), 'finances_send_amount');
    });

    test('collapses ids so one defect does not become one issue per user', () {
      expect(
        ErrorGrouping.origin('refreshSession for 11260'),
        ErrorGrouping.origin('refreshSession for 98432'),
      );
    });

    test('collapses emails', () {
      expect(
        ErrorGrouping.origin('_refreshInactiveSessions: someone@example.com'),
        ErrorGrouping.origin('_refreshInactiveSessions: other@example.org'),
      );
    });

    test('collapses uuids', () {
      expect(
        ErrorGrouping.origin('load 3f2504e0-4f89-11d3-9a0c-0305e82c3301'),
        ErrorGrouping.origin('load 6ba7b810-9dad-11d1-80b4-00c04fd430c8'),
      );
    });

    test('keeps the whole payload of an edge failure within the tag budget', () {
      const dirty =
          'FunctionException: team-withdraw, status: 500. Error: kxb(status: 500, '
          'details: {is_error: true, user_message: Houve um erro aqui, data: {}, error: No auth})';

      final String origin = ErrorGrouping.origin(dirty);

      expect(origin.length, lessThanOrEqualTo(ErrorGrouping.originMaxLength));
      expect(origin, isNot(contains(' ')));
    });

    test('falls back to a placeholder when nothing usable is left', () {
      expect(ErrorGrouping.origin('   '), 'unknown');
    });
  });

  group('ErrorGrouping.normalizeMessage', () {
    test('groups the same failure raised for different records', () {
      expect(
        ErrorGrouping.normalizeMessage('Team 4821 has no bank account'),
        ErrorGrouping.normalizeMessage('Team 9137 has no bank account'),
      );
    });

    test('collapses whitespace and caps the length', () {
      final String message = ErrorGrouping.normalizeMessage('a\n  b   c${'!' * 500}');

      expect(message, startsWith('a b c'));
      expect(message.length, lessThanOrEqualTo(ErrorGrouping.messageMaxLength));
    });
  });

  group('report', () {
    test('AppException answers by a literal type, not by runtimeType', () {
      final exception = AppException(
        'Falhou',
        error: Exception('boom'),
        stackTrace: StackTrace.current,
      );

      expect(exception.report.type, 'AppException');
    });

    test('ServerResponseException groups by the message the server chose', () {
      final first = ServerResponseException(
        ServerResponse.customError('Saldo insuficiente'),
      );
      final second = ServerResponseException(
        ServerResponse.customError('Saldo insuficiente'),
      );
      final other = ServerResponseException(
        ServerResponse.customError('Conta bancária não cadastrada'),
      );

      expect(first.report.grouping, second.report.grouping);
      expect(first.report.grouping, isNot(other.report.grouping));
    });
  });
}
