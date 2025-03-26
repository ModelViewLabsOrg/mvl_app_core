import 'package:mvl_app_core/app_config_values.dart';
import 'package:mvl_app_core/app_logger.dart';
import 'package:mvl_app_core/utils/env_enum.dart';

class AppConfig {
  factory AppConfig.I() {
    return _instance ?? (throw UnimplementedError('Must call setup() before use it'));
  }

  AppConfig._internal();
  static late final AppConfig? _instance;

  static EnvEnum env = EnvEnum.prd;

  late final AppConfigValues configValues;

  static AppConfig setup(AppConfigValues values) {
    final config = AppConfig._internal()..configValues = values;
    AppLogger.I().debug('Env: ${env.name}');

    _instance = config;
    return config;
  }

  // static Future<EnvEnum> _env() async {
  //   String? flavor;
  //   try {
  //     const channel = MethodChannel('flavor');
  //     flavor = await channel.invokeMethod<String>('getFlavor');
  //   } catch (_) {
  //     // ignore: do_not_use_environment
  //     flavor = const String.fromEnvironment('flavor', defaultValue: 'uat');
  //   } finally {
  //     AppLogger.I().debug('Flavor: $flavor');
  //   }

  //   if (flavor == null) return EnvEnum.prd;

  //   return EnvEnum.values.firstWhere(
  //     (e) => flavor == e.name,
  //     orElse: () => EnvEnum.prd,
  //   );
  // }
}
