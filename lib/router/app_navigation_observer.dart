import 'package:material_ui/material_ui.dart';
import 'package:mvl_app_core/app_logger.dart';

class AppNavigationObserver extends NavigatorObserver {
  AppNavigationObserver();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logRoute(route, action: 'PUSH');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _logRoute(previousRoute, action: 'POP');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _logRoute(newRoute, action: 'REPLACE');
    }
  }

  void _logRoute(Route<dynamic> route, {required String action}) {
    final RouteSettings settings = route.settings;
    final String? screenName = settings is Page ? settings.runtimeType.toString() : null;

    final prefix = '🧭 [NAV $action] ➔';

    final String? path = settings.name;

    if (screenName == null && path == null) {
      final routeType = route.runtimeType.toString();
      if (routeType.contains('Dialog') ||
          routeType.contains('BottomSheet') ||
          routeType.contains('Popup')) {
        appLogger.info('$prefix $routeType');
      }
      return;
    }

    final buffer = StringBuffer(prefix);

    final bool hasScreen = screenName != null && screenName != 'Builder';
    if (hasScreen) {
      buffer.write(' Screen: $screenName');
    }

    if (path != null) {
      if (hasScreen) {
        buffer.write(' | ');
      }
      buffer.write(' Path: $path');
    }

    appLogger.info(buffer.toString());
  }
}
