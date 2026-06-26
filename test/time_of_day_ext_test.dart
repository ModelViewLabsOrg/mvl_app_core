import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/extensions/time_of_day_extension.dart';

void main() {
  group('TimeOfDayExt', () {
    group('fromJson', () {
      test('parses ISO 8601 string to TimeOfDay', () {
        final TimeOfDay result = TimeOfDayExt.fromJson('2024-03-15T14:30:00.000Z');
        expect(result.hour, 14);
        expect(result.minute, 30);
      });

      test('parses midnight correctly', () {
        final TimeOfDay result = TimeOfDayExt.fromJson('2024-01-01T00:00:00.000Z');
        expect(result.hour, 0);
        expect(result.minute, 0);
      });
    });

    group('toJson', () {
      test('serializes TimeOfDay to ISO string', () {
        const tod = TimeOfDay(hour: 14, minute: 30);
        final String result = tod.toJson();
        expect(result, isNotEmpty);
        expect(result, contains('14'));
        expect(result, contains('30'));
      });

      test('serializes midnight correctly', () {
        const tod = TimeOfDay(hour: 0, minute: 0);
        expect(tod.toJson(), isNotEmpty);
      });
    });
  });
}
