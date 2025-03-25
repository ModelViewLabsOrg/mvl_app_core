import 'package:flutter/material.dart';
import 'package:mvl_app_core/widgets/app_dimens.dart';

class AppToastAction {
  AppToastAction({required this.label, required this.onPressed});

  final String label;
  final void Function() onPressed;

  SnackBarAction toToastAction() => SnackBarAction(
        label: label,
        onPressed: onPressed,
      );
}

class AppToastMessages {
  AppToastMessages(
    String message, {
    AppToastAction? action,
    IconData? iconData,
    bool isError = false,
    bool showCloseIcon = false,
  })  : assert(message.isNotEmpty, 'Message must not be empty'),
        snackBar = SnackBar(
          content: _content(
            message,
            iconData ?? (isError ? Icons.error_outline : null),
          ),
          showCloseIcon: !isError && showCloseIcon,
          action: action?.toToastAction(),
        );

  static Widget _content(String message, IconData? iconData) {
    if (iconData == null) return Text(message);

    return Row(
      children: [
        Icon(iconData),
        gapS,
        Expanded(child: Text(message)),
      ],
    );
  }

  final SnackBar snackBar;

  static const int secondsDuration = 4;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context,
  ) {
    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
