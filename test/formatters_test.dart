import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/brazil/formatters.dart';

void main() {
  group('Formatters', () {
    group('toPhoneFormatted', () {
      test('formats 11-digit mobile number', () {
        expect(Formatters('11912345678').toPhoneFormatted(), '(11) 91234-5678');
      });

      test('formats 10-digit landline number', () {
        expect(Formatters('1133334444').toPhoneFormatted(), '(11) 3333-4444');
      });

      test('strips +55 DDI before formatting', () {
        expect(Formatters('+5511912345678').toPhoneFormatted(), '(11) 91234-5678');
      });

      test('returns value unchanged when fewer than 10 digits', () {
        expect(Formatters('9999').toPhoneFormatted(), '9999');
      });
    });

    group('toDocumentFormatted', () {
      test('formats valid 11-digit string as CPF', () {
        expect(Formatters('52998224725').toDocumentFormatted(), '529.982.247-25');
      });

      test('formats valid 14-digit string as CNPJ', () {
        expect(Formatters('11222333000181').toDocumentFormatted(), '11.222.333/0001-81');
      });

      test('formats alphanumeric CNPJ', () {
        expect(Formatters('12ABC34501DE35').toDocumentFormatted(), '12.ABC.345/01DE-35');
        expect(Formatters('12.abc.345/01de-35').toDocumentFormatted(), '12.ABC.345/01DE-35');
      });

      test('returns empty for wrong length', () {
        expect(Formatters('12345').toDocumentFormatted(), '');
      });
    });

    group('toCpfFormatted', () {
      test('returns formatted CPF for valid CPF', () {
        expect(Formatters('52998224725').toCpfFormatted(), '529.982.247-25');
      });

      test('returns empty string for invalid CPF', () {
        expect(Formatters('00000000000').toCpfFormatted(), '');
        expect(Formatters('12345').toCpfFormatted(), '');
      });
    });

    group('toCnpjFormatted', () {
      test('returns formatted CNPJ for valid CNPJ', () {
        expect(Formatters('11222333000181').toCnpjFormatted(), '11.222.333/0001-81');
      });

      test('returns empty string for invalid CNPJ', () {
        expect(Formatters('00000000000000').toCnpjFormatted(), '');
        expect(Formatters('123').toCnpjFormatted(), '');
      });

      test('returns formatted alphanumeric CNPJ', () {
        expect(Formatters('12ABC34501DE35').toCnpjFormatted(), '12.ABC.345/01DE-35');
      });
    });

    group('toZipCodeFormatted', () {
      test('formats 8-digit zip code', () {
        expect(Formatters('12345678').toZipCodeFormatted(), '12.345-678');
      });

      test('returns value unchanged when not 8 digits', () {
        expect(Formatters('1234567').toZipCodeFormatted(), '1234567');
        expect(Formatters('123456789').toZipCodeFormatted(), '123456789');
      });
    });

    group('capitalizeFullName', () {
      test('capitalizes first letter of each word', () {
        expect(Formatters('gabriel rozendo').capitalizeFullName(), 'Gabriel Rozendo');
      });

      test('keeps exception words lowercase', () {
        expect(Formatters('gabriel de oliveira').capitalizeFullName(), 'Gabriel de Oliveira');
        expect(Formatters('ana das dores').capitalizeFullName(), 'Ana das Dores');
      });

      test('handles names with apostrophe', () {
        final String result = Formatters("d'avila").capitalizeFullName();
        expect(result, "D'Avila");
      });

      test('handles already uppercase name', () {
        expect(Formatters('GABRIEL ROZENDO').capitalizeFullName(), 'Gabriel Rozendo');
      });
    });

    group('normalizeRg', () {
      test('removes non-alphanumeric characters and uppercases', () {
        expect(Formatters('12.345.678-9').normalizeRg(), '123456789');
        expect(Formatters('ab-123').normalizeRg(), 'AB123');
      });
    });

    group('normalizePassport', () {
      test('removes non-alphanumeric characters and uppercases', () {
        expect(Formatters('ab-123456').normalizePassport(), 'AB123456');
        expect(Formatters('YB123456').normalizePassport(), 'YB123456');
      });
    });
  });
}
