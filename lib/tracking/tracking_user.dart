import 'package:sentry_flutter/sentry_flutter.dart';

class AppAnalyticsUser extends SentryUser {
  AppAnalyticsUser({
    required String id,
    super.username,
    super.email,
    super.name,
    super.data,
  }) : assert(data == null || data.isNotEmpty, 'data cannot be empty'),
       super(id: id);
}
