//Credits: CPF/CNPJ Validators
//https://github.com/leonardocaldas/flutter-cpf-cnpj-validator

import 'dart:math';

import 'package:mvl_app_core/brazil/document/document.dart';
import 'package:mvl_app_core/extensions/string_extension.dart';

const _blockList = [
  '00000000000000',
  '11111111111111',
  '22222222222222',
  '33333333333333',
  '44444444444444',
  '55555555555555',
  '66666666666666',
  '77777777777777',
  '88888888888888',
  '99999999999999',
];

class CNPJHelper extends DocHelper {
  CNPJHelper(String value) : super(strip(value));

  static const _stripRegex = '[^A-Z0-9]';

  int _charValue(String char) {
    return char.codeUnitAt(0) - 48;
  }

  // Compute the Verifier Digit (or 'Dígito Verificador (DV)' in PT-BR).
  // You can learn more about the algorithm on [wikipedia (pt-br)](https://pt.wikipedia.org/wiki/D%C3%ADgito_verificador)
  int _verifierDigit(String cnpj) {
    var index = 2;
    final List<int> reverse = cnpj.split('').map(_charValue).toList().reversed.toList();
    var sum = 0;

    for (final number in reverse) {
      sum += number * index;
      index = index == 9 ? 2 : index + 1;
    }
    final int mod = sum % 11;

    return mod < 2 ? 0 : 11 - mod;
  }

  @override
  String format() {
    if (!isValid()) {
      return '';
    }

    final regExp = RegExp(r'^([A-Z0-9]{2})([A-Z0-9]{3})([A-Z0-9]{3})([A-Z0-9]{4})(\d{2})$');

    return strip(value).replaceAllMapped(regExp, (m) => '${m[1]}.${m[2]}.${m[3]}/${m[4]}-${m[5]}');
  }

  static String strip(String value) {
    return value.toUpperCase().replaceAll(RegExp(_stripRegex), '').trim();
  }

  @override
  bool isValid() {
    final String cnpj = strip(value);

    // 12 alphanumeric chars + 2 numeric check digits
    if (cnpj.length != 14 || !RegExp(r'^\d{2}$').hasMatch(cnpj.substring(12))) {
      return false;
    }

    if (_blockList.contains(cnpj)) {
      return false;
    }

    String numbers = cnpj.limit(12);
    numbers += _verifierDigit(numbers).toString();
    numbers += _verifierDigit(numbers).toString();

    return numbers.substring(numbers.length - 2) == cnpj.substring(cnpj.length - 2);
  }

  static String generateRandom({bool useFormat = false, bool alphanumeric = false}) {
    final helper = CNPJHelper('');
    final random = Random();
    final body = StringBuffer();
    const alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    for (var i = 0; i < 12; i += 1) {
      if (alphanumeric) {
        body.write(alphabet[random.nextInt(alphabet.length)]);
      } else {
        body.write(random.nextInt(9).toString());
      }
    }

    body
      ..write(helper._verifierDigit(body.toString()).toString())
      ..write(helper._verifierDigit(body.toString()).toString());

    final value = body.toString();

    return useFormat ? CNPJHelper(value).format() : value;
  }

  @override
  DocType get docType => DocType.cnpj;
}
