import 'package:mvl_app_core/utils/json.dart';

class ApiHeaders {
  const ApiHeaders({
    required this.version,
    required this.os,
    required this.osVersion,
    required this.device,
    required this.fcmToken,
  });

  JsonString toJson() => {
        'appVersion': version,
        'appOs': os,
        'appOsVersion': osVersion,
        'appDevice': device,
        'appFcmToken': fcmToken ?? '',
      };

  final String version;
  final String os;
  final String osVersion;
  final String device;
  final String? fcmToken;
}
