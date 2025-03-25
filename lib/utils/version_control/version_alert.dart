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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (versionControl.isOptional)
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: Navigator.of(context).pop,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      // color: appcolors.?,
                    ),
                    child: const Icon(
                      Icons.close,
                      // color: appcolors.?,
                    ),
                  ),
                ),
              ),
            const Padding(
              padding: EdgeInsets.only(bottom: AppDimens.kDefaultPadding),
              child: Icon(Icons.warning_amber_rounded),
              // child: Assets.images.versionOutdatedLogo.image(
              //   height: 160,
              //   width: double.maxFinite,
              //   fit: BoxFit.fill,
              // ),
            ),
            Center(
              child: AppText.headlineMedium(
                context,
                versionControl.title,
              ),
            ),
            gapM,
            Center(
              child: AppText.bodyMedium(
                context,
                versionControl.message,
              ),
            ),
            gap,
            OutlinedButton(
              onPressed: () {
                unawaited(VersionControl.launchStore(writeReview: false));
                if (versionControl.isOptional) Navigator.of(context).pop();
              },
              child: const Text('Ir para a loja'),
            ),
            if (versionControl.isOptional)
              Padding(
                padding: const EdgeInsets.only(top: AppDimens.kDefaultPadding),
                child: TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: const Text('Agora não'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
