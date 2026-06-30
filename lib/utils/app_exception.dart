class AppException implements Exception {
  const AppException(
    this.userMessage, {
    required this.error,
    this.stackTrace,
    this.shouldLogAsError = true,
  });

  final String userMessage;
  final Object error;
  final StackTrace? stackTrace;
  final bool shouldLogAsError;

  @override
  String toString() {
    return 'AppException: $userMessage${' (Error: $error)'}';
  }
}
