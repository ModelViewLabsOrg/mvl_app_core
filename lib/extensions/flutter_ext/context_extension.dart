import 'package:flutter/material.dart';
import 'package:mvl_app_core/constants/account_strings.dart';
import 'package:mvl_app_core/mvl_app_core.dart';
import 'package:mvl_app_core/widgets/base_view.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;

  bool get isDarkMode => theme.brightness == Brightness.dark;
  bool get isLightMode => theme.brightness == Brightness.light;

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
  double textScaleFactorAjustment(double value) => value * textScaleFactor;

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

  void dismissKeyboard() => unfocus();

  void showToast(String message, {String? title}) => showSnackbar(this, message, title: title);

  void showError(Object error) => showSnackbarError(this, error);

  void logAndShowException({
    required Object exception,
    required String method,
    StackTrace? stackTrace,
    String customError = StringsCore.genericError,
  }) {
    AppLogger.I().error(method, exception, stackTrace ?? StackTrace.current);
    if (mounted) {
      showSnackbarError(this, exception, customError: customError);
    }
  }
}
