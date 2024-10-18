import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:mvl_app_core/app_tracking.dart';
import 'package:mvl_app_core/extensions/date_time_ext.dart';

class AppLogger {
  factory AppLogger.I() => _instance;
  AppLogger._internal() {
    hierarchicalLoggingEnabled = true;
    _logger.level = Level.ALL;
    _logger.onRecord.listen(_print);

    final supabaseLogger = Logger('supabase')..level = Level.ALL;
    supabaseLogger.onRecord.listen(_printSupabase);
  }

  String _logIcon(Level level) => switch (level) {
        Level.FINEST || Level.FINER || Level.FINE => '🐛',
        Level.CONFIG => '🔧',
        Level.INFO => 'ℹ️',
        Level.WARNING => '🔔',
        Level.SEVERE => '🚨',
        Level.SHOUT => '🧨',
        _ => '❓',
      };

  String _logPrefix(Level level) => '\x1B[${switch (level) {
        Level.FINEST || Level.FINER || Level.FINE => 35,
        Level.CONFIG => 37,
        Level.INFO => 32,
        Level.WARNING => 33,
        Level.SEVERE || Level.SHOUT => 31,
        _ => 36,
      }}m';

  void _print(LogRecord record) {
    if (!kDebugMode) return;

    debugPrint(
      '$_logIcon '
      '${_logPrefix(record.level)}'
      '[${record.level.name}] '
      '${record.time.onlyTimeWithSeconds()}: '
      '${record.message}\x1B[0m',
    );
  }

  void _printSupabase(LogRecord record) {
    if (!kDebugMode) return;

    final name = record.loggerName.toUpperCase();
    debugPrint(
      '${_logPrefix(record.level)}'
      '[$name ${record.level.name}] '
      '${record.time.onlyTimeWithSeconds()}: '
      '${record.message}\x1B[0m',
    );
  }

  static final AppLogger _instance = AppLogger._internal();

  final _logger = Logger('AG');

  void error(
    String method,
    Object error,
    StackTrace stackTrace, [
    Map<String, String>? parameters,
  ]) {
    _logger.severe(
      'Error $method $parameters',
      error,
      stackTrace,
    );

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
    _logger.info(message);
    AppTracking.I().info(message);
  }

  void debug(String message) => _logger.fine(message);
}
