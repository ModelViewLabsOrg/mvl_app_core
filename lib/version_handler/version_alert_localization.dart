import 'package:flutter/widgets.dart';

abstract class VersionAlertLocalization {
  const VersionAlertLocalization({
    required this.title,
    required this.message,
    this.buttonNow = 'Atualizar',
    this.image,
  });

  final String title;
  final String message;
  final String buttonNow;
  final Image? image;
}

class VersionAlertLocalizationMandatory extends VersionAlertLocalization {
  const VersionAlertLocalizationMandatory({
    super.title = 'Versão desatualizada',
    super.message =
        'Você tem uma versão que não é suportada, '
        'atualize antes de continuar!',
    this.buttonLater = 'Depois',
    super.buttonNow,
    super.image,
  });

  final String buttonLater;
}

class VersionAlertLocalizationRecommended extends VersionAlertLocalization {
  const VersionAlertLocalizationRecommended({
    super.title = 'Atualização disponível',
    super.message =
        'Mantenha seu aplicativo atualizado '
        'para manter livre de falhas e fique com as novidades em dia.',
    super.buttonNow,
    super.image,
  });
}
