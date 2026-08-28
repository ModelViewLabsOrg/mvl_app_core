import 'package:flutter/services.dart';
import 'package:mvl_app_core/brazil/document/cnpj_helper.dart';
import 'package:mvl_app_core/brazil/document/cnpj_mask_formatter.dart';
import 'package:mvl_app_core/brazil/document/cpf_mask_formatter.dart';

/// Escolhe entre [CpfMaskFormatter] e [CnpjMaskFormatter] conforme o input.
class CpfOuCnpjInputFormatter extends TextInputFormatter {
  const CpfOuCnpjInputFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String stripped = CNPJHelper.strip(newValue.text);
    if (stripped.isEmpty) {
      return TextEditingValue.empty;
    }

    if (_isCpfInput(stripped)) {
      return const CpfMaskFormatter().formatEditUpdate(
        oldValue,
        TextEditingValue(text: stripped),
      );
    }

    return const CnpjMaskFormatter().formatEditUpdate(
      oldValue,
      TextEditingValue(text: stripped),
    );
  }

  static bool _isCpfInput(String raw) {
    return raw.length <= CpfMaskFormatter.maxLength && RegExp(r'^\d+$').hasMatch(raw);
  }
}
