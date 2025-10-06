import 'package:sentry_flutter/sentry_flutter.dart';

class AppAnalyticsUser extends SentryUser {
  AppAnalyticsUser({required super.id, super.email, super.name, super.data});
}
