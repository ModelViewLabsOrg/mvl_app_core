import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mvl_app_core/utils/validator_form.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt-br');
    Intl.defaultLocale = 'pt-br';
    await Jiffy.setLocale('pt-br');
  });

  group('FormValidator', () {
    group('email', () {
      test('returns null for valid email', () {
        expect(const FormValidator('user@example.com').email(), isNull);
      });

      test('returns error for invalid email', () {
        expect(const FormValidator('notanemail').email(), isNotNull);
        expect(const FormValidator(null).email(), isNotNull);
      });
    });

    group('password', () {
      test('returns null for a valid password consisting only of a String', () {
        expect(const FormValidator('validpassword').password(), isNull);
      });

      test('returns null for a valid password consisting only of a Number', () {
        expect(const FormValidator('0123456789').password(), isNull);
      });

      test('returns error for too short password', () {
        expect(const FormValidator('short').password(), isNotNull);
      });

      test('returns error for null password', () {
        expect(const FormValidator(null).password(), isNotNull);
      });

      test('returns message error for too short password', () {
        expect(const FormValidator('short').password(), 'Senha inválida. Pelo menos 8 caracteres');
      });

      test('returns message error for too long password', () {
        expect(
          const FormValidator('abcdefghijklmnopqrstuvwxyz12345').password(),
          'Senha inválida. Máximo 30 caracteres',
        );
      });

      test('returns null for valid password with min length', () {
        expect(const FormValidator('short').password(minLength: 4), isNull);
      });

      test('returns null for valid password with max length', () {
        expect(
          const FormValidator('abcdefghijklmnopqrstuvwxyz12345').password(maxLength: 40),
          isNull,
        );
      });
    });

    group('confirmPassword', () {
      test('returns null when passwords match', () {
        expect(const FormValidator('mypassword').confirmPassword('mypassword'), isNull);
      });

      test('returns error when passwords do not match', () {
        expect(const FormValidator('mypassword').confirmPassword('other'), isNotNull);
      });
    });

    group('phone', () {
      test('returns null for valid 11-digit phone', () {
        expect(const FormValidator('11912345678').phone(), isNull);
      });

      test('returns null for valid 10-digit phone', () {
        expect(const FormValidator('1133334444').phone(), isNull);
      });

      test('returns error for null phone', () {
        expect(const FormValidator(null).phone(), isNotNull);
      });

      test('returns error for too short phone', () {
        expect(const FormValidator('123456789').phone(), isNotNull);
      });
    });

    group('mobile', () {
      test('returns null for valid 11-digit mobile', () {
        expect(const FormValidator('11912345678').mobile(), isNull);
      });

      test('returns error for 10-digit landline', () {
        expect(const FormValidator('1133334444').mobile(), isNotNull);
      });

      test('returns error for null', () {
        expect(const FormValidator(null).mobile(), isNotNull);
      });
    });

    group('cpf', () {
      test('returns null for valid CPF', () {
        expect(const FormValidator('52998224725').cpf(), isNull);
        expect(const FormValidator('529.982.247-25').cpf(), isNull);
      });

      test('returns error for invalid CPF', () {
        expect(const FormValidator('00000000000').cpf(), isNotNull);
        expect(const FormValidator('12345').cpf(), isNotNull);
      });
    });

    group('cnpj', () {
      test('returns null for valid CNPJ', () {
        expect(const FormValidator('11222333000181').cnpj(), isNull);
      });

      test('returns error for invalid CNPJ', () {
        expect(const FormValidator('00000000000000').cnpj(), isNotNull);
        expect(const FormValidator(null).cnpj(), isNotNull);
      });
    });

    group('cpfOrCnpj', () {
      test('validates CPF when value has 14 chars (formatted)', () {
        expect(const FormValidator('529.982.247-25').cpfOrCnpj(), isNull);
      });

      test('validates CNPJ when value has more than 14 chars (formatted)', () {
        expect(const FormValidator('11.222.333/0001-81').cpfOrCnpj(), isNull);
      });

      test('returns error when null or too short', () {
        expect(const FormValidator(null).cpfOrCnpj(), isNotNull);
        expect(const FormValidator('123').cpfOrCnpj(), isNotNull);
      });
    });

    group('name', () {
      test('returns null for name within bounds', () {
        expect(const FormValidator('Gabriel').name(), isNull);
      });

      test('returns error for name too short', () {
        expect(const FormValidator('AB').name(), isNotNull);
      });

      test('returns error for name too long', () {
        expect(
          const FormValidator(
            'aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeff',
          ).name(),
          isNotNull,
        );
      });
    });

    group('fullName', () {
      test('returns null for valid full name', () {
        expect(const FormValidator('Gabriel Rozendo').fullName(), isNull);
      });

      test('returns error for single name', () {
        expect(const FormValidator('Gabriel').fullName(), isNotNull);
        expect(const FormValidator(null).fullName(), isNotNull);
      });
    });

    group('nickname', () {
      test('returns null for nickname within limit', () {
        expect(const FormValidator('gabi').nickname(), isNull);
        expect(const FormValidator(null).nickname(), isNull);
      });

      test('returns error when nickname exceeds 20 chars', () {
        expect(
          const FormValidator('aaaaaaaaaabbbbbbbbbbcc').nickname(),
          isNotNull,
        );
      });
    });

    group('rg', () {
      test('returns null for RG with 5+ chars', () {
        expect(const FormValidator('12345').rg(), isNull);
        expect(const FormValidator('12.345.678-9').rg(), isNull);
      });

      test('returns error for RG too short', () {
        expect(const FormValidator('1234').rg(), isNotNull);
        expect(const FormValidator(null).rg(), isNotNull);
      });
    });

    group('passport', () {
      test('returns null for passport with 5+ chars', () {
        expect(const FormValidator('AB12345').passport(), isNull);
      });

      test('returns error for passport too short', () {
        expect(const FormValidator('1234').passport(), isNotNull);
        expect(const FormValidator(null).passport(), isNotNull);
      });
    });

    group('inviteCode', () {
      test('returns null for 6-character code', () {
        expect(const FormValidator('ABC123').inviteCode(), isNull);
      });

      test('returns error for wrong length', () {
        expect(const FormValidator('12345').inviteCode(), isNotNull);
        expect(const FormValidator('1234567').inviteCode(), isNotNull);
        expect(const FormValidator(null).inviteCode(), isNotNull);
      });
    });

    group('otp', () {
      test('returns null for 6-digit OTP', () {
        expect(const FormValidator('123456').otp(), isNull);
      });

      test('returns error for wrong format', () {
        expect(const FormValidator('12345').otp(), isNotNull);
        expect(const FormValidator('abcdef').otp(), isNotNull);
        expect(const FormValidator(null).otp(), isNotNull);
      });
    });

    group('cvv', () {
      test('returns null for 3-digit CVV', () {
        expect(const FormValidator('123').cvv(), isNull);
      });

      test('returns null for 4-digit CVV', () {
        expect(const FormValidator('1234').cvv(), isNull);
      });

      test('returns error for wrong length', () {
        expect(const FormValidator('12').cvv(), isNotNull);
        expect(const FormValidator(null).cvv(), isNotNull);
      });
    });

    group('zipcode', () {
      test('returns null for formatted zip code', () {
        expect(const FormValidator('12.345-678').zipcode(), isNull);
      });

      test('returns error for unformatted zip code', () {
        expect(const FormValidator('12345678').zipcode(), isNotNull);
        expect(const FormValidator(null).zipcode(), isNotNull);
      });
    });

    group('creditCardNumber', () {
      test('returns null for valid card number length', () {
        expect(const FormValidator('4111111111111111').creditCardNumber(), isNull);
        expect(const FormValidator('411111111111').creditCardNumber(), isNull);
      });

      test('returns error for wrong length', () {
        expect(const FormValidator('41111').creditCardNumber(), isNotNull);
        expect(const FormValidator('41111111111111111').creditCardNumber(), isNotNull);
      });
    });

    group('expDate', () {
      test('returns null for future card expiry', () {
        withClock(Clock.fixed(DateTime(2024)), () {
          expect(const FormValidator('12/25').expDate(), isNull);
          expect(const FormValidator('06/24').expDate(), isNull);
        });
      });

      test('returns error for expired card', () {
        withClock(Clock.fixed(DateTime(2024, 6)), () {
          expect(const FormValidator('05/24').expDate(), isNotNull);
          expect(const FormValidator('12/23').expDate(), isNotNull);
        });
      });

      test('returns error for invalid month', () {
        withClock(Clock.fixed(DateTime(2024)), () {
          expect(const FormValidator('13/25').expDate(), isNotNull);
          expect(const FormValidator('00/25').expDate(), isNotNull);
        });
      });

      test('returns error for null or wrong format', () {
        withClock(Clock.fixed(DateTime(2024)), () {
          expect(const FormValidator(null).expDate(), isNotNull);
          expect(const FormValidator('1225').expDate(), isNotNull);
          expect(const FormValidator('abc/de').expDate(), isNotNull);
        });
      });
    });

    group('expOnlyDay', () {
      test('returns null for day between 2 and 28', () {
        expect(const FormValidator('5').expOnlyDay(), isNull);
        expect(const FormValidator('28').expOnlyDay(), isNull);
      });

      test('returns error for day outside bounds', () {
        expect(const FormValidator('1').expOnlyDay(), isNotNull);
        expect(const FormValidator('29').expOnlyDay(), isNotNull);
      });

      test('returns null when empty and acceptEmpty is true', () {
        expect(const FormValidator('').expOnlyDay(acceptEmpty: true), isNull);
        expect(const FormValidator(null).expOnlyDay(acceptEmpty: true), isNull);
      });

      test('returns error for non-numeric value', () {
        expect(const FormValidator('abc').expOnlyDay(), isNotNull);
      });
    });

    group('amount', () {
      test('returns null for valid numeric amount string', () {
        expect(const FormValidator('100').amount(), isNull);
      });

      test('returns error for empty value', () {
        expect(const FormValidator('').amount(), isNotNull);
        expect(const FormValidator(null).amount(), isNotNull);
      });

      test('returns error for non-numeric value', () {
        expect(const FormValidator('abc').amount(), isNotNull);
      });
    });

    group('birthday (static)', () {
      test('returns null for valid birthday', () {
        withClock(Clock.fixed(DateTime(2025)), () {
          expect(FormValidator.birthday(DateTime(2000)), isNull);
          expect(FormValidator.birthday(DateTime(2022)), isNull);
        });
      });

      test('returns error for null birthday', () {
        expect(FormValidator.birthday(null), isNotNull);
      });

      test('returns error for birthday too recent (age <= 1)', () {
        withClock(Clock.fixed(DateTime(2025)), () {
          expect(FormValidator.birthday(DateTime(2024, 6)), isNotNull);
        });
      });

      test('returns error when under 18 and checkIs18yrs is true', () {
        withClock(Clock.fixed(DateTime(2025)), () {
          expect(
            FormValidator.birthday(DateTime(2010), checkIs18yrs: true),
            isNotNull,
          );
          expect(
            FormValidator.birthday(DateTime(2000), checkIs18yrs: true),
            isNull,
          );
        });
      });
    });

    group('birthdayFromString', () {
      test('returns null for valid date string', () {
        withClock(Clock.fixed(DateTime(2025)), () {
          expect(const FormValidator('15/06/2000').birthdayFromString(), isNull);
        });
      });

      test('returns error for null value', () {
        expect(const FormValidator(null).birthdayFromString(), isNotNull);
      });

      test('returns error for unparseable date string', () {
        withClock(Clock.fixed(DateTime(2025)), () {
          expect(const FormValidator('not-a-date').birthdayFromString(), isNotNull);
        });
      });

      test('returns error when under 18 and checkIs18yrs is true', () {
        withClock(Clock.fixed(DateTime(2025)), () {
          expect(
            const FormValidator('15/06/2010').birthdayFromString(checkIs18yrs: true),
            isNotNull,
          );
          expect(const FormValidator('15/06/2000').birthdayFromString(checkIs18yrs: true), isNull);
        });
      });
    });

    group('country', () {
      test('returns null for valid 2-letter country code', () {
        expect(const FormValidator('br').country(), isNull);
        expect(const FormValidator('us').country(), isNull);
      });

      test('returns error for null country', () {
        expect(const FormValidator(null).country(), isNotNull);
      });
    });

    group('validateChars', () {
      test('returns null within bounds', () {
        expect(const FormValidator('hello').validateChars(), isNull);
      });

      test('returns error when too short', () {
        expect(const FormValidator('ab').validateChars(), isNotNull);
      });

      test('returns error when too long', () {
        expect(
          const FormValidator(
            'aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeff',
          ).validateChars(),
          isNotNull,
        );
      });

      test('returns error for null', () {
        expect(const FormValidator(null).validateChars(), isNotNull);
      });

      test('uses custom fieldName in error message', () {
        final String? error = const FormValidator(null).validateChars(fieldName: 'Endereço');
        expect(error, contains('Endereço'));
      });
    });
  });
}
