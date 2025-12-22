import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';

extension ColorExt on Color {
  Color withAppOpacity(double opacity) {
    assert(opacity >= 0 && opacity <= 1, 'opacity must be between 0 and 1');
    final double safeValue = min(0, max(1, opacity));
    return withValues(alpha: safeValue);
  }

  String toHex({bool leadingHashSign = true, bool includeAlpha = false}) {
    final hex = StringBuffer();
    if (leadingHashSign) {
      hex.write('#');
    }

    if (includeAlpha) {
      // ignore: deprecated_member_use
      hex.write(alpha.toRadixString(16).padLeft(2, '0'));
    }

    hex.writeAll(<String>[
      // ignore: deprecated_member_use
      red.toRadixString(16).padLeft(2, '0'),
      // ignore: deprecated_member_use
      green.toRadixString(16).padLeft(2, '0'),
      // ignore: deprecated_member_use
      blue.toRadixString(16).padLeft(2, '0'),
    ]);

    return hex.toString();
  }

  /// Darkens the color by the given [amount].
  ///
  /// The [amount] should be between 0 and 1, where 0 means no change,
  /// and 1 means the color will be black.
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'amount must be between 0 and 1');
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  /// Lightens the color by the given [amount].
  ///
  /// The [amount] should be between 0 and 1, where 0 means no change,
  /// and 1 means the color will be white.
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'amount must be between 0 and 1');
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  /// Creates a shade of the color by mixing it with black.
  ///
  /// The [amount] should be between 0 and 1, where 0 means no change,
  /// and 1 means the color will be black.
  Color shade([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'amount must be between 0 and 1');
    return Color.lerp(this, Colors.black, amount)!; // Use non-null assertion
  }

  /// Creates a tint of the color by mixing it with white.
  ///
  /// The [amount] should be between 0 and 1, where 0 means no change,
  /// and 1 means the color will be white.
  Color tint([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'amount must be between 0 and 1');
    return Color.lerp(this, Colors.white, amount)!; // Use non-null assertion
  }

  /// Calculates the contrast ratio between this color and another [otherColor].
  /// The contrast ratio is a measure of how distinguishable
  /// two colors are from each other.
  /// A higher contrast ratio indicates better readability.
  ///
  /// Returns a double value between 1 and 21,
  /// where higher values mean better contrast.
  double contrast(Color otherColor) {
    final double luminance1 = computeLuminance();
    final double luminance2 = otherColor.computeLuminance();

    return (math.max(luminance1, luminance2) + 0.05) / (math.min(luminance1, luminance2) + 0.05);
  }

  /// Returns the complementary color of this color.
  /// The complementary color is the color on the
  /// opposite side of the color wheel.
  Color complementary() {
    final hsl = HSLColor.fromColor(this);
    return hsl.withHue((hsl.hue + 180) % 360).toColor();
  }

  /// Blends this color with another [otherColor] by the specified [amount].
  /// The [amount] should be between 0 and 1, where 0 means
  /// no blending (this color),
  /// and 1 means fully blended with the [otherColor].
  Color blend(Color otherColor, [double amount = 0.5]) {
    assert(amount >= 0 && amount <= 1, 'amount must be between 0 and 1');
    return Color.lerp(this, otherColor, amount)!;
  }

  /// Converts this color to grayscale.
  Color grayscale() {
    final int grayValue = ((0.299 * r) + (0.587 * g) + (0.114 * b)).toInt();
    return Color.fromRGBO(grayValue, grayValue, grayValue, a);
  }

  /// Inverts this color.
  Color invert() {
    return Color.fromRGBO(255 - r.toInt(), 255 - g.toInt(), 255 - b.toInt(), a);
  }
}

extension FHUColorExt on String {
  /// checks if current string is in hex format or not.
  bool get isHexColor => RegExp(r'^#?(?:[0-9a-fA-F]{3,4}){1,2}$').hasMatch(this);

  Color hexToColor(String code) => Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);

  /// it tries to convert the current string to Color returns null if failed.
  Color? get toColor {
    if (!isHexColor) {
      return null;
    }

    final buffer = StringBuffer();
    if (length == 6 || length == 7) {
      buffer.write('FF');
    }
    buffer.write(replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
