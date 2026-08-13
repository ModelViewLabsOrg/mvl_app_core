import 'package:flutter/foundation.dart';
import 'package:mvl_app_core/utils/json.dart';

/// Identity an error keeps inside the crash reporter.
///
/// Release builds run with `--obfuscate`, so `runtimeType` reaches the server
/// as a renamed symbol (`kxb`) and the rendered message usually carries the
/// whole HTTP payload. Neither can title or group an issue, so a reportable
/// exception spells its identity out with literals instead.
@immutable
class ErrorReport {
  const ErrorReport({
    required this.type,
    this.grouping = const <String>[],
    this.tags = const <String, String>{},
    this.extra,
  }) : assert(type != '', 'type cannot be empty');

  /// Class name shown as the issue title. Must be a string literal so the
  /// obfuscator cannot rename it.
  final String type;

  /// Discriminators appended to the origin to build the fingerprint. Ids,
  /// amounts, names and user-facing sentences must stay out: anything that
  /// changes between occurrences creates one issue per occurrence.
  final List<String> grouping;

  /// Searchable key/value pairs on the event. Same cardinality rule as
  /// [grouping], since a tag with thousands of values is not filterable.
  final Map<String, String> tags;

  /// Free-form payload attached for debugging. Cardinality is irrelevant here
  /// because it never takes part in the grouping.
  final Json? extra;
}

/// Exception that decides how it is titled and grouped by the crash reporter.
mixin ReportableException implements Exception {
  ErrorReport get report;
}

/// Turns free-form text into values safe to use as a tag or as part of a
/// fingerprint.
abstract final class ErrorGrouping {
  /// Sentry rejects tag values above 200 characters; a shorter budget also
  /// keeps the issue list readable.
  static const originMaxLength = 64;
  static const messageMaxLength = 120;

  static final _uuid = RegExp(
    r'\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b',
  );
  static final _email = RegExp(r'\b[\w.+-]+@[\w-]+\.[\w.-]+\b');

  /// Three digits or more, so record ids and timestamps are scrubbed while
  /// version numbers and HTTP status codes written by hand survive.
  static final _number = RegExp(r'\d{3,}');
  static final _invalidOriginChars = RegExp(r'[^a-z0-9_.\-]+');
  static final _whitespace = RegExp(r'\s+');

  /// Normalises the caller-provided context into a short, stable slug.
  ///
  /// Origins are meant to be written as literals (`team-withdraw`,
  /// `finances_send_amount`). This is the safety net for the ones that still
  /// interpolate a user id or an error message and would otherwise produce a
  /// new tag value — and a new issue — on every occurrence.
  static String origin(String value) {
    final String scrubbed = _scrub(value).toLowerCase();

    final String slug = scrubbed
        .replaceAll(_invalidOriginChars, '_')
        .replaceAll(RegExp('_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    if (slug.isEmpty) {
      return 'unknown';
    }

    return slug.length > originMaxLength ? slug.substring(0, originMaxLength) : slug;
  }

  /// Collapses an exception message into something that stays identical across
  /// occurrences of the same defect.
  static String normalizeMessage(String value) {
    final String scrubbed = _scrub(value).replaceAll(_whitespace, ' ').trim();

    if (scrubbed.isEmpty) {
      return 'unknown';
    }

    return scrubbed.length > messageMaxLength ? scrubbed.substring(0, messageMaxLength) : scrubbed;
  }

  static String _scrub(String value) {
    return value.replaceAll(_uuid, '<id>').replaceAll(_email, '<email>').replaceAll(_number, '<n>');
  }
}
