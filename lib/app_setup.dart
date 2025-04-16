import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart' if (dart.library.html) 'package:intl/intl_browser.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mvl_app_core/app_config.dart';
import 'package:mvl_app_core/app_config_values.dart';
import 'package:mvl_app_core/app_logger.dart';
import 'package:mvl_app_core/app_remote_config.dart';
import 'package:mvl_app_core/app_tracking.dart';
import 'package:mvl_app_core/utils/app_version.dart';
import 'package:timezone/data/latest_10y.dart' as tz_latest10y;
import 'package:timezone/standalone.dart' as tz;
import 'package:url_strategy/url_strategy.dart';

abstract class AppSetupBase {
  // AppSetupBase({
  //   required this.configKeys,
  //   required this.configValues,
  //   required this.firebase,
  //   this.customSetup,
  // });

  FirebaseOptions get firebase;
  List<AppRemoteConfigKeys> get configKeys;
  AppConfigValues get configValues;

  Future<void> customSetup();

  Future<void> initialize() async {
    await _setupFlutter();

    AppConfig.setup(configValues);

    await AppVersion.I().init();
    await _initFirebase();
    await customSetup();

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

  static Future<void> initLocale([String? locale]) async {
    locale ??= await findSystemLocale();

    await initializeDateFormatting(locale);
    Intl.defaultLocale = locale;

    tz_latest10y.initializeTimeZones();

    try {
      tz.Location location;

      try {
        final String currentLocation = await FlutterTimezone.getLocalTimezone();
        location = tz.getLocation(currentLocation);
      } catch (e, s) {
        AppLogger.I().error('AppSetup Set Location error', e, s);
        location = tz.getLocation('UTC');
      }

      tz.setLocalLocation(location);

      AppLogger.I().info('Location defined: ${location.name}');
    } catch (e, s) {
      AppLogger.I().error('AppSetup InitLocale error', e, s);
    }

    await Jiffy.setLocale(locale);
  }

  Future<void> _initFirebase() async {
    AppLogger.I().info('Initialize Firebase ${firebase.projectId}');

    await Firebase.initializeApp(options: firebase);
    await AppRemoteConfig.setup(configKeys);

    await tracking.init(configValues);
  }
}
