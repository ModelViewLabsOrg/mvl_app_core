import 'package:flutter/services.dart';

/// Keeps the caret on the same useful character. An active IME composition is
/// left untouched so Android can finish the character before the mask runs.
TextEditingValue formatMaskedValue({
  required TextEditingValue newValue,
  required int maxLength,
  required String Function(String text) strip,
  required String Function(String raw) format,
  required bool Function(String char) isUseful,
}) {
  if (!newValue.composing.isCollapsed) {
    return newValue;
  }

  final String raw = strip(newValue.text);
  if (raw.isEmpty) {
    return TextEditingValue.empty;
  }

  final String limited = raw.length > maxLength ? raw.substring(0, maxLength) : raw;
  final String formatted = format(limited);
  final int sourceEnd = _sourceEnd(newValue);
  final int usefulBeforeCursor = _countUseful(newValue.text, sourceEnd, isUseful);
  final int kept = usefulBeforeCursor > limited.length ? limited.length : usefulBeforeCursor;

  return TextEditingValue(
    text: formatted,
    selection: TextSelection.collapsed(offset: _offsetAfterUseful(formatted, kept, isUseful)),
  );
}

int _sourceEnd(TextEditingValue value) {
  final int end = value.selection.end;
  if (end < 0 || end > value.text.length) {
    return value.text.length;
  }

  return end;
}

int _countUseful(String text, int end, bool Function(String char) isUseful) {
  var count = 0;
  for (var i = 0; i < end; i++) {
    if (isUseful(text[i])) {
      count++;
    }
  }

  return count;
}

int _offsetAfterUseful(String formatted, int usefulCount, bool Function(String char) isUseful) {
  if (usefulCount <= 0) {
    return 0;
  }

  var seen = 0;
  for (var i = 0; i < formatted.length; i++) {
    if (isUseful(formatted[i])) {
      seen++;
      if (seen == usefulCount) {
        return i + 1;
      }
    }
  }

  return formatted.length;
}
