import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvl_app_core/app_config.dart';
import 'package:mvl_app_core/push_notifications/fcm_manager.dart';
import 'package:mvl_app_core/utils/env_enum.dart';
import 'package:mvl_app_core/utils/json.dart';
import 'package:mvl_app_core/utils/version_control/version_control.dart';
import 'package:mvl_app_core/widgets/app_dimens.dart';
import 'package:mvl_app_core/widgets/app_text.dart';
import 'package:mvl_app_core/widgets/app_toast_message.dart';
import 'package:mvl_app_core/widgets/copy_text.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

class AppVersionArgs {
  AppVersionArgs({required String min, required String ideal})
    : min = Version.parse(min),
      ideal = Version.parse(ideal);

  final Version min;
  final Version ideal;
}

class AppVersion {
  factory AppVersion.I() => _instance;
  AppVersion._internal();
  static final _instance = AppVersion._internal();

  Future<void> init() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    versionStr = info.version;
    version = Version.parse(info.version);

    versionFull = '$versionStr+${info.buildNumber}';
    appName = info.appName;
    await _deviceOSInfo();
  }

  late final String appName;
  late final String versionStr;
  late final Version version;

  late final String versionFull;
  late final String osName;
  late final String osVersion;
  late final String deviceFull;
  late final String? deviceId;

  late final VersionControl? versionControl;

  String get appHeader => '$versionFull $osName $osVersion';

  // void checkVersion(AppVersionArgs args) {
  //   if (args.min > version) {
  //     versionControl = VersionControlOutdated(newVersion: args.min);
  //     return;
  //   }

  //   if (args.ideal > version) {
  //     versionControl = VersionControlAdvised(newVersion: args.ideal);
  //     return;
  //   }

  //   versionControl = null;
  // }

  Widget versionWidget(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        final String? token = AppFcmManager.I().token;
        if (token == null) {
          AppToastMessages('Sem token!', isError: true).show(context);
        } else {
          return CopyAndShowMessage(
            textToCopy: token,
            messageFeedback: 'Copiado: $token',
          ).show(context);
        }
      },
      child: _versionChild(context),
    );
  }

  Widget _versionChild(BuildContext context) {
    final EnvEnum env = AppConfig.env;

    if (env.isPrd) {
      return AppText.titleLarge(context, versionStr);
    }

    return Column(
      children: <Widget>[
        AppText.titleLarge(context, versionFull),
        gapM,
        AppText.titleLarge(context, env.name.toUpperCase()),
      ],
    );
  }

  Future<void> _deviceOSInfo() async {
    final plugin = DeviceInfoPlugin();

    if (kIsWeb) {
      final WebBrowserInfo info = await plugin.webBrowserInfo;

      osName = 'web';
      osVersion = info.appVersion ?? '';
      deviceFull = info.browserName.name;
      return;
    }

    osName = Platform.operatingSystem;

    if (Platform.isAndroid) {
      final AndroidDeviceInfo info = await plugin.androidInfo;
      final AndroidBuildVersion version = info.version;
      osVersion = '${version.release} (SDK ${version.sdkInt})';
      deviceFull = '${info.manufacturer} ${info.model}';
      deviceId = null;
    } else if (Platform.isIOS) {
      final IosDeviceInfo info = await plugin.iosInfo;
      osVersion = info.systemVersion;
      deviceFull = info.model;
      deviceId = info.identifierForVendor;
    } else if (Platform.isMacOS) {
      final MacOsDeviceInfo info = await plugin.macOsInfo;
      osVersion = info.osRelease;
      deviceFull = info.model;
      deviceId = info.systemGUID;
    } else if (Platform.isLinux) {
      final LinuxDeviceInfo info = await plugin.linuxInfo;
      osVersion = info.version ?? '?';
      deviceFull = info.prettyName;
      deviceId = info.id;
    }
  }

  @override
  String toString() => '$appName $versionFull\n$osName $osVersion';

  JsonString toHeaders() {
    return <String, String>{'app-name': appName, 'version': versionFull, 'os': osName, 'os-version': osVersion};
  }
}
