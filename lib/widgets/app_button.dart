import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvl_app_core/widgets/app_loading.dart';

enum AppButtonType { filled, elevated, outlined, text }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.onPressed,
    this.isLoading = false,
    this.labelText,
    this.buttonType = AppButtonType.filled,
    this.child,
    this.icon,
    super.key,
  }) : assert(
         (child == null && labelText != null) || (child != null && labelText == null),
         'Must have either a label text for Text or a child, not both',
       );

  final bool isLoading;
  final Future<void> Function()? onPressed;
  final String? labelText;
  final Widget? child;
  final Widget? icon;
  final AppButtonType buttonType;

  @override
  Widget build(BuildContext context) {
    final Future<void> Function()? action;
    final Widget? icon;

    if (isLoading) {
      action = null;
      icon = const AppLoading();
    } else {
      action = onPressed;
      icon = this.icon;
    }

    final Widget label = _label();
    return switch (buttonType) {
      AppButtonType.filled => FilledButton.icon(onPressed: action, label: label, icon: icon),
      AppButtonType.elevated => ElevatedButton.icon(onPressed: action, label: label, icon: icon),
      AppButtonType.outlined => OutlinedButton.icon(onPressed: action, label: label, icon: icon),
      AppButtonType.text => TextButton.icon(onPressed: action, label: label, icon: icon),
    };
  }

  Widget _label() {
    final String? labelText = this.labelText;

    if (labelText != null) {
      return Text(labelText);
    }
    return child ?? const SizedBox();
  }
}
