import 'package:flutter/foundation.dart';
import 'package:mvl_app_core/tracking/app_tracking.dart';
import 'package:mvl_app_core/utils/app_exception.dart';
import 'package:talker_flutter/talker_flutter.dart';

AppLogger get appLogger => AppLogger.I();

class AppLogger {
  factory AppLogger.I() => _instance;

  AppLogger._internal();

  bool Function(Object error) shouldLogAsError = (_) => true;

  final Talker talker = TalkerFlutter.init(
    settings: TalkerSettings(
      // ignore: avoid_redundant_argument_values
      enabled: kDebugMode,
    ),
  );

  static final _instance = AppLogger._internal();

  /// [method] is the origin: a short literal describing the operation, such as
  /// `team-withdraw` or `finances_send_amount`. Never interpolate the error,
  /// an id or an email into it — that is what turns one defect into hundreds
  /// of issues in the dashboard.
  void error(
    String method,
    Object error,
    StackTrace stackTrace, [
    Map<String, String>? parameters,
  ]) {
    if (kDebugMode) {
      _instance.talker.handle(error, stackTrace, 'Error $method $parameters. $error');
      return;
    }

    if (!shouldLogAsError(error)) {
      return;
    }

    // Expected outcomes the app already turns into a message on screen.
    if (error is AppException && !error.shouldLogAsError) {
      return;
    }

    // The error and the stack trace are first-class fields on the event; adding
    // them again as strings only inflates the payload.
    tracking.recordError(method, error, stackTrace, parameters: parameters);
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
