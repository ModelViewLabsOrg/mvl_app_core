import 'package:mvl_app_core/app_tracking.dart';
import 'package:talker_flutter/talker_flutter.dart';

class AppLogger {
  factory AppLogger.I() => _instance;
  AppLogger._();

  static final _instance = AppLogger._();

  final talker = TalkerFlutter.init();

  void error(
    String method,
    Object error,
    StackTrace stackTrace, [
    Map<String, String>? parameters,
  ]) {
    talker.handle(error, stackTrace, 'Error $method $parameters');

    parameters ??= {};
    parameters.addAll({
      'method': method,
      'error': error.toString(),
      'stacktrace': stackTrace.toString(),
    });

    AppTracking.I().recordError(method, error, stackTrace);
    //   AppTracking.I().event('erro', customParams: parameters);
  }

  void info(String message) {
    talker.info(message);
    AppTracking.I().info(message);
  }

  void debug(String message) => talker.debug(message);
}
