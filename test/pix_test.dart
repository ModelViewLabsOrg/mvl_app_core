import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/brazil/pix.dart';

const _validCpf = '52998224725';
const _validCnpj = '11222333000181';
const _validPhone = '11912345678';
const _validEmail = 'user@example.com';
const _validUuid = '550e8400-e29b-41d4-a716-446655440000';

void main() {
  group('PixKeyType', () {
    test('has expected serverValue and label', () {
      expect(PixKeyType.cpf.serverValue, 'CPF');
      expect(PixKeyType.cnpj.serverValue, 'CNPJ');
      expect(PixKeyType.telefone.serverValue, 'TELEFONE');
      expect(PixKeyType.email.serverValue, 'EMAIL');
      expect(PixKeyType.aleatorio.serverValue, 'ALEATORIO');
    });
  });

  group('PixKeyTypeExt', () {
    test('isCpf', () {
      expect(PixKeyType.cpf.isCpf, isTrue);
      expect(PixKeyType.cnpj.isCpf, isFalse);
    });

    test('isCnpj', () {
      expect(PixKeyType.cnpj.isCnpj, isTrue);
      expect(PixKeyType.cpf.isCnpj, isFalse);
    });

    test('isTelefone', () {
      expect(PixKeyType.telefone.isTelefone, isTrue);
      expect(PixKeyType.email.isTelefone, isFalse);
    });

    test('isEmail', () {
      expect(PixKeyType.email.isEmail, isTrue);
      expect(PixKeyType.cpf.isEmail, isFalse);
    });

    test('isAleatorio', () {
      expect(PixKeyType.aleatorio.isAleatorio, isTrue);
      expect(PixKeyType.cpf.isAleatorio, isFalse);
    });

    test('isDoc is true for cpf and cnpj only', () {
      expect(PixKeyType.cpf.isDoc, isTrue);
      expect(PixKeyType.cnpj.isDoc, isTrue);
      expect(PixKeyType.telefone.isDoc, isFalse);
      expect(PixKeyType.email.isDoc, isFalse);
      expect(PixKeyType.aleatorio.isDoc, isFalse);
    });
  });

  group('Pix', () {
    group('validate', () {
      test('validates CPF pix key', () {
        expect(const Pix(_validCpf).validate(PixKeyType.cpf), isTrue);
        expect(const Pix('00000000000').validate(PixKeyType.cpf), isFalse);
      });

      test('validates CNPJ pix key', () {
        expect(const Pix(_validCnpj).validate(PixKeyType.cnpj), isTrue);
        expect(const Pix('00000000000000').validate(PixKeyType.cnpj), isFalse);
      });

      test('validates phone pix key', () {
        expect(const Pix(_validPhone).validate(PixKeyType.telefone), isTrue);
        expect(const Pix('123').validate(PixKeyType.telefone), isFalse);
      });

      test('validates email pix key', () {
        expect(const Pix(_validEmail).validate(PixKeyType.email), isTrue);
        expect(const Pix('notanemail').validate(PixKeyType.email), isFalse);
      });

      test('validates UUID pix key', () {
        expect(const Pix(_validUuid).validate(PixKeyType.aleatorio), isTrue);
        expect(const Pix('not-a-uuid').validate(PixKeyType.aleatorio), isFalse);
      });
    });

    group('pixKeyType', () {
      test('detects CPF', () {
        expect(const Pix(_validCpf).pixKeyType, PixKeyType.cpf);
      });

      test('detects CNPJ', () {
        expect(const Pix(_validCnpj).pixKeyType, PixKeyType.cnpj);
      });

      test('detects phone', () {
        expect(const Pix(_validPhone).pixKeyType, PixKeyType.telefone);
      });

      test('detects email', () {
        expect(const Pix(_validEmail).pixKeyType, PixKeyType.email);
      });

      test('detects UUID as aleatorio', () {
        expect(const Pix(_validUuid).pixKeyType, PixKeyType.aleatorio);
      });

      test('returns null for empty string', () {
        expect(const Pix('').pixKeyType, isNull);
      });

      test('returns null for unrecognized value', () {
        expect(const Pix('not-any-valid-key').pixKeyType, isNull);
      });
    });

    group('isValid', () {
      test('returns true for valid pix keys', () {
        expect(const Pix(_validCpf).isValid, isTrue);
        expect(const Pix(_validCnpj).isValid, isTrue);
        expect(const Pix(_validPhone).isValid, isTrue);
        expect(const Pix(_validEmail).isValid, isTrue);
        expect(const Pix(_validUuid).isValid, isTrue);
      });

      test('returns false for invalid values', () {
        expect(const Pix('').isValid, isFalse);
        expect(const Pix('invalid').isValid, isFalse);
      });
    });

    group('pixKeyTypeThrow', () {
      test('returns key type for valid key', () {
        expect(const Pix(_validCpf).pixKeyTypeThrow, PixKeyType.cpf);
      });

      test('throws for invalid key', () {
        expect(() => const Pix('invalid').pixKeyTypeThrow, throwsException);
      });
    });

    group('convenience booleans', () {
      test('isCpf', () {
        expect(const Pix(_validCpf).isCpf, isTrue);
        expect(const Pix(_validCnpj).isCpf, isFalse);
      });

      test('isCnpj', () {
        expect(const Pix(_validCnpj).isCnpj, isTrue);
        expect(const Pix(_validCpf).isCnpj, isFalse);
      });

      test('isTelefone', () {
        expect(const Pix(_validPhone).isTelefone, isTrue);
      });

      test('isEmail', () {
        expect(const Pix(_validEmail).isEmail, isTrue);
      });

      test('isAleatorio', () {
        expect(const Pix(_validUuid).isAleatorio, isTrue);
      });
    });

    group('sanitizedValue', () {
      test('returns only digits for CPF', () {
        expect(const Pix('529.982.247-25').sanitizedValue, '52998224725');
      });

      test('returns only digits for CNPJ', () {
        expect(const Pix('11.222.333/0001-81').sanitizedValue, '11222333000181');
      });

      test('returns only digits for phone', () {
        expect(const Pix('(11) 91234-5678').sanitizedValue, '11912345678');
      });

      test('returns normalized email', () {
        expect(const Pix('  User@Example.COM  ').sanitizedValue, 'user@example.com');
      });

      test('returns UUID as-is for valid UUID key', () {
        expect(const Pix(_validUuid).sanitizedValue, _validUuid);
      });

      test('returns empty string for empty input', () {
        expect(const Pix('').sanitizedValue, '');
      });
    });

    group('formattedValue', () {
      test('formats CPF', () {
        expect(const Pix(_validCpf).formattedValue, '529.982.247-25');
      });

      test('formats CNPJ', () {
        expect(const Pix(_validCnpj).formattedValue, '11.222.333/0001-81');
      });

      test('formats phone', () {
        expect(const Pix(_validPhone).formattedValue, '(11) 91234-5678');
      });

      test('formats email as lowercase trimmed', () {
        expect(const Pix('  User@Example.COM  ').formattedValue, 'user@example.com');
      });

      test('returns UUID as-is for valid UUID key', () {
        expect(const Pix(_validUuid).formattedValue, _validUuid);
      });
    });
  });
}
