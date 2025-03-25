import 'package:flutter/material.dart';
import 'package:mvl_app_core/widgets/app_dimens.dart';

extension WidgetExtensions on Widget {
  Widget withMouse() {
    return MouseRegion(cursor: SystemMouseCursors.click, child: this);
  }

  Widget withRoundCorners() => DecoratedBox(
    decoration: const BoxDecoration(
      color: Colors.grey,
      borderRadius: BorderRadius.all(Radius.circular(25)),
    ),
    child: this,
  );

  /// A shadow cast by a box
  ///
  /// [shadowColor]
  Widget withShadow({
    Color shadowColor = Colors.grey,
    double blurRadius = 20.0,
    double spreadRadius = 1.0,
    Offset offset = const Offset(10, 10),
  }) => DecoratedBox(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
          offset: offset,
        ),
      ],
    ),
    child: this,
  );

  Widget addNeumorphism({
    double borderRadius = AppDimens.defaultRadius,
    Offset offset = AppDimens.defaultOffset,
    double blurRadius = AppDimens.defaultBlurRadius,
    Color topShadowColor = Colors.white60,
    Color bottomShadowColor = Colors.black87,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppDimens.defaultBorder(radius: borderRadius),
        boxShadow: [
          BoxShadow(
            offset: offset,
            blurRadius: blurRadius,
            color: bottomShadowColor,
          ),
          BoxShadow(
            offset: Offset(-offset.dx, -offset.dx),
            blurRadius: blurRadius,
            color: topShadowColor,
          ),
        ],
      ),
      child: this,
    );
  }

  Widget withTooltip(
    String message, {
    Decoration? decoration,
    double? height,
    bool? preferBelow,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    Duration? waitDuration,
    EdgeInsetsGeometry? margin,
  }) => Tooltip(
    message: message,
    decoration: decoration,
    height: height,
    padding: padding,
    preferBelow: preferBelow,
    textStyle: textStyle,
    waitDuration: waitDuration,
    margin: margin,
    child: this,
  );
}
