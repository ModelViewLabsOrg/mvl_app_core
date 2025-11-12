import 'package:flutter/material.dart';
import 'package:mvl_app_core/widgets/app_dimens.dart';

class AppToastAction {
  AppToastAction({required this.label, required this.onPressed});

  final String label;
  final void Function() onPressed;

  SnackBarAction toToastAction() => SnackBarAction(label: label, onPressed: onPressed);
}

class AppToastMessages {
  AppToastMessages(
    String message, {
    String? title,
    AppToastAction? action,
    IconData? iconData,
    bool isError = false,
    bool showCloseIcon = false,
  }) : assert(message.isNotEmpty, 'Message must not be empty'),
       snackBar = SnackBar(
         content: _content(
           message,
           title: title,
           iconData: iconData ?? (isError ? Icons.error_outline : null),
         ),
         showCloseIcon: !isError && showCloseIcon,
         action: action?.toToastAction(),
       );

  static Widget _content(String message, {String? title, IconData? iconData}) {
    final Widget messageWidget = title == null || title.isEmpty
        ? Text(message)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(message),
            ],
          );

    if (iconData == null) {
      return messageWidget;
    }

    return Row(
      children: <Widget>[
        Icon(iconData),
        gapS,
        Expanded(child: messageWidget),
      ],
    );
  }

  final SnackBar snackBar;

  static const secondsDuration = 4;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
