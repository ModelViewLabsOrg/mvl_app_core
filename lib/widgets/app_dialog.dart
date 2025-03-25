import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class AppDialog {
  const AppDialog({
    required this.title,
    required this.defaultActionText,
    required this.content,
    required this.cancelActionText,
  });

  final String title;
  final String defaultActionText;
  final String? content;
  final String? cancelActionText;

  Future<bool?> showAlertDialog(BuildContext context) async {
    final content = this.content;
    final cancelActionText = this.cancelActionText;

    if (kIsWeb || !Platform.isIOS) {
      return showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(title),
              content: content != null ? Text(content) : null,
              actions: <Widget>[
                if (cancelActionText != null)
                  TextButton(
                    child: Text(cancelActionText),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                TextButton(
                  child: Text(defaultActionText),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
      );
    }

    return showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: Text(title),
            content: content != null ? Text(content) : null,
            actions: <Widget>[
              if (cancelActionText != null)
                CupertinoDialogAction(
                  child: Text(cancelActionText),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              CupertinoDialogAction(
                child: Text(defaultActionText),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );
  }
}
