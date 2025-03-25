import 'package:flutter/material.dart';
import 'package:mvl_app_core/extensions/flutter_ext/context_extension.dart';
import 'package:mvl_app_core/widgets/app_dimens.dart';

class Avatar extends StatelessWidget {
  const Avatar(this.profileUrl, {super.key});

  final String? profileUrl;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: context.theme.primaryColor,
      radius: AppDimens.defaultRadius,
      child: CircleAvatar(
        radius: AppDimens.defaultRadius - 5,
        backgroundColor: context.theme.colorScheme.secondaryContainer,
        backgroundImage: _image(),
      ),
    );
  }

  NetworkImage? _image() {
    final profileUrl = this.profileUrl;
    return profileUrl == null ? null : NetworkImage(profileUrl);
  }
}
