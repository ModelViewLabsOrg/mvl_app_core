import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvl_app_core/widgets/app_toast_message.dart';

String genericErrorMessage = 'Something went wrong. Please try again later.';

String? Function(dynamic exception) handleException = (_) => null;

void showException({required BuildContext context, required dynamic exception}) {
  AppToastMessages(_message(exception), isError: true).show(context);
}

String _message(dynamic exception) {
  final message = handleException(exception);
  if (message != null) return message;

  if (exception is PlatformException) return exception.message ?? genericErrorMessage;

  //  exception.toString();
  return genericErrorMessage;
}
