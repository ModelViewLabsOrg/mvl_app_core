import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mvl_app_core/app_config.dart';
import 'package:mvl_app_core/app_config_values.dart';
import 'package:mvl_app_core/app_remote_config.dart';
import 'package:mvl_app_core/app_tracking.dart';
import 'package:mvl_app_core/utils/app_version.dart';
import 'package:mvl_app_core/utils/env_enum.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:timezone/timezone.dart';
import 'package:url_strategy/url_strategy.dart';

class AppSetup {
  AppSetup({
    required this.configKeys,
    required this.configValues,
    required this.firebase,
    this.customSetup,
  });

  final FirebaseOptions firebase;
  final List<AppRemoteConfigKeys> configKeys;
  final AppConfigValues configValues;
  final Future<void> Function()? customSetup;

  Future<void> initialize() async {
    await _setupFlutter();

    final config = await AppConfig.setup(configValues);

    await AppVersion.I().init(config.env);
    await _initFirebase(config.env);
    await customSetup?.call();

    AppLogger.I().info('init');
  }

  Future<void> _setupFlutter() async {
    // await SystemChrome.setEnabledSystemUIMode(
    //   SystemUiMode.manual,
    //   overlays: [SystemUiOverlay.top],
    // );

    setPathUrlStrategy();

    // await SystemChrome.setEnabledSystemUIMode(
    //   SystemUiMode.immersive,
    // );

    // await SystemChrome.setPreferredOrientations(
    //   [DeviceOrientation.portraitUp],
    // );
  }

  static Future<void> initLocale() async {
    const locale = 'pt';
    await initializeDateFormatting(locale);
    Intl.defaultLocale = locale;

    await tz.initializeTimeZone();

    try {
      final currentLocation = await FlutterTimezone.getLocalTimezone();

      Location? location;

      try {
        location = tz.getLocation(currentLocation);
      } catch (e, s) {
        AppLogger.I().error('AppSetup Set Location error', e, s);
        location = UTC;
      }

      tz.setLocalLocation(location);

      AppLogger.I().info('Location defined: ${location.name}');
    } catch (e, s) {
      AppLogger.I().error('AppSetup InitLocale error', e, s);
    }

    await Jiffy.setLocale('pt_br');
  }

  Future<void> _initFirebase(EnvEnum env) async {
    AppLogger.I().info('Initialize Firebase ${firebase.projectId}');

    await Firebase.initializeApp(options: firebase);
    await AppRemoteConfig.setup(configKeys);

    await Future.wait([
      AppTracking.I().init(),
      _initSentry(env),
    ]);
  }

  Future<void> _initSentry(EnvEnum env) async {
    final rate = configValues.sentryConfig.rateRemote.getDouble();

    AppLogger.I().info('Sentry init, rate: $rate');
    await SentryFlutter.init((options) {
      options
        ..debug = kDebugMode
        ..dsn = configValues.sentryConfig.dsnRemote.getString()
        ..environment = env.name
        ..sampleRate = rate
        ..tracesSampleRate = rate
        ..captureFailedRequests = true
        ..enableAutoSessionTracking = false
        ..enableWindowMetricBreadcrumbs = true;
    });

    AppLogger.I().debug('Sentry ok!');
  }
}
