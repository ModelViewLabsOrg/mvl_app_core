import 'package:flutter/material.dart';
import 'package:mvl_app_core/app_logger.dart';

/// Generic helper class for handling deep links from push notifications and other sources.
///
/// This is router-agnostic and works with any navigation system by accepting
/// a navigation callback function.
///
/// Supports:
/// - Immediate navigation when context is available
/// - Queue routes when context is not available (e.g., app terminated)
/// - Process queued routes when app becomes ready
class DeepLinkHelper {
  DeepLinkHelper._internal();

  factory DeepLinkHelper.I() => _instance;
  static DeepLinkHelper get instance => _instance;
  static final _instance = DeepLinkHelper._internal();

  /// Navigation callback function
  /// Should handle the actual navigation logic for your router
  void Function(String route)? _navigationCallback;

  /// Context getter callback
  /// Should return the current BuildContext or null if not available
  BuildContext? Function()? _contextGetter;

  /// Queue of routes waiting to be navigated when context becomes available
  final List<String> _pendingRoutes = [];

  /// Maximum number of pending routes to keep
  static const _maxPendingRoutes = 5;

  /// Initialize the helper with navigation callback and context getter
  ///
  /// [navigationCallback] - Function to handle navigation (e.g., `(route) => context.go(route)`)
  /// [contextGetter] - Function to get current context (e.g., `() => navigatorKey.currentContext`)
  void initialize({
    required void Function(String route) navigationCallback,
    BuildContext? Function()? contextGetter,
  }) {
    _navigationCallback = navigationCallback;
    _contextGetter = contextGetter;
    AppLogger.I().info('DeepLinkHelper: Initialized');
  }

  /// Navigate to a route immediately if context is available,
  /// otherwise queue it for later.
  ///
  /// Returns `true` if navigation was successful, `false` if queued.
  bool navigate(String route, {bool replace = false}) {
    if (route.isEmpty) {
      AppLogger.I().error(
        'deep_link_navigate',
        StateError('Empty route provided'),
        StackTrace.current,
      );
      return false;
    }

    if (_navigationCallback == null) {
      AppLogger.I().error(
        'deep_link_navigate',
        StateError('Not initialized. Call initialize() first.'),
        StackTrace.current,
      );
      _queueRoute(route);
      return false;
    }

    // Ensure route starts with '/'
    final normalizedRoute = route.startsWith('/') ? route : '/$route';

    // Check if context is available (if contextGetter is provided)
    final BuildContext? context = _contextGetter?.call();
    final bool isContextAvailable = context != null && context.mounted;

    if (isContextAvailable || _contextGetter == null) {
      try {
        _navigationCallback!(normalizedRoute);
        AppLogger.I().info('DeepLinkHelper: Navigated to $normalizedRoute');
        return true;
      } catch (e, stackTrace) {
        AppLogger.I().error(
          'deep_link_navigate',
          e,
          stackTrace,
          <String, String>{'route': normalizedRoute},
        );
        // Queue route on error
        _queueRoute(normalizedRoute);
        return false;
      }
    } else {
      // Context not available, queue the route
      _queueRoute(normalizedRoute);
      AppLogger.I().info('DeepLinkHelper: queued $normalizedRoute, context not available');
      return false;
    }
  }

  /// Queue a route to be processed later
  void _queueRoute(String route) {
    // Remove duplicates (keep the latest)
    _pendingRoutes
      ..remove(route)
      ..add(route);

    // Keep only the most recent routes
    if (_pendingRoutes.length > _maxPendingRoutes) {
      _pendingRoutes.removeAt(0);
    }
  }

  /// Process pending routes.
  /// By default, processes only the most recent route to avoid navigation loops.
  /// Set [processAll] to true to process all pending routes.
  ///
  /// Call this when the app is ready (e.g., after authentication check).
  ///
  /// Returns the number of routes successfully navigated.
  int processPendingRoutes({bool processAll = false}) {
    if (_pendingRoutes.isEmpty) {
      return 0;
    }

    if (_navigationCallback == null) {
      AppLogger.I().error(
        'deep_link_pending_route',
        StateError('Cannot process pending routes, not initialized'),
        StackTrace.current,
      );
      return 0;
    }

    // Check if context is available (if contextGetter is provided)
    final BuildContext? context = _contextGetter?.call();
    if (_contextGetter != null && (context == null || !context.mounted)) {
      AppLogger.I().info('DeepLinkHelper: cannot process pending routes, context not available');
      return 0;
    }

    // By default, process only the most recent route (last in queue)
    // This prevents rapid navigation through multiple routes
    final List<String> routesToProcess = processAll
        ? List.from(_pendingRoutes)
        : [_pendingRoutes.last];

    _pendingRoutes.clear();

    var successCount = 0;
    for (final route in routesToProcess) {
      try {
        _navigationCallback!(route);
        successCount++;
        AppLogger.I().info('DeepLinkHelper: Processed pending route $route');
      } catch (e, stackTrace) {
        AppLogger.I().error(
          'deep_link_pending_route',
          e,
          stackTrace,
          <String, String>{'route': route},
        );
      }
    }

    return successCount;
  }

  /// Clear all pending routes
  void clearPendingRoutes() {
    _pendingRoutes.clear();
    AppLogger.I().info('DeepLinkHelper: Cleared all pending routes');
  }

  /// Get the list of pending routes (for debugging)
  List<String> getPendingRoutes() => List.unmodifiable(_pendingRoutes);

  /// Check if there are pending routes
  bool hasPendingRoutes() => _pendingRoutes.isNotEmpty;
}
