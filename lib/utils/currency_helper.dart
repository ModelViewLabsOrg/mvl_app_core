// import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class CurrencyHelper {
  // CurrencyHelper([String locale = 'pt_BR']) {
  //   Intl.defaultLocale = locale;
  //   initializeDateFormatting(locale);
  // }

  // static String formatNumber(String s) =>
  //     NumberFormat.decimalPattern(locale).format(double.parse(s));

  static String toCurrency(num number, {bool allowNegative = false}) {
    final regex = allowNegative ? r'[^A-Za-z0-9$.,\-]' : r'[^A-Za-z0-9$.,]';

    return NumberFormat.currency(
      symbol: currencySymbol,
    ).format(number).replaceAll(RegExp(regex), ' ');
  }
  // The character  is invisible. Adjust settings

  static String get currencySymbol =>
      NumberFormat.compactSimpleCurrency().currencySymbol;
}
