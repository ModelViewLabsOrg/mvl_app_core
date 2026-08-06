import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvl_app_core/app_logger.dart';

/// Must be called *before* `SentryFlutter.init`.
///
/// Sentry's `FlutterErrorIntegration` and `OnErrorIntegration` wrap whatever
/// handler is already installed: they report the error themselves — with the
/// correct `mechanism` and `handled: false` — and only then call the previous
/// handler. Reporting again from here would produce two events per crash and
/// split the same defect across two issues, so these handlers only mirror the
/// error to the local log.
class AppErrorHandler {
  static void registerErrorHandler() {
    FlutterError.onError = (details) {
      AppLogger.I().debug('FlutterError: ${details.exceptionAsString()}');

      FlutterError.presentError(details);
    };

    // * Handle errors from the underlying platform/OS
    PlatformDispatcher.instance.onError = (e, s) {
      AppLogger.I().debug('PlatformDispatcher error: $e');

      return true;
    };

    // * Show some error UI when any widget in the app fails to build
    ErrorWidget.builder = (details) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.red, title: const Text('An error occurred')),
        body: Center(
          child: Column(
            children: [
              Text('Error: ${details.exceptionAsString()}'),
              Text(details.summary.toString()),
            ],
          ),
        ),
      );
    };
  }
}
