import 'package:flutter/services.dart';

/// A generic validator and input sanitizer for names (e.g. user names,
/// entity names, team names, project names).
class NameValidator {
  const NameValidator({
    this.fieldName = defaultFieldName,
    this.minChars = defaultMinChars,
    this.maxChars = defaultMaxChars,
    this.isRequired = true,
    this.disallowedRegex,
    this.customErrorMessage,
  }) : assert(minChars >= 0, 'minChars must be non-negative'),
       assert(maxChars >= minChars, 'maxChars must be greater than or equal to minChars'),
       assert(fieldName.length > 0, 'fieldName cannot be empty');

  final String fieldName;
  final int minChars;
  final int maxChars;
  final bool isRequired;
  final RegExp? disallowedRegex;
  final String? customErrorMessage;

  static const defaultFieldName = 'Name';
  static const defaultMinChars = 3;
  static const defaultMaxChars = 50;

  /// Default regular expression for disallowed characters: `'`, `"`, `%`, and `*`.
  static final defaultDisallowedCharsRegex = RegExp("['\"%*]");

  /// Backward-compatible alias for [defaultDisallowedCharsRegex].
  static RegExp get disallowedCharsRegex => defaultDisallowedCharsRegex;

  /// Default text input formatter that denies [defaultDisallowedCharsRegex].
  static final TextInputFormatter defaultInputFormatter = FilteringTextInputFormatter.deny(
    defaultDisallowedCharsRegex,
  );

  /// Backward-compatible alias for [defaultInputFormatter].
  static TextInputFormatter get inputFormatter => defaultInputFormatter;

  /// Default error message for disallowed characters in English.
  static const disallowedCharsErrorMessage = "Name cannot contain the characters: ' \" % *";

  /// Creates a [TextInputFormatter] that denies characters matching [disallowedRegex].
  static TextInputFormatter createInputFormatter([RegExp? disallowedRegex]) {
    return FilteringTextInputFormatter.deny(disallowedRegex ?? defaultDisallowedCharsRegex);
  }

  /// Builds the error message for disallowed characters formatted with [fieldName].
  static String formatDisallowedCharsError([String fieldName = defaultFieldName]) {
    assert(fieldName.isNotEmpty, 'fieldName cannot be empty');
    return "$fieldName cannot contain the characters: ' \" % *";
  }

  /// Validates [value] against length constraints and disallowed characters.
  ///
  /// Can be used directly as a Flutter `FormFieldValidator` tear-off:
  /// `validator: NameValidator.validate`.
  static String? validate(
    String? value, {
    String fieldName = defaultFieldName,
    int minChars = defaultMinChars,
    int maxChars = defaultMaxChars,
    bool isRequired = true,
    RegExp? disallowedRegex,
    String? customErrorMessage,
  }) {
    assert(minChars >= 0, 'minChars must be non-negative');
    assert(maxChars >= minChars, 'maxChars must be greater than or equal to minChars');
    assert(fieldName.isNotEmpty, 'fieldName cannot be empty');

    final String? trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return isRequired ? '$fieldName cannot be empty' : null;
    }

    if (trimmed.length < minChars) {
      final unit = minChars == 1 ? 'character' : 'characters';
      return '$fieldName must be at least $minChars $unit';
    }

    if (trimmed.length > maxChars) {
      return '$fieldName cannot exceed $maxChars characters';
    }

    final RegExp regex = disallowedRegex ?? defaultDisallowedCharsRegex;
    if (regex.hasMatch(trimmed)) {
      return customErrorMessage ?? formatDisallowedCharsError(fieldName);
    }

    return null;
  }

  /// Returns `true` if [value] satisfies all validation rules.
  static bool isValid(
    String? value, {
    String fieldName = defaultFieldName,
    int minChars = defaultMinChars,
    int maxChars = defaultMaxChars,
    bool isRequired = true,
    RegExp? disallowedRegex,
  }) {
    return validate(
          value,
          fieldName: fieldName,
          minChars: minChars,
          maxChars: maxChars,
          isRequired: isRequired,
          disallowedRegex: disallowedRegex,
        ) ==
        null;
  }

  /// Sanitizes [value] by removing all disallowed characters.
  static String sanitize(String value, [RegExp? disallowedRegex]) {
    return value.replaceAll(disallowedRegex ?? defaultDisallowedCharsRegex, '');
  }

  /// Validates [value] using this instance's configuration.
  String? call(String? value) {
    return validate(
      value,
      fieldName: fieldName,
      minChars: minChars,
      maxChars: maxChars,
      isRequired: isRequired,
      disallowedRegex: disallowedRegex,
      customErrorMessage: customErrorMessage,
    );
  }
}

/// Backward-compatible alias for projects referencing [TeamNameValidator].
typedef TeamNameValidator = NameValidator;
