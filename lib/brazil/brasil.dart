import 'package:enum_to_string/enum_to_string.dart';

enum BrasilState {
  ac,
  al,
  ap,
  am,
  ba,
  ce,
  df,
  es,
  go,
  ma,
  mt,
  ms,
  mg,
  pa,
  pb,
  pr,
  pe,
  pi,
  rj,
  rn,
  rs,
  ro,
  rr,
  sc,
  sp,
  se,
  to,
}

BrasilState stateFromJson(String value) =>
    EnumToString.fromString(BrasilState.values, value.toLowerCase())!;

extension BrasilStateExt on BrasilState {
  String get state => Brasil.listStates[this] ?? '';
}

mixin Brasil {
  static const country = 'br';

  static const Map<BrasilState, String> listStates = {
    BrasilState.ac: 'Acre',
    BrasilState.al: 'Alagoas',
    BrasilState.ap: 'Amapá',
    BrasilState.am: 'Amazonas',
    BrasilState.ba: 'Bahia',
    BrasilState.ce: 'Ceará',
    BrasilState.df: 'Distrito Federal',
    BrasilState.es: 'Espírito Santo',
    BrasilState.go: 'Goiás',
    BrasilState.ma: 'Maranhão',
    BrasilState.mt: 'Mato Grosso',
    BrasilState.ms: 'Mato Grosso do Sul',
    BrasilState.mg: 'Minas Gerais',
    BrasilState.pa: 'Pará',
    BrasilState.pb: 'Paraíba',
    BrasilState.pr: 'Paraná',
    BrasilState.pe: 'Pernambuco',
    BrasilState.pi: 'Piauí',
    BrasilState.rj: 'Rio de Janeiro',
    BrasilState.rn: 'Rio Grande do Norte',
    BrasilState.rs: 'Rio Grande do Sul',
    BrasilState.ro: 'Rondônia',
    BrasilState.rr: 'Roraima',
    BrasilState.sc: 'Santa Catarina',
    BrasilState.sp: 'São Paulo',
    BrasilState.se: 'Sergipe',
    BrasilState.to: 'Tocantins',
  };

  static List<String> get statesFullNames => listStates.values.toList();

  static const List<String> listaRegioes = ['Centro-Oeste', 'Nordeste', 'Norte', 'Sudeste', 'Sul'];
}
