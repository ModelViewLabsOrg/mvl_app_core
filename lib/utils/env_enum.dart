enum EnvEnum { prd, uat, dev }

extension EnvEnumExt on EnvEnum {
  bool get isDev => this == EnvEnum.dev;
  bool get isUat => this == EnvEnum.uat;
  bool get isPrd => this == EnvEnum.prd;
}
