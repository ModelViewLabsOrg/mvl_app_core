import 'dart:async';

import 'package:mvl_app_core/constants/account_strings.dart';
import 'package:mvl_app_core/models/server_response.dart';
import 'package:mvl_app_core/mvl_app_core.dart';
import 'package:mvl_app_core/mvl_app_core_view.dart';
import 'package:mvl_app_core/network/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Widget withConstraint(Widget child) {
  return Container(
    constraints: const BoxConstraints(maxWidth: AppDimens.kMaxWidth),
    padding: const EdgeInsets.fromLTRB(
      AppDimens.kDefaultPadding,
      0,
      AppDimens.kDefaultPadding,
      AppDimens.kPaddingXL,
    ),
    child: child,
  );
}

Widget withConstraintCenter(Widget child) => Center(child: withConstraint(child));

Widget widgetBottomPadding(BuildContext context, [double adicional = 0]) {
  return SizedBox(height: bottomPadding(context, adicional));
}

double bottomPadding(BuildContext context, [double adicional = 0]) {
  return MediaQuery.of(context).viewInsets.bottom + adicional;
}

Future<void> showSnackbarServerResponse(
  BuildContext context,
  ServerResponse response,
) {
  return showSnackbar(context, response.userMessage, isError: response.isError);
}

Future<void> showSnackbar(
  BuildContext context,
  String message, {
  String? title,
  bool isError = false,
  int duration = AppToastMessages.secondsDuration,
}) async {
  isError
      ? AppToastMessages(message, isError: true).show(context)
      : AppToastMessages(message).show(context);
}

Future<void> showSnackbarError(
  BuildContext context,
  Object? error, {
  String customError = StringsCore.genericError,
}) {
  if (error is String) {
    return showSnackbar(context, error, isError: true);
  }

  var errorMessage = customError;
  if (error is NetworkException) {
    final String? userMessage = error.userMessage;
    if (userMessage != null) {
      errorMessage = userMessage;
    }
  } else if (error is ServerResponse) {
    errorMessage = error.userMessage;
  } else if (error is FunctionException) {
    final dynamic details = error.details;
    if (details is Json) {
      final userMessage = details['user_message'] as String?;
      if (userMessage != null) {
        errorMessage = userMessage;
      }
    }
  } else if (error is AppException) {
    final String? userMessage = error.userMessage;
    if (userMessage != null) {
      errorMessage = userMessage;
    }
  }
  // else if (error is AuthWeakPasswordException) {
  //   errorMessage = 'Essa senha é muito fraca, tente usar uma senha mais forte';
  // }

  return showSnackbar(context, errorMessage, isError: true);
}

void dismissKeyboard(BuildContext context) => context.unfocus();
