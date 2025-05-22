//Credits: CPF/CNPJ Validators
//https://github.com/leonardocaldas/flutter-cpf-cnpj-validator

import 'dart:math';

import 'package:mvl_app_core/extensions/string_extension.dart';

class CNPJHelper {
  CNPJHelper(String cnpj) : value = _strip(cnpj);
  final String value;

  static const _stipRegex = r'[^\d]';

  static const _blockList = <String>[
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

  // Compute the Verifier Digit (or 'Dígito Verificador (DV)' in PT-BR).
  // You can learn more about the algorithm on [wikipedia (pt-br)](https://pt.wikipedia.org/wiki/D%C3%ADgito_verificador)
  int _verifierDigit(String cnpj) {
    var index = 2;
    final List<int> reverse = cnpj.split('').map(int.parse).toList().reversed.toList();
    var sum = 0;

    for (final number in reverse) {
      sum += number * index;
      index = index == 9 ? 2 : index + 1;
    }
    final int mod = sum % 11;

    return mod < 2 ? 0 : 11 - mod;
  }

  String format() {
    if (!isValid()) {
      return '';
    }

    final regExp = RegExp(r'^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})$');

    return _strip(value).replaceAllMapped(regExp, (m) => '${m[1]}.${m[2]}.${m[3]}/${m[4]}-${m[5]}');
  }

  static String _strip(String? value) {
    final regex = RegExp(_stipRegex);
    final String cnpj = value ?? '';

    return cnpj.replaceAll(regex, '');
  }

  bool isValid() {
    final String cnpj = _strip(value);

    // cnpj must have 14 chars
    if (cnpj.length != 14) {
      return false;
    }

    // cnpj can't be blacklisted
    if (_blockList.contains(cnpj)) {
      return false;
    }

    String numbers = cnpj.limit(12);
    numbers += _verifierDigit(numbers).toString();
    numbers += _verifierDigit(numbers).toString();

    return numbers.substring(numbers.length - 2) == cnpj.substring(cnpj.length - 2);
  }

  static String generateRandom({bool useFormat = false}) {
    final helper = CNPJHelper('');
    final numbers = StringBuffer();

    for (var i = 0; i < 12; i += 1) {
      numbers.write(Random().nextInt(9).toString());
    }

    numbers
      ..write(helper._verifierDigit(numbers.toString()).toString())
      ..write(helper._verifierDigit(numbers.toString()).toString());

    final value = numbers.toString();

    return useFormat ? CNPJHelper(value).format() : value;
  }
}
