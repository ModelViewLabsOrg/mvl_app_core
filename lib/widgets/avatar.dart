import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mvl_app_core/extensions/flutter_ext/context_extension.dart';

class Avatar extends StatelessWidget {
  Avatar({
    String? profileUrl,
    Uint8List? file,
    super.key,
    this.placeholderIcon = Icons.image,
  }) : _image = profileUrl != null
           ? NetworkImage(profileUrl)
           : file != null
           ? MemoryImage(file)
           : null,
       assert(
         (profileUrl == null && file != null) || (profileUrl != null && file == null),
         'Only one must be provide: profile url or file',
       );

  final IconData placeholderIcon;

  final ImageProvider? _image;

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
