enum EnvEnum { dev, uat, prd }

extension EnvEnumExt on EnvEnum {
  bool get isDev => this == EnvEnum.dev;
  bool get isUat => this == EnvEnum.uat;
  bool get isPrd => this == EnvEnum.prd;
}

class AppFlavor {
  static EnvEnum env = EnvEnum.prd;
}
