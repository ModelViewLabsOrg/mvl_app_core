import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvl_app_core/app_logger.dart';
import 'package:mvl_app_core/constants/account_strings.dart';
import 'package:mvl_app_core/models/server_response.dart';
import 'package:mvl_app_core/network/exceptions.dart';
import 'package:mvl_app_core/utils/json.dart';
import 'package:mvl_app_core/widgets/app_toast_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String? Function(BuildContext context, Object? exception) handleException = (_, _) => null;

String defaultErrorMessage = StringsCore.genericError;

void showException({
  required BuildContext context,
  required String method,
  required Object exception,
  StackTrace? stackTrace,
  String customError = StringsCore.genericError,
}) {
  AppLogger.I().error(method, exception, stackTrace ?? StackTrace.current);

  AppToastMessages(
    handleErrorMessage(context, exception),
    isError: true,
  ).show(context);
}

String handleErrorMessage(BuildContext context, Object? exception, {String? customMessage}) {
  if (exception == null) {
    return customMessage ?? defaultErrorMessage;
  }

  final Object error = exception;

  if (error is String) {
    return error;
  }

  if (error is AppException) {
    final String? userMessage = error.userMessage;
    if (userMessage != null) {
      return userMessage;
    }
  }

  if (error is NetworkException) {
    final String? userMessage = error.userMessage;
    if (userMessage != null) {
      return userMessage;
    }
  }

  if (error is ServerResponse) {
    return error.userMessage;
  }

  if (error is FunctionException) {
    final dynamic details = error.details;
    if (details is Json) {
      final userMessage = details['user_message'] as String?;
      if (userMessage != null) {
        return userMessage;
      }
    }
  }

  if (exception is PlatformException) {
    final String? message = exception.message;
    if (message != null && message.isNotEmpty) {
      return message;
    }
  }

  if (error is AuthWeakPasswordException) {
    return 'Essa senha é muito fraca, tente usar uma senha mais forte';
  }

  final String? message = handleException(context, exception);
  if (message != null) {
    return message;
  }

  return customMessage ?? defaultErrorMessage;
}
