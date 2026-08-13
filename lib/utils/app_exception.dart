import 'package:mvl_app_core/tracking/error_report.dart';

class AppException with ReportableException {
  const AppException(
    this.userMessage, {
    required this.error,
    required this.stackTrace,
    this.shouldLogAsError = true,
  }) : assert(userMessage != '', 'userMessage cannot be empty');

  factory AppException.fromStringError(
    String error,
    StackTrace stackTrace, {
    bool shouldLogAsError = true,
  }) {
    assert(error.isNotEmpty, 'error must not be empty');

    return AppException(
      error,
      error: Exception(error),
      stackTrace: stackTrace,
      shouldLogAsError: shouldLogAsError,
    );
  }

  final String userMessage;
  final Object error;
  final StackTrace stackTrace;
  final bool shouldLogAsError;

  /// Name this exception answers by in the crash reporter. Subclasses override
  /// it with their own literal — `runtimeType` is renamed by the obfuscator.
  String get reportType => 'AppException';

  /// Extra discriminators for the fingerprint, on top of the origin and the
  /// [reportType]. Keep ids and user text out of it.
  List<String> get reportGrouping => <String>[
    ErrorGrouping.normalizeMessage(error.toString()),
  ];

  @override
  ErrorReport get report => ErrorReport(type: reportType, grouping: reportGrouping);

  /// Rendered as the issue subtitle, so it stays free of the class name: the
  /// reporter already prints it from [reportType].
  @override
  String toString() => '$userMessage (Error: $error)';
}
