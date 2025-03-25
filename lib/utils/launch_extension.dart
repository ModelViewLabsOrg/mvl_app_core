import 'package:mvl_app_core/app_logger.dart';
import 'package:mvl_app_core/extensions/string_extension.dart';
import 'package:mvl_app_core/utils/device_info/device_info.dart';
import 'package:url_launcher/url_launcher.dart';

extension LaunchExt on String {
  Future<bool> launchURL({
    LaunchMode launchMode = LaunchMode.platformDefault,
  }) async {
    try {
      final result = await launchUrl(Uri.parse(this), mode: launchMode);
      return result;
      // } else {
      // AppLogger().error('launchURL',
      //'Could not launch $url', StackTrace.empty,);
      // }
      // return false;
    } catch (e, s) {
      AppLogger.I().error('launchURL', e, s);
      return false;
    }
  }
}

extension LaunchNullExt on String? {
  Future<bool> launchURL({
    LaunchMode launchMode = LaunchMode.platformDefault,
  }) async {
    final url = this;
    if (url == null) return false;
    return url.launchURL(launchMode: launchMode);
  }

  Future<bool> downloadFile() =>
      launchURL(launchMode: LaunchMode.externalApplication);

  Future<void> launchWhatsapp({String? msg}) async {
    var number = onlyNumbers();
    if (number.isReallyEmpty()) return;
    number = number.startsWith('55') ? number : '55$number';
    // number = number.startsWith('55') ? number.substring(2) : number;
    final text = msg == null ? '' : 'text=${Uri.encodeFull(msg)}';

    final bool shouldTryAgain;
    final String url;

    if (DeviceInfo.isApple) {
      url = 'whatsapp://wa.me/$number/?$text';
      shouldTryAgain = true;
    } else if (DeviceInfo.isAndroid) {
      url = 'whatsapp://send?phone=$number&$text';
      shouldTryAgain = true;
    } else {
      url = 'https://wa.me/$number?$text';
      shouldTryAgain = false;
    }

    final result = await url.launchURL();
    if (!result && shouldTryAgain) {
      await 'https://wa.me/$number?$text'.launchURL();
    }
  }

  Future<void> mailTo({String? subject, String? body}) async {
    final params = Uri(
      scheme: 'mailto',
      path: this,
      query: 'subject=${subject ?? ''}&body=${body ?? ''}',
    );

    await params.toString().launchURL();
  }

  Future<void> call() async {
    final number = '+${onlyNumbers()}';
    await 'tel://$number'.launchURL();
  }
}
