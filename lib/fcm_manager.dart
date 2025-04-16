import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvl_app_core/app_logger.dart';
import 'package:mvl_app_core/app_tracking.dart';
import 'package:mvl_app_core/utils/device_info/device_info.dart';
import 'package:overlay_notification/overlay_notification.dart';

// Future<void> _setBadge(SharedPreferences prefs, int value) async {
//   await Future.wait([
//     prefs.setInt(_badgeCounterKey, value),
//     FlutterAppBadger.updateBadgeCount(value),
//   ]);
// }

Future<void> _onBackgroundMessage(RemoteMessage message) async {
  AppLogger.I().info('>> background: $message');
}

class FCMManager {
  factory FCMManager.I() => _instance;
  FCMManager._internal();
  static final _instance = FCMManager._internal();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  String? _fcmWebToken;
  String? _token;
  String? get token => _token;

  Future<bool> _isAuthorizaded() async {
    final NotificationSettings settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<void> init(String? fcmWebToken) async {
    _fcmWebToken = fcmWebToken;

    await _setup();
    await _initialMessage();
  }

  Future<void> requestPermission() async {
    if (kIsWeb) {
      return;
    }

    NotificationSettings settings = await _messaging.getNotificationSettings();
    final AuthorizationStatus status = settings.authorizationStatus;
    if (status != AuthorizationStatus.notDetermined) {
      return;
    }
    settings = await _messaging.requestPermission();

    if (DeviceInfo.isApple) {
      tracking.event('notifications_${settings.authorizationStatus}');
    }

    await _setup();
  }

  Future<void> _setup() async {
    final bool isAuthorized = await _isAuthorizaded();
    if (!isAuthorized) {
      AppLogger.I().info('>> FirebaseMessaging isNotAuthorized');

      return;
    }

    try {
      _token = await _messaging.getToken(vapidKey: kIsWeb ? _fcmWebToken : null);
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
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp, onError: _onError);
    } catch (e) {
      /* Dont do anything */
    }

    try {
      FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    } catch (e) {
      /* Dont do anything */
    }
  }

  void _onTokenRefresh(String token) {
    _token = token;
    AppLogger.I().info('>> FCM NewToken: $token');
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
    AppLogger.I().info('>> _onMessage: ${message.toMap()}');
    //  if (message.data['type'] == 'chat') {
    //   Navigator.pushNamed(context, '/chat',
    //     arguments: ChatArguments(message),
    //   );
    // }
    final RemoteNotification? notification = message.notification;
    final Map<String, dynamic> data = message.data;

    if (notification != null) {
      AppLogger.I().info(
        'Message also contained a notification: '
        '${notification.toMap()}',
      );
      _showNotification(notification);
    }

    if (data.isNotEmpty) {
      AppLogger.I().info(
        'Message also contained a data: '
        '$data',
      );
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    AppLogger.I().info('>> onMessageOpenedApp: $message');
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
      _onMessage(initial);
    }
  }
}
