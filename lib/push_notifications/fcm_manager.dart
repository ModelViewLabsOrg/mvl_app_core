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

  Future<bool> _isAuthorizaded() async {
    return await status() == AuthorizationStatus.authorized;
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

  Future<AuthorizationStatus?> requestPermission() async {
    if (kIsWeb) {
      return null; // TODO: Null indeed?
    }

    AuthorizationStatus authorizationStatus = await status();
    if (authorizationStatus != AuthorizationStatus.notDetermined) {
      return authorizationStatus;
    }

    authorizationStatus = (await _messaging.requestPermission()).authorizationStatus;

    if (DeviceInfo.isApple) {
      tracking.event('notifications_$authorizationStatus');
    }

    await _setup();

    return authorizationStatus;
  }

  Future<void> _setup() async {
    final bool isAuthorized = await _isAuthorizaded();
    if (!isAuthorized) {
      appLogger.info('>> Firebase FCM isNotAuthorized');

      return;
    }

    try {
      _token = await _messaging.getToken(
        vapidKey: kIsWeb ? _fcmWebToken : null,
      );
    } catch (e) {
      appLogger.info('>> Firebase FCM Could not get token: $e');
    }

    final String? token = _token;
    appLogger.info('>> Firebase FCM instance token id: $token');
    if (token != null) {
      onTokenRefresh?.call(token);
    }

    try {
      FirebaseMessaging.onMessage.listen(_onMessage);

      _messaging.onTokenRefresh.listen(_onTokenRefresh);
    } catch (e) {
      /* Dont do anything */
    }

    try {
      FirebaseMessaging.onMessageOpenedApp.listen(
        _onMessageOpenedApp,
        onError: _onError,
      );
    } catch (e) {
      /* Dont do anything */
    }

    try {
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    } catch (e) {
      /* Dont do anything */
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
