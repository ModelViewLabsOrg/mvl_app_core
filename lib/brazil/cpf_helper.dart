//Credits: CPF/CNPJ Validators
//https://github.com/leonardocaldas/flutter-cpf-cnpj-validator

import 'dart:math';

import 'package:mvl_app_core/extensions/string_extension.dart';

class CPFHelper {
  CPFHelper(String cpf) : value = _strip(cpf);
  final String value;

  static const _blockList = <String>[
    '00000000000',
    '11111111111',
    '22222222222',
    '33333333333',
    '44444444444',
    '55555555555',
    '66666666666',
    '77777777777',
    '88888888888',
    '99999999999',
    '12345678909',
  ];

  static const _stipRegex = r'[^\d]';

  // Compute the Verifier Digit (or 'Dígito Verificador (DV)' in PT-BR).
  // You can learn more about the algorithm on [wikipedia (pt-br)](https://pt.wikipedia.org/wiki/D%C3%ADgito_verificador)
  int _verifierDigit(String cpf) {
    final List<int> numbers =
        cpf.split('').map((number) => int.parse(number, radix: 10)).toList();

    final int modulus = numbers.length + 1;

    final multiplied = <int>[];

    for (var i = 0; i < numbers.length; i++) {
      multiplied.add(numbers[i] * (modulus - i));
    }

    final int mod = multiplied.reduce((buffer, number) => buffer + number) % 11;

    return mod < 2 ? 0 : 11 - mod;
  }

  String format() {
    if (!isValid()) {
      return '';
    }
    final regExp = RegExp(r'^(\d{3})(\d{3})(\d{3})(\d{2})$');

    return _strip(value).replaceAllMapped(regExp, (m) => '${m[1]}.${m[2]}.${m[3]}-${m[4]}');
  }

  static String _strip(String? value) {
    final regExp = RegExp(_stipRegex);
    final String cpf = value ?? '';

    return cpf.replaceAll(regExp, '');
  }

  bool isValid() {
    final String cpf = _strip(value);

    // CPF must have 11 chars
    if (cpf.length != 11) {
      return false;
    }

    // CPF can't be blacklisted
    if (_blockList.contains(cpf)) {
      return false;
    }

    String numbers = cpf.limit(9);
    numbers += _verifierDigit(numbers).toString();
    numbers += _verifierDigit(numbers).toString();

    return numbers.substring(numbers.length - 2) == cpf.substring(cpf.length - 2);
  }

  static String generateRandom({bool useFormat = false}) {
    final helper = CPFHelper('');
    final numbers = StringBuffer();

    for (var i = 0; i < 9; i += 1) {
      numbers.write(Random().nextInt(9).toString());
    }

    numbers
      ..write(helper._verifierDigit(numbers.toString()).toString())
      ..write(helper._verifierDigit(numbers.toString()).toString());

    final value = numbers.toString();

    return useFormat ? CPFHelper(value).format() : value;
  }
}
