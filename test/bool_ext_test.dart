import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/extensions/bool_ext.dart';

void main() {
  group('BoolExt.toPtBr', () {
    test('returns "Sim" for true', () {
      expect(true.toPtBr(), 'Sim');
    });

    test('returns "Não" for false', () {
      expect(false.toPtBr(), 'Não');
    });
  });
}
