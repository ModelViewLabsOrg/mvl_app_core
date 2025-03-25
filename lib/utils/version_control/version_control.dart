import 'package:flutter/foundation.dart';
import 'package:mvl_app_core/app_config.dart';
import 'package:mvl_app_core/app_logger.dart';
import 'package:mvl_app_core/utils/device_info/device_info.dart';
import 'package:mvl_app_core/utils/launch_extension.dart';
import 'package:mvl_app_core/utils/version_control/version_flag.dart';
import 'package:version/version.dart';

abstract class VersionControl {
  VersionControl({
    required this.newVersion,
    required this.title,
    required this.message,
  }) : _versionAvailableFlag = VersionAvailableFlag(newVersion.toString());

  final VersionAvailableFlag _versionAvailableFlag;
  final Version newVersion;
  final String title;
  final String message;

  bool get isForce => this is VersionControlOutdated;
  bool get isOptional => !isForce;

  Future<bool> shouldShow() => _versionAvailableFlag.shouldShow();
  Future<void> didShow() => _versionAvailableFlag.didShow();

  static Future<void> launchStore({required bool writeReview}) async {
    try {
      if (kIsWeb) return;

      final config = AppConfig.I().configValues;

      if (DeviceInfo.isApple) {
        final suffix = writeReview ? '?action=write-review' : '';
        final appStoreLink =
            'https://apps.apple.com/app/id'
            '${config.appStoreId}$suffix';

        AppLogger.I().info('LaunchUrl: $appStoreLink');

        await appStoreLink.launchURL();
        return;
      }

      if (DeviceInfo.isAndroid) {
        final id = config.playStoreId;
        final market = 'market://details?id=$id';
        AppLogger.I().info('LaunchUrl: $market');

        if (!(await market.launchURL())) {
          final play = 'https://play.google.com/store/apps/details?id=$id';
          AppLogger.I().info('couldnt launch market, trying : $play');

          await play.launchURL();
        }
      }
    } catch (e, s) {
      AppLogger.I().error('LaunchStore', e, s);
    }
  }
}

class VersionControlOutdated extends VersionControl {
  VersionControlOutdated({
    required super.newVersion,
    super.title = 'Versão desatualizada!',
    super.message =
        'Essa versão está antiga e não vai funcionar como deveria, por '
            'favor atualize seu app pela loja de aplicativos para continuar '
            'usando a nossa plataforma!',
  });
}

class VersionControlAdvised extends VersionControl {
  VersionControlAdvised({
    required super.newVersion,
    super.title = 'Existe uma nova atualização disponível!',
    super.message =
        'Tem uma versão nova disponível. '
            'Atualize seu app para ter acesso às últimas novidades, '
            'novos recursos e correções de erros!',
  });
}
