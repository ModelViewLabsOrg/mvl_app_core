import 'package:mvl_app_core/app_remote_config.dart';

class AppSentryConfig {
  const AppSentryConfig({
    required this.dsnDefaultValue,
    required this.dsnRemoteKey,
    required this.rateDefaultValue,
    required this.rateRemoteKey,
  });

  final String dsnDefaultValue;
  final String dsnRemoteKey;
  final double rateDefaultValue;
  final String rateRemoteKey;

  AppRemoteConfigKeys get dsnRemote => AppRemoteConfigKeys(
        key: dsnRemoteKey,
        defaultValue: dsnDefaultValue,
      );
  AppRemoteConfigKeys get rateRemote => AppRemoteConfigKeys(
        key: rateRemoteKey,
        defaultValue: rateDefaultValue,
      );
}

class AppConfigValues {
  AppConfigValues({
    required this.sentryConfig,
    required this.aptabaseKey,
    required this.aptabaseHost,
    required this.playStoreId,
    required this.appStoreId,
  });

  final AppSentryConfig sentryConfig;
  final String aptabaseKey;
  final String aptabaseHost;

  final String playStoreId;
  final String appStoreId;
}
