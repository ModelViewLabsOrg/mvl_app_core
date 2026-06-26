import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/utils/app_version.dart';
import 'package:version/version.dart';

void main() {
  group('AppVersionArgs', () {
    late AppVersionArgs args;

    setUp(() {
      args = AppVersionArgs(min: '1.0.0', ideal: '2.0.0', blacklist: '1.5.0');
    });

    group('check', () {
      test('returns must when current is below min', () {
        expect(args.check(Version.parse('0.9.0')), AppVersionUpdate.must);
        expect(args.check(Version.parse('0.0.1')), AppVersionUpdate.must);
      });

      test('returns must when current is in blacklist', () {
        expect(args.check(Version.parse('1.5.0')), AppVersionUpdate.must);
      });

      test('returns should when current is between min (inclusive) and ideal (exclusive)', () {
        expect(args.check(Version.parse('1.0.0')), AppVersionUpdate.should);
        expect(args.check(Version.parse('1.9.9')), AppVersionUpdate.should);
      });

      test('returns updated when current equals ideal', () {
        expect(args.check(Version.parse('2.0.0')), AppVersionUpdate.updated);
      });

      test('returns updated when current is above ideal', () {
        expect(args.check(Version.parse('2.5.0')), AppVersionUpdate.updated);
        expect(args.check(Version.parse('3.0.0')), AppVersionUpdate.updated);
      });
    });

    group('fromJson', () {
      test('parses all fields from JSON', () {
        final AppVersionArgs parsed = AppVersionArgs.fromJson(const <String, dynamic>{
          'min': '1.0.0',
          'ideal': '2.0.0',
          'blacklist': '1.5.0,1.6.0',
        });

        expect(parsed.min, Version.parse('1.0.0'));
        expect(parsed.ideal, Version.parse('2.0.0'));
        expect(parsed.blacklist, hasLength(2));
        expect(parsed.blacklist, contains(Version.parse('1.5.0')));
        expect(parsed.blacklist, contains(Version.parse('1.6.0')));
      });
    });

    group('toJson', () {
      test('serializes back to JSON', () {
        final Map<String, dynamic> json = AppVersionArgs(
          min: '1.0.0',
          ideal: '2.0.0',
          blacklist: '1.5.0',
        ).toJson();

        expect(json['min'], '1.0.0');
        expect(json['ideal'], '2.0.0');
        expect(json['blacklist'], '1.5.0');
      });

      test('round-trips through JSON', () {
        final original = AppVersionArgs(min: '1.0.0', ideal: '3.0.0', blacklist: '2.0.0,2.1.0');
        final json = original.toJson();
        final restored = AppVersionArgs.fromJson(json);

        expect(restored.min, original.min);
        expect(restored.ideal, original.ideal);
        expect(restored.blacklist, original.blacklist);
      });
    });

    group('multiple blacklisted versions', () {
      test('blacklist with multiple entries blocks each version', () {
        final multi = AppVersionArgs(min: '1.0.0', ideal: '3.0.0', blacklist: '1.5.0,2.0.0');
        expect(multi.check(Version.parse('1.5.0')), AppVersionUpdate.must);
        expect(multi.check(Version.parse('2.0.0')), AppVersionUpdate.must);
        expect(multi.check(Version.parse('2.5.0')), AppVersionUpdate.should);
      });
    });
  });
}
