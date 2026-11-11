import 'package:flutter/services.dart';
import 'package:mvl_app_core/brazil/document/cnpj_helper.dart';
import 'package:mvl_app_core/brazil/document/mask_editing_value.dart';

class CnpjMaskFormatter extends TextInputFormatter {
  const CnpjMaskFormatter();

  static const maxLength = 14;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return formatMaskedValue(
      newValue: newValue,
      maxLength: maxLength,
      strip: CNPJHelper.strip,
      format: format,
      isUseful: _isAlphanumeric,
    );
  }

  static bool _isAlphanumeric(String char) {
    final int code = char.codeUnitAt(0);

    return (code >= 0x30 && code <= 0x39) ||
        (code >= 0x41 && code <= 0x5A) ||
        (code >= 0x61 && code <= 0x7A);
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
