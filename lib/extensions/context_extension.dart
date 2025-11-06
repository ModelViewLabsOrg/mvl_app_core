import 'package:flutter/material.dart';
import 'package:mvl_app_core/utils/show_exception_alert_dialog.dart';
import 'package:mvl_app_core/widgets/app_toast_message.dart';

extension ContextExtensions on BuildContext {
  // Returns the MediaQuery
  MediaQueryData get mq => MediaQuery.of(this);
  MediaQueryData get media => MediaQuery.of(this);

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;

  /// Returns same as MediaQuery.of(context).size
  Size get size => mq.size;

  double get deviceHeight => size.height;
  double get deviceWidth => size.width;

  double get textScaleFactor => mq.textScaler.scale(1);
  bool get isTextBig => textScaleFactor > 1.1;

  double get deviceScaleFactor {
    return switch (deviceWidth) {
      <= 400 => .85,
      >= 600 => 1.25,
      _ => 1,
    };
  }

  /// Returns if Orientation is landscape
  bool get isLandscape => mq.orientation == Orientation.landscape;
  bool get isPortrait => mq.orientation == Orientation.portrait;

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
}
