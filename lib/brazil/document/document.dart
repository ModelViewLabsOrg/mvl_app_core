import 'package:mvl_app_core/brazil/document/cnpj_helper.dart';
import 'package:mvl_app_core/brazil/document/cpf_helper.dart';
import 'package:mvl_app_core/utils/app_exception.dart';

enum DocType {
  cpf,
  cnpj;

  static DocType parseDoc(String rawValue) {
    return tryParseDoc(rawValue) ??
        (throw AppException(
          'Documento inválido!',
          error: Exception('Documento inválido: $rawValue'),
          stackTrace: StackTrace.current,
        ));
  }

  static DocHelper? tryParseHelper(String rawValue) {
    final String value = rawValue.trim();

    final cnpj = CNPJHelper(value);
    if (cnpj.isValid()) {
      return cnpj;
    }

    final cpf = CPFHelper(value);
    if (cpf.isValid()) {
      return cpf;
    }

    return null;
  }

  static DocType? tryParseDoc(String rawValue) => tryParseHelper(rawValue)?.docType;

  static bool isValid(String rawValue) => tryParseDoc(rawValue) != null;
}

abstract class DocHelper {
  DocHelper(this.value);

  final String value;

  DocType get docType;
  String format();
  bool isValid();
}

class Document {
  factory Document(String value) {
    final DocType docType = DocType.parseDoc(value);
    final DocHelper helper = switch (docType) {
      DocType.cpf => CPFHelper(value),
      DocType.cnpj => CNPJHelper(value),
    };
    return Document._(helper);
  }

  Document._(this.helper)
    : rawValue = helper.value,
      docType = helper.docType,
      formatted = helper.format();

  final DocHelper helper;
  final String rawValue;
  final DocType docType;
  final String formatted;

  String get value => rawValue;

  bool get isCnpj => docType == DocType.cnpj;
  bool get isCpf => docType == DocType.cpf;
}
