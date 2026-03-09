import 'dart:async';

import 'package:mvl_app_core/constants/account_strings.dart';
import 'package:mvl_app_core/models/server_response.dart';
import 'package:mvl_app_core/mvl_app_core_view.dart';
import 'package:mvl_app_core/utils/show_exception_alert_dialog.dart';

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
  return showSnackbar(context, handleErrorMessage(context, error), isError: true);
}

void dismissKeyboard(BuildContext context) => context.unfocus();
