import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvl_app_core/widgets/app_toast_message.dart';

String? Function(BuildContext context, Object? exception) handleException = (_, _) => null;

void showException({required BuildContext context, required Object? exception}) {
  AppToastMessages(_message(context, exception), isError: true).show(context);
}

String _message(BuildContext context, Object? exception) {
  if (exception is String) {
    return exception;
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

  return 'Houve um erro aqui, tente novamente mais tarde!';
}
