import 'package:flutter/material.dart';

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
    String? title,
    Icon? icon,
    bool isError = false,
    bool showCloseIcon = false,
  })  : assert(message.isNotEmpty, 'Message must not be empty'),
        snackBar = SnackBar(
          content: _content(
            message,
            title,
            icon ?? (isError ? const Icon(Icons.error_outline) : null),
          ),
          showCloseIcon: !isError && showCloseIcon,
          action: action?.toToastAction(),
        );

  static Widget _content(String message, String? title, Icon? icon) {
    if (icon == null) return _textContent(message, title);

    return Row(
      children: [
        icon,
        _textContent(message, title),
      ],
    );
  }

  static Widget _textContent(String message, String? title) {
    if (title == null) return Text(message);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Text(message),
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
