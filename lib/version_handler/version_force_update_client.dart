import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mvl_app_core/app_logger.dart';
import 'package:mvl_app_core/app_tracking.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

enum ForceUpdateStatus { osIgnored, error, latest, must, should }

extension on ForceUpdateStatus {
  String get trackEventName {
    return switch (this) {
      ForceUpdateStatus.osIgnored => 'SO ignorado',
      ForceUpdateStatus.error => 'Erro',
      ForceUpdateStatus.latest => 'Atualizado',
      ForceUpdateStatus.must => 'Obrigatório',
      ForceUpdateStatus.should => 'Recomendado',
    };
  }
}

/// Client used to check if a force upgrade is needed
class ForceUpdateClient {
  ForceUpdateClient({required this.fetchRequiredVersion, required this.fetchRecommendedVersion});

  final Future<String> Function() fetchRequiredVersion;
  final Future<String> Function() fetchRecommendedVersion;

  PackageInfo? _packageInfo;
  Version? recommendedVersion;

  /// Fetches the required version and checks if a force update is needed by
  /// comparing it with the current version (from PackageInfo)
  Future<ForceUpdateStatus> checkUpdate() async {
    // * Only force app update on iOS & Android

    if (kIsWeb) {
      return ForceUpdateStatus.osIgnored;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        break;

      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return ForceUpdateStatus.osIgnored;
    }

    final Version? requiredVersion = await _version(fetchRequiredVersion);
    if (requiredVersion == null) {
      return ForceUpdateStatus.error;
    }
    recommendedVersion = await _version(fetchRecommendedVersion);
    if (recommendedVersion == null) {
      return ForceUpdateStatus.error;
    }

    final PackageInfo packageInfo = _packageInfo ?? await PackageInfo.fromPlatform();
    _packageInfo ??= packageInfo;

    // * On Android, the current version shows as `X.Y.Z.flavor`
    // * But semver can only parse this if it's formatted as `X.Y.Z-flavor`
    // * and we only care about X.Y.Z, so we can remove the flavor
    const String flavorStr = appFlavor ?? '';
    final String currentVersionStr = flavorStr.isEmpty
        ? packageInfo.version
        : packageInfo.version.replaceAll('.$flavorStr', '');

    // * Parse versions in semver format
    final Version currentVersion = Version.parse(currentVersionStr);

    AppLogger.I().info(
      'Current version: $currentVersion, '
      'required version: $requiredVersion, '
      'recommended version: $recommendedVersion',
    );

    final ForceUpdateStatus status;

    if (currentVersion < requiredVersion) {
      status = ForceUpdateStatus.must;
    } else if (currentVersion < recommendedVersion) {
      status = ForceUpdateStatus.should;
    } else {
      status = ForceUpdateStatus.latest;
    }

    tracking.event(
      'atualizar_alerta',
      customParams: <String, String>{
        'versão instalada': currentVersionStr,
        'requirida': requiredVersion.toString(),
        'recomendada': recommendedVersion.toString(),
        'resultado': status.trackEventName,
      },
    );

    return status;
  }

  Future<Version?> _version(Future<String> Function() fetchVersion) async {
    try {
      final String versionStr = await fetchVersion();
      final Version version = Version.parse(versionStr);
      return version;
    } catch (e, s) {
      AppLogger.I().error('Error on fetch version', e, s);
      return null;
    }
  }
}
