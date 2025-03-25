import 'dart:io';

String get currentLocale {
  const defaultLocale = 'pt';
  const supportedLocales = ['pt', 'en', 'es'];

  final deviceLocale = Platform.localeName.split('_').first;
  return supportedLocales.contains(deviceLocale) ? deviceLocale : defaultLocale;
}
