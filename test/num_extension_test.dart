import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' show Intl;
import 'package:mvl_app_core/extensions/num_extension.dart';

void main() {
  group('NumExt', () {
    group('toPercent', () {
      test('formats with default 1 decimal', () {
        expect(0.5.toPercent(), '0.5%');
        expect(100.0.toPercent(), '100.0%');
        expect(12.345.toPercent(), '12.3%');
      });

      test('respects custom decimal places', () {
        expect(12.345.toPercent(decimal: 2), '12.35%');
        expect(50.0.toPercent(decimal: 0), '50%');
      });
    });

    group('seconds', () {
      test('converts num to Duration in seconds', () {
        expect(2.seconds, const Duration(seconds: 2));
        expect(0.5.seconds, const Duration(milliseconds: 500));
      });
    });

    group('minutes', () {
      test('converts num to Duration in minutes', () {
        expect(1.minutes, const Duration(minutes: 1));
        expect(1.5.minutes, const Duration(seconds: 90));
      });
    });

    group('isBetween', () {
      test('returns true when value is within range', () {
        expect(5.isBetween(1, 10), isTrue);
        expect(1.isBetween(1, 10), isTrue);
        expect(10.isBetween(1, 10), isTrue);
      });

      test('returns true regardless of argument order', () {
        expect(5.isBetween(10, 1), isTrue);
      });

      test('returns false when value is outside range', () {
        expect(0.isBetween(1, 10), isFalse);
        expect(11.isBetween(1, 10), isFalse);
      });
    });

    group('pluralize', () {
      test('keeps the word singular when value is 1 or less', () {
        expect(0.pluralize('atleta'), '0 atleta');
        expect(1.pluralize('atleta'), '1 atleta');
        expect((-2).pluralize('atleta'), '-2 atleta');
        expect(0.5.pluralize('atleta'), '0.5 atleta');
        expect(1.0.pluralize('atleta'), '1.0 atleta');
      });

      test('appends default plural suffix when value is greater than 1', () {
        expect(2.pluralize('atleta'), '2 atletas');
        expect(10.pluralize('item'), '10 items');
        expect(1.5.pluralize('ponto'), '1.5 pontos');
      });

      test('uses the custom plural suffix', () {
        expect(2.pluralize('child', plural: 'ren'), '2 children');
        expect(1.pluralize('child', plural: 'ren'), '1 child');
      });
    });
  });

  group('IntExt', () {
    group('amountToDouble', () {
      test('converts centavos to reais', () {
        expect(100.amountToDouble(), 1.0);
        expect(1050.amountToDouble(), 10.5);
        expect(0.amountToDouble(), 0.0);
      });
    });

    group('toReais', () {
      setUpAll(() {
        Intl.defaultLocale = 'pt_BR';
      });

      test('returns a formatted string', () {
        expect(1000.toReais(), isA<String>());
        expect(1000.toReais(), isNotEmpty);
      });

      test('negative value excluded by default', () {
        expect((-100).toReais(), isNot(contains('-')));
      });

      test('negative value allowed when allowNegative is true', () {
        expect((-100).toReais(allowNegative: true), contains('-'));
      });
    });
  });

  group('jsonToDouble', () {
    test('converts int to double', () {
      expect(jsonToDouble(1), 1.0);
      expect(jsonToDouble(0), 0.0);
    });

    test('converts double to double', () {
      expect(jsonToDouble(3.14), 3.14);
    });
  });
}
