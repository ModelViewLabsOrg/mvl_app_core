import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/utils/validator_email.dart';

void main() {
  group('EmailValidator', () {
    group('isValid', () {
      test('returns true for a valid email', () {
        expect(EmailValidator('user@example.com').isValid(), isTrue);
        expect(EmailValidator('user.name@domain.org').isValid(), isTrue);
        expect(EmailValidator('user+tag@sub.domain.com').isValid(), isTrue);
      });

      test('returns false for null email', () {
        expect(EmailValidator(null).isValid(), isFalse);
      });

      test('returns false for empty string', () {
        expect(EmailValidator('').isValid(), isFalse);
      });

      test('returns false when email has no @', () {
        expect(EmailValidator('userdomain.com').isValid(), isFalse);
      });

      test('returns false when email has double dots', () {
        expect(EmailValidator('user..name@domain.com').isValid(), isFalse);
      });

      test('returns false when email has double dashes', () {
        expect(EmailValidator('user--name@domain.com').isValid(), isFalse);
      });

      test('returns false when email has dash then dot', () {
        expect(EmailValidator('user-.name@domain.com').isValid(), isFalse);
      });

      test('returns false when email is too long (> 254 chars)', () {
        final long = 'user@${'b' * 260}.com';
        expect(long.length, greaterThan(254));
        expect(EmailValidator(long).isValid(), isFalse);
      });

      test('returns false when local part is too long (> 63 chars)', () {
        final long = '${'a' * 64}@domain.com';
        expect(EmailValidator(long).isValid(), isFalse);
      });

      test('returns false when there are multiple @ signs', () {
        expect(EmailValidator('user@@domain.com').isValid(), isFalse);
        expect(EmailValidator('user@domain@com').isValid(), isFalse);
      });

      test('normalizes email (trims, lowercases) before validation', () {
        expect(EmailValidator('  USER@EXAMPLE.COM  ').isValid(), isTrue);
      });

      test('returns false for missing TLD', () {
        expect(EmailValidator('user@domain').isValid(), isFalse);
      });
    });

    group('normalize (static)', () {
      test('trims whitespace and lowercases', () {
        expect(EmailValidator.normalize('  USER@EXAMPLE.COM  '), 'user@example.com');
      });

      test('lowercases uppercase email', () {
        expect(EmailValidator.normalize('User@Domain.COM'), 'user@domain.com');
      });
    });

    group('validate', () {
      test('returns null for valid email', () {
        expect(EmailValidator('user@example.com').validate(), isNull);
      });

      test('returns error string for invalid email', () {
        expect(EmailValidator('not-an-email').validate(), 'E-mail inválido');
      });
    });

    group('EmailValidatorExt.normalize (extension)', () {
      test('normalizes via extension method', () {
        expect(EmailValidator('  Admin@EXAMPLE.COM  ').normalize(), 'admin@example.com');
      });
    });
  });
}
