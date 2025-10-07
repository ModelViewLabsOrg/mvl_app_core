import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvl_app_core/app_logger.dart';
import 'package:mvl_app_core/app_setup.dart';
import 'package:mvl_app_core/widgets/app_error_handler.dart';

Future<void> appMain(AppSetupBase setup, void Function() run) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      AppErrorHandler.registerErrorHandler();
      await setup.initialize();

      run.call();
    },
    (error, stackTrace) {
      AppLogger.I().error('main error', error, stackTrace);
    },
  );
}
