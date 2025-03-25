import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvl_app_core/app_tracking.dart';
import 'package:mvl_app_core/extensions/bool_ext.dart';
import 'package:mvl_app_core/utils/device_info/device_info.dart';
import 'package:mvl_app_core/version_handler/version_alert_localization.dart';
import 'package:mvl_app_core/widgets/app_dimens.dart';

class VersionAlertWidget extends StatelessWidget {
  const VersionAlertWidget({
    required this.allowCancel,
    this.mandatoryLocalization = const VersionAlertLocalizationMandatory(),
    this.recommendedLocalization = const VersionAlertLocalizationMandatory(),
    super.key,
  });

  final bool allowCancel;
  final VersionAlertLocalization mandatoryLocalization;
  final VersionAlertLocalizationMandatory recommendedLocalization;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: allowCancel,
      child: DeviceInfo.shouldUseCupertino ? _cupertinoAlert(context) : _materialAlert(context),
    );
  }

  Widget _materialAlert(BuildContext context) {
    return AlertDialog(
      title: _title(context),
      content: _content(context),
      actions: <Widget>[
        if (allowCancel)
          TextButton(onPressed: () => _notNow(context), child: Text(recommendedLocalization.buttonLater)),
        FilledButton(onPressed: () async => _mainAction(context), child: Text(mandatoryLocalization.buttonNow)),
      ],
    );
  }

  Widget _cupertinoAlert(BuildContext context) {
    return CupertinoAlertDialog(
      title: _title(context),
      content: _content(context),
      actions: <Widget>[
        if (allowCancel)
          CupertinoDialogAction(onPressed: () => _notNow(context), child: Text(recommendedLocalization.buttonLater)),
        CupertinoDialogAction(
          onPressed: () async => _mainAction(context),
          isDefaultAction: true,
          child: Text(mandatoryLocalization.buttonNow),
        ),
      ],
    );
  }

  Widget _title(BuildContext context) {
    return Text(
      allowCancel ? recommendedLocalization.title : mandatoryLocalization.title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor),
    );
  }

  Widget _content(BuildContext context) {
    final text = Text(
      allowCancel ? recommendedLocalization.message : mandatoryLocalization.message,
      style: Theme.of(context).textTheme.bodyMedium,
      maxLines: 9,
    );

    final image = mandatoryLocalization.image;
    if (image == null) return text;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [gap, image, gapXL, text],
    );
  }

  Future<void> _mainAction(BuildContext context) async {
    tracking.event('atualizar_alerta_agora', customParams: {'opcional': allowCancel.toPtBr()});

    await tracking.openStore();

    if (context.mounted && allowCancel) Navigator.of(context).pop();
  }

  void _notNow(BuildContext context) {
    tracking.event('atualizar_alerta_depois');

    Navigator.of(context).pop(false);
  }
}
