import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvl_app_core/app_logger.dart';
import 'package:mvl_app_core/tracking/app_tracking.dart';
import 'package:mvl_app_core/utils/device_info/device_info.dart';
import 'package:mvl_app_core/utils/json.dart';
import 'package:overlay_notification/overlay_notification.dart';

export 'package:firebase_messaging/firebase_messaging.dart';
export 'package:mvl_app_core/push_notifications/push_notification_payload.dart';

// Future<void> _setBadge(SharedPreferences prefs, int value) async {
//   await Future.wait([
//     prefs.setInt(_badgeCounterKey, value),
//     FlutterAppBadger.updateBadgeCount(value),
//   ]);
// }

Future<void> onBackgroundMessage(RemoteMessage message) async {
  appLogger.info('>> Firebase FCM background: $message');

  AppFcmManager.I().onMessage?.call(message);
}

class AppFcmManager {
  factory AppFcmManager.I() => _instance;
  AppFcmManager._internal();
  static final _instance = AppFcmManager._internal();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  String? _fcmWebToken;
  String? _token;
  String? get token => _token;

  /// Callback for handling messages (called for background messages and foreground data-only messages)
  void Function(RemoteMessage message)? onMessage;

  /// Callback for handling when user taps a notification (deep links)
  void Function(RemoteMessage message)? onMessageOpenedApp;

  /// Callback for handling initial message when app is opened from terminated state
  void Function(RemoteMessage message)? onInitialMessage;

  void Function(String token)? onTokenRefresh;

  Future<bool> _isAuthorized() async {
    final AuthorizationStatus s = await status();
    return s == AuthorizationStatus.authorized || s == AuthorizationStatus.provisional;
  }

  Future<void> init(
    String? fcmWebToken, {
    void Function(RemoteMessage message)? onMessage,
    void Function(RemoteMessage message)? onMessageOpenedApp,
    void Function(RemoteMessage message)? onInitialMessage,
  }) async {
    _fcmWebToken = fcmWebToken;
    this.onMessage = onMessage;
    this.onMessageOpenedApp = onMessageOpenedApp;
    this.onInitialMessage = onInitialMessage;

    await _setup();
    await _initialMessage();
  }

  Future<AuthorizationStatus> status() async {
    final NotificationSettings settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  Future<bool> isSupported() => _messaging.isSupported();

  Map<String, String> _fcmDebugContext({
    required String step,
    AuthorizationStatus? statusBefore,
    bool? messagingSupported,
  }) {
    final String? vapid = _fcmWebToken;
    return <String, String>{
      'step': step,
      'status_before': statusBefore?.name ?? 'unknown',
      'messaging_supported': '${messagingSupported ?? 'unknown'}',
      'is_web': '$kIsWeb',
      'platform': defaultTargetPlatform.name,
      'has_vapid_key': '${vapid != null && vapid.isNotEmpty}',
      'has_token': '${_token != null}',
    };
  }

  Future<AuthorizationStatus> requestPermission() async {
    var step = 'begin';
    AuthorizationStatus? statusBefore;
    bool? messagingSupported;

    try {
      step = 'is_supported';
      messagingSupported = await isSupported();
      appLogger.info(
        '>> Firebase FCM requestPermission: '
        'supported=$messagingSupported web=$kIsWeb '
        'platform=${defaultTargetPlatform.name}',
      );

      if (!messagingSupported) {
        appLogger.info('>> Firebase FCM not supported on this browser/platform');
        return AuthorizationStatus.denied;
      }

      step = 'status';
      statusBefore = await status();
      appLogger.info('>> Firebase FCM permission status before: $statusBefore');

      if (statusBefore == AuthorizationStatus.notDetermined ||
          statusBefore == AuthorizationStatus.denied) {
        step = 'request_permission';
        final AuthorizationStatus requested =
            (await _messaging.requestPermission()).authorizationStatus;
        appLogger.info('>> Firebase FCM permission after request: $requested');
        return requested;
      }

      if (!kIsWeb && DeviceInfo.isApple) {
        tracking.event('notifications_$statusBefore');
      }

      if (statusBefore == AuthorizationStatus.authorized ||
          statusBefore == AuthorizationStatus.provisional) {
        step = 'setup';
        await _setup();
      }

      return statusBefore;
    } catch (e, s) {
      appLogger.error(
        'fcm_request_permission',
        e,
        s,
        _fcmDebugContext(
          step: step,
          statusBefore: statusBefore,
          messagingSupported: messagingSupported,
        ),
      );
      rethrow;
    }
  }

  Future<void> _setup() async {
    if (!await _isAuthorized()) {
      appLogger.info('>> Firebase FCM isNotAuthorized');
      return;
    }

    try {
      _token = await _messaging.getToken(
        vapidKey: kIsWeb ? _fcmWebToken : null,
      );
    } catch (e, s) {
      // Common on unsupported/partial web push browsers; keep as breadcrumb.
      appLogger.info(
        '>> Firebase FCM Could not get token '
        '(${_fcmDebugContext(step: 'get_token')}): $e !! $s',
      );
    }

    final String? token = _token;
    appLogger.info('>> Firebase FCM instance token id: $token');
    if (token != null) {
      onTokenRefresh?.call(token);
    }

    try {
      FirebaseMessaging.onMessage.listen(_onMessage);
      _messaging.onTokenRefresh.listen(_onTokenRefresh);
    } catch (e, s) {
      appLogger.info('>> Firebase FCM listen onMessage failed: $e !! $s');
    }

    try {
      FirebaseMessaging.onMessageOpenedApp.listen(
        _onMessageOpenedApp,
        onError: _onError,
      );
    } catch (e, s) {
      appLogger.info('>> Firebase FCM listen onMessageOpenedApp failed: $e !! $s');
    }

    try {
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    } catch (e, s) {
      appLogger.info('>> Firebase FCM background handler failed: $e !! $s');
    }
  }

  void _onTokenRefresh(String token) {
    _token = token;
    appLogger.info('>> Firebase FCM NewToken: $token');

    onTokenRefresh?.call(token);
  }

  void _onError(Object e, StackTrace s) {
    // AppappLogger.error('FirebaseMessaging.onMessageOpenedApp', e, s);
    appLogger.info('>> Firebase FCM onError $e !! $s');
  }

  void _showNotification(RemoteMessage message) {
    final RemoteNotification? notification = message.notification;
    if (notification == null) {
      return;
    }

    final String? title = notification.title;
    final String? body = notification.body;
    if (title == null || title.isEmpty) {
      return;
    }

    final Json data = message.data;

    showSimpleNotification(
      Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: body == null || body.isEmpty
          ? null
          : Text(body, style: const TextStyle(color: Colors.white)),
      background: Colors.black87,
      duration: Duration(seconds: (data['duration'] as int?) ?? 6),
    );
  }

  void _onMessage(RemoteMessage message) {
    appLogger.info(
      '>> Firebase FCM _onMessage (foreground): ${message.toMap()}',
    );

    final RemoteNotification? notification = message.notification;
    final Map<String, dynamic> data = message.data;

    // If message has notification payload, show overlay notification
    if (notification != null) {
      appLogger.info(
        'Message also contained a notification: '
        '${notification.toMap()}',
      );
      _showNotification(message);
    }

    // Log data payload
    if (data.isNotEmpty) {
      appLogger.info(
        'Message also contained a data: '
        '$data',
      );
    }

    // Call user's callback for data-only messages or to handle additional logic
    // This allows user to show toast for data-only messages or handle custom logic
    onMessage?.call(message);
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    appLogger.info('>> Firebase FCM onMessageOpenedApp: $message');

    // Call user's callback to handle deep links
    onMessageOpenedApp?.call(message);
  }

  // Future<String?> _fcmToken() async {
  //   if (kIsWeb) return null;

  //   if (await _isAuthorizaded()) {
  //     const vapidKey = kIsWeb ? AppConfig.fcmWebkey : null;
  //     final token = await _messaging.getToken(vapidKey: vapidKey);
  //     return token;
  //   }

  //   return null;
  // }

  Future<void> _initialMessage() async {
    final RemoteMessage? initial = await _messaging.getInitialMessage();
    if (initial != null) {
      appLogger.info('>> Firebase FCM initial: ${initial.toMap()}');

      // Call user's callback to handle deep links from terminated state
      onInitialMessage?.call(initial);
    }
  }
}
