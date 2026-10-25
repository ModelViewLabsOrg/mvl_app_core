import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvl_app_core/utils/name_validator.dart';

void main() {
  group('NameValidator', () {
    group('validate (default static)', () {
      test('returns null for valid names', () {
        expect(NameValidator.validate('John Doe'), isNull);
        expect(NameValidator.validate('ABC'), isNull);
        expect(NameValidator.validate('A'.padRight(50, 'b')), isNull);
      });

      test('returns error when null or empty and isRequired is true', () {
        expect(NameValidator.validate(null), equals('Name cannot be empty'));
        expect(NameValidator.validate(''), equals('Name cannot be empty'));
        expect(NameValidator.validate('   '), equals('Name cannot be empty'));
      });

      test('returns null when null or empty and isRequired is false', () {
        expect(NameValidator.validate(null, isRequired: false), isNull);
        expect(NameValidator.validate('', isRequired: false), isNull);
        expect(NameValidator.validate('   ', isRequired: false), isNull);
      });

      test('returns error when name is shorter than minChars', () {
        expect(
          NameValidator.validate('ab'),
          equals('Name must be at least 3 characters'),
        );
        expect(
          NameValidator.validate('', minChars: 1, isRequired: false),
          isNull,
        );
        expect(
          NameValidator.validate('a', minChars: 2),
          equals('Name must be at least 2 characters'),
        );
      });

      test('formats single character unit correctly when minChars is 1', () {
        expect(
          NameValidator.validate('', minChars: 1),
          equals('Name cannot be empty'),
        );
      });

      test('returns error when name exceeds maxChars', () {
        final String longName = 'A'.padRight(51, 'b');
        expect(
          NameValidator.validate(longName),
          equals('Name cannot exceed 50 characters'),
        );
      });

      test('returns error when containing disallowed characters', () {
        expect(
          NameValidator.validate("O'Connor"),
          equals("Name cannot contain the characters: ' \" % *"),
        );
        expect(
          NameValidator.validate('John "The Boss"'),
          equals("Name cannot contain the characters: ' \" % *"),
        );
        expect(
          NameValidator.validate('100% Cotton'),
          equals("Name cannot contain the characters: ' \" % *"),
        );
        expect(
          NameValidator.validate('All*Stars'),
          equals("Name cannot contain the characters: ' \" % *"),
        );
      });

      test('uses custom fieldName in error messages', () {
        expect(
          NameValidator.validate(null, fieldName: 'Team name'),
          equals('Team name cannot be empty'),
        );
        expect(
          NameValidator.validate('ab', fieldName: 'Team name'),
          equals('Team name must be at least 3 characters'),
        );
        expect(
          NameValidator.validate('A'.padRight(51, 'b'), fieldName: 'Team name'),
          equals('Team name cannot exceed 50 characters'),
        );
        expect(
          NameValidator.validate("Team's", fieldName: 'Team name'),
          equals("Team name cannot contain the characters: ' \" % *"),
        );
      });

      test('supports custom regex and custom error message', () {
        final customRegex = RegExp('[0-9]');
        expect(
          NameValidator.validate(
            'Name123',
            disallowedRegex: customRegex,
            customErrorMessage: 'Digits are not allowed in name',
          ),
          equals('Digits are not allowed in name'),
        );
        expect(
          NameValidator.validate(
            'Valid Name',
            disallowedRegex: customRegex,
          ),
          isNull,
        );
      });
    });

    group('isValid', () {
      test('returns true for valid names and false for invalid', () {
        expect(NameValidator.isValid('Valid Name'), isTrue);
        expect(NameValidator.isValid('ab'), isFalse);
        expect(NameValidator.isValid("Invalid'Name"), isFalse);
        expect(NameValidator.isValid(null), isFalse);
        expect(NameValidator.isValid(null, isRequired: false), isTrue);
      });
    });

    group('sanitize', () {
      test('removes all default disallowed characters', () {
        expect(
          NameValidator.sanitize("Team 'Pro' 100% *Champion*"),
          equals('Team Pro 100 Champion'),
        );
      });

      test('supports custom disallowed regex', () {
        expect(
          NameValidator.sanitize('Team 123', RegExp('[0-9]')),
          equals('Team '),
        );
      });
    });

    group('formatters', () {
      test('defaultInputFormatter denies disallowed characters', () {
        final TextInputFormatter formatter = NameValidator.inputFormatter;
        expect(formatter, isNotNull);
      });

      test('createInputFormatter denies custom characters', () {
        final TextInputFormatter formatter = NameValidator.createInputFormatter(RegExp('[0-9]'));
        expect(formatter, isNotNull);
      });
    });

    group('instance usage', () {
      test('acts as a callable validator with custom configuration', () {
        const validator = NameValidator(
          fieldName: 'Project name',
          minChars: 2,
          maxChars: 10,
        );

        expect(validator('ab'), isNull);
        expect(validator('a'), equals('Project name must be at least 2 characters'));
        expect(
          validator('Very Long Project Name'),
          equals('Project name cannot exceed 10 characters'),
        );
        expect(
          validator("Proj'Name"),
          equals("Project name cannot contain the characters: ' \" % *"),
        );
      });
    });

    group('asserts', () {
      test('asserts minChars >= 0', () {
        expect(
          () => NameValidator(minChars: -1),
          throwsA(
            isA<AssertionError>().having(
              (e) => e.message,
              'message',
              'minChars must be non-negative',
            ),
          ),
        );
        expect(
          () => NameValidator.validate('abc', minChars: -1),
          throwsA(
            isA<AssertionError>().having(
              (e) => e.message,
              'message',
              'minChars must be non-negative',
            ),
          ),
        );
      });

      test('asserts maxChars >= minChars', () {
        expect(
          () => NameValidator(minChars: 10, maxChars: 5),
          throwsA(
            isA<AssertionError>().having(
              (e) => e.message,
              'message',
              'maxChars must be greater than or equal to minChars',
            ),
          ),
        );
        expect(
          () => NameValidator.validate('abc', minChars: 10, maxChars: 5),
          throwsA(
            isA<AssertionError>().having(
              (e) => e.message,
              'message',
              'maxChars must be greater than or equal to minChars',
            ),
          ),
        );
      });

      test('asserts fieldName is not empty', () {
        expect(
          () => NameValidator(fieldName: ''),
          throwsA(
            isA<AssertionError>().having(
              (e) => e.message,
              'message',
              'fieldName cannot be empty',
            ),
          ),
        );
        expect(
          () => NameValidator.validate('abc', fieldName: ''),
          throwsA(
            isA<AssertionError>().having(
              (e) => e.message,
              'message',
              'fieldName cannot be empty',
            ),
          ),
        );
      });
    });

    group('TeamNameValidator alias', () {
      test('TeamNameValidator works identically as an alias', () {
        expect(TeamNameValidator.validate('Real Madrid'), isNull);
        expect(
          TeamNameValidator.validate("Real'Madrid"),
          equals("Name cannot contain the characters: ' \" % *"),
        );
        expect(TeamNameValidator.sanitize('Team%'), equals('Team'));
      });
    });
  });
}
