import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/brazil/document/document.dart';
import 'package:mvl_app_core/brazil/pix.dart';
import 'package:mvl_app_core/extensions/date_time_ext.dart';
import 'package:mvl_app_core/utils/app_exception.dart';
import 'package:mvl_app_core/utils/validator.dart';

void main() {
  group('Validator', () {
    test('isPasswordValid requires at least 8 characters', () {
      expect(const Validator('1234567').isPasswordValid(), isFalse);
      expect(const Validator('12345678').isPasswordValid(), isTrue);
    });

    test('isCountryValid matches two consecutive lowercase letters', () {
      expect(const Validator('br').isCountryValid(), isTrue);
      expect(const Validator('BR').isCountryValid(), isFalse);
      expect(const Validator('bra').isCountryValid(), isTrue);
      expect(const Validator('123').isCountryValid(), isFalse);
    });

    test('isPhoneValid accepts 10 or 11 digits', () {
      expect(const Validator('3133334444').isPhoneValid(), isTrue);
      expect(const Validator('31998765432').isPhoneValid(), isTrue);
      expect(const Validator('31998').isPhoneValid(), isFalse);
    });

    test('isMobileValid requires mobile pattern', () {
      expect(const Validator('31998765432').isMobileValid(), isTrue);
      expect(const Validator('3133334444').isMobileValid(), isFalse);
    });

    test('isNameValid validates full name when required', () {
      expect(const Validator('João Silva').isNameValid(), isTrue);
      expect(const Validator('João').isNameValid(), isFalse);
      expect(const Validator('João Silva').isNameValid(fullName: false), isTrue);
    });

    test('isRandomPixKey validates UUID-like pix key', () {
      expect(
        const Pix('a1b2c3d4-e5f6-7890-abcd-ef1234567890').validate(PixKeyType.aleatorio),
        isTrue,
      );
      expect(const Pix('invalid-key').validate(PixKeyType.aleatorio), isFalse);
    });

    test('isBirthdayValid requires age greater than 1', () {
      final DateTime recent = DateTime.now().subtract(const Duration(days: 30));
      final DateTime oldEnough = DateTime.now().minus(years: 5);

      expect(const Validator('').isBirthdayValid(recent), isFalse);
      expect(const Validator('').isBirthdayValid(oldEnough), isTrue);
    });

    test('isCPFValid and isCNPJValid', () {
      expect(const Validator('52998224725').isCPFValid(), isTrue);
      expect(const Validator('12345678901').isCPFValid(), isFalse);
      expect(const Validator('11222333000181').isCNPJValid(), isTrue);
      expect(const Validator('12345678901234').isCNPJValid(), isFalse);
    });

    test('docType returns correct document type', () {
      expect(DocType.parseDoc('52998224725'), DocType.cpf);
      expect(DocType.parseDoc('11222333000181'), DocType.cnpj);
    });

    test('docType throws for invalid document', () {
      expect(
        () => DocType.parseDoc('invalid'),
        throwsA(isA<AppException>()),
      );
    });
  });
}
