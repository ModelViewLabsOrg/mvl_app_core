import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvl_app_core/extensions/flutter_ext/context_extension.dart';
import 'package:mvl_app_core/mvl_app_core.dart';

extension AsyncValueUI on AsyncValue<dynamic> {
  void showAlertDialogOnError(BuildContext context, [String? method]) {
    final Object? error = this.error;

    if (error != null) {
      context.logAndShowException(
        method: method ?? 'showAlertDialogOnError',
        exception: error,
      );
    }
  }
}

Future<AsyncValue<T>> valueGuard<T>(Future<T> Function() future, {required String method}) {
  bool handleError(Object e) {
    AppLogger.I().error(
      method,
      e,
      StackTrace.current,
      {'method': method, 'error': e.toString()},
    );

    return true;
  }

  return AsyncValue.guard(future, handleError);
}
