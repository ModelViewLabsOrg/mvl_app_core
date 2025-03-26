import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvl_app_core/app_logger.dart';

class AppErrorHandler {
  static void registerErrorHandler() {
    FlutterError.onError = (details) {
      AppLogger.I().error(
        details.summary.name ?? 'onError',
        details.exception,
        details.stack ?? StackTrace.current,
      );

      FlutterError.presentError(details);
    };

    // * Handle errors from the underlying platform/OS
    PlatformDispatcher.instance.onError = (e, s) {
      AppLogger.I().error('PlatformDispatcher error', e, s);

      return true;
    };

    // * Show some error UI when any widget in the app fails to build
    ErrorWidget.builder = (details) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.red, title: const Text('An error occurred')),
        body: Center(child: Text(details.toString())),
      );
    };
  }
}
