import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:mvl_app_core/app_tracking.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

class AppLogger {
  factory AppLogger.I() => _instance;
  AppLogger._internal() {
    hierarchicalLoggingEnabled = true;
    final supabaseLogger = Logger('supabase')..level = Level.ALL;
    supabaseLogger.onRecord.listen(_supabasePrint);
  }

  final talker = TalkerFlutter.init();

  void _supabasePrint(LogRecord event) {
    final prefix = event.loggerName.toUpperCase();
    //.split('.').last.toUpperCase();
    final message = '[$prefix] ${event.message}';

    switch (event.level) {
      case <= Level.FINE:
      // debug(message);
      case <= Level.INFO:
        info(message);
      default:
        error(message, event.error ?? Object(), event.stackTrace ?? StackTrace.current);
    }
  }

  static final AppLogger _instance = AppLogger._internal();

  void error(String method, Object error, StackTrace stackTrace, [Map<String, String>? parameters]) {
    if (kDebugMode) {
      _instance.talker.handle(error, stackTrace, 'Error $method $parameters. $error');
    }

    if (error is AuthException && !_shouldLogAsError(error)) return;

    parameters ??= {};
    parameters.addAll({'method': method, 'error': error.toString(), 'stacktrace': stackTrace.toString()});

    tracking.recordError(method, error, stackTrace);
    //  tracking.event('erro', customParams: parameters);
  }

  bool _shouldLogAsError(AuthException e) {
    if (e.message == 'Session expired.' && e.statusCode == null && e.code == null) {
      return false;
    }

    if (e.code == 'otp_expired') return false;

    if (e.message == 'Email not confirmed' && e.statusCode == '400') return false;

    return true;
  }

  void info(String message) {
    if (kDebugMode) _instance.talker.info(message);
    tracking.info(message);
  }

  void debug(String message) {
    if (kDebugMode) _instance.talker.debug(message);
  }
}
