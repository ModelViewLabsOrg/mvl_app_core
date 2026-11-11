import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/brazil/document/cnpj_mask_formatter.dart';

void main() {
  const formatter = CnpjMaskFormatter();

  TextEditingValue format(String text) {
    return formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: text),
    );
  }

  group('CnpjMaskFormatter', () {
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

    test('keeps the caret when editing in the middle', () {
      const value = TextEditingValue(
        text: 'AB.12C.345/01DE-53',
        selection: TextSelection.collapsed(offset: 6),
      );

      final TextEditingValue actual = formatter.formatEditUpdate(TextEditingValue.empty, value);

      expect(actual.text, 'AB.12C.345/01DE-53');
      expect(actual.selection.extentOffset, 6);
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
        text: 'ab1',
        selection: TextSelection.collapsed(offset: 3),
        composing: TextRange(start: 0, end: 3),
      );

      expect(formatter.formatEditUpdate(TextEditingValue.empty, composing), composing);
    });
  });
}
