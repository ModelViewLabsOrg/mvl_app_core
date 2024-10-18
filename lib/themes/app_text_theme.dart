import 'package:flutter/material.dart';
import 'package:mvl_app_core/widgets/app_fonts.dart';

class AppTextTheme {
  static const theme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: AppFonts.interVariable,
      fontSize: 57,
      height: 1.12,
      fontWeight: FontWeight.w400,
      letterSpacing: -.25,
    ),
    displayMedium: TextStyle(
      fontFamily: AppFonts.interVariable,
      fontSize: 45,
      height: 1.15,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: TextStyle(
      fontFamily: AppFonts.interVariable,
      fontSize: 36,
      height: 1.22,
      fontWeight: FontWeight.w400,
    ),
    headlineLarge: TextStyle(
      fontFamily: AppFonts.montserratVariable,
      fontSize: 32,
      height: 1.25,
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: TextStyle(
      fontFamily: AppFonts.montserratVariable,
      fontSize: 28,
      height: 1.28,
      fontWeight: FontWeight.w400,
    ),
    headlineSmall: TextStyle(
      fontFamily: AppFonts.montserratVariable,
      fontSize: 24,
      height: 1.33,
      fontWeight: FontWeight.w400,
    ),
    titleLarge: TextStyle(
      fontFamily: AppFonts.montserratVariable,
      fontSize: 22,
      height: 1.27,
      fontWeight: FontWeight.w400,
    ),
    titleMedium: TextStyle(
      fontFamily: AppFonts.montserratVariable,
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w500,
      letterSpacing: .25,
    ),
    titleSmall: TextStyle(
      fontFamily: AppFonts.montserratVariable,
      fontSize: 14,
      height: 1.4,
      fontWeight: FontWeight.w500,
      letterSpacing: .1,
    ),
    labelLarge: TextStyle(
      fontFamily: AppFonts.montserratVariable,
      fontSize: 14,
      height: 1.42,
      fontWeight: FontWeight.w500,
      letterSpacing: .1,
    ),
    labelMedium: TextStyle(
      fontFamily: AppFonts.montserratVariable,
      fontSize: 12,
      height: 1.33,
      fontWeight: FontWeight.w500,
      letterSpacing: .5,
    ),
    labelSmall: TextStyle(
      fontFamily: AppFonts.montserratVariable,
      fontSize: 11,
      height: 1.45,
      fontWeight: FontWeight.w500,
      letterSpacing: .5,
    ),
    bodyLarge: TextStyle(
      fontFamily: AppFonts.montserratVariable,
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w400,
      letterSpacing: .5,
    ),
    bodyMedium: TextStyle(
      fontFamily: AppFonts.montserratVariable,
      fontSize: 14,
      height: 1.42,
      fontWeight: FontWeight.w400,
      letterSpacing: .25,
    ),
    bodySmall: TextStyle(
      fontFamily: AppFonts.montserratVariable,
      fontSize: 12,
      height: 1.33,
      fontWeight: FontWeight.w400,
      letterSpacing: .4,
    ),
  );
}
