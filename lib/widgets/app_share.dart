import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class AppShare extends StatelessWidget {
  const AppShare({required this.content, this.buttonLabel = 'Compartilhar', super.key});

  final String? buttonLabel;
  final String content;

  Future<void> shareText(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return Future.value();

    return Share.share(content, sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context) {
    final label = buttonLabel;

    final icon = Icon(Icons.adaptive.share);
    Future<void> onPressed() async => shareText(context);

    if (label == null) {
      return IconButton(onPressed: onPressed, icon: icon);
    }

    return ElevatedButton.icon(onPressed: onPressed, icon: icon, label: Text(label));
  }
}
