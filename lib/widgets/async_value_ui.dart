import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvl_app_core/utils/show_exception_alert_dialog.dart';

extension AsyncValueUI on AsyncValue<dynamic> {
  bool get isLoading => this is AsyncLoading<dynamic>;

  void showAlertDialogOnError(BuildContext context) {
    if (hasError && error != null) {
      showException(context: context, exception: error);
    }
  }
}
