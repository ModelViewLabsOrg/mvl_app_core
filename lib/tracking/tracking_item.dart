import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mvl_app_core/extensions/num_extension.dart';

class TrackingItem {
  const TrackingItem(this.id, this.name, {this.value, this.currency = 'BRL'});

  final int id;
  final String name;
  final int? value;
  final String currency;

  AnalyticsEventItem get analytics => AnalyticsEventItem(
    itemId: id.toString(),
    itemName: name,
    currency: value == null ? null : currency,
    price: value?.amountToDouble(),
  );

  Map<String, String> get properties => <String, String>{
    'id': id.toString(),
    'name': name,
    'value': (value ?? 0).toString(),
  };
}
