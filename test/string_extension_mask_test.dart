import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/extensions/string_extension.dart';

void main() {
  group('maskEmail', () {
    test('masks local and domain parts', () {
      expect('user@example.com'.maskEmail(), 'u*****r@e*****m');
    });

    test('returns null if no @ sign', () {
      expect('notanemail'.maskEmail(), isNull);
    });

    test('returns null for null input', () {
      const String? s = null;
      expect(s.maskEmail(), isNull);
    });
  });

  group('firstAndLastChar', () {
    test('returns empty string for null', () {
      const String? s = null;
      expect(s.firstAndLastChar(), '');
    });

    test('returns empty string for empty string', () {
      expect(''.firstAndLastChar(), '');
    });

    test('returns the single character for a 1-char string', () {
      expect('a'.firstAndLastChar(), 'a');
    });

    test('masks middle characters', () {
      expect('hello'.firstAndLastChar(), 'h*****o');
      expect('ab'.firstAndLastChar(), 'a*****b');
    });
  });

  group('maskCreditCard', () {
    test('returns fully masked suffix for null or empty input', () {
      const String? nullValue = null;
      expect(nullValue.maskCreditCard(), '•••• •••• •••• ****');
      expect(''.maskCreditCard(), '•••• •••• •••• ****');
    });

    test('shows last four digits when input has exactly four digits', () {
      expect('1234'.maskCreditCard(), '•••• •••• •••• 1234');
    });

    test('pads with asterisks when fewer than four digits remain', () {
      expect('12'.maskCreditCard(), '•••• •••• •••• **12');
      expect('1'.maskCreditCard(), '•••• •••• •••• ***1');
    });

    test('strips non-digit characters before masking', () {
      expect('4111 1111 1111 1234'.maskCreditCard(), '•••• •••• •••• 1234');
      expect('4111-1111-1111-0000'.maskCreditCard(), '•••• •••• •••• 0000');
      expect('4111111111110000'.maskCreditCard(), '•••• •••• •••• 0000');
      expect('4111.1111.1111.0000'.maskCreditCard(), '•••• •••• •••• 0000');
      expect('****1234'.maskCreditCard(), '•••• •••• •••• 1234');
    });
  });
}
