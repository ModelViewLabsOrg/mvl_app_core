class AppException implements Exception {
  const AppException(
    this.userMessage, {
    required this.error,
    required this.stackTrace,
    this.shouldLogAsError = true,
  }) : assert(userMessage != '', 'userMessage cannot be empty');

  factory AppException.fromStringError(
    String error,
    StackTrace stackTrace, {
    bool shouldLogAsError = true,
  }) {
    assert(error.isNotEmpty, 'error must not be empty');

    return AppException(
      error,
      error: Exception(error),
      stackTrace: stackTrace,
      shouldLogAsError: shouldLogAsError,
    );
  }

  final String userMessage;
  final Object error;
  final StackTrace stackTrace;
  final bool shouldLogAsError;

  @override
  String toString() {
    return 'AppException: $userMessage${' (Error: $error)'}. shouldLogAsError: $shouldLogAsError';
  }
}
