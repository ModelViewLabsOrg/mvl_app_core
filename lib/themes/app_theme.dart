import 'package:flutter/material.dart';
import 'package:mvl_app_core/themes/app_text_theme.dart';

class AppTheme {
  AppTheme({
    Color? lightColor,
    ColorScheme? lightScheme,
    Color? darkColor,
    ColorScheme? darkScheme,
  }) : assert(
         (lightColor == null && lightScheme != null) ||
             (lightColor != null && lightScheme == null),
         'Either light color or light scheme must be provided',
       ),
       _lightScheme =
           lightScheme ?? ColorScheme.fromSeed(seedColor: lightColor!),
       assert(
         (darkColor == null && darkScheme != null) ||
             (darkColor != null && darkScheme == null),
         'Either dark color or dark scheme must be provided',
       ),
       _darkScheme =
           darkScheme ??
           ColorScheme.fromSeed(
             seedColor: darkColor!,
             brightness: Brightness.dark,
           );

  final ColorScheme _lightScheme;
  final ColorScheme _darkScheme;

  static final _baseButtonStyle = ButtonStyle(
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textStyle: WidgetStatePropertyAll(AppTextTheme.theme.labelLarge),
  );

  static ThemeData _basicTheme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: AppTextTheme.theme,
    primaryTextTheme: AppTextTheme.theme,
    filledButtonTheme: FilledButtonThemeData(style: _baseButtonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: _baseButtonStyle),
    textButtonTheme: TextButtonThemeData(style: _baseButtonStyle),
    elevatedButtonTheme: ElevatedButtonThemeData(style: _baseButtonStyle),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: colorScheme.surfaceContainerHigh),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          width: 2,
          color: colorScheme.surfaceContainerHighest,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );

  late final lightTheme = _basicTheme(_lightScheme);
  late final darkTheme = _basicTheme(_darkScheme);
}
