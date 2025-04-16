import 'dart:math';

import 'package:diacritic/diacritic.dart';
import 'package:html/parser.dart';
import 'package:mvl_app_core/brazil/util_brasil_fields.dart';
import 'package:mvl_app_core/utils/validator_email.dart';
import 'package:remove_emoji/remove_emoji.dart';

extension StringExt on String {
  bool containsInsensitive(String term) => toLowerCase().contains(term.toLowerCase());

  int? toInt() => int.tryParse(replaceAll('.', '').replaceAll(',', ''));

  bool toBool() {
    return toLowerCase() == 'true' || this == '1';
  }

  String capitalizeFirstLetter() {
    final String first = this[0].toUpperCase();
    final String last = substring(1).toLowerCase();

    return '$first$last';
  }

  String capitalize({bool fullSentence = true}) {
    return fullSentence
        ? split(' ').map((e) => e.capitalizeFirstLetter()).join(' ')
        : capitalizeFirstLetter();
  }

  String onlyAlphanumerics([String replaceFor = '']) {
    return removeDiacritics(this).replaceAll(RegExp('[^A-Za-z0-9]'), replaceFor);
  }

  String removeAccentsAndEmojiWithTrim() => removeAccentsDiacritics().removeEmoji();

  String removeAccentsDiacritics() => removeDiacritics(this);
  String removeEmoji({String word = '', bool trimText = true}) =>
      RemoveEmoji().clean(this, word, trimText);

  String limit(int chars) => substring(0, min(chars, length)).trim();

  String cleanLimit(int chars) => removeAccentsAndEmojiWithTrim().limit(chars).trim();

  String removeHtml() {
    String text = replaceAll(RegExp(r'<(br|BR|Br|bR|h\d|p)\s?\/?>'), '\n');
    text = parseFragment(text).text ?? '';
    text = text.split('\n').map((e) => e.trim()).join('\n');

    if (text.startsWith('\n')) {
      text = text.substring(1);
    }
    if (text.endsWith('\n')) {
      text = text.substring(0, text.length - 1);
    }

    return text.trim();
  }

  String normalizeEmail() => EmailValidator(this).normalize();
}

extension StringNullableExt on String? {
  bool isReallyEmpty() {
    final value = this;
    if (value == null) {
      return true;
    }

    return value.trim().isEmpty;
  }

  int reallyLength() {
    final value = this;
    if (value == null) {
      return 0;
    }

    return value.trim().length;
  }

  int toAmount() => (moedaToDouble() * 100).toInt();

  double? toDouble() {
    final String? value = this?.replaceAll('.', '').replaceAll(',', '.');
    if (value == null) {
      return null;
    }

    return double.tryParse(value);
  }

  double moedaToDouble() {
    final value = this;
    if (value == null || value.isReallyEmpty()) {
      return 0;
    }

    return UtilBrasilFields.currencyToDouble(value);
  }

  String toPhoneServer() => reallyLength() == 0 ? '' : '+55${onlyNumbers()}';

  String toZipCodeFormatted() {
    final value = this;
    if (value == null) {
      return '';
    }

    return UtilBrasilFields.getCep(value);
  }

  String onlyNumbers() => this?.replaceAll(RegExp('[^0-9]+'), '') ?? '';
  int onlyNumbersLength() => onlyNumbers().reallyLength();
}
