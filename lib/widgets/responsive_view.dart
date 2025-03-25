import 'package:flutter/material.dart';
import 'package:mvl_app_core/widgets/app_dimens.dart';

class ResponsiveView extends StatelessWidget {
  const ResponsiveView(
    this.desktopChild, {
    this.mobileChild,
    this.tabletChild,
    super.key,
  });

  final Widget desktopChild;
  final Widget? mobileChild;
  final Widget? tabletChild;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return switch (constraints.maxWidth) {
              > AppDimens.kBreakpointDesktop => desktopChild,
              > AppDimens.kBreakpointTablet => tabletChild,
              _ => mobileChild
            } ??
            desktopChild;
      },
    );
  }
}
