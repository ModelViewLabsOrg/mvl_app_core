class AppException implements Exception {
  const AppException(
    this.message, {
    required this.error,
    this.stackTrace,
    this.shouldLogAsError = true,
  });

  final String message;
  final Object error;
  final StackTrace? stackTrace;
  final bool shouldLogAsError;

  @override
  String toString() {
    return 'AppException: $message${' (Error: $error)'}';
  }
}

class AppFormError extends AppException {
  const AppFormError(super.message) : super(error: message);

  @override
  bool get shouldLogAsError => false;

  @override
  String toString() => 'AppFormError: $message';
}
