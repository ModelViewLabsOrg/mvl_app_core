import 'package:flutter_test/flutter_test.dart';

void main() {
  const formatter = CpfOuCnpjInputFormatter();

  TextEditingValue format(String text) {
    return formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: text),
    );
  }

  group('CpfOrCnpjInputFormatter', () {
    test('formats numeric CPF while typing', () {
      expect(format('12345678901').text, '123.456.789-01');
    });

    test('formats numeric CNPJ while typing', () {
      expect(format('11222333000181').text, '11.222.333/0001-81');
    });

    test('formats alphanumeric CNPJ while typing', () {
      expect(format('AB12C34501DE53').text, 'AB.12C.345/01DE-53');
    });

    test('accepts pasted formatted alphanumeric CNPJ', () {
      expect(format('AB.12C.345/01DE-53').text, 'AB.12C.345/01DE-53');
    });

    test('uppercases letters', () {
      expect(format('ab12c34501de53').text, 'AB.12C.345/01DE-53');
    });
  });
}
