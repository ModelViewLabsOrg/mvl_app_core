import 'dart:async';

import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mvl_app_core/app_config.dart';
import 'package:mvl_app_core/extensions/num_extension.dart';
import 'package:mvl_app_core/utils/app_version.dart';
import 'package:mvl_app_core/utils/json.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

export 'app_logger.dart';

typedef AnalyticsParameters = JsonString;

class TrackingItem {
  TrackingItem(this.id, this.name, {this.value});

  final int id;
  final String name;
  final int? value;

  AnalyticsEventItem get analytics => AnalyticsEventItem(
        itemId: id.toString(),
        itemName: name,
        currency: value == null ? null : AppTracking._currency,
        price: value?.amountToDouble(),
      );

  Map<String, String> get properties => {
        'id': id.toString(),
        'name': name,
        'value': (value ?? 0).toString(),
      };
}

class AppTracking {
  factory AppTracking.I() => _instance;
  AppTracking._internal();
  static final AppTracking _instance = AppTracking._internal();

  Future<void> init() async {
    const value = AppConfig.trackingEnabled;

    await _analytics.setAnalyticsCollectionEnabled(value);

    if (!kIsWeb) {
      await FirebaseInAppMessaging.instance
          .setAutomaticDataCollectionEnabled(value);
    }

    _resetDefaultEventParams();
  }

  static const kEventNameMaxLength = 40;

  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;
  Aptabase get _aptabase => Aptabase.instance;

  void _triggerEvent(String eventName) {
    if (kIsWeb) return;

    unawaited(FirebaseInAppMessaging.instance.triggerEvent(eventName));
  }

  List<NavigatorObserver> get navigatorObservers {
    return [
      FirebaseAnalyticsObserver(analytics: _analytics),
      SentryNavigatorObserver(),
    ];
  }

  static const _currency = 'BRL';

  var _eventsParameters = <String, String>{};

  void _resetDefaultEventParams() {
    _eventsParameters = {
      'app': AppVersion.I().appName,
      'app_details': AppVersion.I().toString().replaceAll('\n', ' '),
    };
  }

  void appOpen() {
    unawaited(Sentry.addBreadcrumb(Breadcrumb(message: 'open')));

    _aptabase.trackEventSync('app_open');
    unawaited(_analytics.logAppOpen());
    _triggerEvent('appOpen');
  }

  Future<void> clearUser() async {
    Sentry.configureScope((scope) => scope.clear());

    await _analytics.setUserId();
    if (!kIsWeb) await _analytics.resetAnalyticsData();

    _resetDefaultEventParams();
  }

  Future<void> setUser(SentryUser user) async {
    final userId = user.id;

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
      Sentry.addBreadcrumb(
        Breadcrumb(message: 'SignUp $signUpMethod'),
      ),
    );

    unawaited(
      _analytics.logSignUp(signUpMethod: signUpMethod),
    );

    _aptabase.trackEventSync(
      'registro',
      {'metodo': signUpMethod},
    );

    _triggerEvent('signUp');
  }

  void info(String message) {
    unawaited(
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: message,
          level: SentryLevel.info,
        ),
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
    final parameters = (customParams ?? {})..addAll(_eventsParameters);

    unawaited(
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: eventName,
          data: parameters,
          level: SentryLevel.info,
        ),
      ),
    );

    final safeEventName = eventName; //.cleanLimit(kEventNameMaxLength);

    unawaited(
      _analytics.logEvent(
        name: safeEventName,
        parameters: parameters,
      ),
    );

    if (triggerInApp) {
      _triggerEvent(safeEventName);
    }

    _aptabase.trackEventSync(eventName, parameters);
  }

  void beginCheckout(int value, List<TrackingItem>? items) {
    final total = value.amountToDouble();

    final parameters = {'total': total.toString()}
      ..addAll(_eventsParameters)
      ..addAll(
        items?.fold(
              {},
              (m, e) {
                m?[e.id.toString()] = e.name;
                return m;
              },
            ) ??
            {},
      );

    unawaited(
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'BeginCheckout',
          data: parameters,
        ),
      ),
    );

    _aptabase.trackEventSync('checkout', parameters);

    unawaited(
      _analytics.logBeginCheckout(
        value: total,
        currency: _currency,
        items: items?.map((e) => e.analytics).toList(),
      ),
    );
  }

  void purchase(
    int value,
    String transactionId,
    List<TrackingItem>? items,
  ) {
    final total = value.amountToDouble();

    final parameters = {'total': total.toString()}
      ..addAll(_eventsParameters)
      ..addAll(
        items?.fold(
              {},
              (m, e) {
                m?[e.id.toString()] = e.name;
                return m;
              },
            ) ??
            {},
      );

    unawaited(
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'purchase',
          data: parameters,
        ),
      ),
    );

    _aptabase.trackEventSync('compra', parameters);

    unawaited(
      _analytics.logPurchase(
        value: total,
        currency: _currency,
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

    _aptabase.trackEventSync(
      'item_selecionado',
      {
        'lista': listName,
        'item': item.name,
      }..addAll(_eventsParameters),
    );

    unawaited(
      _analytics.logSelectItem(
        items: [item.analytics],
        itemListName: listName,
      ),
    );
  }

  void share(String contentType, String id, String method) {
    unawaited(
      Sentry.addBreadcrumb(
        Breadcrumb(message: 'share $method $contentType'),
      ),
    );

    _aptabase.trackEventSync(
      'share',
      {
        'metodo': method,
        'id': id,
        'tipo conteudo': contentType,
      }..addAll(_eventsParameters),
    );

    unawaited(
      _analytics.logShare(
        contentType: contentType,
        itemId: id,
        method: method,
      ),
    );
  }
}
