import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:mvl_app_core/utils/json.dart';
import 'package:universal_io/io.dart';

const kHttpSuccess = 200;

final HttpClient _http = newUniversalHttpClient();

Future<IpInfo> fetchIpInfo() async {
  final uri = Uri.https('api.ip2location.io');
  final HttpClientRequest request = await _http.getUrl(uri)
    ..followRedirects = true;

  final HttpClientResponse httpResponse = await request.close();

  final String bodyResponse = await httpResponse.transform(utf8.decoder).join();

  if (httpResponse.statusCode == kHttpSuccess) {
    return IpInfo.fromJson(jsonDecode(bodyResponse) as Json);
  }

  if (kDebugMode) {
    developer.log('Error: ${httpResponse.statusCode}. Response: $bodyResponse');
  }

  throw Exception('Unable to get ip');
}

Future<IpInfo?> fetchIpInfoSafe() async {
  try {
    return await fetchIpInfo();
  } catch (e) {
    return null;
  }
}

// {"ip":"2804:14d:c282:82ff:d5c1:43ef:eb97:9ae0","country_code":"BR","country_name":"Brazil","region_name":"Minas Gerais","city_name":"Belo Horizonte","latitude":-19.92071,"longitude":-43.93772,"zip_code":"30000-000","time_zone":"-03:00","asn":"28573","as":"Claro NXT Telecomunicacoes Ltda","is_proxy":false,"message":"Limit to 1,000 queries per day. Sign up for a Free plan at https://www.ip2location.io to get 50K queries per month."}%
class IpInfo {
  const IpInfo({
    required this.ip,
    required this.countryCode,
    required this.countryName,
    required this.regionName,
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.zipCode,
    required this.timeZone,
    required this.asn,
    required this.as,
    required this.isProxy,
  });

  factory IpInfo.fromJson(Map<String, dynamic> json) {
    return IpInfo(
      ip: json['ip'] as String,
      countryCode: json['country_code'] as String,
      countryName: json['country_name'] as String,
      regionName: json['region_name'] as String,
      cityName: json['city_name'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      zipCode: json['zip_code'] as String,
      timeZone: json['time_zone'] as String,
      asn: json['asn'] as String,
      as: json['as'] as String,
      isProxy: json['is_proxy'] as bool,
    );
  }

  final String ip;
  final String countryCode;
  final String countryName;
  final String regionName;
  final String cityName;
  final double latitude;
  final double longitude;
  final String zipCode;
  final String timeZone;
  final String asn;
  final String as;
  final bool isProxy;
}
