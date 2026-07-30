import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mvl_app_core/extensions/flutter_ext/context_extension.dart';
import 'package:mvl_app_core/utils/device_info/device_size.dart';

export 'device_size.dart';

class DeviceInfo {
  DeviceInfo(BuildContext c) {
    size = c.mq.size;
    ppi = kIsWeb ? 96 : 150;

    final double width = size.width;
    final double height = size.height;
    diagonal = sqrt((width * width) + (height + height));
    inches = Size(width / ppi, height / ppi);
    diagonalInches = diagonal / ppi;

    sizeType = DeviceSizeExt.deviceSizeType(diagonalInches);

    // print('DiagonalIn: $diagonalInches, Size $sizeType, Type $type');
  }

  late Size size;
  late DeviceSizeType sizeType;

  late double diagonal;
  late double ppi;
  late double diagonalInches;
  late Size inches;

  static bool isLandscape(BuildContext c) => MediaQuery.of(c).orientation == Orientation.landscape;
  static double devicePixelRatio(BuildContext c) => MediaQuery.of(c).devicePixelRatio;

  @override
  String toString() {
    return '$size\n$sizeType\n\n'
        'width: ${size.width.toStringAsFixed(2)} x '
        'height: ${size.height.toStringAsFixed(2)}\n'
        'diagonal: ${diagonal.toStringAsFixed(2)}\n'
        'ppi: $ppi\n'
        'inches: $inches\n'
        'diagonalInches: ${diagonalInches.toStringAsFixed(2)}\n'
        'devicePixelRatio: $devicePixelRatio\n'
        'isLandscape: $isLandscape';
  }
  // 'widthInches: ${widthInches.toStringAsFixed(2)} x heightInches: ${heightInches.toStringAsFixed(2)}\n'

  static bool get shouldUseCupertino => !kIsWeb && isApple;

  static bool get isWeb => kIsWeb;
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  static bool get isIos => defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isMacos => defaultTargetPlatform == TargetPlatform.macOS;
  static bool get isApple => isIos || isMacos;

  static bool get isMobile => !isWeb && (isAndroid || isIos);
  static bool get isDesktop {
    if (isWeb) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => false,
      TargetPlatform.fuchsia ||
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => true,
    };
  }
}
