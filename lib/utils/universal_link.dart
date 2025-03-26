import 'package:flutter/foundation.dart';
import 'package:mvl_app_core/utils/device_info/device_info.dart';
import 'package:url_launcher/url_launcher.dart';

mixin HasStoreLink {
  Uri get storeLink;
}

@immutable
class _AppStoreApp with HasStoreLink {
  const _AppStoreApp({required this.country, required this.appId});

  final String country;
  final String appId;

  @override
  Uri get storeLink =>
      DeviceInfo.isApple
          ? Uri.parse('itms-apps://itunes.apple.com/app/apple-store/id$appId')
          : Uri.parse('https://apps.apple.com/$country/app/id$appId');
}

@immutable
class _PlayStoreApp with HasStoreLink {
  const _PlayStoreApp(this.packageName);
  final String packageName;

  @override
  Uri get storeLink =>
      DeviceInfo.isAndroid
          ? Uri.parse('market://details?id=$packageName')
          : Uri.parse('https://play.google.com/store/apps/details?id=$packageName');
}

@immutable
class UniversalApp {
  const UniversalApp({required this.appId, required this.country, required this.packageName});

  final String appId;
  final String country;
  final String packageName;

  Future<void> open() {
    if (DeviceInfo.isApple) {
      return launchUrl(_AppStoreApp(appId: appId, country: country).storeLink);
    }
    if (DeviceInfo.isAndroid) {
      return launchUrl(_PlayStoreApp(packageName).storeLink);
    }

    throw UnsupportedError('Platform not supported');
  }
}

// void testIt() async {
//   const needForSpeedNoLimits = UniversalApp(
//     appId: 'id883393043',
//     country: 'us',
//     packageName: 'com.ea.game.nfs14_row',
//   );
//   await needForSpeedNoLimits.open();
// }
