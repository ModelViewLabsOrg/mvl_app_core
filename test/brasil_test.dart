import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/brazil/brasil.dart';

void main() {
  group('BrasilState', () {
    test('has 27 state values', () {
      expect(BrasilState.values.length, 27);
    });
  });

  group('stateFromJson', () {
    test('parses state string to BrasilState enum', () {
      expect(stateFromJson('sp'), BrasilState.sp);
      expect(stateFromJson('rj'), BrasilState.rj);
      expect(stateFromJson('ac'), BrasilState.ac);
    });
  });

  group('BrasilStateExt', () {
    test('state returns full name from Brasil.listStates', () {
      expect(BrasilState.sp.state, 'São Paulo');
      expect(BrasilState.rj.state, 'Rio de Janeiro');
      expect(BrasilState.ac.state, 'Acre');
    });
  });

  group('Brasil', () {
    test('country is br', () {
      expect(Brasil.country, 'br');
    });

    test('listStates contains all 27 states', () {
      expect(Brasil.listStates.length, 27);
    });

    test('statesFullNames returns list of all state names', () {
      final List<String> names = Brasil.statesFullNames;
      expect(names, hasLength(27));
      expect(names, contains('São Paulo'));
      expect(names, contains('Amazonas'));
    });
  });
}
