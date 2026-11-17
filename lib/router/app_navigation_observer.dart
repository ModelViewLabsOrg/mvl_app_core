import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mvl_app_core/app_logger.dart';

class AppNavigationObserver extends NavigatorObserver {
  AppNavigationObserver();

  static const _wrapperTypes = <String>{
    'Builder',
    'StatefulBuilder',
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
    final BuildContext? context = route.navigator?.context;

    Widget? widget = switch (settings) {
      MaterialPage<Object?>(:final child) || CupertinoPage<Object?>(:final child) => child,
      Page<Object?>() => _extractDynamicChild(settings),
      _ => null,
    };

    widget ??= switch ((route, context)) {
      (MaterialPageRoute<Object?>(:final builder), final BuildContext ctx) ||
      (
        CupertinoPageRoute<Object?>(:final builder),
        final BuildContext ctx,
      ) => _tryBuild(builder, ctx),
      (final PageRoute<Object?> pageRoute, _) => _extractDynamicChild(pageRoute),
      _ => null,
    };

    if (widget != null) {
      final Widget unwrapped = _unwrapWidget(widget, context);
      if (unwrapped is Builder) {
        return _extractClosureReturnType(unwrapped.builder);
      }
      final name = unwrapped.runtimeType.toString();
      if (name != 'Builder') {
        return name;
      }
    }

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

  Widget _unwrapWidget(Widget widget, BuildContext? context) {
    var current = widget;
    for (var i = 0; i < 10; i++) {
      final Widget? next = _nextChild(current, context);
      if (next == null) {
        break;
      }
      current = next;
    }
    return current;
  }

  Widget? _nextChild(Widget current, BuildContext? context) {
    final String typeName = current.runtimeType.toString().split('<').first;
    if (!_wrapperTypes.contains(typeName) && current is! ProxyWidget) {
      return null;
    }

    try {
      return switch (current) {
        Builder(:final builder) when context != null => builder(context),
        StatefulBuilder(:final builder) when context != null => builder(context, (_) {}),
        ProxyWidget(:final child) ||
        KeyedSubtree(:final child) ||
        SafeArea(:final child) ||
        PopScope<Object?>(:final child) ||
        HeroControllerScope(:final child) ||
        NotificationListener<Notification>(:final child) ||
        Focus(:final child) => child,
        SingleChildRenderObjectWidget(:final child?) => child,
        _ => _extractDynamicChild(current),
      };
    } catch (_) {
      return null;
    }
  }

  Widget? _tryBuild(WidgetBuilder builder, BuildContext context) {
    try {
      return builder(context);
    } catch (_) {
      return null;
    }
  }

  Widget? _extractDynamicChild(Object target) {
    try {
      final dynamic child = (target as dynamic).child;
      return child is Widget ? child : null;
    } catch (_) {
      return null;
    }
  }

  String? _extractClosureReturnType(Object fn) {
    final fnType = fn.runtimeType.toString();
    final int arrowIndex = fnType.lastIndexOf('=> ');
    if (arrowIndex != -1) {
      final String returnType = fnType.substring(arrowIndex + 3).trim();
      if (returnType.isNotEmpty &&
          returnType != 'Widget' &&
          returnType != 'Widget?' &&
          returnType != 'dynamic' &&
          returnType != 'Object' &&
          returnType != 'Object?') {
        return returnType;
      }
    }
    return null;
  }
}
