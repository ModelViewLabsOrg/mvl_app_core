import 'package:mvl_app_core/utils/app_exception.dart';

class NetworkException extends AppException {
  const NetworkException(
    super.userMessage, {
    required super.error,
    required super.shouldLogAsError,
  });
}

class OtpValidationException extends NetworkException {
  const OtpValidationException(
    super.userMessage, {
    required super.error,
    required super.shouldLogAsError,
  });
}

class AuthOtpValidationExpiredException extends NetworkException {
  AuthOtpValidationExpiredException()
    : super(
        'Esse código expirou, vamos te enviar um novo. '
        'Confira seu email o novo código',
        error: Exception(
          'Esse código expirou, vamos te enviar um novo. '
          'Confira seu email o novo código',
        ),
        shouldLogAsError: false,
      );
}

class AppFormError extends AppException {
  const AppFormError(super.userMessage, {required super.error}) : super(shouldLogAsError: false);

  @override
  bool get shouldLogAsError => false;

  @override
  String toString() => 'AppFormError: $userMessage';
}
