import 'package:flutter/foundation.dart';
import 'package:mvl_app_core/app_tracking.dart';
import 'package:talker_flutter/talker_flutter.dart';

class AppLogger {
  factory AppLogger.I() => _instance;

  AppLogger._internal();

  bool Function(Object error) shouldLogAsError = (error) => true;

  final Talker talker = TalkerFlutter.init();

  static final _instance = AppLogger._internal();

  void error(
    String method,
    Object error,
    StackTrace stackTrace, [
    Map<String, String>? parameters,
  ]) {
    if (kDebugMode) {
      _instance.talker.handle(error, stackTrace, 'Error $method $parameters. $error');
    }

    if (!shouldLogAsError(error)) {
      return;
    }

    parameters ??= <String, String>{};
    parameters.addAll(<String, String>{
      'method': method,
      'error': error.toString(),
      'stacktrace': stackTrace.toString(),
    });

    tracking.recordError(method, error, stackTrace);
    //  tracking.event('erro', customParams: parameters);
  }

  void info(String message) {
    if (kDebugMode) {
      _instance.talker.info(message);
    }
    tracking.info(message);
  }

  void debug(String message) {
    if (kDebugMode) {
      _instance.talker.debug(message);
    }
  }
}
