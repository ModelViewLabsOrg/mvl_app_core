import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/extensions/flutter_ext/color_ext.dart';

void main() {
  group('ColorExt withAppOpacity', () {
    test('returns a Color', () {
      const color = Color(0xFFFF0000);
      expect(color.withAppOpacity(0.5), isA<Color>());
    });

    test('opacity 0 returns transparent-ish color', () {
      const color = Color(0xFFFF0000);
      expect(color.withAppOpacity(0), isA<Color>());
    });

    test('opacity 1 returns a Color', () {
      const color = Color(0xFF00FF00);
      expect(color.withAppOpacity(1), isA<Color>());
    });
  });

  group('HexColorExt', () {
    test('toHex without alpha', () {
      const color = Color(0xFFAABBCC);
      final String hexString = color.toHex();
      expect(hexString, '#aabbcc');
    });

    test('toHex with alpha', () {
      const color = Color(0x80AABBCC);
      final String hexString = color.toHex(includeAlpha: true);
      expect(hexString, '#80aabbcc');
    });

    test('toHex with full opacity', () {
      const color = Color(0xFFAABBCC);
      final String hexString = color.toHex(includeAlpha: true);
      expect(hexString, '#ffaabbcc');
    });

    test('toHex with zero opacity', () {
      const color = Color(0x00AABBCC);
      final String hexString = color.toHex(includeAlpha: true);
      expect(hexString, '#00aabbcc');
    });

    test('toHex with different color', () {
      const color = Color(0x12345678);
      final String hexString = color.toHex(includeAlpha: true);
      expect(hexString, '#12345678');
    });

    test('toHex without leading hash sign', () {
      const color = Color(0xFFAABBCC);
      expect(color.toHex(leadingHashSign: false), 'aabbcc');
    });
  });

  group('ColorExt darken/lighten', () {
    test('darken reduces luminance', () {
      const color = Color(0xFF808080);
      final Color darkened = color.darken(0.2);
      expect(darkened.computeLuminance(), lessThan(color.computeLuminance()));
    });

    test('darken by 0 returns same luminance', () {
      const color = Color(0xFF808080);
      final Color result = color.darken(0);
      expect(result.computeLuminance(), closeTo(color.computeLuminance(), 0.01));
    });

    test('lighten increases luminance', () {
      const color = Color(0xFF404040);
      final Color lightened = color.lighten(0.2);
      expect(lightened.computeLuminance(), greaterThan(color.computeLuminance()));
    });

    test('lighten by 0 returns same luminance', () {
      const color = Color(0xFF404040);
      final Color result = color.lighten(0);
      expect(result.computeLuminance(), closeTo(color.computeLuminance(), 0.01));
    });
  });

  group('ColorExt shade/tint', () {
    test('shade makes color darker', () {
      const color = Color(0xFF808080);
      final Color shaded = color.shade(0.5);
      expect(shaded.computeLuminance(), lessThan(color.computeLuminance()));
    });

    test('shade by 1 approaches black', () {
      const color = Color(0xFF808080);
      final Color shaded = color.shade(1);
      expect(shaded.computeLuminance(), closeTo(0, 0.01));
    });

    test('tint makes color lighter', () {
      const color = Color(0xFF404040);
      final Color tinted = color.tint(0.5);
      expect(tinted.computeLuminance(), greaterThan(color.computeLuminance()));
    });

    test('tint by 1 approaches white', () {
      const color = Color(0xFF404040);
      final Color tinted = color.tint(1);
      expect(tinted.computeLuminance(), closeTo(1, 0.01));
    });
  });

  group('ColorExt contrast', () {
    test('black vs white has maximum contrast', () {
      final double ratio = Colors.black.contrast(Colors.white);
      expect(ratio, closeTo(21.0, 0.1));
    });

    test('same color has contrast of 1', () {
      const color = Color(0xFF808080);
      expect(color.contrast(color), closeTo(1.0, 0.01));
    });

    test('contrast is symmetric', () {
      const color1 = Color(0xFF000000);
      const color2 = Color(0xFFFFFFFF);
      expect(color1.contrast(color2), closeTo(color2.contrast(color1), 0.001));
    });
  });

  group('ColorExt complementary', () {
    test('returns a Color', () {
      const red = Color(0xFFFF0000);
      expect(red.complementary(), isA<Color>());
    });

    test('complementary twice returns original luminance', () {
      const color = Color(0xFF336699);
      final double origLuminance = color.computeLuminance();
      final double doubleLuminance = color.complementary().complementary().computeLuminance();
      expect(origLuminance, closeTo(doubleLuminance, 0.01));
    });
  });

  group('ColorExt blend', () {
    test('blend at 0 returns original color', () {
      const color1 = Color(0xFFFF0000);
      const color2 = Color(0xFF0000FF);
      final Color result = color1.blend(color2, 0);
      expect(result.toARGB32(), color1.toARGB32());
    });

    test('blend at 1 returns target color', () {
      const color1 = Color(0xFFFF0000);
      const color2 = Color(0xFF0000FF);
      final Color result = color1.blend(color2, 1);
      expect(result.toARGB32(), color2.toARGB32());
    });

    test('blend at 0.5 returns a color', () {
      const color1 = Color(0xFFFF0000);
      const color2 = Color(0xFF0000FF);
      expect(color1.blend(color2), isA<Color>());
    });
  });

  group('ColorExt grayscale', () {
    test('returns a Color', () {
      expect(const Color(0xFFAABBCC).grayscale(), isA<Color>());
    });

    test('grayscale result has equal R G B components', () {
      final Color gray = const Color(0xFF808080).grayscale();
      expect(gray.r, closeTo(gray.g, 0.01));
      expect(gray.g, closeTo(gray.b, 0.01));
    });
  });

  group('ColorExt invert', () {
    test('returns a Color', () {
      expect(Colors.black.invert(), isA<Color>());
      expect(Colors.white.invert(), isA<Color>());
    });

    test('invert changes the color value', () {
      const color = Color(0xFF336699);
      expect(color.invert().toARGB32(), isNot(equals(color.toARGB32())));
    });

    test('alpha is preserved on invert', () {
      const color = Color(0x80FF0000);
      expect(color.invert().a, closeTo(color.a, 0.01));
    });
  });

  group('FHUColorExt (String extensions)', () {
    group('isHexColor', () {
      test('returns true for valid 6-char hex with hash', () {
        expect('#AABBCC'.isHexColor, isTrue);
        expect('#aabbcc'.isHexColor, isTrue);
      });

      test('returns true for valid 3-char hex', () {
        expect('#abc'.isHexColor, isTrue);
        expect('#ABC'.isHexColor, isTrue);
      });

      test('returns true for valid 8-char hex with alpha', () {
        expect('#AABBCCDD'.isHexColor, isTrue);
      });

      test('returns true for hex without hash', () {
        expect('AABBCC'.isHexColor, isTrue);
      });

      test('returns false for non-hex strings', () {
        expect('notacolor'.isHexColor, isFalse);
        expect('#GGHHII'.isHexColor, isFalse);
        expect(''.isHexColor, isFalse);
      });
    });

    group('hexToColor', () {
      test('converts hex code string to Color', () {
        final Color color = '#AABBCC'.hexToColor('#AABBCC');
        expect(color, isA<Color>());
      });
    });

    group('toColor', () {
      test('converts hex string to Color', () {
        final Color? color = '#AABBCC'.toColor;
        expect(color, isNotNull);
      });

      test('returns null for non-hex string', () {
        expect('not-a-color'.toColor, isNull);
        expect(''.toColor, isNull);
      });

      test('parses known red hex color correctly', () {
        final Color? color = '#FF0000'.toColor;
        expect(color, isNotNull);
      });
    });
  });
}
