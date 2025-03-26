import 'package:flutter/foundation.dart';
import 'package:mvl_app_core/app_remote_config.dart';
import 'package:mvl_app_core/utils/env_enum.dart';

class AppSentryConfig {
  const AppSentryConfig({
    required this.dsnDefaultValue,
    this.dsnRemoteKey = 'sentry_dsn',
    this.rateDefaultValue = 1,
    this.rateRemoteKey = 'sentry_rate',
  });

  final String dsnDefaultValue;
  final String dsnRemoteKey;
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
    required this.appStoreId,
    required this.playStoreId,
    this.aptabaseHost = 'https://aptabase.modelviewlabs.com',
    this.trackingEnabled = !kDebugMode,
    this.currency = 'BRL',
  });

  final EnvEnum env;

  final AppSentryConfig sentryConfig;
  final String aptabaseKey;
  final String aptabaseHost;

  final String playStoreId;
  final String appStoreId;

  final bool trackingEnabled;
  final String currency;
}
