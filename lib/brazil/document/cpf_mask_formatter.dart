import 'package:flutter/services.dart';
import 'package:mvl_app_core/extensions/string_extension.dart';

class CpfMaskFormatter extends TextInputFormatter {
  const CpfMaskFormatter();

  static const maxLength = 11;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String digits = newValue.text.onlyNumbers();
    if (digits.isEmpty) {
      return TextEditingValue.empty;
    }

    final String limited = digits.length > maxLength ? digits.substring(0, maxLength) : digits;
    final String formatted = format(limited);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String format(String digits) {
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      switch (i) {
        case 3:
        case 6:
          buffer.write('.');
        case 9:
          buffer.write('-');
      }
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }
}
