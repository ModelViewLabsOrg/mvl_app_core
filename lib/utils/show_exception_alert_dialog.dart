import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvl_app_core/app_logger.dart';
import 'package:mvl_app_core/utils/app_exception.dart';
import 'package:mvl_app_core/widgets/app_toast_message.dart';

String? Function(BuildContext context, Object? exception) handleException = (_, _) => null;

var defaultErrorMessage = 'Houve um erro aqui, tente novamente mais tarde!';

void showException({
  required BuildContext context,
  required String method,
  required Object exception,
  StackTrace? stackTrace,
}) {
  AppLogger.I().error(method, exception, stackTrace ?? StackTrace.current);

  AppToastMessages(
    handleErrorMessage(context, exception),
    isError: true,
  ).show(context);
}

String handleErrorMessage(BuildContext context, Object? exception) {
  if (exception is String) {
    return exception;
  }

  if (exception is AppException) {
    return exception.message;
  }

  final String? message = handleException(context, exception);
  if (message != null) {
    return message;
  }

  if (exception is PlatformException) {
    final String? message = exception.message;
    if (message != null && message.isNotEmpty) {
      return message;
    }
  }

  return defaultErrorMessage;
}
