import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mvl_app_core/app_logger.dart';

class AppNavigationObserver extends NavigatorObserver {
  AppNavigationObserver();

  static const _wrapperTypes = <String>{
    'KeyedSubtree',
    'Semantics',
    'SafeArea',
    'PopScope',
    'WillPopScope',
    'RepaintBoundary',
    'HeroControllerScope',
    'AnnotatedRegion',
    'NotificationListener',
    'FocusScope',
    'Focus',
    'ProviderScope',
    'UncontrolledProviderScope',
    'MultiProvider',
    'MultiBlocProvider',
    'MultiRepositoryProvider',
    'MultiBlocListener',
    'Provider',
    'ChangeNotifierProvider',
    'ListenableProvider',
    'ValueListenableProvider',
    'FutureProvider',
    'StreamProvider',
    'InheritedProvider',
    'BlocProvider',
    'RepositoryProvider',
    'BlocListener',
  };

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
    final String? screenName = _extractScreenName(route);

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

  String? _extractScreenName(Route<dynamic> route) {
    final RouteSettings settings = route.settings;
    Widget? widget;

    if (settings is MaterialPage<dynamic>) {
      widget = settings.child;
    } else if (settings is CupertinoPage<dynamic>) {
      widget = settings.child;
    } else if (settings is Page<dynamic>) {
      try {
        // Suporta páginas customizadas como CustomTransitionPage / NoTransitionPage do go_router
        final dynamic child = (settings as dynamic).child;
        if (child is Widget) {
          widget = child;
        }
      } catch (_) {}
    } else {
      final BuildContext? context = route.navigator?.context;
      if (context != null) {
        try {
          if (route is MaterialPageRoute<dynamic>) {
            widget = route.builder(context);
          } else if (route is CupertinoPageRoute<dynamic>) {
            widget = route.builder(context);
          }
        } catch (_) {}
      }
    }

    if (widget != null) {
      final Widget unwrapped = _unwrapWidget(widget);
      return unwrapped.runtimeType.toString();
    }

    if (settings is Page<dynamic>) {
      final pageType = settings.runtimeType.toString();
      if (!pageType.startsWith('MaterialPage') &&
          !pageType.startsWith('CupertinoPage') &&
          !pageType.startsWith('CustomTransitionPage') &&
          !pageType.startsWith('NoTransitionPage')) {
        return pageType;
      }
    }

    return null;
  }

  Widget _unwrapWidget(Widget widget) {
    var current = widget;
    for (var i = 0; i < 10; i++) {
      final String typeName = current.runtimeType.toString().split('<').first;
      if (!_wrapperTypes.contains(typeName) && current is! ProxyWidget) {
        break;
      }

      if (current is ProxyWidget) {
        current = current.child;
        continue;
      }

      try {
        final dynamic child = (current as dynamic).child;
        if (child is Widget) {
          current = child;
          continue;
        }
      } catch (_) {}
      break;
    }
    return current;
  }
}
