enum EnvEnum { prd, uat }

extension EnvEnumExt on EnvEnum {
  // bool get isDev => this == EnvEnum.dev;
  bool get isUat => this == EnvEnum.uat;
  bool get isPrd => this == EnvEnum.prd;
}

class Flavor {
  static EnvEnum appEnv = EnvEnum.prd;
}
