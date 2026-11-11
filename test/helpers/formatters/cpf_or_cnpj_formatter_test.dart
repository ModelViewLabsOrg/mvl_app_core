import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/brazil/document/cpf_or_cnpj_formatter.dart';

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

    test('keeps the caret while the value is still a CPF', () {
      const value = TextEditingValue(
        text: '123.456.789-01',
        selection: TextSelection.collapsed(offset: 7),
      );

      final TextEditingValue actual = formatter.formatEditUpdate(TextEditingValue.empty, value);

      expect(actual.text, '123.456.789-01');
      expect(actual.selection.extentOffset, 7);
    });

    test('keeps the caret when a letter switches the mask to CNPJ', () {
      const value = TextEditingValue(
        text: '123A',
        selection: TextSelection.collapsed(offset: 3),
      );

      final TextEditingValue actual = formatter.formatEditUpdate(TextEditingValue.empty, value);

      expect(actual.text, '12.3A');
      expect(actual.selection.extentOffset, 4);
    });

    test('keeps the caret at the end of a pasted formatted CNPJ', () {
      const pasted = 'AB.12C.345/01DE-53';
      final TextEditingValue actual = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: pasted,
          selection: TextSelection.collapsed(offset: pasted.length),
        ),
      );

      expect(actual.text, pasted);
      expect(actual.selection.extentOffset, actual.text.length);
    });

    test('leaves an active composition unchanged', () {
      const composing = TextEditingValue(
        text: '123a',
        selection: TextSelection.collapsed(offset: 4),
        composing: TextRange(start: 3, end: 4),
      );

      expect(formatter.formatEditUpdate(TextEditingValue.empty, composing), composing);
    });
  });
}
