import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvl_app_core/app_logger.dart';
import 'package:mvl_app_core/tracking/app_tracking.dart';
import 'package:mvl_app_core/utils/device_info/device_info.dart';
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
  AppLogger.I().info('>> background: $message');

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
      AppLogger.I().info('>> FirebaseMessaging isNotAuthorized');

      return;
    }

    try {
      _token = await _messaging.getToken(
        vapidKey: kIsWeb ? _fcmWebToken : null,
      );
    } catch (e) {
      AppLogger.I().info('Could not get token: $e');
    }

    AppLogger.I().info('>> FirebaseMessaging instance token id: $token');

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
    AppLogger.I().info('>> FCM NewToken: $token');

    onTokenRefresh?.call(token);
  }

  void _onError(Object e, StackTrace s) {
    // AppAppLogger.I().error('FirebaseMessaging.onMessageOpenedApp', e, s);
    AppLogger.I().info('>> onError $e !! $s');
  }

  void _showNotification(RemoteNotification notification) {
    final String? title = notification.title;
    final String? body = notification.body;
    if (title == null || body == null) {
      return;
    }

    showSimpleNotification(
      Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(body, style: const TextStyle(color: Colors.white)),
      background: Colors.black87,
      duration: const Duration(seconds: 6),
    );
  }

  void _onMessage(RemoteMessage message) {
    AppLogger.I().info('>> _onMessage (foreground): ${message.toMap()}');

    final RemoteNotification? notification = message.notification;
    final Map<String, dynamic> data = message.data;

    // If message has notification payload, show overlay notification
    if (notification != null) {
      AppLogger.I().info(
        'Message also contained a notification: '
        '${notification.toMap()}',
      );
      _showNotification(notification);
    }

    // Log data payload
    if (data.isNotEmpty) {
      AppLogger.I().info(
        'Message also contained a data: '
        '$data',
      );
    }

    // Call user's callback for data-only messages or to handle additional logic
    // This allows user to show toast for data-only messages or handle custom logic
    onMessage?.call(message);
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    AppLogger.I().info('>> onMessageOpenedApp: $message');

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
      AppLogger.I().info('>> initial: ${initial.toMap()}');

      // Call user's callback to handle deep links from terminated state
      onInitialMessage?.call(initial);
    }
  }
}
