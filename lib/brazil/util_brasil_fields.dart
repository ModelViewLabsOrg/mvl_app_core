import 'package:mvl_app_core/brazil/cnpj_helper.dart';
import 'package:mvl_app_core/brazil/cpf_helper.dart';

mixin UtilBrasilFields {
  static String removeCaracteres(String value) {
    assert(value.isNotEmpty, '');

    return value.replaceAll(RegExp('[^0-9a-zA-Z]+'), '');
  }

  static String removeCurrencySymbol(String value) {
    assert(value.isNotEmpty, '');

    return value.replaceAll(r'R$ ', '');
  }

  static double currencyToDouble(String value) {
    assert(value.isNotEmpty, '');
    final doubleValue = double.tryParse(value.replaceAll(r'R$ ', '').replaceAll('.', '').replaceAll(',', '.'));

    return doubleValue ?? 0;
  }

  static String addSeparator(String value) {
    var valueFinal = '';
    var pointCount = 0;
    for (var i = value.length - 1; i > -1; i--) {
      if (pointCount == 3) {
        valueFinal = '.$valueFinal';
        pointCount = 0;
      }
      pointCount = pointCount + 1;
      valueFinal = value[i] + valueFinal;
    }

    return valueFinal;
  }

  /// Retorna o CNPJ informado, utilizando a máscara: `XX.YYY-ZZZ`
  ///
  /// Para remover o `.`, informe `ponto=false`.
  static String getCep(String cep, {bool dot = true}) {
    assert(cep.length == 8, 'CEP com tamanho inválido. Deve conter 8 caracteres');

    return dot
        ? '${cep.substring(0, 2)}.${cep.substring(2, 5)}-${cep.substring(5, 8)}'
        : '${cep.substring(0, 2)}${cep.substring(2, 5)}-${cep.substring(5, 8)}';
  }

  /// Retorna o phone informado, utilizando a máscara: `(00) 11111-2222`
  ///
  /// Ajusta-se automaticamente para celular e fixo.
  ///
  /// Para retornar apenas os números, informe `mascara=false`.
  static String getPhone(String phone, {bool ddd = true, bool mask = true}) {
    assert(phone.length <= 15, 'phone com tamanho inválido. Deve conter 10 ou 11 caracteres');
    if (!mask) return removeCaracteres(phone);

    if (ddd) {
      assert(phone.length == 10 || phone.length == 11, 'phone com tamanho inválido. Deve conter 10 ou 11 caracteres');

      final prefix = '(${phone.substring(0, 2)}) ';
      final pad = phone.length == 10 ? 0 : 1;

      return '$prefix'
          '${phone.substring(2, 6 + pad)}-'
          '${phone.substring(6 + pad, 10 + pad)}';
    } else {
      assert(phone.length == 8 || phone.length == 9, 'phone com tamanho inválido. Deve conter 8 ou 9 caracteres');

      return (phone.length == 8)
          ? '${phone.substring(0, 4)}-${phone.substring(4, 8)}'
          : '${phone.substring(0, 5)}-${phone.substring(5, 9)}';
    }
  }

  static String getDDD(String phone) {
    assert(phone.length == 14 || phone.length == 15, 'phone com tamanho inválido. Deve conter 14 ou 15 caracteres');

    return phone.substring(1, 3);
  }

  // ///Faz a validação do CPF retornando `[true]` ou `[false]`
  // static bool isCPFValido(String? cpf) =>
  //     cpf != null && CPFHelper(cpf).isValid();

  // ///Faz a validação do CNPJ retornando `[true]` ou `[false]`
  // static bool isCNPJValido(String? cnpj) =>
  //     cnpj != null && CNPJHelper(cnpj).isValid();

  // ///Gera um CPF aleatório
  // static String gerarCPF({bool useFormat = false}) =>
  //     CPFHelper.generate(useFormat: useFormat);

  // ///Gera um CNPJ aleatório
  // static String gerarCNPJ({bool useFormat = false}) =>
  //     CNPJHelper.generate(useFormat: useFormat);

  /// Retorna o CPF utilizando a máscara: `XXX.YYY.ZZZ-NN`
  static String formatCpf(String cpf) {
    final helper = CPFHelper(cpf);
    assert(helper.isValid(), 'CPF inválido!');

    return helper.format();
  }

  /// Retorna o CNPJ informado, utilizando a máscara: `XX.YYY.ZZZ/NNNN-SS`
  static String getCnpj(String cnpj) {
    final helper = CNPJHelper(cnpj);
    assert(helper.isValid(), 'CNPJ inválido!');

    return helper.format();
  }

  /// Retorna o número real informado, utilizando a máscara:
  /// `R$ 50.000,00` ou `50.000,00`
  static String doubleToCurrency(double number, {bool currency = true, int decimal = 2}) {
    var isNegative = false;

    final double value;
    if (number.isNegative) {
      isNegative = true;
      value = number * (-1);
    } else {
      value = number;
    }

    final fixed = value.toStringAsFixed(decimal);
    final separatedValues = fixed.split('.');

    separatedValues[0] = addSeparator(separatedValues[0]);
    var formatted = separatedValues.join(',');

    if (isNegative) {
      formatted = '-$formatted';
    }

    return '${currency ? r'R$ ' : ''}$formatted';
  }
}
