import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/utils/json.dart';

void main() {
  group('defaultHeaders', () {
    test('contains Accept and Content-Type headers', () {
      final Map<String, String> headers = defaultHeaders;
      expect(headers['Accept'], 'application/json');
      expect(headers['Content-Type'], 'application/json');
    });

    test('returns a new map each call', () {
      expect(defaultHeaders, isA<Map<String, String>>());
    });
  });
}
