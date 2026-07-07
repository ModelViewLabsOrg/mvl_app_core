import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mvl_app_core/utils/currency_helper.dart';

void main() {
  setUpAll(() {
    Intl.defaultLocale = 'pt_BR';
  });

  group('CurrencyHelper', () {
    group('currencySymbol', () {
      test('returns a non-empty string', () {
        expect(CurrencyHelper.currencySymbol, isNotEmpty);
      });
    });

    group('toCurrency', () {
      test('formats zero correctly', () {
        final String result = CurrencyHelper.toCurrency(0);
        expect(result, isNotEmpty);
        expect(result, contains('0'));
      });

      test('formatted value contains the number', () {
        final String result = CurrencyHelper.toCurrency(1000);
        expect(result, contains('1'));
        expect(result, contains('0'));
      });

      test('negative number is excluded by default', () {
        final String result = CurrencyHelper.toCurrency(-100);
        expect(result.contains('-'), isFalse);
      });

      test('negative number is allowed when allowNegative is true', () {
        final String result = CurrencyHelper.toCurrency(-100, allowNegative: true);
        expect(result, contains('-'));
      });

      test('returns a string', () {
        expect(CurrencyHelper.toCurrency(50.0), isA<String>());
      });
    });
  });
}
