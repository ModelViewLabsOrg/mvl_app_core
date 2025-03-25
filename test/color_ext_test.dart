import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/extensions/flutter_ext/color_ext.dart';

void main() {
  group('HexColorExt', () {
    test('toHex without alpha', () {
      const color = Color(0xFFAABBCC);
      final hexString = color.toHex(includeAlpha: false);
      expect(hexString, '#aabbcc');
    });

    test('toHex with alpha', () {
      const color = Color(0x80AABBCC);
      final hexString = color.toHex(includeAlpha: true);
      expect(hexString, '#80aabbcc');
    });

    test('toHex with full opacity', () {
      const color = Color(0xFFAABBCC);
      final hexString = color.toHex(includeAlpha: true);
      expect(hexString, '#ffaabbcc');
    });

    test('toHex with zero opacity', () {
      const color = Color(0x00AABBCC);
      final hexString = color.toHex(includeAlpha: true);
      expect(hexString, '#00aabbcc');
    });

    test('toHex with different color', () {
      const color = Color(0x12345678);
      final hexString = color.toHex(includeAlpha: true);
      expect(hexString, '#12345678');
    });
  });
}
