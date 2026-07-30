import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvl_app_core/extensions/flutter_ext/context_extension.dart';
import 'package:mvl_app_core/utils/app_version.dart';
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
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.kDefaultPadding),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: context.theme.colorScheme.error,
                ),
                // child: Assets.images.versionOutdatedLogo.image(
                //   height: 160,
                //   width: double.maxFinite,
                //   fit: BoxFit.fill,
                // ),
              ),
            ),
            Center(
              child: AppText.headlineMedium(
                context,
                versionControl.title,
                textAlign: TextAlign.center,
              ),
            ),
            gapM,
            Center(
              child: AppText.bodySmall(
                context,
                'Sua versão atual é: ${AppVersion.I().versionStr}',
              ),
            ),
            gapM,
            Center(child: AppText.bodyMedium(context, versionControl.message)),
            gap,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    unawaited(VersionControl.launchStore(writeReview: false));
                    if (versionControl.isShouldUpdate) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Ir para a loja'),
                ),
                if (versionControl.isShouldUpdate)
                  Padding(
                    padding: const EdgeInsets.only(left: AppDimens.kDefaultPadding),
                    child: TextButton(
                      onPressed: Navigator.of(context).pop,
                      child: const Text('Agora não'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
