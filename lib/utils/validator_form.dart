import 'package:jiffy/jiffy.dart';
import 'package:mvl_app_core/extensions/date_time_ext.dart';
import 'package:mvl_app_core/extensions/date_time_ext_extras.dart';
import 'package:mvl_app_core/extensions/string_extension.dart';
import 'package:mvl_app_core/utils/validator.dart';
import 'package:mvl_app_core/utils/validator_email.dart';

class FormValidator {
  const FormValidator(this.value);

  final String? value;
  static const nameMinChars = 3;
  static const nameMaxChars = 50;
  static const nameModalityMaxChars = 30;
  static const nameEventMaxChars = 30;
  static const nameChargeMaxChars = 30;
  static const nicknameMaxChars = 20;

  String? email() => EmailValidator(value).isValid() ? null : 'E-mail inválido';

  String? password({int minLength = pswMinLength, int maxLength = pswMaxLength}) {
    final String? value = this.value;
    if (value == null) {
      return 'Senha inválida. Pelo menos 8 caracteres';
    }

    return Validator(value).isPasswordValid(minLength: minLength, maxLength: maxLength);
  }

  String? confirmPassword(String? confirmation) {
    return value == confirmation ? null : 'Senha e confirmação não estão iguais';
  }

  String? phone() {
    final String? value = this.value;
    if (value == null || !Validator(value).isPhoneValid()) {
      return 'Telefone inválido';
    }

    return null;
  }

  String? expDate() {
    const error = 'Data inválida';

    try {
      final String? value = this.value;
      if (value == null) {
        return error;
      }

      final List<String> split = value.split('/');
      if (split.length != 2) {
        return error;
      }
      if (split.first.length != 2 || split.last.length != 2) {
        return error;
      }

      final int year = int.parse(split.last) + 2000;

      final int diff = DateTime(year).differenceInYearsFromToday().abs();
      if (diff > 50) {
        return error;
      }

      final int month = int.parse(split.first);
      if (month < 1 || month > 12) {
        return error;
      }

      final DateTime date = Jiffy.parseFromDateTime(
        DateTime(year, month),
      ).endOf(Unit.month).toLocal().dateTime;

      if (!date.isFuture()) {
        return 'A data não pode ser no passado';
      }

      return null;
    } catch (_) {
      return error;
    }
  }

  String? creditCardNumber() {
    final int length = value.onlyNumbersLength();
    if (length < 12 || length > 16) {
      return 'Número inválido';
    }

    return null;
  }

  String? expOnlyDay({bool acceptEmpty = false}) {
    final String? value = this.value;

    if (acceptEmpty && (value == null || value.isReallyEmpty())) {
      return null;
    }

    if (value == null) {
      return 'Dia inválido';
    }

    final int? day = int.tryParse(value);
    if (day == null) {
      return 'Dia inválido';
    }

    if (day < 2 || day > 28) {
      return 'Dia deve estar entre 2 e 28';
    }

    return null;
  }

  String? country() {
    final String? value = this.value;
    if (value == null || !Validator(value).isCountryValid()) {
      return 'País inválido';
    }

    return null;
  }

  String? mobile() {
    final String? value = this.value;
    if (value == null || !Validator(value).isMobileValid()) {
      return 'Celular inválido';
    }

    return null;
  }

  String? name([int minChars = nameMinChars, int maxChars = nameMaxChars]) {
    return validateChars(fieldName: 'Nome', minChars: minChars, maxChars: maxChars);
  }

  String? validateChars({
    String? fieldName,
    int minChars = nameMinChars,
    int maxChars = nameMaxChars,
  }) {
    final String? value = this.value?.trim();
    if (value == null) {
      return '${fieldName ?? 'Campo'} inválido';
    }

    if (value.length < minChars) {
      final plural = minChars == 1 ? '' : 'es';

      return 'No mínimo $minChars caracter$plural';
    }
    if (value.length > maxChars) {
      final plural = minChars == 1 ? '' : 'es';

      return 'No máximo $maxChars caracter$plural';
    }

    return null;
  }

  String? fullName() {
    final String? value = this.value;
    if (value == null || !Validator(value).isNameValid()) {
      return 'Nome completo inválido';
    }

    return null;
  }

  String? nickname() {
    if ((value?.length ?? 0) > nicknameMaxChars) {
      return 'Apelido muito grande';
    }

    return null;
  }

  static const birthDayError = 'Data de nascimento inválida';

  static String? birthday(DateTime? value, {bool checkIs18yrs = false}) {
    if (value == null) {
      return birthDayError;
    }
    final bool isValid = const Validator('').isBirthdayValid(value);
    if (!isValid) {
      return birthDayError;
    }

    if (checkIs18yrs) {
      if (!value.is18yrs()) {
        return 'Idade menor de 18 anos';
      }
    }

    return null;
  }

  String? birthdayFromString({bool checkIs18yrs = false}) {
    final String? value = this.value;
    if (value == null) {
      return birthDayError;
    }

    final DateTime? date = value.parseBrFormat('/');

    return birthday(date, checkIs18yrs: checkIs18yrs);
  }

  String? cpfOrCnpj() {
    final String? value = this.value;
    if (value == null || value.length < 14) {
      return 'Documento inválido';
    }

    return value.length == 14 ? cpf() : cnpj();
  }

  String? cpf() {
    final String value = this.value.onlyNumbers();

    return Validator(value).isCPFValid() ? null : 'CPF inválido';
  }

  String? cnpj() {
    final String? value = this.value;
    if (value == null || !Validator(value).isCNPJValid()) {
      return 'CNPJ inválido';
    }

    return null;
  }

  String? rg() {
    final String? value = this.value;
    if (value == null || value.length < 5) {
      return 'RG inválido';
    }

    return null;
  }

  String? passport() {
    final String? value = this.value;
    if (value == null || value.length < 5) {
      return 'Passaporte inválido';
    }

    return null;
  }

  String? inviteCode() {
    final int length = value?.length ?? 0;

    if (length != 6) {
      return 'O código deve ser de 6 dígitos';
    }

    return null;
  }

  String? otp() {
    final String? value = this.value;
    if (value == null) {
      return 'Código inválido';
    }

    if (RegExp(r'\d{6}').hasMatch(value)) {
      return null;
    }

    return 'O código deve ser de 6 dígitos';
  }

  String? cvv() {
    final String? value = this.value;
    if (value == null) {
      return 'CVV inválido';
    }

    if (RegExp(r'\d{3,4}').hasMatch(value)) {
      return null;
    }

    return 'O CVV deve ser de 3 ou 4 dígitos';
  }

  String? zipcode() {
    final String? value = this.value;
    if (value == null) {
      return 'Cep inválido';
    }

    if (RegExp(r'\d{2}\.\d{3}-\d{3}').hasMatch(value)) {
      return null;
    }

    return 'Cep inválido';
  }

  String? amount({int minAmount = 0, int? maxAmount}) {
    final String? value = this.value;

    if (value == null || !Validator(value).isAmountValid(minAmount, maxAmount)) {
      return 'Valor inválido';
    }

    return null;
  }
}
