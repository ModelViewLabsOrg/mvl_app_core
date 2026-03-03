import 'package:mvl_app_core/brazil/cnpj_helper.dart';
import 'package:mvl_app_core/brazil/cpf_helper.dart';
import 'package:mvl_app_core/brazil/formatters.dart';
import 'package:mvl_app_core/mvl_app_core_view.dart';
import 'package:mvl_app_core/utils/validator.dart';

enum PixKeyType {
  cpf(serverValue: 'CPF', label: 'CPF'),
  cnpj(serverValue: 'CNPJ', label: 'CNPJ'),
  telefone(serverValue: 'TELEFONE', label: 'Telefone'),
  email(serverValue: 'EMAIL', label: 'E-mail'),
  aleatorio(serverValue: 'ALEATORIO', label: 'Chave Aleatória');

  const PixKeyType({required this.serverValue, required this.label});

  final String serverValue;
  final String label;
}

class Pix {
  const Pix(this.value);

  final String value;

  PixKeyType? get pixKeyType {
    if (value.isReallyEmpty()) {
      return null;
    }

    if (Validator(value).isCPFValid()) {
      return PixKeyType.cpf;
    }
    if (Validator(value).isCNPJValid()) {
      return PixKeyType.cnpj;
    }
    if (Validator(value).isPhoneValid()) {
      return PixKeyType.telefone;
    }
    if (EmailValidator(value).isValid()) {
      return PixKeyType.email;
    }
    if (Validator(value).isUUID()) {
      return PixKeyType.aleatorio;
    }

    return null;
  }

  PixKeyType get pixKeyTypeThrow => pixKeyType ?? (throw Exception('Invalid Pix Key Type'));

  bool get isValid => pixKeyType != null;

  bool get isCpf => pixKeyType == PixKeyType.cpf;
  bool get isCnpj => pixKeyType == PixKeyType.cnpj;
  bool get isTelefone => pixKeyType == PixKeyType.telefone;
  bool get isEmail => pixKeyType == PixKeyType.email;
  bool get isAleatorio => pixKeyType == PixKeyType.aleatorio;

  /// Retorna o valor limpo (sem pontuação) para CPF, CNPJ e Telefone.
  /// Para E-mail e Chave Aleatória, apenas remove espaços extras.
  String get sanitizedValue {
    if (value.isReallyEmpty()) {
      return '';
    }

    return switch (pixKeyType) {
      PixKeyType.cpf || PixKeyType.cnpj || PixKeyType.telefone => value.onlyNumbers(),
      PixKeyType.email => EmailValidator.normalize(value),
      PixKeyType.aleatorio => value.trim(),
      null => value,
    };
  }

  /// Retorna a chave formatada para exibição na UI (ex: 000.000.000-00)
  String get formattedValue {
    return switch (pixKeyType) {
      PixKeyType.cpf => CPFHelper(value).format(),
      PixKeyType.cnpj => CNPJHelper(value).format(),
      PixKeyType.telefone => Formatters(value).toPhoneFormatted(),
      PixKeyType.email => value.toLowerCase().trim(),
      PixKeyType.aleatorio => value.trim(),
      null => value,
    };
  }
}
