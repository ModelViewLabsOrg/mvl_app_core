import 'package:flutter_test/flutter_test.dart';
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
  });

  group('IntExt', () {
    group('amountToDouble', () {
      test('converts centavos to reais', () {
        expect(100.amountToDouble(), 1.0);
        expect(1050.amountToDouble(), 10.5);
        expect(0.amountToDouble(), 0.0);
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
