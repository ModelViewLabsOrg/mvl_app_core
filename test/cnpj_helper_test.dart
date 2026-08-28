import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/brazil/document/cnpj_helper.dart';

void main() {
  group('CNPJHelper', () {
    group('isValid', () {
      test('returns true for a valid CNPJ (unformatted)', () {
        expect(CNPJHelper('11222333000181').isValid(), isTrue);
      });

      test('returns true for a valid CNPJ (formatted)', () {
        expect(CNPJHelper('11.222.333/0001-81').isValid(), isTrue);
      });

      test('returns false for CNPJ with wrong length', () {
        expect(CNPJHelper('1122233300018').isValid(), isFalse);
        expect(CNPJHelper('112223330001810').isValid(), isFalse);
      });

      test('returns false for all-same-digit CNPJs (blocklist)', () {
        for (final blocked in [
          '00000000000000',
          '11111111111111',
          '22222222222222',
          '33333333333333',
          '44444444444444',
          '55555555555555',
          '66666666666666',
          '77777777777777',
          '88888888888888',
          '99999999999999',
        ]) {
          expect(CNPJHelper(blocked).isValid(), isFalse, reason: '$blocked should be invalid');
        }
      });

      test('returns false for CNPJ with invalid verifier digits', () {
        expect(CNPJHelper('11222333000182').isValid(), isFalse);
        expect(CNPJHelper('11222333000180').isValid(), isFalse);
      });

      test('returns false for empty string', () {
        expect(CNPJHelper('').isValid(), isFalse);
      });

      test('returns true for the official alphanumeric CNPJ example', () {
        expect(CNPJHelper('12ABC34501DE35').isValid(), isTrue);
        expect(CNPJHelper('12.ABC.345/01DE-35').isValid(), isTrue);
      });

      test('accepts lowercase alphanumeric CNPJ and normalizes it', () {
        expect(CNPJHelper('12abc34501de35').isValid(), isTrue);
        expect(CNPJHelper('12.abc.345/01de-35').isValid(), isTrue);
        expect(CNPJHelper('12.abc.345/01de-35').value, '12ABC34501DE35');
      });

      test('returns false for alphanumeric CNPJ with invalid verifier digits', () {
        expect(CNPJHelper('12ABC34501DE00').isValid(), isFalse);
      });

      test('returns false when check digits are not numeric', () {
        expect(CNPJHelper('12ABC34501DE3A').isValid(), isFalse);
      });
    });

    group('format', () {
      test('returns formatted CNPJ for a valid CNPJ', () {
        expect(CNPJHelper('11222333000181').format(), '11.222.333/0001-81');
      });

      test('returns formatted CNPJ when already formatted', () {
        expect(CNPJHelper('11.222.333/0001-81').format(), '11.222.333/0001-81');
      });

      test('returns empty string for invalid CNPJ', () {
        expect(CNPJHelper('00000000000000').format(), '');
        expect(CNPJHelper('123').format(), '');
      });

      test('returns formatted alphanumeric CNPJ', () {
        expect(CNPJHelper('12ABC34501DE35').format(), '12.ABC.345/01DE-35');
        expect(CNPJHelper('12abc34501de35').format(), '12.ABC.345/01DE-35');
      });
    });

    group('generateRandom', () {
      test('generates a valid 14-digit CNPJ', () {
        final String cnpj = CNPJHelper.generateRandom();
        expect(cnpj.length, 14);
        expect(CNPJHelper(cnpj).isValid(), isTrue);
      });

      test('generates a formatted CNPJ when useFormat is true', () {
        final String cnpj = CNPJHelper.generateRandom(useFormat: true);
        expect(
          RegExp(r'^\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}$').hasMatch(cnpj),
          isTrue,
        );
        expect(CNPJHelper(cnpj).isValid(), isTrue);
      });

      test('generates a valid alphanumeric CNPJ', () {
        final String cnpj = CNPJHelper.generateRandom(alphanumeric: true);
        expect(cnpj.length, 14);
        expect(RegExp(r'^[A-Z0-9]{12}\d{2}$').hasMatch(cnpj), isTrue);
        expect(CNPJHelper(cnpj).isValid(), isTrue);
      });

      test('generates a formatted alphanumeric CNPJ when useFormat is true', () {
        final String cnpj = CNPJHelper.generateRandom(useFormat: true, alphanumeric: true);
        expect(
          RegExp(r'^[A-Z0-9]{2}\.[A-Z0-9]{3}\.[A-Z0-9]{3}/[A-Z0-9]{4}-\d{2}$').hasMatch(cnpj),
          isTrue,
        );
        expect(CNPJHelper(cnpj).isValid(), isTrue);
      });
    });
  });
}
