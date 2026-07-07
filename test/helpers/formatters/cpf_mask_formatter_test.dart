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
  });
}
