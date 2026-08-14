import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/brazil/brasil.dart';
import 'package:mvl_app_core/utils/app_exception.dart';

void main() {
  group('BrasilState.tryParse', () {
    test('parses UF codes case-insensitively and trims whitespace', () {
      expect(BrasilState.tryParse('sp'), BrasilState.sp);
      expect(BrasilState.tryParse('SP'), BrasilState.sp);
      expect(BrasilState.tryParse(' rj '), BrasilState.rj);
      expect(BrasilState.tryParse(' AC'), BrasilState.ac);
      expect(BrasilState.tryParse('Df'), BrasilState.df);
    });

    test('returns null for empty or whitespace-only input', () {
      expect(BrasilState.tryParse(''), isNull);
      expect(BrasilState.tryParse('       '), isNull);
    });

    test('parses full state names case-insensitively and trims whitespace', () {
      expect(BrasilState.tryParse('São Paulo'), BrasilState.sp);
      expect(BrasilState.tryParse('acre'), BrasilState.ac);
      expect(BrasilState.tryParse('  DISTRITO FEDERAL  '), BrasilState.df);
      expect(BrasilState.tryParse('Minas Gerais'), BrasilState.mg);
    });

    test('returns null for unknown codes and extra characters', () {
      expect(BrasilState.tryParse('invalid'), isNull);
      expect(BrasilState.tryParse('xx'), isNull);
      expect(BrasilState.tryParse('spp'), isNull);
      expect(BrasilState.tryParse('sp1'), isNull);
    });

    test('does not match partial state names', () {
      expect(BrasilState.tryParse('Paulo'), isNull);
      expect(BrasilState.tryParse('Minas'), isNull);
    });
  });

  group('BrasilState.parse', () {
    test('parses uppercase UF and full names', () {
      expect(BrasilState.parse('SP'), BrasilState.sp);
      expect(BrasilState.parse('DF'), BrasilState.df);
      expect(BrasilState.parse('São Paulo'), BrasilState.sp);
      expect(BrasilState.parse('Distrito Federal'), BrasilState.df);
    });

    test('round-trips every enum name and label', () {
      for (final BrasilState state in BrasilState.values) {
        expect(BrasilState.parse(state.name), state);
        expect(BrasilState.parse(state.label), state);
        expect(BrasilState.tryParse(state.name), state);
        expect(BrasilState.tryParse(state.label), state);
      }
    });

    test('throws AppException for invalid input', () {
      expect(() => BrasilState.parse(''), throwsA(isA<AppException>()));
      expect(() => BrasilState.parse('       '), throwsA(isA<AppException>()));
      expect(() => BrasilState.parse('invalid'), throwsA(isA<AppException>()));
    });

    test('includes the raw value in the error message', () {
      expect(
        () => BrasilState.parse('xx'),
        throwsA(
          isA<AppException>().having(
            (e) => e.userMessage,
            'userMessage',
            contains('xx'),
          ),
        ),
      );
    });
  });

  group('BrasilState.label', () {
    test('returns the full Portuguese name', () {
      expect(BrasilState.rr.label, 'Roraima');
      expect(BrasilState.ba.label, 'Bahia');
      expect(BrasilState.mg.label, 'Minas Gerais');
      expect(BrasilState.df.label, 'Distrito Federal');
      expect(BrasilState.sp.label, 'São Paulo');
    });

    test('every state has a unique non-empty label', () {
      final List<String> labels = BrasilState.values.map((e) => e.label).toList();

      expect(labels.every((label) => label.isNotEmpty), isTrue);
      expect(labels.toSet().length, BrasilState.values.length);
    });
  });

  group('BrasilState.values', () {
    test('contains all 27 federative units as unique two-letter UFs', () {
      final List<String> names = BrasilState.values.map((e) => e.name).toList();

      expect(names.length, 27);
      expect(names.every((name) => name.length == 2), isTrue);
      expect(names.toSet().length, 27);
    });
  });

  group('BrasilState.region', () {
    test('maps each state to the official IBGE region', () {
      expect(BrasilState.ac.region, BrasilRegion.norte);
      expect(BrasilState.am.region, BrasilRegion.norte);
      expect(BrasilState.ap.region, BrasilRegion.norte);
      expect(BrasilState.ba.region, BrasilRegion.nordeste);
      expect(BrasilState.df.region, BrasilRegion.centroOeste);
      expect(BrasilState.go.region, BrasilRegion.centroOeste);
      expect(BrasilState.sp.region, BrasilRegion.sudeste);
      expect(BrasilState.rj.region, BrasilRegion.sudeste);
      expect(BrasilState.pr.region, BrasilRegion.sul);
      expect(BrasilState.rs.region, BrasilRegion.sul);
    });
  });

  group('BrasilRegion', () {
    test('has the five official regions', () {
      expect(BrasilRegion.values.map((e) => e.label), [
        'Centro-Oeste',
        'Nordeste',
        'Norte',
        'Sudeste',
        'Sul',
      ]);
    });
  });

}
