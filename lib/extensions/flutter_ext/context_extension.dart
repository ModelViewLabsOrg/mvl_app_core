import 'package:flutter/material.dart';
import 'package:mvl_app_core/utils/show_exception_alert_dialog.dart';
import 'package:mvl_app_core/widgets/app_toast_message.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;

  // Returns the MediaQuery
  MediaQueryData get mq => MediaQuery.of(this);

  /// Returns if Orientation is landscape
  bool get isLandscape => mq.orientation == Orientation.landscape;

  /// Returns same as MediaQuery.of(context).size
  Size get sizePx => mq.size;

  /// Returns same as MediaQuery.of(context).size.width
  double get widthPx => sizePx.width;

  /// Returns same as MediaQuery.of(context).height
  double get heightPx => sizePx.height;

  double get textScaleFactor => mq.textScaler.scale(1);
  bool get isTextBig => textScaleFactor > 1.1;

  double get deviceScaleFactor {
    return switch (widthPx) {
      <= 400 => .85,
      >= 600 => 1.25,
      _ => 1,
    };
  }

  void unfocus() {
    try {
      FocusScope.of(this).unfocus();
      final FocusScopeNode currentScope = FocusScope.of(this);
      if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    } catch (_) {}
  }

  void requestFocus(FocusNode node) {
    FocusScope.of(this).requestFocus(node);
  }

  void dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  void showToastError(Object exception, {StackTrace? stackTrace, String? method}) {
    showException(
      context: this,
      method: method ?? 'showToastError',
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  void showToast(String message) {
    AppToastMessages(message).show(this);
  }
}
