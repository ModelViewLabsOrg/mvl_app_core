import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:mvl_app_core/app_logger.dart';

class AppRemoteConfigKeys {
  const AppRemoteConfigKeys({
    required this.key,
    required this.defaultValue,
  });

  final String key;
  final dynamic defaultValue;
}

extension AppRemoteConfigKeysExt on AppRemoteConfigKeys {
  String getString() => AppRemoteConfig.getString(this);
  bool getBool() => AppRemoteConfig.getBool(this);
  double getDouble() => AppRemoteConfig.getDouble(this);
  bool featureFlag() => kDebugMode || AppRemoteConfig.getBool(this);
}

class AppRemoteConfig {
  AppRemoteConfig._();

  static FirebaseRemoteConfig get _remoteConfig =>
      FirebaseRemoteConfig.instance;

  static Future<void> setup(List<AppRemoteConfigKeys> keys) async {
    AppLogger.I().info('RemoteConfig init');

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        minimumFetchInterval: const Duration(hours: 1),
        fetchTimeout: const Duration(minutes: 2),
      ),
    );

    await _remoteConfig.ensureInitialized();

    try {
      final defaultValues = Map.fromEntries(
        keys.map((e) => MapEntry(e.key, e.defaultValue)),
      );

      await _remoteConfig.setDefaults(defaultValues);

      _remoteConfig.onConfigUpdated.listen(
        (data) {
          AppLogger.I().info(
            'AppRemoteConfig onConfigUpdated: ${data.updatedKeys}',
          );
        },
        onError: (dynamic e) {
          AppLogger.I().error(
            'AppRemoteConfig onConfigUpdated error',
            e is Object ? e : 'onConfigUpdated error',
            StackTrace.current,
          );
        },
        onDone: () =>
            AppLogger.I().info('AppRemoteConfig onConfigUpdated done'),
      );

      final result = await _remoteConfig.fetchAndActivate();
      AppLogger.I().debug('AppRemoteConfig result: $result');
    } catch (e) {
      AppLogger.I().debug('AppRemoteConfig setup error: $e');
    }
  }

  static String getString(AppRemoteConfigKeys item) =>
      _remoteConfig.getString(item.key);
  static bool getBool(AppRemoteConfigKeys item) =>
      _remoteConfig.getBool(item.key);
  static double getDouble(AppRemoteConfigKeys item) =>
      _remoteConfig.getDouble(item.key);
  static int getInt(AppRemoteConfigKeys item) => _remoteConfig.getInt(item.key);
  static bool featureFlag(AppRemoteConfigKeys item) =>
      kDebugMode || _remoteConfig.getBool(item.key);
}
