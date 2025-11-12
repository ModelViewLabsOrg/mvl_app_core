import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:mvl_app_core/utils/json.dart';

/// Model for parsing and handling push notification payload data.
///
/// Provides a structured way to extract common fields from FCM message data.
@immutable
class PushNotificationPayload {
  const PushNotificationPayload({
    this.route,
    this.type,
    this.userMessage,
    this.data,
  });

  /// Create from Firebase RemoteMessage data
  factory PushNotificationPayload.fromRemoteMessage(RemoteMessage message) {
    final Json messageData = message.data;

    return PushNotificationPayload(
      route: messageData['route'] as String?,
      type: messageData['type'] as String?,
      userMessage: messageData['user_message'] as String?,
      data: messageData.isNotEmpty ? messageData : null,
    );
  }

  /// Create from raw JSON data
  factory PushNotificationPayload.fromJson(Json json) {
    return PushNotificationPayload(
      route: json['route'] as String?,
      type: json['type'] as String?,
      userMessage: json['user_message'] as String?,
      data: json,
    );
  }

  /// Deep link route to navigate to (e.g., '/pro/job_details/123')
  final String? route;

  /// Message type for handling different notification types
  /// (e.g., 'job_update', 'notification', 'chat')
  final String? type;

  /// User-facing message to display
  final String? userMessage;

  /// Additional custom data
  final Json? data;

  /// Check if payload contains a deep link route
  bool get hasRoute => route != null && route!.isNotEmpty;

  /// Check if payload contains a user message
  bool get hasUserMessage => userMessage != null && userMessage!.isNotEmpty;

  /// Check if payload contains a type
  bool get hasType => type != null && type!.isNotEmpty;

  /// Get a specific value from the data map
  T? getDataValue<T>(String key) {
    return data?[key] as T?;
  }

  /// Convert to JSON
  Json toJson() {
    return {
      if (route != null) 'route': route,
      if (type != null) 'type': type,
      if (userMessage != null) 'user_message': userMessage,
      ...?data,
    };
  }

  @override
  String toString() {
    return 'PushNotificationPayload('
        'route: $route, '
        'type: $type, '
        'userMessage: $userMessage, '
        'hasData: ${data != null}'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PushNotificationPayload &&
        other.route == route &&
        other.type == type &&
        other.userMessage == userMessage;
  }

  @override
  int get hashCode => Object.hash(route, type, userMessage);
}
