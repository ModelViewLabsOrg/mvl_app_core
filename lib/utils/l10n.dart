import 'dart:io';

String get currentLocale {
  const defaultLocale = 'pt';
  const supportedLocales = <String>['pt', 'en', 'es'];

  final String deviceLocale = Platform.localeName.split('_').first;
  return supportedLocales.contains(deviceLocale) ? deviceLocale : defaultLocale;
}
