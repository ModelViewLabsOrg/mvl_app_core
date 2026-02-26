import 'package:mvl_app_core/brazil/cnpj_helper.dart';
import 'package:mvl_app_core/brazil/cpf_helper.dart';
import 'package:mvl_app_core/extensions/date_time_ext.dart';
import 'package:mvl_app_core/extensions/string_extension.dart';
import 'package:mvl_app_core/utils/validator_form.dart';

const pswMinLength = 8;
const pswMaxLength = 30;

class Validator {
  const Validator(this.value);
  final String value;

  bool isPasswordValid({
    int minLength = pswMinLength,
    int maxLength = pswMaxLength,
  }) => value.length >= minLength && value.length < maxLength;

  bool isAddressValid() => value.reallyLength() > 3;

  bool isCountryValid() => RegExp('[a-z]{2}').hasMatch(value);

  bool isPhoneValid() {
    final int length = value.onlyNumbersLength();

    return length == 10 || length == 11;
  }

  bool isMobileValid() => value.onlyNumbersLength() == 11;

  bool isNameValid({bool fullName = true}) {
    final String name = value;
    if (name.length < FormValidator.nameMinChars || name.length > FormValidator.nameMaxChars) {
      return false;
    }

    if (fullName) {
      return RegExp(r'(\S{2,}\s)+\S{1,}').hasMatch(name);
    }

    return true;
  }

  bool isBirthdayValid(DateTime value) {
    return value.age() > 1;
  }

  bool isCPFValid() => CPFHelper(value).isValid();

  bool isCNPJValid() => CNPJHelper(value).isValid();
}
