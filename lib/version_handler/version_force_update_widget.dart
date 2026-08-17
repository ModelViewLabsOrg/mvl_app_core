import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvl_app_core/mvl_app_core.dart';
import 'package:mvl_app_core/version_handler/version_alert_localization.dart';
import 'package:mvl_app_core/version_handler/version_alert_widget.dart';
import 'package:mvl_app_core/version_handler/version_force_update_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VersionForceUpdateWidget extends StatefulWidget {
  const VersionForceUpdateWidget({
    required this.child,
    required this.navigatorKey,
    required this.forceUpdateClient,
    this.mandatoryLocalization = const VersionAlertLocalizationMandatory(),
    this.recommendedLocalization = const VersionAlertLocalizationMandatory(),
    this.repeatRecommendedAlertDays = 3,
    this.cacheMinutes = 30,
    super.key,
  });

  final VersionAlertLocalization mandatoryLocalization;
  final VersionAlertLocalizationMandatory recommendedLocalization;

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  final ForceUpdateClient forceUpdateClient;

  String get versionLaterKey =>
      'update_version_'
      '${forceUpdateClient.recommendedVersion}';
  final int repeatRecommendedAlertDays;
  final int cacheMinutes;

  @override
  State<VersionForceUpdateWidget> createState() => _VersionForceUpdateWidgetState();
}

class _VersionForceUpdateWidgetState extends State<VersionForceUpdateWidget>
    with WidgetsBindingObserver {
  var _isAlertVisible = false;
  DateTime? _lastCheck;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_checkIfAppUpdateIsNeeded());
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await _checkIfAppUpdateIsNeeded();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkIfAppUpdateIsNeeded() async {
    if (_isAlertVisible) {
      tracking.event('atualizar_alerta_visivel');
      appLogger.info('Update alert still visible');
      return;
    }

    if (_checkCacheIsValid()) {
      appLogger.info('Update alert still has valid cache');
      return;
    }

    try {
      final ForceUpdateStatus updateResult = await widget.forceUpdateClient.checkUpdate();
      _lastCheck = DateTime.now();
      appLogger.info(
        'Check Update result: '
        '${updateResult.name.toUpperCase()}',
      );

      tracking.event(
        'atualizar_alerta_verificação',
        customParams: <String, String>{'status': updateResult.name},
      );

      switch (updateResult) {
        case ForceUpdateStatus.must:
          await _triggerForceUpdate(false);

        case ForceUpdateStatus.should:
          await _shouldShowRecommendedAlertAgain();

        case ForceUpdateStatus.osIgnored:
        case ForceUpdateStatus.error:
        case ForceUpdateStatus.latest:
          break;
      }
    } catch (e, s) {
      appLogger.error('Update version error', e, s);
    }
  }

  bool _checkCacheIsValid() {
    final DateTime? lastCheck = _lastCheck;
    if (lastCheck == null) {
      return false;
    }

    final Duration diff = DateTime.now().difference(lastCheck);
    final bool isValid = diff.inMinutes < widget.cacheMinutes;

    if (isValid) {
      tracking.event(
        'atualizar_alerta_cache',
        customParams: <String, String>{'diferença minutos': diff.inMinutes.toString()},
      );
    }

    return isValid;
  }

  Future<void> _shouldShowRecommendedAlertAgain() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    final int? lastTimeMs = sharedPrefs.getInt(widget.versionLaterKey);

    if (lastTimeMs != null) {
      final lastTime = DateTime.fromMillisecondsSinceEpoch(lastTimeMs);

      final int diff = DateTime.now().difference(lastTime).inDays;
      if (diff < widget.repeatRecommendedAlertDays) {
        appLogger.info(
          'Last alert showed in $diff days, '
          'ignoring this alert.',
        );
        tracking.event(
          'atualizar_alerta_depois',
          customParams: <String, String>{'diferença dias': diff.toString()},
        );

        return;
      }
    }

    return _triggerForceUpdate(true);
  }

  Future<bool?> _showAlert(BuildContext context, bool allowCancel) {
    return showAdaptiveDialog<bool>(
      context: context,
      barrierDismissible: allowCancel,
      builder: (context) {
        return VersionAlertWidget(
          allowCancel: allowCancel,
          mandatoryLocalization: widget.mandatoryLocalization,
          recommendedLocalization: widget.recommendedLocalization,
        );
      },
    );
  }

  Future<void> _triggerForceUpdate(bool allowCancel) async {
    _isAlertVisible = true;
    final BuildContext context = widget.navigatorKey.currentContext ?? this.context;
    await _showAlert(context, allowCancel);

    _isAlertVisible = false;

    return allowCancel ? _saveForLater() : _triggerForceUpdate(allowCancel);
  }

  Future<void> _saveForLater() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

    await sharedPrefs.setInt(widget.versionLaterKey, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
