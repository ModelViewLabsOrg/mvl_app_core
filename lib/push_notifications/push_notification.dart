import 'package:flutter/foundation.dart';

@immutable
class PushNotification {
  const PushNotification(
    this.id,
    this.title,
    this.body,
    this.imageUrl,
    this.payload,
  );

  final int id;
  final String? title;
  final String? body;
  final String? imageUrl;
  final String? payload;

  @override
  String toString() {
    return 'FcmNotification('
        'id: $id, '
        'title: $title, '
        'body: $body, '
        'imageUrl: $imageUrl, '
        'payload: $payload'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PushNotification &&
        other.id == id &&
        other.title == title &&
        other.body == body &&
        other.imageUrl == imageUrl &&
        other.payload == payload;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        body.hashCode ^
        imageUrl.hashCode ^
        payload.hashCode;
  }
}
