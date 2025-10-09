class AppException implements Exception {
  const AppException({required this.userMessage, this.shouldLogAsError = true});

  final String? userMessage;
  final bool shouldLogAsError;

  @override
  String toString() => '${super.toString()}; [$shouldLogAsError]; $userMessage';
}

class NetworkException extends AppException {
  const NetworkException({
    required super.userMessage,
    required super.shouldLogAsError,
  });
}

class OtpValidationException extends NetworkException {
  const OtpValidationException({required super.userMessage}) : super(shouldLogAsError: false);
}

class AuthOtpValidationExpiredException extends NetworkException {
  AuthOtpValidationExpiredException()
    : super(
        userMessage:
            'Esse código expirou, vamos te enviar um novo. '
            'Confira seu email o novo código',
        shouldLogAsError: false,
      );
}
