import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/utils/random_generator.dart';

void main() {
  group('randomOtp6Numbers', () {
    test('returns a 6-digit number', () {
      final int otp = randomOtp6Numbers();
      expect(otp, greaterThanOrEqualTo(100000));
      expect(otp, lessThanOrEqualTo(999999));
    });

    test('generates different values on consecutive calls', () {
      final List<int> samples = List.generate(10, (_) => randomOtp6Numbers());
      final Set<int> unique = samples.toSet();
      // Extremely unlikely all 10 are the same 6-digit number
      expect(unique.length, greaterThan(1));
    });
  });

  group('randomUuid', () {
    test('returns a non-empty UUID v7 string', () {
      final String uuid = randomUuid();
      expect(uuid, isNotEmpty);
      // UUID format: 8-4-4-4-12 hex chars separated by dashes
      expect(uuid.split('-').length, 5);
    });

    test('generates unique values', () {
      final String first = randomUuid();
      final String second = randomUuid();
      expect(first, isNot(equals(second)));
    });
  });

  group('randomUlid', () {
    test('returns a non-empty ULID string', () {
      final String ulid = randomUlid();
      expect(ulid, isNotEmpty);
      expect(ulid.length, 26);
    });

    test('generates unique values', () {
      final String first = randomUlid();
      final String second = randomUlid();
      expect(first, isNot(equals(second)));
    });
  });
}
