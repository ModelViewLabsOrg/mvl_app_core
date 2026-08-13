import 'package:mvl_app_core/utils/app_exception.dart';

class NetworkException extends AppException {
  NetworkException(
    super.userMessage, {
    required super.error,
    required super.shouldLogAsError,
  }) : super(stackTrace: StackTrace.current);

  factory NetworkException.fromStringError(String error, {bool shouldLogAsError = true}) {
    return NetworkException(error, error: Exception(error), shouldLogAsError: shouldLogAsError);
  }

  @override
  String get reportType => 'NetworkException';
}

class OtpValidationException extends NetworkException {
  OtpValidationException([
    super.userMessage = 'Confira o código de confirmação enviado para sua conta',
  ]) : super(error: Exception(userMessage), shouldLogAsError: false);

  @override
  String get reportType => 'OtpValidationException';
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

  @override
  String get reportType => 'AuthOtpValidationExpiredException';
}

class AppFormError extends AppException {
  AppFormError([super.userMessage = 'Campo obrigatório'])
    : super(error: Exception(userMessage), shouldLogAsError: false, stackTrace: StackTrace.current);

  @override
  bool get shouldLogAsError => false;

  @override
  String get reportType => 'AppFormError';

  @override
  String toString() => userMessage;
}
