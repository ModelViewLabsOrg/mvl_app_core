import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/brazil/document/cpf_helper.dart';

void main() {
  group('CPFHelper', () {
    group('isValid', () {
      test('returns true for a valid CPF (unformatted)', () {
        expect(CPFHelper('52998224725').isValid(), isTrue);
      });

      test('returns true for a valid CPF (formatted)', () {
        expect(CPFHelper('529.982.247-25').isValid(), isTrue);
      });

      test('returns false for CPF with wrong length', () {
        expect(CPFHelper('1234567890').isValid(), isFalse);
        expect(CPFHelper('123456789012').isValid(), isFalse);
      });

      test('returns false for all-same-digit CPFs (blocklist)', () {
        for (final blocked in [
          '00000000000',
          '11111111111',
          '22222222222',
          '33333333333',
          '44444444444',
          '55555555555',
          '66666666666',
          '77777777777',
          '88888888888',
          '99999999999',
          '12345678909',
        ]) {
          expect(CPFHelper(blocked).isValid(), isFalse, reason: '$blocked should be invalid');
        }
      });

      test('returns false for CPF with invalid verifier digits', () {
        expect(CPFHelper('52998224724').isValid(), isFalse);
        expect(CPFHelper('52998224726').isValid(), isFalse);
      });

      test('returns false for empty string', () {
        expect(CPFHelper('').isValid(), isFalse);
      });
    });

    group('format', () {
      test('returns formatted CPF for a valid CPF', () {
        expect(CPFHelper('52998224725').format(), '529.982.247-25');
      });

      test('returns formatted CPF when already formatted', () {
        expect(CPFHelper('529.982.247-25').format(), '529.982.247-25');
      });

      test('returns empty string for invalid CPF', () {
        expect(CPFHelper('00000000000').format(), '');
        expect(CPFHelper('12345').format(), '');
      });
    });

    group('generateRandom', () {
      test('generates a valid 11-digit CPF', () {
        final String cpf = CPFHelper.generateRandom();
        expect(cpf.length, 11);
        expect(CPFHelper(cpf).isValid(), isTrue);
      });

      test('generates a formatted CPF when useFormat is true', () {
        final String cpf = CPFHelper.generateRandom(useFormat: true);
        expect(RegExp(r'^\d{3}\.\d{3}\.\d{3}-\d{2}$').hasMatch(cpf), isTrue);
        expect(CPFHelper(cpf).isValid(), isTrue);
      });

      test('each generated CPF is valid', () {
        for (var i = 0; i < 5; i++) {
          final String cpf = CPFHelper.generateRandom();
          expect(CPFHelper(cpf).isValid(), isTrue, reason: 'Generated CPF $cpf should be valid');
        }
      });
    });
  });
}
