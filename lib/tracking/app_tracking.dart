import 'dart:async';
import 'dart:io';

import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mvl_app_core/app_logger.dart';
import 'package:mvl_app_core/app_remote_config.dart';
import 'package:mvl_app_core/app_sentry_config.dart';
import 'package:mvl_app_core/extensions/num_extension.dart';
import 'package:mvl_app_core/tracking/error_report.dart';
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

/// Restores a readable class name for an exception the app does not own.
///
/// Returning `null` lets the next resolver — and ultimately the obfuscated
/// `runtimeType` — decide.
typedef ExceptionTypeResolver = String? Function(Object error);

class _AppExceptionTypeIdentifier implements ExceptionTypeIdentifier {
  const _AppExceptionTypeIdentifier(this._resolvers);

  final List<ExceptionTypeResolver> _resolvers;

  @override
  String? identifyType(dynamic throwable) {
    if (throwable is ReportableException) {
      return throwable.report.type;
    }

    if (throwable is! Object) {
      return null;
    }

    for (final ExceptionTypeResolver resolve in _resolvers) {
      final String? type = resolve(throwable);
      if (type != null) {
        return type;
      }
    }

    return null;
  }
}

class AppTracking {
  AppTracking._internal();
  static final _instance = AppTracking._internal();

  static const kEventNameMaxLength = 40;
  static const int _kTagMaxLength = ErrorGrouping.originMaxLength;

  late final AppConfigValues _config;

  /// Errors raised before [init] finishes have no destination yet. Reading
  /// `_config` then would throw a LateInitializationError from inside the
  /// error handler and hide the original failure.
  var _initialized = false;

  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;
  Aptabase get _aptabase => Aptabase.instance;
  Posthog? get _posthog => (_config.posthogKey?.isEmpty ?? true) ? null : Posthog();

  AppAnalyticsUser? _user;

  Future<void> init(AppConfigValues config) async {
    _config = config;
    _initialized = true;

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

    _registerCrashlyticsHandlers();
    _resetDefaultEventParams();
  }

  /// Chains onto the handlers Sentry installed instead of replacing them, so a
  /// framework error reaches both backends exactly once.
  ///
  /// Runs after [_initSentry] because Sentry wraps whatever is registered at
  /// init time; registering earlier would put Crashlytics inside Sentry's
  /// wrapper and make ordering depend on integration internals.
  void _registerCrashlyticsHandlers() {
    if (kIsWeb || kDebugMode || !_config.trackingEnabled) {
      return;
    }

    final FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

    final FlutterExceptionHandler? previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      unawaited(crashlytics.recordFlutterError(details));
      previousOnError?.call(details);
    };

    final ErrorCallback? previousPlatformOnError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (e, s) {
      unawaited(crashlytics.recordError(e, s, fatal: true));
      return previousPlatformOnError?.call(e, s) ?? true;
    };
  }

  Future<void> _initSentry() async {
    SentryWidgetsFlutterBinding.ensureInitialized();

    // An empty DSN keeps the SDK inert, so the automatic integrations
    // (FlutterError, PlatformDispatcher, http) stay silent too.
    if (kDebugMode || !_config.trackingEnabled) {
      await SentryFlutter.init((options) {
        options
          ..debug = kDebugMode
          ..dsn = ''
          ..sampleRate = 0
          ..tracesSampleRate = 0
          ..environment = kDebugMode ? 'debug' : _config.env.name;
      });

      appLogger.debug('Sentry disabled (debug mode or tracking off)');
      return;
    }

    // Only traces follow the remote rate. Errors stay at 100% so throttling the
    // server disk usage can never silently hide production issues.
    final double tracesRate = _config.sentryConfig.rateRemote.getDouble();
    appLogger.info('Sentry init, traces rate: $tracesRate');

    await SentryFlutter.init((options) {
      options
        ..debug = kDebugMode
        ..dsn = _config.sentryConfig.dsnRemote.getString()
        ..release = AppVersion.I().versionStr
        ..environment = _config.env.name
        ..sampleRate = 1
        ..tracesSampleRate = tracesRate
        ..enableLogs = false
        // Every offline Supabase call would otherwise become an issue.
        ..captureFailedRequests = false
        ..enableAutoSessionTracking = false
        // Logs every resize/rotation and pushes real events out of the
        // breadcrumb buffer.
        ..enableWindowMetricBreadcrumbs = false
        ..maxBreadcrumbs = 150
        ..beforeSend = _beforeSend
        // Recovers readable class names from `--obfuscate`d builds, where
        // `runtimeType` is a two-letter symbol such as `kxb`.
        ..prependExceptionTypeIdentifier(
          _AppExceptionTypeIdentifier(_config.exceptionTypeResolvers),
        );

      <String>{'mvl_app_core', ..._config.inAppPackages}.forEach(options.addInAppInclude);
    });

    final appVersion = AppVersion.I();
    await Sentry.configureScope((scope) async {
      await scope.setContexts('app_details', <String, String>{
        'app_name': appVersion.appName,
        'app_version': appVersion.versionFull,
        'device': appVersion.deviceFull,
        'os': '${appVersion.osName} ${appVersion.osVersion}',
      });
    });

    appLogger.debug('Sentry ok!');
  }

  SentryEvent? _beforeSend(SentryEvent event, Hint hint) {
    final List<String> patterns = _config.ignoredErrorPatterns;

    // The original cause is often wrapped (GoException, AsyncError), so the
    // rendered text is matched instead of the runtime type.
    final text = StringBuffer()
      ..write(event.throwable ?? '')
      ..write(event.exceptions?.map((e) => '${e.type} ${e.value}').join(' ') ?? '')
      ..write(event.message?.formatted ?? '');

    final haystack = text.toString();
    if (patterns.any(haystack.contains)) {
      return null;
    }

    _dropRedundantTypePrefix(event);

    return event;
  }

  /// Dart exceptions repeat their class name inside `toString()`, so the issue
  /// title arrives as `AppException: AppException: …`. The type is already a
  /// separate field on the event.
  void _dropRedundantTypePrefix(SentryEvent event) {
    for (final SentryException exception in event.exceptions ?? const <SentryException>[]) {
      final String? type = exception.type;
      final String? value = exception.value;
      if (type == null || value == null) {
        continue;
      }

      final prefix = '$type: ';
      if (value.startsWith(prefix) && value.length > prefix.length) {
        exception.value = value.substring(prefix.length);
      }
    }
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

    appLogger.debug(
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
      TalkerRouteObserver(appLogger.talker),
      if (_config.posthogKey != null) PosthogObserver(),
    ];
  }

  var _eventsParameters = <String, String>{};

  void _resetDefaultEventParams() {
    _eventsParameters = <String, String>{
      'auth_user_id': _user?.id ?? '',
      if (_user?.data != null) 'auth_user_data': _user?.data?.toString() ?? '',
      'app_details': AppVersion.I().toString().replaceAll('\n', ' '),
    };
  }

  void appOpen() {
    _breadcrumb('app_open', category: 'lifecycle');

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
    _user = null;

    // Only the identity is dropped: scope.clear() would also wipe tags,
    // contexts and every breadcrumb collected so far.
    await Sentry.configureScope((scope) async {
      await scope.setUser(null);
      await scope.removeTag('role');
    });

    await _analytics.setUserId();
    if (!kIsWeb) {
      await _analytics.resetAnalyticsData();
    }

    await _posthog?.reset();

    _resetDefaultEventParams();
  }

  Future<void> setUser(AppAnalyticsUser user) async {
    _user = user;
    final String? userId = user.id;

    // `role` is duplicated as a tag because user context fields are not
    // filterable in the issue search, tags are.
    final role = user.data?['role']?.toString();

    await Sentry.configureScope((scope) async {
      await scope.setUser(user);

      if (role != null) {
        await scope.setTag('role', role);
      }
    });

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

    _resetDefaultEventParams();
  }

  void signUp(String signUpMethod) {
    _breadcrumb('sign_up', category: 'auth', data: {'method': signUpMethod});

    _analytics.logSignUp(signUpMethod: signUpMethod).ignore();

    final properties = <String, String>{'method': signUpMethod};

    _aptabaseTrackEvent('register', properties);
    _posthogTrackEvent('register', properties);

    _triggerEvent('signUp');
  }

  void info(String message) {
    _breadcrumb(message, category: 'log');
  }

  /// Breadcrumbs carry only what is specific to the event. Identity and app
  /// details live on the scope, set once, instead of being copied into every
  /// entry of the timeline.
  void _breadcrumb(
    String message, {
    required String category,
    Map<String, dynamic>? data,
    SentryLevel level = SentryLevel.info,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        type: 'user',
        data: (data?.isEmpty ?? true) ? null : data,
        level: level,
      ),
    ).ignore();
  }

  /// [method] identifies *where* the failure happened and must be written as a
  /// short literal (`team-withdraw`, `finances_send_amount`). It becomes the
  /// `origin` tag and the first segment of the fingerprint, so interpolating
  /// the error, an id or an email into it splits one defect into one issue per
  /// occurrence. [ErrorGrouping.origin] scrubs what slips through.
  void recordError(
    String method,
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
    Map<String, String>? parameters,
  }) {
    if (!_initialized || !_config.trackingEnabled) {
      return;
    }

    assert(
      method.length <= _kTagMaxLength,
      'origin "$method" is too long: pass a short literal, not the error text',
    );

    final String origin = ErrorGrouping.origin(method);
    final ErrorReport? report = error is ReportableException ? error.report : null;

    // The origin goes on the scope, never as `message:` — a message on a
    // captureException overrides the title without helping the grouping.
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) async {
        scope
          ..transaction = origin
          ..level = fatal ? SentryLevel.fatal : SentryLevel.error
          ..fingerprint = _fingerprint(origin, error, report);

        await scope.setTag('origin', origin);

        for (final MapEntry<String, String> tag
            in report?.tags.entries ?? const <MapEntry<String, String>>[]) {
          await scope.setTag(tag.key, tag.value);
        }

        final Json? details = report?.extra;
        if (details != null && details.isNotEmpty) {
          await scope.setContexts('error_details', details);
        }

        if (parameters != null && parameters.isNotEmpty) {
          await scope.setContexts('parameters', parameters);
        }
      },
    ).ignore();

    if (!kIsWeb && !kDebugMode) {
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

  /// Sentry's default grouping relies on the stack trace, and release builds
  /// only ship native instruction addresses that change with every build. An
  /// explicit fingerprint is what keeps one defect as one issue across
  /// releases.
  List<String> _fingerprint(String origin, Object error, ErrorReport? report) {
    if (report != null) {
      return <String>[origin, report.type, ...report.grouping];
    }

    // The class name is obfuscated and its symbol changes between builds, so
    // the scrubbed message is the only discriminator that survives.
    return <String>[origin, ErrorGrouping.normalizeMessage(error.toString())];
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

    _breadcrumb(eventName, category: 'analytics', data: customParams);

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

    _breadcrumb('begin_checkout', category: 'commerce', data: {'total': total});

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

    _breadcrumb(
      'purchase',
      category: 'commerce',
      data: {'total': total, 'transaction_id': transactionId},
    );

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
    _breadcrumb(
      'select_item',
      category: 'ui',
      data: {'list': listName, 'item': item.name},
    );

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
    _breadcrumb(
      'share',
      category: 'ui',
      data: {'method': method, 'id': id, 'content_type': contentType},
    );

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
      appLogger.info('Web has no store');
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
          appLogger.info('Store for Android: $store');
          return store;
        }

      case TargetPlatform.iOS:
        {
          // * On iOS, use the given app ID
          final store = 'https://apps.apple.com/br/app/id${_config.appStoreId}';
          appLogger.info('Store for iOS: $store');
          return store;
        }

      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        {
          appLogger.info(
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
    appLogger.debug('store: $store');

    final InAppReview review = InAppReview.instance;

    if (await review.isAvailable()) {
      await review.openStoreListing(appStoreId: _config.appStoreId);
    }
  }
}
