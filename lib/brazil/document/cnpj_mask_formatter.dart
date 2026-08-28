import 'package:flutter/services.dart';
import 'package:mvl_app_core/brazil/document/cnpj_helper.dart';

class CnpjMaskFormatter extends TextInputFormatter {
  const CnpjMaskFormatter();

  static const maxLength = 14;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String raw = CNPJHelper.strip(newValue.text);
    if (raw.isEmpty) {
      return TextEditingValue.empty;
    }

    final String limited = raw.length > maxLength ? raw.substring(0, maxLength) : raw;
    final String formatted = format(limited);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String format(String raw) {
    final buffer = StringBuffer();

    for (var i = 0; i < raw.length; i++) {
      switch (i) {
        case 2:
        case 5:
          buffer.write('.');
        case 8:
          buffer.write('/');
        case 12:
          buffer.write('-');
      }
      buffer.write(raw[i]);
    }

    return buffer.toString();
  }
}
