import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvl_app_core/utils/version_control/version_control.dart';
import 'package:mvl_app_core/widgets/app_dimens.dart';
import 'package:mvl_app_core/widgets/app_text.dart';

class VersionAlertDialog extends StatelessWidget {
  const VersionAlertDialog(this.versionControl, {super.key});

  final VersionControl versionControl;

  @override
  Widget build(BuildContext context) {
    unawaited(versionControl.didShow());

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppDimens.defaultBorder()),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: padDefault,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (versionControl.isShouldUpdate)
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: Navigator.of(context).pop,
                  child: Container(
                    padding: padM,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: const Icon(Icons.close),
                  ),
                ),
              ),

            Row(
              children: [
                const Icon(Icons.warning_amber_rounded),
                gap,
                Expanded(child: AppText.headlineMedium(context, versionControl.title)),
              ],
            ),
            gapM,
            Center(child: AppText.bodyMedium(context, versionControl.message)),
            gap,
            if (versionControl.isShouldUpdate)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [_updateButton(context), _notNowButton(context)],
              )
            else
              _notNowButton(context),
          ],
        ),
      ),
    );
  }

  Widget _updateButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        unawaited(VersionControl.launchStore(writeReview: false));
        if (versionControl.isShouldUpdate) {
          Navigator.of(context).pop();
        }
      },
      child: const Text('Ir para a loja'),
    );
  }

  Widget _notNowButton(BuildContext context) {
    return TextButton(
      onPressed: Navigator.of(context).pop,
      child: const Text('Agora não'),
    );
  }
}
