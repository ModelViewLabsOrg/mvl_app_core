import 'package:flutter/material.dart';
import 'package:mvl_app_core/widgets/app_dimens.dart';
import 'package:mvl_app_core/widgets/center_max_width.dart';

class ResponsiveView extends StatelessWidget {
  const ResponsiveView(this.defaultChild, {this.desktopChild, this.tabletChild, super.key});

  final Widget defaultChild;
  final Widget? tabletChild;
  final Widget? desktopChild;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return switch (constraints.maxWidth) {
          >= AppDimens.kBreakpointDesktop => _maxWidth(desktopChild),
          >= AppDimens.kBreakpointTablet => _maxWidth(tabletChild),
          _ => defaultChild,
        };
      },
    );
  }

  Widget _maxWidth(Widget? child) {
    if (child == null) {
      return defaultChild;
    }

    return CenterMaxWidth(child: child);
  }
}
