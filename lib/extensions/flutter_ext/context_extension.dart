import 'package:flutter/material.dart';
import 'package:mvl_app_core/app_logger.dart';
import 'package:mvl_app_core/constants/account_strings.dart';
import 'package:mvl_app_core/models/server_response.dart';
import 'package:mvl_app_core/utils/show_exception_alert_dialog.dart';
import 'package:mvl_app_core/widgets/app_dimens.dart';
import 'package:mvl_app_core/widgets/app_toast_message.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;

  bool get isDarkMode => theme.brightness == Brightness.dark;
  bool get isLightMode => theme.brightness == Brightness.light;

  // Returns the MediaQuery
  MediaQueryData get mq => MediaQuery.of(this);

  /// Returns if Orientation is landscape
  bool get isLandscape => mq.orientation == Orientation.landscape;

  bool get isLargeScreen => mq.size.width > AppDimens.kBreakpointDesktop;

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
    } catch (e, s) {
      appLogger.error('unfocus error $e', e, s);
    }
  }

  void requestFocus(FocusNode node) {
    FocusScope.of(this).requestFocus(node);
  }

  void dismissKeyboard() => unfocus();

  void showToast(
    String message, {
    String? title,
    bool isError = false,
    int duration = AppToastMessages.secondsDuration,
  }) {
    isError
        ? AppToastMessages(message, isError: true).show(this)
        : AppToastMessages(message).show(this);
  }

  void showError(Object error, {String customMsg = StringsCore.genericError}) {
    return showToast(
      handleErrorMessage(this, error, customMessage: customMsg),
      isError: true,
    );
  }

  void showServerResponse(ServerResponse response) {
    return showToast(response.userMessage, isError: response.isError);
  }

  void logAndShowException({
    required Object exception,
    required String method,
    required StackTrace stackTrace,
    String customMsg = StringsCore.genericError,
  }) {
    appLogger.error(method, exception, stackTrace); //?? StackTrace.current);
    if (mounted) {
      showError(exception, customMsg: customMsg);
    }
  }
}
