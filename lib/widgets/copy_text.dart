import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvl_app_core/widgets/app_toast_message.dart';

class CopyAndShowMessage extends StatelessWidget {
  const CopyAndShowMessage({
    required this.textToCopy,
    this.messageFeedback,
    this.buttonLabel = 'Copiar',
    super.key,
  });

  final String textToCopy;
  final String? messageFeedback;
  final String? buttonLabel;

  Future<void> show(BuildContext context, {bool popBeforeToast = false}) {
    return Clipboard.setData(ClipboardData(text: textToCopy)).then((_) {
      if (!context.mounted) return;
      if (popBeforeToast) Navigator.of(context).pop();

      final messageFeedback = this.messageFeedback;
      if (messageFeedback != null) {
        AppToastMessages(
          messageFeedback,
          icon: const Icon(Icons.copy),
        ).show(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = buttonLabel;

    const icon = Icon(Icons.copy);
    Future<void> onPressed() async => show(context);

    if (label == null) {
      return IconButton(onPressed: onPressed, icon: icon);
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(label),
    );
  }
}
