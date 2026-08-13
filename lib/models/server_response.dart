import 'package:flutter/foundation.dart';
import 'package:mvl_app_core/constants/account_strings.dart';
import 'package:mvl_app_core/mvl_app_core.dart';
import 'package:mvl_app_core/utils/app_exception.dart';

@immutable
class ServerResponse {
  const ServerResponse({required this.isError, required this.userMessage, this.data});

  factory ServerResponse.fromJson(Json json) {
    return ServerResponse(
      isError: json['is_error'] as bool? ?? false,
      userMessage: json['user_message'] as String? ?? '',
      data: json['data'] as Json?,
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
  final Json? data;

  ServerResponseException asException() => ServerResponseException(this);
}

class ServerResponseException extends AppException {
  ServerResponseException(ServerResponse response)
    : assert(response.isError, 'response must be an error'),
      super(
        response.userMessage,
        error: Exception(response.userMessage),
        stackTrace: StackTrace.current,
      );

  @override
  String get reportType => 'ServerResponseException';

  /// The server already decided this is a business rule the user can act on,
  /// so the message it chose is what separates one defect from another.
  @override
  List<String> get reportGrouping => <String>[ErrorGrouping.normalizeMessage(userMessage)];
}
