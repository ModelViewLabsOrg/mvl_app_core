import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/brazil/document/cpf_mask_formatter.dart';

void main() {
  const formatter = CpfMaskFormatter();

  TextEditingValue format(String text) {
    return formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: text),
    );
  }

  group('CpfMaskFormatter', () {
    test('formats CPF while typing', () {
      expect(format('12345678901').text, '123.456.789-01');
    });

    test('accepts pasted formatted CPF', () {
      expect(format('123.456.789-01').text, '123.456.789-01');
    });

    test('ignores letters', () {
      expect(format('123abc45678901').text, '123.456.789-01');
    });

    test('keeps the caret when editing in the middle', () {
      const value = TextEditingValue(
        text: '123.456.789-01',
        selection: TextSelection.collapsed(offset: 7),
      );

      final TextEditingValue actual = formatter.formatEditUpdate(TextEditingValue.empty, value);

      expect(actual.text, '123.456.789-01');
      expect(actual.selection.extentOffset, 7);
    });

    test('keeps the caret at the end of a pasted formatted CPF', () {
      const pasted = '123.456.789-01';
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
        text: '123',
        selection: TextSelection.collapsed(offset: 3),
        composing: TextRange(start: 1, end: 3),
      );

      expect(formatter.formatEditUpdate(TextEditingValue.empty, composing), composing);
    });
  });
}
