import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvl_app_core/widgets/app_toast_message.dart';

String? Function(BuildContext context, dynamic exception) handleException = (_, _) => null;

void showException({required BuildContext context, required dynamic exception}) {
  AppToastMessages(_message(context, exception), isError: true).show(context);
}

String _message(BuildContext context, dynamic exception) {
  final message = handleException(context, exception);
  if (message != null) return message;

  if (exception is PlatformException) {
    final message = exception.message;
    if (message != null && message.isNotEmpty) return message;
  }

  return 'Houve um erro aqui, tente novamente mais tarde!';
}
