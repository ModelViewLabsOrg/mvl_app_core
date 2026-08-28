import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/utils/validator.dart';

void main() {
  group('Validator', () {
    group('isPasswordValid', () {
      test('returns true for password within minimum and maximum bounds', () {
        expect(const Validator('password1').isPasswordValid(), isTrue);
        expect(const Validator('validpasswordtwentynineX').isPasswordValid(), isTrue);
      });

      test('returns false for password shorter than minimum', () {
        expect(const Validator('short').isPasswordValid(), isFalse);
        expect(const Validator('1234567').isPasswordValid(), isFalse);
      });

      test('returns false for password at or above maxLength', () {
        expect(const Validator('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').isPasswordValid(), isFalse);
      });

      test('respects custom minLength', () {
        expect(const Validator('ab').isPasswordValid(minLength: 2), isTrue);
      });
    });

    group('isPhoneValid', () {
      test('returns true for 10-digit phone (landline with DDD)', () {
        expect(const Validator('1133334444').isPhoneValid(), isTrue);
      });

      test('returns true for 11-digit phone (mobile with DDD)', () {
        expect(const Validator('11912345678').isPhoneValid(), isTrue);
      });

      test('ignores non-digit characters when counting length', () {
        expect(const Validator('(11) 3333-4444').isPhoneValid(), isTrue);
      });

      test('returns false for phone with wrong number of digits', () {
        expect(const Validator('119123456').isPhoneValid(), isFalse);
        expect(const Validator('119123456789').isPhoneValid(), isFalse);
      });
    });

    group('isMobileValid', () {
      test('returns true only for 11-digit mobile number', () {
        expect(const Validator('11912345678').isMobileValid(), isTrue);
      });

      test('returns false for 10-digit landline', () {
        expect(const Validator('1133334444').isMobileValid(), isFalse);
      });

      test('returns false for wrong length', () {
        expect(const Validator('119123').isMobileValid(), isFalse);
      });
    });

    group('isNameValid', () {
      test('returns true for valid full name', () {
        expect(const Validator('Gabriel Rozendo').isNameValid(), isTrue);
        expect(const Validator('Ana Maria da Silva').isNameValid(), isTrue);
      });

      test('returns false for single name when fullName required', () {
        expect(const Validator('Gabriel').isNameValid(), isFalse);
      });

      test('returns true for single name when fullName is false', () {
        expect(const Validator('Gabriel').isNameValid(fullName: false), isTrue);
      });

      test('returns false for name that is too short', () {
        expect(const Validator('AB').isNameValid(fullName: false), isFalse);
      });

      test('returns false for name that is too long (above 50 chars)', () {
        expect(
          const Validator(
            'aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeff',
          ).isNameValid(fullName: false),
          isFalse,
        );
      });
    });

    group('isBirthdayValid', () {
      test('returns true for birthday giving age > 1 year', () {
        withClock(Clock.fixed(DateTime(2025)), () {
          expect(const Validator('').isBirthdayValid(DateTime(2022)), isTrue);
          expect(const Validator('').isBirthdayValid(DateTime(2000, 6, 15)), isTrue);
        });
      });

      test('returns false for birthday giving age <= 1 year', () {
        withClock(Clock.fixed(DateTime(2025)), () {
          expect(const Validator('').isBirthdayValid(DateTime(2024, 6)), isFalse);
          expect(const Validator('').isBirthdayValid(DateTime(2025)), isFalse);
        });
      });
    });

    group('isCPFValid', () {
      test('returns true for valid CPF', () {
        expect(const Validator('52998224725').isCPFValid(), isTrue);
        expect(const Validator('529.982.247-25').isCPFValid(), isTrue);
      });

      test('returns false for invalid CPF', () {
        expect(const Validator('00000000000').isCPFValid(), isFalse);
        expect(const Validator('12345678901').isCPFValid(), isFalse);
      });
    });

    group('isCNPJValid', () {
      test('returns true for valid CNPJ', () {
        expect(const Validator('11222333000181').isCNPJValid(), isTrue);
        expect(const Validator('11.222.333/0001-81').isCNPJValid(), isTrue);
        expect(const Validator('12ABC34501DE35').isCNPJValid(), isTrue);
      });

      test('returns false for invalid CNPJ', () {
        expect(const Validator('00000000000000').isCNPJValid(), isFalse);
        expect(const Validator('12345678901234').isCNPJValid(), isFalse);
      });
    });

    group('isAmountValid', () {
      test('returns false for empty string', () {
        expect(const Validator('').isAmountValid(), isFalse);
      });

      test('returns false for non-numeric characters', () {
        expect(const Validator('abc').isAmountValid(), isFalse);
        expect(const Validator('1,00').isAmountValid(), isFalse);
      });

      test('returns true for a valid numeric string within default bounds', () {
        expect(const Validator('0').isAmountValid(), isTrue);
        expect(const Validator('9999').isAmountValid(), isTrue);
      });

      test('returns false when amount exceeds maxAmount', () {
        expect(const Validator('100').isAmountValid(1, 50), isFalse);
      });

      test('returns false when amount is below minAmount', () {
        expect(const Validator('0').isAmountValid(1), isFalse);
      });
    });

    group('isUUID', () {
      test('returns true for valid UUID format', () {
        expect(
          const Validator('550e8400-e29b-41d4-a716-446655440000').isUUID(),
          isTrue,
        );
      });

      test('returns false for invalid UUID', () {
        expect(const Validator('not-a-uuid').isUUID(), isFalse);
        expect(const Validator('').isUUID(), isFalse);
        expect(const Validator('550e8400e29b41d4a716446655440000').isUUID(), isFalse);
      });
    });

    group('isAddressValid', () {
      test('returns true for address longer than 3 chars', () {
        expect(const Validator('Rua das Flores').isAddressValid(), isTrue);
      });

      test('returns false for short address', () {
        expect(const Validator('Rua').isAddressValid(), isFalse);
        expect(const Validator('').isAddressValid(), isFalse);
      });
    });

    group('isCountryValid', () {
      test('returns true for value containing lowercase letters', () {
        expect(const Validator('br').isCountryValid(), isTrue);
        expect(const Validator('us').isCountryValid(), isTrue);
      });
    });
  });
}
