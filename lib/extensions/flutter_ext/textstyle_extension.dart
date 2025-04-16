import 'dart:math';

import 'package:flutter/material.dart';

extension TextStyleHelpers on TextStyle {
  TextStyle get bold {
    final int? index = fontWeight?.index;
    if (index == null) {
      return this;
    }
    final int newIndex = min(FontWeight.values.length, index + 2);
    return copyWith(fontWeight: FontWeight.values[newIndex]);
  }

  TextStyle get extraBold => copyWith(fontWeight: FontWeight.w900);

  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
  // TextStyle c(Color value) => copyWith(color: value);
  // TextStyle letterSpacing(double value) => copyWith(letterSpacing: value);
  TextStyle error(BuildContext context) =>
      copyWith(decoration: TextDecoration.lineThrough, color: Theme.of(context).colorScheme.error);

  TextStyle letterMoreSpacing({double add = 0.1}) {
    final double value = (letterSpacing ?? 1) + add;
    return copyWith(letterSpacing: value);
  }
}
