class AppException implements Exception {
  const AppException(
    this.userMessage, {
    required this.error,
    this.stackTrace,
    this.shouldLogAsError = true,
  }) : assert(userMessage != '', 'userMessage cannot be empty'),
       assert(error is Exception || error is String, 'error must be an Exception or a String');

  final String userMessage;
  final Object error;
  final StackTrace? stackTrace;
  final bool shouldLogAsError;

  @override
  String toString() {
    return 'AppException: $userMessage${' (Error: $error)'}. shouldLogAsError: $shouldLogAsError';
  }
}
