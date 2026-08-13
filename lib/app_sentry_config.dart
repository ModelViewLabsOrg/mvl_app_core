import 'package:flutter/foundation.dart';
import 'package:mvl_app_core/app_remote_config.dart';
import 'package:mvl_app_core/tracking/app_tracking.dart';
import 'package:mvl_app_core/utils/env_enum.dart';

class AppSentryConfig {
  const AppSentryConfig({
    required this.dsnDefaultValue,
    this.dsnRemoteKey = sentryConfigDefaultKey,
    this.rateDefaultValue = 1,
    this.rateRemoteKey = sentryConfigRateKey,
  });

  static const sentryConfigDefaultKey = 'sentry_dsn';
  static const sentryConfigRateKey = 'sentry_rate';

  final String dsnDefaultValue;
  final String dsnRemoteKey;

  /// Throttles performance traces only. Errors are always sampled at 100% so
  /// lowering this remotely can never make production issues disappear.
  final double rateDefaultValue;
  final String rateRemoteKey;

  AppRemoteConfigKeys get dsnRemote =>
      AppRemoteConfigKeys(key: dsnRemoteKey, defaultValue: dsnDefaultValue);
  AppRemoteConfigKeys get rateRemote =>
      AppRemoteConfigKeys(key: rateRemoteKey, defaultValue: rateDefaultValue);
}

class AppConfigValues {
  const AppConfigValues({
    required this.env,
    required this.sentryConfig,
    required this.aptabaseKey,
    required this.posthogKey,
    required this.appStoreId,
    required this.playStoreId,
    this.aptabaseHost = 'https://aptabase.modelviewlabs.com',
    this.posthogHost = 'https://eu.i.posthog.com',
    this.trackingEnabled = !kDebugMode,
    this.currency = 'BRL',
    this.inAppPackages = const <String>[],
    this.ignoredErrorPatterns = defaultIgnoredErrorPatterns,
    this.exceptionTypeResolvers = const <ExceptionTypeResolver>[],
  });

  /// Connectivity failures are not defects: they say the device was offline,
  /// they carry no actionable stack trace and they drown out real issues.
  static const defaultIgnoredErrorPatterns = <String>[
    'Failed host lookup',
    'AuthRetryableFetchException',
    'SocketException',
    'ClientException',
    'Connection closed',
    'Connection reset by peer',
    'Software caused connection abort',
    'Network is unreachable',
    'Connection timed out',
    'XMLHttpRequest error',
  ];

  final EnvEnum env;

  /// Dart package names owned by the team. Frames from these packages are
  /// marked in-app so the issue culprit points at our code and not at the SDK.
  final List<String> inAppPackages;

  /// Substrings matched against the exception and message of every outgoing
  /// event. A match drops the event before it leaves the device.
  final List<String> ignoredErrorPatterns;

  /// Recovers class names for third-party exceptions, which release builds
  /// obfuscate into symbols like `kxb`. Exceptions owned by the app describe
  /// themselves through `ReportableException` and need no resolver.
  final List<ExceptionTypeResolver> exceptionTypeResolvers;

  final AppSentryConfig sentryConfig;
  final String aptabaseKey;
  final String aptabaseHost;

  final String? posthogKey;
  final String posthogHost;

  final String playStoreId;
  final String appStoreId;

  final bool trackingEnabled;
  final String currency;
}
