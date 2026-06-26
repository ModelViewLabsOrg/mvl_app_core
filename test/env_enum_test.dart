import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/utils/env_enum.dart';

void main() {
  group('EnvEnumExt', () {
    group('isDev', () {
      test('returns true only for dev', () {
        expect(EnvEnum.dev.isDev, isTrue);
        expect(EnvEnum.uat.isDev, isFalse);
        expect(EnvEnum.prd.isDev, isFalse);
      });
    });

    group('isUat', () {
      test('returns true only for uat', () {
        expect(EnvEnum.uat.isUat, isTrue);
        expect(EnvEnum.dev.isUat, isFalse);
        expect(EnvEnum.prd.isUat, isFalse);
      });
    });

    group('isPrd', () {
      test('returns true only for prd', () {
        expect(EnvEnum.prd.isPrd, isTrue);
        expect(EnvEnum.dev.isPrd, isFalse);
        expect(EnvEnum.uat.isPrd, isFalse);
      });
    });

    test('enum has exactly 3 values', () {
      expect(EnvEnum.values.length, 3);
    });
  });

  group('AppFlavor', () {
    test('default env is prd', () {
      expect(AppFlavor.env, EnvEnum.prd);
    });

    test('env can be changed', () {
      AppFlavor.env = EnvEnum.dev;
      expect(AppFlavor.env, EnvEnum.dev);
      AppFlavor.env = EnvEnum.prd;
    });
  });
}
