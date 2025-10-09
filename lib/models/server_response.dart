import 'package:flutter/foundation.dart';
import 'package:mvl_app_core/constants/account_strings.dart';
import 'package:mvl_app_core/mvl_app_core.dart';

@immutable
class ServerResponse {
  const ServerResponse({required this.isError, required this.userMessage});

  factory ServerResponse.fromJson(Json json) {
    return ServerResponse(
      isError: json['is_error'] as bool? ?? false,
      userMessage: json['user_message'] as String,
    );
  }

  factory ServerResponse.success(String message) {
    return ServerResponse(isError: false, userMessage: message);
  }

  factory ServerResponse.customError(String message) {
    return ServerResponse(isError: true, userMessage: message);
  }

  factory ServerResponse.listErrorsValidation(List<String> errors) {
    final plural = errors.length > 1 ? 's' : '';

    return ServerResponse(
      isError: true,
      userMessage:
          'Corrija o$plural erro$plural antes de continuar: '
          '${errors.join('; ')}',
    );
  }

  factory ServerResponse.internalError() {
    return const ServerResponse(
      isError: true,
      userMessage: StringsCore.genericError,
    );
  }

  final bool isError;
  final String userMessage;
}
