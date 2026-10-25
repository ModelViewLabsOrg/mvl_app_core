import 'package:flutter/services.dart';

/// A generic validator and input sanitizer for names (e.g. user names,
/// entity names, team names, project names).
///
/// By default, only letters, numbers, and spaces are allowed. Special characters
/// and emojis are disallowed unless explicitly enabled via [allowSpecialChars]
/// or [allowEmojis].
class NameValidator {
  const NameValidator({
    this.fieldName = defaultFieldName,
    this.minChars = defaultMinChars,
    this.maxChars = defaultMaxChars,
    this.isRequired = true,
    this.allowSpecialChars = false,
    this.allowEmojis = false,
    this.disallowedRegex,
    this.customErrorMessage,
  }) : assert(minChars >= 0, 'minChars must be non-negative'),
       assert(maxChars >= minChars, 'maxChars must be greater than or equal to minChars'),
       assert(fieldName.length > 0, 'fieldName cannot be empty');

  final String fieldName;
  final int minChars;
  final int maxChars;
  final bool isRequired;
  final bool allowSpecialChars;
  final bool allowEmojis;
  final RegExp? disallowedRegex;
  final String? customErrorMessage;

  static const defaultFieldName = 'Name';
  static const defaultMinChars = 3;
  static const defaultMaxChars = 50;

  /// Pattern matching emojis (pictographic symbols, flags, dingbats/shapes).
  static final emojiRegex = RegExp(
    // ignore: valid_regexps
    r'(\p{Extended_Pictographic}|[\u{1F1E6}-\u{1F1FF}]{2}|[\u{2600}-\u{27BF}])',
    unicode: true,
  );

  /// Pattern matching any character that is not a letter, number, or whitespace.
  static final specialCharsRegex = RegExp(
    r'[^\p{L}\p{N}\s]',
    unicode: true,
  );

  /// Pattern matching characters that are not letters, numbers, whitespace, or emojis.
  static final specialCharsExceptEmojiRegex = RegExp(
    // ignore: valid_regexps
    r'[^\p{L}\p{N}\s\p{Extended_Pictographic}\u{1F1E6}-\u{1F1FF}\u{2600}-\u{27BF}]',
    unicode: true,
  );

  /// Backward-compatible alias for [specialCharsRegex].
  static RegExp get defaultDisallowedCharsRegex => specialCharsRegex;

  /// Backward-compatible alias for [defaultDisallowedCharsRegex].
  static RegExp get disallowedCharsRegex => defaultDisallowedCharsRegex;

  /// Default text input formatter that denies special characters and emojis.
  static final TextInputFormatter defaultInputFormatter = FilteringTextInputFormatter.deny(
    specialCharsRegex,
  );

  /// Backward-compatible alias for [defaultInputFormatter].
  static TextInputFormatter get inputFormatter => defaultInputFormatter;

  /// Formatter tailored to this instance's configuration.
  TextInputFormatter get formatter => createInputFormatter(
    allowSpecialChars: allowSpecialChars,
    allowEmojis: allowEmojis,
    disallowedRegex: disallowedRegex,
  );

  /// Default error message when input contains special characters.
  static const specialCharsErrorMessage = 'Name cannot contain special characters';

  /// Default error message when input contains emojis.
  static const emojisErrorMessage = 'Name cannot contain emojis';

  /// Backward-compatible error message.
  static const String disallowedCharsErrorMessage = specialCharsErrorMessage;

  /// Creates a [TextInputFormatter] based on allowed character rules.
  static TextInputFormatter createInputFormatter({
    bool allowSpecialChars = false,
    bool allowEmojis = false,
    RegExp? disallowedRegex,
  }) {
    if (disallowedRegex != null) {
      return FilteringTextInputFormatter.deny(disallowedRegex);
    }
    if (!allowSpecialChars && !allowEmojis) {
      return FilteringTextInputFormatter.deny(specialCharsRegex);
    }
    if (!allowSpecialChars && allowEmojis) {
      return FilteringTextInputFormatter.deny(specialCharsExceptEmojiRegex);
    }
    if (allowSpecialChars && !allowEmojis) {
      return FilteringTextInputFormatter.deny(emojiRegex);
    }
    return FilteringTextInputFormatter.deny(RegExp('[]'));
  }

  /// Builds error message for special characters formatted with [fieldName].
  static String formatSpecialCharsError([String fieldName = defaultFieldName]) {
    assert(fieldName.isNotEmpty, 'fieldName cannot be empty');
    return '$fieldName cannot contain special characters';
  }

  /// Builds error message for emojis formatted with [fieldName].
  static String formatEmojisError([String fieldName = defaultFieldName]) {
    assert(fieldName.isNotEmpty, 'fieldName cannot be empty');
    return '$fieldName cannot contain emojis';
  }

  /// Builds the error message for disallowed characters formatted with [fieldName].
  /// Kept for backward compatibility.
  static String formatDisallowedCharsError([String fieldName = defaultFieldName]) {
    return formatSpecialCharsError(fieldName);
  }

  /// Validates [value] against length constraints, emojis, special characters,
  /// and custom disallowed rules.
  ///
  /// Can be used directly as a Flutter `FormFieldValidator` tear-off:
  /// `validator: NameValidator.validate`.
  static String? validate(
    String? value, {
    String fieldName = defaultFieldName,
    int minChars = defaultMinChars,
    int maxChars = defaultMaxChars,
    bool isRequired = true,
    bool allowSpecialChars = false,
    bool allowEmojis = false,
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

    if (!allowEmojis && emojiRegex.hasMatch(trimmed)) {
      return customErrorMessage ?? formatEmojisError(fieldName);
    }

    if (!allowSpecialChars) {
      final RegExp regex = allowEmojis ? specialCharsExceptEmojiRegex : specialCharsRegex;
      if (regex.hasMatch(trimmed)) {
        return customErrorMessage ?? formatSpecialCharsError(fieldName);
      }
    }

    if (disallowedRegex != null && disallowedRegex.hasMatch(trimmed)) {
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
    bool allowSpecialChars = false,
    bool allowEmojis = false,
    RegExp? disallowedRegex,
  }) {
    return validate(
          value,
          fieldName: fieldName,
          minChars: minChars,
          maxChars: maxChars,
          isRequired: isRequired,
          allowSpecialChars: allowSpecialChars,
          allowEmojis: allowEmojis,
          disallowedRegex: disallowedRegex,
        ) ==
        null;
  }

  /// Sanitizes [value] by removing characters disallowed by configuration.
  static String sanitize(
    String value, {
    bool allowSpecialChars = false,
    bool allowEmojis = false,
    RegExp? disallowedRegex,
  }) {
    var result = value;
    if (disallowedRegex != null) {
      result = result.replaceAll(disallowedRegex, '');
    }
    if (!allowEmojis) {
      result = result.replaceAll(emojiRegex, '');
    }
    if (!allowSpecialChars) {
      final RegExp regex = allowEmojis ? specialCharsExceptEmojiEmojiRegexSafe : specialCharsRegex;
      result = result.replaceAll(regex, '');
    }
    return result;
  }

  /// Alias helper for internal sanitization.
  static RegExp get specialCharsExceptEmojiEmojiRegexSafe => specialCharsExceptEmojiRegex;

  /// Validates [value] using this instance's configuration.
  String? call(String? value) {
    return validate(
      value,
      fieldName: fieldName,
      minChars: minChars,
      maxChars: maxChars,
      isRequired: isRequired,
      allowSpecialChars: allowSpecialChars,
      allowEmojis: allowEmojis,
      disallowedRegex: disallowedRegex,
      customErrorMessage: customErrorMessage,
    );
  }
}

/// Backward-compatible alias for projects referencing [TeamNameValidator].
typedef TeamNameValidator = NameValidator;
