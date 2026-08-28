import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/brazil/document/cnpj_helper.dart';
import 'package:mvl_app_core/brazil/document/cpf_helper.dart';
import 'package:mvl_app_core/brazil/document/document.dart';
import 'package:mvl_app_core/utils/app_exception.dart';

void main() {
  final String validCpf = CPFHelper.generateRandom();
  final String validCnpj = CNPJHelper.generateRandom();
  final String formattedCpf = CPFHelper(validCpf).format();
  final String formattedCnpj = CNPJHelper(validCnpj).format();

  // Official Receita Federal example: 12.ABC.345/01DE-35
  const alphanumericCnpj = '12ABC34501DE35';
  const formattedAlphanumericCnpj = '12.ABC.345/01DE-35';

  group('DocType', () {
    group('parseDoc', () {
      test('returns cpf for a valid CPF', () {
        expect(DocType.parseDoc(validCpf), DocType.cpf);
        expect(DocType.parseDoc(formattedCpf), DocType.cpf);
      });

      test('returns cnpj for a valid numeric CNPJ', () {
        expect(DocType.parseDoc(validCnpj), DocType.cnpj);
        expect(DocType.parseDoc(formattedCnpj), DocType.cnpj);
      });

      test('returns cnpj for a valid alphanumeric CNPJ', () {
        expect(DocType.parseDoc(alphanumericCnpj), DocType.cnpj);
        expect(DocType.parseDoc(formattedAlphanumericCnpj), DocType.cnpj);
        expect(DocType.parseDoc('12.abc.345/01de-35'), DocType.cnpj);
      });

      test('trims whitespace before parsing', () {
        expect(DocType.parseDoc('  $validCpf  '), DocType.cpf);
        expect(DocType.parseDoc('  $alphanumericCnpj  '), DocType.cnpj);
      });

      test('throws AppException for invalid document', () {
        expect(() => DocType.parseDoc('invalid'), throwsA(isA<AppException>()));
        expect(() => DocType.parseDoc(''), throwsA(isA<AppException>()));
      });
    });

    group('tryParseDoc', () {
      test('returns the type for valid documents', () {
        expect(DocType.tryParseDoc(validCpf), DocType.cpf);
        expect(DocType.tryParseDoc(validCnpj), DocType.cnpj);
        expect(DocType.tryParseDoc(alphanumericCnpj), DocType.cnpj);
      });

      test('returns null for invalid document', () {
        expect(DocType.tryParseDoc('invalid'), isNull);
        expect(DocType.tryParseDoc(''), isNull);
      });
    });

    group('isValid', () {
      test('returns true for valid CPF and CNPJ', () {
        expect(DocType.isValid(validCpf), isTrue);
        expect(DocType.isValid(formattedCpf), isTrue);
        expect(DocType.isValid(validCnpj), isTrue);
        expect(DocType.isValid(alphanumericCnpj), isTrue);
        expect(DocType.isValid(formattedAlphanumericCnpj), isTrue);
      });

      test('returns false for invalid document', () {
        expect(DocType.isValid('invalid'), isFalse);
        expect(DocType.isValid(''), isFalse);
      });
    });
  });

  group('Document', () {
    test('creates a CPF document with normalized value, formatted display and helper', () {
      final doc = Document(formattedCpf);

      expect(doc.docType, DocType.cpf);
      expect(doc.isCpf, isTrue);
      expect(doc.isCnpj, isFalse);
      expect(doc.rawValue, validCpf);
      expect(doc.value, validCpf);
      expect(doc.formatted, formattedCpf);
      expect(doc.helper, isA<CPFHelper>());
      expect(doc.helper.value, validCpf);
    });

    test('creates a numeric CNPJ document with normalized value, formatted display and helper', () {
      final doc = Document(formattedCnpj);

      expect(doc.docType, DocType.cnpj);
      expect(doc.isCnpj, isTrue);
      expect(doc.isCpf, isFalse);
      expect(doc.rawValue, validCnpj);
      expect(doc.formatted, formattedCnpj);
      expect(doc.helper, isA<CNPJHelper>());
    });

    test('creates an alphanumeric CNPJ document keeping letters in value', () {
      final doc = Document('12.abc.345/01de-35');

      expect(doc.isCnpj, isTrue);
      expect(doc.isCpf, isFalse);
      expect(doc.rawValue, alphanumericCnpj);
      expect(doc.formatted, formattedAlphanumericCnpj);
      expect(doc.helper, isA<CNPJHelper>());
    });

    test('throws AppException for invalid document', () {
      expect(() => Document('invalid'), throwsA(isA<AppException>()));
    });
  });
}
