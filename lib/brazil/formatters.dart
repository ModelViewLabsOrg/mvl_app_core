import 'package:mvl_app_core/brazil/cnpj_helper.dart';
import 'package:mvl_app_core/brazil/cpf_helper.dart';
import 'package:mvl_app_core/brazil/util_brasil_fields.dart';
import 'package:mvl_app_core/extensions/string_extension.dart';
import 'package:mvl_app_core/utils/currency_helper.dart';

class Formatters {
  Formatters(this.value);
  final String value;

  String phoneWithoutDdi() => value.replaceAll('+55', '').onlyNumbers();

  String toPhoneFormatted() {
    final phone = phoneWithoutDdi();
    return (phone.length < 10 || phone.length > 12) ? value : UtilBrasilFields.getPhone(phone);
  }

  String toReaisFormatted() => CurrencyHelper.toCurrency(value.toAmount());

  String toDocumentFormatted() {
    final length = value.onlyNumbersLength();
    if (length == 11) return toCpfFormatted();
    if (length == 14) return toCnpjFormatted();

    return '';
  }

  String toCpfFormatted() {
    final helper = CPFHelper(value.trim());
    if (!helper.isValid()) return '';

    return helper.format();
  }

  String toCnpjFormatted() {
    final helper = CNPJHelper(value);
    if (!helper.isValid()) return '';

    return helper.format();
  }

  String toZipCodeFormatted() {
    final numbers = value.onlyNumbers();
    if (numbers.length != 8) return value;

    return '${numbers.substring(0, 2)}.'
        '${numbers.substring(2, 5)}-'
        '${numbers.substring(5)}';
  }

  String capitalizeFullName() {
    const exceptions = ['da', 'de', 'di', 'do', 'du', 'das', 'dos', 'e'];

    final split = value.toLowerCase().split(' ');
    var result = split.map((e) => exceptions.contains(e) ? e : e.capitalizeFirstLetter()).join(' ');

    if (result.contains("'")) {
      final index = result.indexOf("'");
      if (index > -1) {
        result =
            result.substring(0, index + 1) +
            result.substring(index + 1, index + 2).toUpperCase() +
            result.substring(index + 2);
      }
    }

    return result;
  }

  String normalizeRg() => value.onlyAlphanumerics().toUpperCase().replaceAll(' ', '');

  String normalizePassport() => value.onlyAlphanumerics().toUpperCase().replaceAll(' ', '');
}
