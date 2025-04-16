class EmailValidator {
  EmailValidator(this.email);
  final String? email;

  static String normalize(String email) => email.trim().toLowerCase();

  final _emailRegex = RegExp(
    '^[a-zA-Z0-9]+[a-zA-Z0-9._%+-]+[a-zA-Z0-9_-]+@'
    r'[a-zA-Z0-9]+[a-zA-Z0-9-.]*\.[a-zA-Z]{2,}$',
  );

  bool isValid() {
    final String value = normalize(email ?? '');
    if (value.isEmpty) {
      return false;
    }
    if (value.contains('..')) {
      return false;
    }
    if (value.contains('--')) {
      return false;
    }
    if (value.contains('-.')) {
      return false;
    }
    if (!value.contains('@')) {
      return false;
    }
    if (value.length > 254) {
      return false;
    }

    final List<String> split = value.split('@');
    if (split.length != 2) {
      return false;
    }
    if (split.first.length > 63) {
      return false;
    }

    return _emailRegex.hasMatch(value);
  }
}

extension EmailValidatorExt on EmailValidator {
  String normalize() => EmailValidator.normalize(email ?? '');
}
