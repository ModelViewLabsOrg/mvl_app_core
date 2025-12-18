import 'dart:math';

import 'package:mvl_app_core/utils/currency_helper.dart';

extension IntExt on int {
  String toReais({bool allowNegative = false}) =>
      CurrencyHelper.toCurrency(this / 100, allowNegative: allowNegative);

  double amountToDouble() => this / 100;
}

double jsonToDouble(dynamic value) => (value as num).toDouble();

extension NumExt on num {
  String toPercent({int decimal = 1}) {
    final String value = toStringAsFixed(decimal);

    return '$value%';
  }

  Duration get seconds => Duration(microseconds: (1000000 * this).round());
  Duration get minutes => Duration(milliseconds: (1000 * 60 * this).round());

  bool isBetween(num first, num second) {
    final num lower = min(first, second);
    final num upper = max(first, second);

    return this >= lower && this <= upper;
  }
}
