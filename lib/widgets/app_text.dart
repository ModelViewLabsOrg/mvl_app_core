import 'package:flutter/material.dart';
import 'package:mvl_app_core/extensions/context_extension.dart';

class AppText extends Text {
  const AppText._(
    super.data, {
    super.style,
    super.maxLines,
    super.textAlign,
    super.overflow,
    super.key,
  });

  factory AppText._internal(
    String data,
    TextStyle? textStyle, {
    Color? color,
    bool bold = false,
    bool underline = false,
    TextOverflow? overflow,
    TextAlign? textAlign,
    int? maxLines,
    Key? key,
  }) {
    var style = textStyle?.copyWith(color: color) ?? TextStyle(color: color);

    if (bold) style = style.copyWith(fontWeight: FontWeight.w700);

    if (underline) {
      style = style.copyWith(decorationStyle: TextDecorationStyle.solid);
    }

    return AppText._(
      data,
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
      key: key,
    );
  }

  factory AppText.headlineLarge(
    String text,
    BuildContext c, {
    Color? color,
    TextAlign textAlign = TextAlign.left,
    int maxLines = 999,
  }) =>
      AppText._(
        text,
        style: c.textTheme.headlineLarge?.copyWith(color: color),
        textAlign: textAlign,
        maxLines: maxLines,
      );

  factory AppText.headlineMedium(
    String text,
    BuildContext c, {
    Color? color,
    bool bold = false,
    bool underline = false,
    TextAlign textAlign = TextAlign.left,
    int maxLines = 999,
  }) {
    return AppText._internal(
      text,
      c.textTheme.headlineMedium,
      bold: bold,
      color: color,
      underline: underline,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
  factory AppText.headlineSmall(
    String text,
    BuildContext c, {
    Color? color,
  }) =>
      AppText._(
        text,
        style: c.textTheme.headlineSmall?.copyWith(color: color),
      );

  factory AppText.titleLarge(
    String text,
    BuildContext c, {
    Color? color,
    bool bold = false,
    bool underline = false,
    TextAlign textAlign = TextAlign.left,
    int maxLines = 999,
  }) {
    return AppText._internal(
      text,
      c.textTheme.titleLarge,
      bold: bold,
      color: color,
      underline: underline,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }

  factory AppText.titleMedium(
    String text,
    BuildContext c, {
    Color? color,
    TextAlign textAlign = TextAlign.left,
    int maxLines = 999,
  }) =>
      AppText._(
        text,
        style: c.textTheme.titleMedium?.copyWith(color: color),
        textAlign: textAlign,
        maxLines: maxLines,
      );

  factory AppText.titleSmall(
    String text,
    BuildContext c, {
    Color? color,
    TextAlign textAlign = TextAlign.left,
    int maxLines = 999,
  }) =>
      AppText._(
        text,
        style: c.textTheme.titleSmall?.copyWith(color: color),
        textAlign: textAlign,
        maxLines: maxLines,
      );

  factory AppText.labelLarge(
    String text,
    BuildContext c, {
    Color? color,
    bool bold = false,
    bool underline = false,
    TextAlign textAlign = TextAlign.left,
    int maxLines = 999,
    TextOverflow? overflow,
    Key? key,
  }) {
    return AppText._internal(
      text,
      c.textTheme.labelLarge,
      bold: bold,
      color: color,
      underline: underline,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      key: key,
    );
  }

  factory AppText.labelMedium(
    String text,
    BuildContext c, {
    Color? color,
    bool bold = false,
    bool underline = false,
    TextAlign textAlign = TextAlign.left,
    int maxLines = 999,
    TextOverflow? overflow,
  }) {
    return AppText._internal(
      text,
      c.textTheme.labelMedium,
      bold: bold,
      color: color,
      underline: underline,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.labelSmall(
    String text,
    BuildContext c, {
    Color? color,
    TextAlign textAlign = TextAlign.left,
    int maxLines = 999,
    bool bold = false,
    bool underline = false,
  }) {
    return AppText._internal(
      text,
      c.textTheme.labelMedium,
      bold: bold,
      color: color,
      underline: underline,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }

  factory AppText.bodyLarge(
    String text,
    BuildContext c, {
    Color? color,
    TextAlign textAlign = TextAlign.left,
    bool bold = false,
    bool underline = false,
    int? maxLines,
  }) {
    return AppText._internal(
      text,
      c.textTheme.bodyLarge,
      bold: bold,
      color: color,
      underline: underline,
      maxLines: maxLines,
      textAlign: textAlign,
    );
  }

  factory AppText.bodyMedium(
    String text,
    BuildContext c, {
    Color? color,
    bool bold = false,
    bool underline = false,
    int? maxLines,
    TextAlign textAlign = TextAlign.left,
  }) {
    return AppText._internal(
      text,
      c.textTheme.bodyMedium,
      bold: bold,
      color: color,
      underline: underline,
      maxLines: maxLines,
      textAlign: textAlign,
    );
  }

  factory AppText.bodySmall(
    String text,
    BuildContext c, {
    Color? color,
  }) {
    return AppText._internal(
      text,
      c.textTheme.bodySmall,
      color: color,
    );
  }

  /// Alias for Body Small
  factory AppText.caption(String text, BuildContext c, {Color? color}) =>
      AppText.bodySmall(text, c, color: color);
}
