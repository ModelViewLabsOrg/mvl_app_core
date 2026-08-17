import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:mvl_app_core/app_logger.dart';

class AppRemoteConfigKeys {
  const AppRemoteConfigKeys({required this.key, required this.defaultValue});

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

  static FirebaseRemoteConfig get _remoteConfig => FirebaseRemoteConfig.instance;

  static Future<void> setup(List<AppRemoteConfigKeys> keys) async {
    appLogger.info('RemoteConfig init');

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        minimumFetchInterval: const Duration(hours: 1),
        fetchTimeout: const Duration(minutes: 2),
      ),
    );

    await _remoteConfig.ensureInitialized();

    try {
      final Map<String, dynamic> defaultValues = Map.fromEntries(
        keys.map((e) => MapEntry(e.key, e.defaultValue)),
      );

      await _remoteConfig.setDefaults(defaultValues);

      if (!kIsWeb) {
        _remoteConfig.onConfigUpdated.listen(
          (data) {
            appLogger.info('AppRemoteConfig onConfigUpdated: ${data.updatedKeys}');
          },
          onError: (Object e) {
            appLogger.error('AppRemoteConfig onConfigUpdated error', e, StackTrace.current);
          },
          onDone: () => appLogger.info('AppRemoteConfig onConfigUpdated done'),
        );
      }

      final bool result = await _remoteConfig.fetchAndActivate();
      appLogger.debug('AppRemoteConfig result: $result');
    } catch (e) {
      appLogger.debug('AppRemoteConfig setup error: $e');
    }
  }

  static String getString(AppRemoteConfigKeys item) => _remoteConfig.getString(item.key);
  static bool getBool(AppRemoteConfigKeys item) => _remoteConfig.getBool(item.key);
  static double getDouble(AppRemoteConfigKeys item) => _remoteConfig.getDouble(item.key);
  static int getInt(AppRemoteConfigKeys item) => _remoteConfig.getInt(item.key);
  static bool featureFlag(AppRemoteConfigKeys item) =>
      kDebugMode || _remoteConfig.getBool(item.key);
}
