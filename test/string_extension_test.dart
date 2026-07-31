import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/extensions/date_time_ext_extras.dart';
import 'package:mvl_app_core/extensions/string_extension.dart';

void main() {
  group('StringExt', () {
    group('containsInsensitive', () {
      test('finds match with different cases', () {
        expect('Hello World'.containsInsensitive('hello'), isTrue);
        expect('Hello World'.containsInsensitive('WORLD'), isTrue);
        expect('Hello World'.containsInsensitive('xyz'), isFalse);
      });
    });

    group('toInt', () {
      test('parses plain integer string', () {
        expect('42'.toInt(), 42);
        expect('0'.toInt(), 0);
      });

      test('parses integer string with thousand separators', () {
        expect('1.000'.toInt(), 1000);
        expect('1.000.000'.toInt(), 1000000);
      });

      test('returns null for non-numeric string', () {
        expect('abc'.toInt(), isNull);
        expect(''.toInt(), isNull);
      });
    });

    group('toBool', () {
      test('returns true for "true" (case-insensitive)', () {
        expect('true'.toBool(), isTrue);
        expect('TRUE'.toBool(), isTrue);
        expect('True'.toBool(), isTrue);
      });

      test('returns true for "1"', () {
        expect('1'.toBool(), isTrue);
      });

      test('returns false for other values', () {
        expect('false'.toBool(), isFalse);
        expect('0'.toBool(), isFalse);
        expect('yes'.toBool(), isFalse);
        expect(''.toBool(), isFalse);
      });
    });

    group('capitalizeFirstLetter', () {
      test('capitalizes first letter and lowercases the rest', () {
        expect('hello'.capitalizeFirstLetter(), 'Hello');
        expect('HELLO'.capitalizeFirstLetter(), 'Hello');
        expect('hELLO'.capitalizeFirstLetter(), 'Hello');
      });
    });

    group('capitalize', () {
      test('capitalizes each word when fullSentence is true (default)', () {
        expect('hello world'.capitalize(), 'Hello World');
        expect('HELLO WORLD'.capitalize(), 'Hello World');
      });

      test('capitalizes only first word when fullSentence is false', () {
        expect('hello world'.capitalize(fullSentence: false), 'Hello world');
      });
    });

    group('onlyAlphanumerics', () {
      test('removes non-alphanumeric characters', () {
        expect('abc 123!@#'.onlyAlphanumerics(), 'abc123');
      });

      test('replaces with provided character', () {
        expect('abc 123'.onlyAlphanumerics('-'), 'abc-123');
      });

      test('removes diacritics (accented chars)', () {
        expect('café'.onlyAlphanumerics(), 'cafe');
      });
    });

    group('limit', () {
      test('limits string to specified number of chars', () {
        expect('hello world'.limit(5), 'hello');
      });

      test('returns full string if shorter than limit', () {
        expect('hi'.limit(10), 'hi');
      });

      test('trims result', () {
        expect('hello  '.limit(7), 'hello');
      });
    });

    group('removeAccentsDiacritics', () {
      test('removes accents from characters', () {
        expect('café'.removeAccentsDiacritics(), 'cafe');
        expect('São Paulo'.removeAccentsDiacritics(), 'Sao Paulo');
        expect('naïve'.removeAccentsDiacritics(), 'naive');
      });

      test('leaves plain ASCII unchanged', () {
        expect('hello'.removeAccentsDiacritics(), 'hello');
      });
    });

    group('removeEmoji', () {
      test('removes emoji characters', () {
        final String result = 'Hello 😀 World'.removeEmoji();
        expect(result.contains('Hello'), isTrue);
        expect(result.contains('World'), isTrue);
      });

      test('leaves plain text unchanged', () {
        expect('hello world'.removeEmoji(), 'hello world');
      });
    });

    group('removeAccentsAndEmojiWithTrim', () {
      test('removes both accents and emoji', () {
        final String result = 'café 😀'.removeAccentsAndEmojiWithTrim();
        expect(result, 'cafe');
      });
    });

    group('cleanLimit', () {
      test('removes accents and limits chars', () {
        expect('café'.cleanLimit(3), 'caf');
        expect('hello'.cleanLimit(10), 'hello');
      });
    });

    group('normalizeEmail', () {
      test('lowercases and trims email', () {
        expect(' User@Example.COM '.normalizeEmail(), 'user@example.com');
      });

      test('handles already normalized email', () {
        expect('user@example.com'.normalizeEmail(), 'user@example.com');
      });
    });

    group('fromTzToLocalDate', () {
      test('parses ISO string to local DateTime', () {
        final DateTime result = '2024-03-15T00:00:00.000'.fromTzToLocalDate();
        expect(result.year, 2024);
        expect(result.month, 3);
        expect(result.day, 15);
      });
    });

    group('removeHtml', () {
      test('strips HTML tags', () {
        expect('<p>Hello</p>'.removeHtml(), 'Hello');
        expect('<b>Bold</b> text'.removeHtml(), 'Bold text');
      });

      test('converts br tags to newlines', () {
        final String result = 'Line1<br>Line2'.removeHtml();
        expect(result.contains('Line1'), isTrue);
        expect(result.contains('Line2'), isTrue);
      });

      test('returns plain text unchanged', () {
        expect('plain text'.removeHtml(), 'plain text');
      });

      test('trims leading newline', () {
        expect('<br>Hello'.removeHtml(), 'Hello');
      });

      test('trims trailing newline', () {
        expect('Hello<br>'.removeHtml(), 'Hello');
      });
    });
  });

  group('StringNullableExt', () {
    group('isReallyEmpty', () {
      test('returns true for null', () {
        const String? s = null;
        expect(s.isReallyEmpty(), isTrue);
      });

      test('returns true for empty string', () {
        expect(''.isReallyEmpty(), isTrue);
      });

      test('returns true for whitespace-only string', () {
        expect('   '.isReallyEmpty(), isTrue);
      });

      test('returns false for non-empty string', () {
        expect('hello'.isReallyEmpty(), isFalse);
        expect(' a '.isReallyEmpty(), isFalse);
      });
    });

    group('reallyLength', () {
      test('returns 0 for null', () {
        const String? s = null;
        expect(s.reallyLength(), 0);
      });

      test('returns 0 for whitespace-only string', () {
        expect('   '.reallyLength(), 0);
      });

      test('returns trimmed length', () {
        expect('  hello  '.reallyLength(), 5);
        expect('abc'.reallyLength(), 3);
      });
    });

    group('onlyNumbers', () {
      test('removes all non-digit characters', () {
        expect('(11) 99999-8888'.onlyNumbers(), '11999998888');
        expect('abc123def'.onlyNumbers(), '123');
        expect(''.onlyNumbers(), '');
      });

      test('returns empty string for null', () {
        const String? s = null;
        expect(s.onlyNumbers(), '');
      });
    });

    group('onlyNumbersLength', () {
      test('returns count of digit characters', () {
        expect('(11) 99999-8888'.onlyNumbersLength(), 11);
        expect('abc'.onlyNumbersLength(), 0);
      });
    });

    group('toPhoneFormatted', () {
      test('returns empty string for null', () {
        const String? s = null;
        expect(s.toPhoneFormatted(), '');
      });

      test('returns empty string for blank string', () {
        expect('   '.toPhoneFormatted(), '');
      });

      test('returns raw digits for numbers with fewer than 11 digits', () {
        expect('1133334444'.toPhoneFormatted(), '1133334444');
      });

      test('formats 11-digit mobile number with DDD', () {
        expect('11912345678'.toPhoneFormatted(), '(11) 91234-5678');
      });
    });

    group('toPhoneServer', () {
      test('returns empty string for empty input', () {
        expect(''.toPhoneServer(), '');
        const String? s = null;
        expect(s.toPhoneServer(), '');
      });

      test('prepends +55 and keeps only digits', () {
        expect('11912345678'.toPhoneServer(), '+5511912345678');
        expect('(11) 91234-5678'.toPhoneServer(), '+5511912345678');
      });
    });

    group('toDouble', () {
      test('parses BR-formatted decimal string', () {
        expect('1,50'.toDouble(), 1.5);
        expect('1.000,50'.toDouble(), 1000.5);
      });

      test('returns null for non-numeric strings', () {
        expect('abc'.toDouble(), isNull);
      });

      test('returns null for null input', () {
        const String? s = null;
        expect(s.toDouble(), isNull);
      });
    });

    group('moedaToDouble', () {
      test('parses currency string', () {
        expect('1,00'.moedaToDouble(), 1.0);
        expect('1.000,00'.moedaToDouble(), 1000.0);
      });

      test('returns 0 for null or empty', () {
        const String? s = null;
        expect(s.moedaToDouble(), 0.0);
        expect(''.moedaToDouble(), 0.0);
        expect('  '.moedaToDouble(), 0.0);
      });
    });

    group('toZipCodeFormatted', () {
      test('returns empty string for null', () {
        const String? s = null;
        expect(s.toZipCodeFormatted(), '');
      });

      test('formats 8-digit zip code', () {
        expect('12345678'.toZipCodeFormatted(), '12.345-678');
      });
    });
  });
}
