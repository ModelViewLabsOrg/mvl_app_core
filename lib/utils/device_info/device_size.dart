import 'package:mvl_app_core/utils/device_info/device_info.dart';

enum DeviceSizeType {
  mobileExtraSmall,
  mobileSmall,
  mobileMedium,
  mobileLarge,
  tabletMedium,
  tabletLarge,
  desktop,
}

enum DeviceScreenType {
  extraSmall,
  small,
  medium,
  large,
  extraLarge,
}

extension DeviceSizeExt on DeviceInfo {
  static DeviceSizeType deviceSizeType(double diagonalInches) {
    // if (width <= 360) return DeviceSizeType.MobileSmall;
    // if (width < 460) return DeviceSizeType.MobileMedium;
    // if (width < 660) return DeviceSizeType.MobileLarge;
    // if (width < 1000) return DeviceSizeType.TabletMedium;
    // if (width < 1300) return DeviceSizeType.TabletLarge;
    // return DeviceSizeType.Desktop;

// 768
// 1024

    // Mobile: 360 x 640
    // Mobile: 375 x 667
    // Mobile: 360 x 720
    // iPhone X: 375 x 812
    // Pixel 2: 411 x 731
    // Tablet: 768 x 1024
    // Laptop: 1366 x 768
    // High-res laptop or desktop: 1920 x 1080

// Design for desktop displays from 1024×768 through 1920×1080
// Design for mobile displays from 360×640 through 414×896
// Design for tablet displays from 601×962 through 1280×800

    if (diagonalInches <= 2.25) {
      return DeviceSizeType.mobileExtraSmall; // 325 SE1
    }
    if (diagonalInches <= 2.55) {
      return DeviceSizeType.mobileSmall; // 375 SE2 8 12Mini
    }
    if (diagonalInches <= 2.85) return DeviceSizeType.mobileMedium; // 425 12
    if (diagonalInches <= 3) return DeviceSizeType.mobileLarge; // 475 12 Pro
    if (diagonalInches <= 5.5) return DeviceSizeType.tabletMedium; // 800
    if (diagonalInches < 7) return DeviceSizeType.tabletLarge; // 1024

    return DeviceSizeType.desktop;
  }

  DeviceScreenType get deviceScreenType {
    if (isExtraSmall) return DeviceScreenType.extraSmall;
    if (isSmall) return DeviceScreenType.small;
    if (isMedium) return DeviceScreenType.medium;
    if (isLarge) return DeviceScreenType.large;

    // if (isExtraLarge)
    return DeviceScreenType.extraLarge;
  }

  bool get isExtraSmall => sizeType == DeviceSizeType.mobileExtraSmall;
  bool get isSmall => sizeType == DeviceSizeType.mobileSmall;
  bool get isMedium =>
      sizeType == DeviceSizeType.mobileMedium ||
      sizeType == DeviceSizeType.mobileLarge;
  bool get isLarge => sizeType == DeviceSizeType.tabletMedium;
  bool get isExtraLarge =>
      sizeType == DeviceSizeType.tabletLarge ||
      sizeType == DeviceSizeType.desktop;

  bool isEqualOrSmaller(DeviceScreenType type) => sizeType.index <= type.index;
  bool isEqualOrBigger(DeviceScreenType type) => sizeType.index >= type.index;
}
