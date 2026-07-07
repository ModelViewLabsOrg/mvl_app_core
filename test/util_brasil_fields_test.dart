import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/brazil/util_brasil_fields.dart';

void main() {
  group('UtilBrasilFields', () {
    group('removeCaracteres', () {
      test('removes non-alphanumeric characters', () {
        expect(UtilBrasilFields.removeCaracteres('abc-123'), 'abc123');
        expect(UtilBrasilFields.removeCaracteres('529.982.247-25'), '52998224725');
        expect(UtilBrasilFields.removeCaracteres('(11) 9999-8888'), '1199998888');
      });

      test('keeps alphanumeric chars', () {
        expect(UtilBrasilFields.removeCaracteres('ABC123'), 'ABC123');
      });
    });

    group('removeCurrencySymbol', () {
      test(r'removes R$ prefix', () {
        expect(UtilBrasilFields.removeCurrencySymbol(r'R$ 1.000,00'), '1.000,00');
      });

      test(r'leaves string unchanged if no R$ present', () {
        expect(UtilBrasilFields.removeCurrencySymbol('1000'), '1000');
      });
    });

    group('currencyToDouble', () {
      test(r'parses R$ currency string', () {
        expect(UtilBrasilFields.currencyToDouble(r'R$ 1.000,50'), 1000.5);
        expect(UtilBrasilFields.currencyToDouble(r'R$ 1,00'), 1.0);
      });

      test('parses plain decimal string', () {
        expect(UtilBrasilFields.currencyToDouble('1000'), 1000.0);
        expect(UtilBrasilFields.currencyToDouble('0'), 0.0);
      });

      test('returns 0 for invalid string', () {
        expect(UtilBrasilFields.currencyToDouble('abc'), 0.0);
      });
    });

    group('addSeparator', () {
      test('adds thousand separator dots', () {
        expect(UtilBrasilFields.addSeparator('1000'), '1.000');
        expect(UtilBrasilFields.addSeparator('1000000'), '1.000.000');
        expect(UtilBrasilFields.addSeparator('100'), '100');
        expect(UtilBrasilFields.addSeparator('1'), '1');
      });
    });

    group('getCep', () {
      test('formats CEP with dot (default)', () {
        expect(UtilBrasilFields.getCep('12345678'), '12.345-678');
      });

      test('formats CEP without dot', () {
        expect(UtilBrasilFields.getCep('12345678', dot: false), '12345-678');
      });
    });

    group('getPhone', () {
      test('formats 11-digit mobile number with DDD', () {
        expect(UtilBrasilFields.getPhone('11912345678'), '(11) 91234-5678');
      });

      test('formats 10-digit landline number with DDD', () {
        expect(UtilBrasilFields.getPhone('1133334444'), '(11) 3333-4444');
      });

      test('formats 9-digit mobile without DDD (ddd: false)', () {
        expect(UtilBrasilFields.getPhone('912345678', ddd: false), '91234-5678');
      });

      test('formats 8-digit landline without DDD (ddd: false)', () {
        expect(UtilBrasilFields.getPhone('33334444', ddd: false), '3333-4444');
      });

      test('returns only numbers when mask is false', () {
        expect(UtilBrasilFields.getPhone('1199998888', mask: false), '1199998888');
      });
    });

    group('getDDD', () {
      test('extracts DDD from 14-char formatted phone', () {
        expect(UtilBrasilFields.getDDD('(11) 3333-4444'), '11');
      });

      test('extracts DDD from 15-char formatted phone', () {
        expect(UtilBrasilFields.getDDD('(11) 91234-5678'), '11');
      });
    });

    group('formatCpf', () {
      test('returns formatted CPF for valid CPF', () {
        expect(UtilBrasilFields.formatCpf('52998224725'), '529.982.247-25');
      });
    });

    group('getCnpj', () {
      test('returns formatted CNPJ for valid CNPJ', () {
        expect(UtilBrasilFields.getCnpj('11222333000181'), '11.222.333/0001-81');
      });
    });

    group('doubleToCurrency', () {
      test(r'formats positive number with R$ prefix', () {
        expect(UtilBrasilFields.doubleToCurrency(1000), r'R$ 1.000,00');
        expect(UtilBrasilFields.doubleToCurrency(1.5), r'R$ 1,50');
        expect(UtilBrasilFields.doubleToCurrency(0), r'R$ 0,00');
      });

      test('formats negative number with minus sign', () {
        final String result = UtilBrasilFields.doubleToCurrency(-100);
        expect(result, contains('-'));
        expect(result, contains('100'));
      });

      test('formats without currency symbol when currency is false', () {
        expect(UtilBrasilFields.doubleToCurrency(1000, currency: false), '1.000,00');
      });

      test('respects custom decimal places', () {
        expect(UtilBrasilFields.doubleToCurrency(1.555, decimal: 1), r'R$ 1,6');
      });
    });
  });
}
