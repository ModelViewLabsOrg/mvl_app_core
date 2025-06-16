import 'dart:async';

import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mvl_app_core/app_config_values.dart';
import 'package:mvl_app_core/app_logger.dart';
import 'package:mvl_app_core/app_remote_config.dart';
import 'package:mvl_app_core/extensions/num_extension.dart';
import 'package:mvl_app_core/utils/app_version.dart';
import 'package:mvl_app_core/utils/json.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

AppTracking get tracking => AppTracking._instance;

typedef AnalyticsParameters = JsonString;

class AppAnalyticsUser extends SentryUser {
  AppAnalyticsUser({required super.id, super.email, super.name, super.data});
}

class TrackingItem {
  TrackingItem(this.id, this.name, {this.value, this.currency = 'BRL'});

  final int id;
  final String name;
  final int? value;
  final String currency;

  AnalyticsEventItem get analytics => AnalyticsEventItem(
    itemId: id.toString(),
    itemName: name,
    currency: value == null ? null : currency,
    price: value?.amountToDouble(),
  );

  Map<String, String> get properties => <String, String>{
    'id': id.toString(),
    'name': name,
    'value': (value ?? 0).toString(),
  };
}

class AppTracking {
  AppTracking._internal();
  static final _instance = AppTracking._internal();

  Future<void> init(AppConfigValues config) async {
    _config = config;

    await Future.wait(<Future<void>>[
      _analytics.setAnalyticsCollectionEnabled(config.trackingEnabled),
      _initSentry(),
      Aptabase.init(
        _config.aptabaseKey,
        InitOptions(host: _config.aptabaseHost),
      ),
    ]);

    if (!kIsWeb) {
      await FirebaseInAppMessaging.instance.setAutomaticDataCollectionEnabled(
        config.trackingEnabled,
      );
    }

    _resetDefaultEventParams();
  }

  Future<void> _initSentry() async {
    SentryWidgetsFlutterBinding.ensureInitialized();

    final double rate = _config.sentryConfig.rateRemote.getDouble();
    AppLogger.I().info('Sentry init, rate: $rate');

    await SentryFlutter.init((options) {
      options
        ..debug = kDebugMode
        ..dsn = _config.sentryConfig.dsnRemote.getString()
        ..environment = _config.env.name
        ..sampleRate = rate
        ..tracesSampleRate = rate
        ..captureFailedRequests = true
        ..enableAutoSessionTracking = false
        ..enableWindowMetricBreadcrumbs = true;
    });

    AppLogger.I().debug('Sentry ok!');
  }

  static const kEventNameMaxLength = 40;

  late final AppConfigValues _config;

  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;
  Aptabase get _aptabase => Aptabase.instance;

  // https://amplitude.com/docs/sdks/analytics/flutter/flutter-sdk-4-0
  // https://posthog.com/docs/libraries/flutter
  // https://github.com/stevenosse/openpanel_flutter
  // static late final Mixpanel? _mixpanel;

  void _triggerEvent(String eventName) {
    if (kIsWeb) {
      return;
    }

    unawaited(FirebaseInAppMessaging.instance.triggerEvent(eventName));
  }

  List<NavigatorObserver> get navigatorObservers {
    return <NavigatorObserver>[
      FirebaseAnalyticsObserver(analytics: _analytics),
      SentryNavigatorObserver(),
      TalkerRouteObserver(AppLogger.I().talker),
    ];
  }

  var _eventsParameters = <String, String>{};

  void _resetDefaultEventParams() {
    _eventsParameters = <String, String>{
      'app': AppVersion.I().appName,
      'app_details': AppVersion.I().toString().replaceAll('\n', ' '),
    };
  }

  void appOpen() {
    unawaited(Sentry.addBreadcrumb(Breadcrumb(message: 'open')));

    _aptabaseTrackEvent('app_open');
    unawaited(_analytics.logAppOpen());
    _triggerEvent('appOpen');
  }

  void _aptabaseTrackEvent(String eventName, [Json? props]) {
    unawaited(_aptabase.trackEvent(eventName, props));
  }

  Future<void> clearUser() async {
    Sentry.configureScope((scope) => scope.clear());

    await _analytics.setUserId();
    if (!kIsWeb) {
      await _analytics.resetAnalyticsData();
    }

    _resetDefaultEventParams();
  }

  Future<void> setUser(AppAnalyticsUser user) async {
    final String? userId = user.id;

    Sentry.configureScope((scope) => scope.setUser(user));

    await _analytics.setUserId(id: userId);
    await _analytics.logLogin();
    _triggerEvent('login');

    if (!kIsWeb && userId != null) {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    }
  }

  void signUp(String signUpMethod) {
    unawaited(
      Sentry.addBreadcrumb(Breadcrumb(message: 'SignUp $signUpMethod')),
    );

    unawaited(_analytics.logSignUp(signUpMethod: signUpMethod));

    final properties = <String, String>{'method': signUpMethod};

    _aptabaseTrackEvent('register', properties);

    _triggerEvent('signUp');
  }

  void info(String message) {
    unawaited(
      Sentry.addBreadcrumb(
        Breadcrumb(message: message, level: SentryLevel.info),
      ),
    );
  }

  void recordError(
    String method,
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
  }) {
    unawaited(
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.fingerprint.add(method);
        },
      ),
    );

    if (!kIsWeb) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          fatal: fatal,
          printDetails: kDebugMode,
        ),
      );
    }
  }

  void event(
    String eventName, {
    AnalyticsParameters? customParams,
    bool triggerInApp = false,
  }) {
    assert(
      eventName.length >= 3,
      'Event name must be at least 3 characters long',
    );

    final Map<String, String> parameters = (customParams ?? <String, String>{})
      ..addAll(_eventsParameters);

    unawaited(
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: eventName,
          data: parameters,
          level: SentryLevel.info,
        ),
      ),
    );

    final String safeEventName = eventName; //.cleanLimit(kEventNameMaxLength);

    unawaited(_analytics.logEvent(name: safeEventName, parameters: parameters));

    if (triggerInApp) {
      _triggerEvent(safeEventName);
    }

    _aptabaseTrackEvent(safeEventName, parameters);
  }

  void beginCheckout(int value, List<TrackingItem>? items) {
    final double total = value.amountToDouble();

    final parameters = <String, String>{'total': total.toString()}
      ..addAll(_eventsParameters)
      ..addAll(
        items?.fold(<String, String>{}, (m, e) {
              m?[e.id.toString()] = e.name;
              return m;
            }) ??
            <String, String>{},
      );

    unawaited(
      Sentry.addBreadcrumb(
        Breadcrumb(message: 'BeginCheckout', data: parameters),
      ),
    );

    _aptabaseTrackEvent('checkout', parameters);

    unawaited(
      _analytics.logBeginCheckout(
        value: total,
        currency: _config.currency,
        items: items?.map((e) => e.analytics).toList(),
      ),
    );
  }

  void purchase(int value, String transactionId, List<TrackingItem>? items) {
    final double total = value.amountToDouble();

    final parameters = <String, String>{'total': total.toString()}
      ..addAll(_eventsParameters)
      ..addAll(
        items?.fold(<String, String>{}, (m, e) {
              m?[e.id.toString()] = e.name;
              return m;
            }) ??
            <String, String>{},
      );

    unawaited(
      Sentry.addBreadcrumb(Breadcrumb(message: 'purchase', data: parameters)),
    );

    _aptabaseTrackEvent('compra', parameters);

    unawaited(
      _analytics.logPurchase(
        value: total,
        currency: _config.currency,
        transactionId: transactionId,
        items: items?.map((e) => e.analytics).toList(),
      ),
    );
  }

  void selectItem(String listName, TrackingItem item) {
    unawaited(
      Sentry.addBreadcrumb(
        Breadcrumb(message: 'Select $listName -> ${item.name}'),
      ),
    );

    const eventName = 'item_selecionado';
    final props = <String, String>{'lista': listName, 'item': item.name}..addAll(_eventsParameters);

    _aptabaseTrackEvent(eventName, props);

    unawaited(
      _analytics.logSelectItem(
        items: <AnalyticsEventItem>[item.analytics],
        itemListName: listName,
      ),
    );
  }

  void share(String contentType, String id, String method) {
    unawaited(
      Sentry.addBreadcrumb(Breadcrumb(message: 'share $method $contentType')),
    );

    const eventName = 'share';
    final props = <String, String>{
      'metodo': method,
      'id': id,
      'tipo conteudo': contentType,
    }..addAll(_eventsParameters);

    _aptabaseTrackEvent(eventName, props);

    unawaited(
      _analytics.logShare(contentType: contentType, itemId: id, method: method),
    );
  }

  Future<void> requestReview() async {
    event('request_review');

    final InAppReview review = InAppReview.instance;

    if (await review.isAvailable()) {
      await review.requestReview();
    }
  }

  /// Returns the download URL for each store depending on the platform
  Future<String?> _storeUrl() async {
    if (kIsWeb) {
      AppLogger.I().info('Web has no store');
      return null;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        {
          final PackageInfo packageInfo = await PackageInfo.fromPlatform();

          // * On Android, use the package name from PackageInfo
          final store =
              'https://play.google.com/store/apps/details?id='
              '${packageInfo.packageName}';
          AppLogger.I().info('Store for Android: $store');
          return store;
        }

      case TargetPlatform.iOS:
        {
          // * On iOS, use the given app ID
          final store =
              'https://apps.apple.com/app/id'
              '${_config.appStoreId}';
          AppLogger.I().info('Store for iOS: $store');
          return store;
        }

      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        {
          AppLogger.I().info(
            'No store URL for platform: '
            '${defaultTargetPlatform.name}',
          );
          return null;
        }
    }
  }

  Future<void> openStore() async {
    event('open_store');

    final String? store = await _storeUrl();
    AppLogger.I().debug('store: $store');

    final InAppReview review = InAppReview.instance;

    if (await review.isAvailable()) {
      await review.openStoreListing(appStoreId: _config.appStoreId);
    }
  }
}
