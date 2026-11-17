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

    // 1. Acessa o .child com tipo forte para MaterialPage/CupertinoPage (Object? aceita <void>, <dynamic>, etc.)
    // e fallback dinâmico para páginas de pacotes externos (ex: CustomTransitionPage / NoTransitionPage do go_router)
    if (settings is MaterialPage<Object?>) {
      widget = settings.child;
    } else if (settings is CupertinoPage<Object?>) {
      widget = settings.child;
    } else if (settings is Page<Object?>) {
      try {
        final dynamic dynamicPage = settings;
        // ignore: avoid_dynamic_calls
        final dynamic child = dynamicPage.child;
        if (child is Widget) {
          widget = child;
        }
      } catch (_) {}
    }

    // 2. Se for um PageRoute customizado que exponha .child diretamente
    if (widget == null && route is PageRoute<Object?>) {
      try {
        final dynamic dynamicRoute = route;
        // ignore: avoid_dynamic_calls
        final dynamic child = dynamicRoute.child;
        if (child is Widget) {
          widget = child;
        }
      } catch (_) {}
    }

    // 3. Fallback via builder da rota se tiver context
    if (widget == null) {
      final BuildContext? context = route.navigator?.context;
      if (context != null) {
        try {
          if (route is MaterialPageRoute<Object?>) {
            widget = route.builder(context);
          } else if (route is CupertinoPageRoute<Object?>) {
            widget = route.builder(context);
          }
        } catch (_) {}
      }
    }

    // 4. Se encontrou o widget, desembala os wrappers
    if (widget != null) {
      final Widget unwrapped = _unwrapWidget(widget);
      final name = unwrapped.runtimeType.toString();
      if (name != 'Builder') {
        return name;
      }
    }

    // 5. Se não conseguiu o child mas a Page tem um nome customizado
    if (settings is Page<Object?>) {
      final pageType = settings.runtimeType.toString();
      if (!pageType.startsWith('MaterialPage') &&
          !pageType.startsWith('CupertinoPage') &&
          !pageType.startsWith('CustomTransitionPage') &&
          !pageType.startsWith('NoTransitionPage') &&
          !pageType.startsWith('_')) {
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
      if (current is SingleChildRenderObjectWidget) {
        final Widget? child = current.child;
        if (child != null) {
          current = child;
          continue;
        }
      }
      if (current is KeyedSubtree) {
        current = current.child;
        continue;
      }
      if (current is SafeArea) {
        current = current.child;
        continue;
      }
      if (current is PopScope<Object?>) {
        current = current.child;
        continue;
      }
      if (current is HeroControllerScope) {
        current = current.child;
        continue;
      }
      if (current is NotificationListener<Notification>) {
        current = current.child;
        continue;
      }
      if (current is Focus) {
        current = current.child;
        continue;
      }

      try {
        // Fallback para wrappers de pacotes externos (Provider, BlocProvider, etc.)
        // ignore: avoid_dynamic_calls
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
