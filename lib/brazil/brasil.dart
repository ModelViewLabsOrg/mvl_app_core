import 'package:collection/collection.dart';
import 'package:mvl_app_core/utils/app_exception.dart';

enum BrasilRegion {
  centroOeste('Centro-Oeste'),
  nordeste('Nordeste'),
  norte('Norte'),
  sudeste('Sudeste'),
  sul('Sul'),
  ;

  const BrasilRegion(this.label);
  final String label;
}

enum BrasilState {
  ac('Acre', BrasilRegion.norte),
  al('Alagoas', BrasilRegion.nordeste),
  ap('Amapá', BrasilRegion.norte),
  am('Amazonas', BrasilRegion.norte),
  ba('Bahia', BrasilRegion.nordeste),
  ce('Ceará', BrasilRegion.nordeste),
  df('Distrito Federal', BrasilRegion.centroOeste),
  es('Espírito Santo', BrasilRegion.sudeste),
  go('Goiás', BrasilRegion.centroOeste),
  ma('Maranhão', BrasilRegion.nordeste),
  mt('Mato Grosso', BrasilRegion.centroOeste),
  ms('Mato Grosso do Sul', BrasilRegion.centroOeste),
  mg('Minas Gerais', BrasilRegion.sudeste),
  pa('Pará', BrasilRegion.norte),
  pb('Paraíba', BrasilRegion.nordeste),
  pr('Paraná', BrasilRegion.sul),
  pe('Pernambuco', BrasilRegion.nordeste),
  pi('Piauí', BrasilRegion.nordeste),
  rj('Rio de Janeiro', BrasilRegion.sudeste),
  rn('Rio Grande do Norte', BrasilRegion.nordeste),
  rs('Rio Grande do Sul', BrasilRegion.sul),
  ro('Rondônia', BrasilRegion.norte),
  rr('Roraima', BrasilRegion.norte),
  sc('Santa Catarina', BrasilRegion.sul),
  sp('São Paulo', BrasilRegion.sudeste),
  se('Sergipe', BrasilRegion.nordeste),
  to('Tocantins', BrasilRegion.norte),
  ;

  const BrasilState(this.label, this.region);
  final String label;
  final BrasilRegion region;

  static BrasilState parse(String raw) {
    final BrasilState? state = tryParse(raw);
    if (state == null) {
      throw AppException.fromStringError(
        'Invalid Brasil state: $raw',
        StackTrace.current,
      );
    }
    return state;
  }

  static BrasilState? tryParse(String raw) {
    final String value = raw.toLowerCase().trim();
    if (value.isEmpty) {
      return null;
    }

    return BrasilState.values.firstWhereOrNull(
      (e) => e.name == value || e.label.toLowerCase() == value,
    );
  }
}
