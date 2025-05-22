import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvl_app_core/mvl_app_core.dart';
import 'package:mvl_app_core/utils/show_exception_alert_dialog.dart';

extension AsyncValueUI on AsyncValue<dynamic> {
  bool get isLoading => this is AsyncLoading<dynamic>;

  void showAlertDialogOnError(BuildContext context) {
    if (hasError && error != null) {
      showException(context: context, exception: error);
    }
  }
}

Future<AsyncValue<T>> valueGuard<T>(
  Future<T> Function() future, {
  required String method,
  AsyncValue<T>? withLoading,
}) {
  if (withLoading != null) {
    withLoading = AsyncLoading();
  }

  return AsyncValue.guard(
    future,
    (e) {
      AppLogger.I().error(
        method,
        e,
        StackTrace.current,
        {'method': method, 'error': e.toString()},
      );
      return true;
    },
  );
}
