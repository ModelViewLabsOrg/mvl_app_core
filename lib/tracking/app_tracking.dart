import 'dart:async';
import 'dart:io';

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
import 'package:mvl_app_core/tracking/tracking_item.dart';
import 'package:mvl_app_core/tracking/tracking_user.dart';
import 'package:mvl_app_core/utils/app_version.dart';
import 'package:mvl_app_core/utils/json.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

AppTracking get tracking => AppTracking._instance;

typedef AnalyticsParameters = Map<String, Object>;

class AppTracking {
  AppTracking._internal();
  static final _instance = AppTracking._internal();

  static const kEventNameMaxLength = 40;

  late final AppConfigValues _config;

  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;
  Aptabase get _aptabase => Aptabase.instance;
  Posthog? get _posthog => _config.posthogKey == null ? null : Posthog();

  Future<void> init(AppConfigValues config) async {
    _config = config;

    await Future.wait(<Future<void>>[
      _analytics.setAnalyticsCollectionEnabled(config.trackingEnabled),
      _initSentry(),
      _initPosthog(),
      Aptabase.init(
        _config.aptabaseKey,
        InitOptions(host: _config.aptabaseHost),
      ),
    ]);

    if (!kIsWeb && !Platform.isMacOS) {
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
        ..release = AppVersion.I().versionStr
        ..environment = _config.env.name
        ..sampleRate = rate
        ..tracesSampleRate = rate
        ..captureFailedRequests = true
        ..enableAutoSessionTracking = false
        ..enableWindowMetricBreadcrumbs = true;
    });

    AppLogger.I().debug('Sentry ok!');
  }

  Future<void> _initPosthog() async {
    final String? posthogKey = _config.posthogKey;
    if (posthogKey != null) {
      await Posthog().setup(
        PostHogConfig(posthogKey)
          ..host = _config.posthogHost
          ..debug = kDebugMode
          ..captureApplicationLifecycleEvents = false
          ..surveys = false
          ..sessionReplay = false
          ..flushAt = 1,
      );
    }

    AppLogger.I().debug(
      'Posthog ${posthogKey == null ? 'not configured' : 'ok'}',
    );
  }

  // https://amplitude.com/docs/sdks/analytics/flutter/flutter-sdk-4-0
  // https://posthog.com/docs/libraries/flutter
  // https://github.com/stevenosse/openpanel_flutter
  // static late final Mixpanel? _mixpanel;

  void _triggerEvent(String eventName) {
    if (kIsWeb) {
      return;
    }

    FirebaseInAppMessaging.instance.triggerEvent(eventName).ignore();
  }

  List<NavigatorObserver> get navigatorObservers {
    return <NavigatorObserver>[
      FirebaseAnalyticsObserver(analytics: _analytics),
      SentryNavigatorObserver(),
      TalkerRouteObserver(AppLogger.I().talker),
      if (_config.posthogKey != null) PosthogObserver(),
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
    Sentry.addBreadcrumb(Breadcrumb(message: 'open')).ignore();

    _aptabaseTrackEvent('app_open');
    _posthogTrackEvent('app_open');
    _analytics.logAppOpen().ignore();
    _triggerEvent('appOpen');
  }

  void _aptabaseTrackEvent(String eventName, [Json? props]) {
    _aptabase.trackEvent(eventName, props).ignore();
  }

  void _posthogTrackEvent(String eventName, [Map<String, Object>? props]) {
    _posthog?.capture(eventName: eventName, properties: props).ignore();
  }

  Future<void> clearUser() async {
    Sentry.configureScope((scope) => scope.clear());

    await _analytics.setUserId();
    if (!kIsWeb) {
      await _analytics.resetAnalyticsData();
    }

    await _posthog?.reset();

    _resetDefaultEventParams();
  }

  Future<void> setUser(AppAnalyticsUser user) async {
    final String? userId = user.id;

    Sentry.configureScope((scope) => scope.setUser(user));

    await _analytics.setUserId(id: userId);
    await _analytics.logLogin();

    if (userId == null) {
      await _posthog?.reset();
    } else {
      final userProperties = <String, Object>{};
      if (user.email != null) {
        userProperties['email'] = user.email ?? '';
      }
      if (user.name != null) {
        userProperties['name'] = user.name ?? '';
      }

      for (final MapEntry<String, dynamic> e in user.data?.entries ?? []) {
        final dynamic value = e.value;
        if (value is Object) {
          userProperties[e.key] = value;
        }
      }

      await _posthog?.identify(
        userId: userId,
        userPropertiesSetOnce: userProperties,
      );
    }

    _triggerEvent('login');

    if (!kIsWeb && userId != null) {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    }
  }

  void signUp(String signUpMethod) {
    Sentry.addBreadcrumb(Breadcrumb(message: 'SignUp $signUpMethod')).ignore();

    _analytics.logSignUp(signUpMethod: signUpMethod).ignore();

    final properties = <String, String>{'method': signUpMethod};

    _aptabaseTrackEvent('register', properties);
    _posthogTrackEvent('register', properties);

    _triggerEvent('signUp');
  }

  void info(String message) {
    Sentry.addBreadcrumb(Breadcrumb(message: message, level: SentryLevel.info)).ignore();
  }

  void recordError(
    String method,
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
  }) {
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      message: SentryMessage(method),
    ).ignore();

    if (!kIsWeb) {
      FirebaseCrashlytics.instance
          .recordError(
            error,
            stackTrace,
            fatal: fatal,
            printDetails: kDebugMode,
          )
          .ignore();
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

    final AnalyticsParameters parameters = (customParams ?? AnalyticsParameters())
      ..addAll(_eventsParameters);

    Sentry.addBreadcrumb(
      Breadcrumb(
        message: eventName,
        data: parameters,
        level: SentryLevel.info,
      ),
    ).ignore();

    // final String safeEventName = eventName; //.cleanLimit(kEventNameMaxLength);

    _analytics.logEvent(name: eventName, parameters: parameters).ignore();

    if (triggerInApp) {
      _triggerEvent(eventName);
    }

    _aptabaseTrackEvent(eventName, parameters);
    _posthogTrackEvent(eventName, parameters);
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

    Sentry.addBreadcrumb(Breadcrumb(message: 'BeginCheckout', data: parameters)).ignore();

    _aptabaseTrackEvent('checkout', parameters);
    _posthogTrackEvent('checkout', parameters);

    _analytics
        .logBeginCheckout(
          value: total,
          currency: _config.currency,
          items: items?.map((e) => e.analytics).toList(),
        )
        .ignore();
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

    Sentry.addBreadcrumb(Breadcrumb(message: 'purchase', data: parameters)).ignore();

    _aptabaseTrackEvent('compra', parameters);
    _posthogTrackEvent('compra', parameters);

    _analytics
        .logPurchase(
          value: total,
          currency: _config.currency,
          transactionId: transactionId,
          items: items?.map((e) => e.analytics).toList(),
        )
        .ignore();
  }

  void selectItem(String listName, TrackingItem item) {
    Sentry.addBreadcrumb(Breadcrumb(message: 'Select $listName -> ${item.name}')).ignore();

    const eventName = 'item_selecionado';
    final props = <String, String>{'lista': listName, 'item': item.name}..addAll(_eventsParameters);

    _aptabaseTrackEvent(eventName, props);
    _posthogTrackEvent(eventName, props);

    _analytics
        .logSelectItem(
          items: <AnalyticsEventItem>[item.analytics],
          itemListName: listName,
        )
        .ignore();
  }

  void share(String contentType, String id, String method) {
    Sentry.addBreadcrumb(Breadcrumb(message: 'share $method $contentType')).ignore();

    const eventName = 'share';
    final props = <String, String>{
      'metodo': method,
      'id': id,
      'tipo conteudo': contentType,
    }..addAll(_eventsParameters);

    _aptabaseTrackEvent(eventName, props);
    _posthogTrackEvent(eventName, props);

    _analytics.logShare(contentType: contentType, itemId: id, method: method).ignore();
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
