import 'package:flutter/material.dart';
import 'package:mvl_app_core/extensions/flutter_ext/context_extension.dart';

class Avatar extends StatelessWidget {
  const Avatar(this.profileUrl, {super.key, this.placeholderIcon = Icons.image});

  final String? profileUrl;
  final IconData placeholderIcon;

  NetworkImage? get _image => profileUrl == null ? null : NetworkImage(profileUrl!);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: context.theme.primaryColor,
      radius: 28,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: context.theme.colorScheme.secondaryContainer,
        backgroundImage: _image,
        child: _image == null
            ? Icon(placeholderIcon, size: 32, color: context.theme.colorScheme.onSecondaryContainer)
            : null,
      ),
    );
  }
}
