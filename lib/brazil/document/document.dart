import 'package:mvl_app_core/brazil/formatters.dart';
import 'package:mvl_app_core/extensions/string_extension.dart';
import 'package:mvl_app_core/utils/app_exception.dart';
import 'package:mvl_app_core/utils/validator.dart';

enum DocType {
  cpf,
  cnpj,
  ;

  static DocType parseDoc(String rawValue) {
    if (Validator(rawValue).isCNPJValid()) {
      return DocType.cnpj;
    }
    if (Validator(rawValue).isCPFValid()) {
      return DocType.cpf;
    }

    throw AppException(
      'Documento inválido',
      error: Exception('Documento inválido'),
    );
  }
}

class Document {
  Document(this.rawValue)
    : docType = DocType.parseDoc(rawValue),
      formatted = Formatters(rawValue).toDocumentFormatted();

  final String rawValue;
  String get value => switch (docType) {
    DocType.cpf => rawValue.onlyNumbers(),
    DocType.cnpj => rawValue.trim(),
  };
  final String formatted;
  final DocType docType;

  bool get isCnpj => docType.isCnpj;
  bool get isCpf => docType.isCpf;
}

extension DocTypeExt on DocType {
  bool get isCnpj => this == DocType.cnpj;
  bool get isCpf => this == DocType.cpf;
}
