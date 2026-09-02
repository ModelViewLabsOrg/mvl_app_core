import 'package:flutter/material.dart';

const gap = SizedBox.square(dimension: AppDimens.kDefaultPadding);
const gapS = SizedBox.square(dimension: AppDimens.kPaddingS);
const gapM = SizedBox.square(dimension: AppDimens.kPaddingM);
const gapXL = SizedBox.square(dimension: AppDimens.kPaddingXL);

const gapSliver = SliverToBoxAdapter(child: gap);

const padS = EdgeInsets.all(AppDimens.kPaddingS);
const padM = EdgeInsets.all(AppDimens.kPaddingM);
const padDefault = EdgeInsets.all(AppDimens.kDefaultPadding);
const padHorizontal = EdgeInsets.symmetric(horizontal: AppDimens.kDefaultPadding);
const padVertical = EdgeInsets.symmetric(vertical: AppDimens.kDefaultPadding);

const marginDefault = EdgeInsets.symmetric(
  horizontal: AppDimens.kDefaultPadding,
  vertical: AppDimens.kPaddingM,
);

const emptyBox = SizedBox.shrink();
const emptyBoxExpanded = Expanded(child: emptyBox);

class AppDimens {
  static const double kDefaultPadding = kPaddingL;

  // Padding
  static const double kPaddingXS = 2;
  static const double kPaddingS = 4;
  static const double kPaddingM = 8;
  static const double kPaddingL = 16;
  static const double kPaddingXL = 24;
  static const double kPaddingXXL = 32;

  static const double kBreakpointTablet = 650;
  static const double kBreakpointDesktop = 900;
  static const double kBreakpointDesktopIntermediate = 1100;
  static const double kQuickActionsMaxWidth = 400;
  static const double kMaxWidth = kBreakpointDesktop;

  //Icons size
  static const double iconS = 16;
  static const double iconM = 24;
  static const double iconL = 32;

  // Radius and Border
  static const double defaultRadius = 16;
  static BorderRadius defaultBorder({double radius = defaultRadius}) =>
      BorderRadius.circular(radius);
  static const defaultOffset = Offset(5, 5);
  static const double defaultBlurRadius = 10;

  // Card
  static const double elevation = 10;

  static List<BoxShadow> defaultBoxShadow(BuildContext context) => <BoxShadow>[
    BoxShadow(
      color: Theme.of(context).cardTheme.shadowColor ?? Colors.black54,
      blurRadius: 10,
      offset: const Offset(2, 4),
    ),
  ];

  static const avatarUploadSize = 720.0;
  static const avatarUploadMaxHeight = 360;
  static const avatarUploadMaxWidth = 3600;
  static const avatarUploadQuality = 100;
}
