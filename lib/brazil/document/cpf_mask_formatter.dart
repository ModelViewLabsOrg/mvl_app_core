import 'package:flutter/services.dart';
import 'package:mvl_app_core/brazil/document/cpf_helper.dart';
import 'package:mvl_app_core/brazil/document/mask_editing_value.dart';

class CpfMaskFormatter extends TextInputFormatter {
  const CpfMaskFormatter();

  static const maxLength = 11;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return formatMaskedValue(
      newValue: newValue,
      maxLength: maxLength,
      strip: CPFHelper.strip,
      format: format,
      isUseful: _isDigit,
    );
  }

  static bool _isDigit(String char) {
    final int code = char.codeUnitAt(0);

    return code >= 0x30 && code <= 0x39;
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
